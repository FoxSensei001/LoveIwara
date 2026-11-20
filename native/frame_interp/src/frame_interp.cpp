// 离线补帧引擎：FFmpeg 解码 → RIFE（ncnn + Vulkan）插出中间帧 → 硬件编码 → 封装。
//
// 整条流水线是同步的、一帧一帧走：解出一帧就和上一帧配成一对，先写上一帧，
// 再写两帧之间的中间帧。离线处理不抢实时，所以不做任何并行流水——并行换来的
// 那点速度抵不上它引入的乱序和显存峰值。
//
// 音轨和字幕轨原样拷贝（不重编码），时间戳跟着原片走，所以输出和原片严格等长。

#include "frame_interp.h"

#include <algorithm>
#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libavutil/dict.h>
#include <libavutil/display.h>
#include <libavutil/hwcontext.h>
#include <libavutil/imgutils.h>
#include <libavutil/mathematics.h>
#include <libavutil/opt.h>
#include <libavutil/pixdesc.h>
#include <libswscale/swscale.h>
}

#include "gpu.h"
#include "rife.h"

#ifdef _WIN32
#  define WIN32_LEAN_AND_MEAN
#  define NOMINMAX
#  include <windows.h>
#endif

#ifdef __APPLE__
#  include <TargetConditionals.h>
#endif

// 手机 / 平板：显存和散热都紧，算光流的分辨率门槛压得比桌面低。
#if defined(__ANDROID__) || (defined(__APPLE__) && TARGET_OS_IPHONE)
#  define FI_MOBILE 1
#else
#  define FI_MOBILE 0
#endif

namespace {

// 两个结构体在 ABI v1 时的大小。头文件承诺「只在末尾追加字段」：对方给的
// struct_size 只要盖得住 v1 的字段就收，往后新加的字段各自按 struct_size 够不够
// 来决定读不读——这样引擎先升级、应用还是旧的，也照样能用。
constexpr uint32_t kJobOptionsSizeV1 = 56;
constexpr uint32_t kProbeResultSizeV1 = 40;
static_assert(sizeof(FiJobOptions) >= kJobOptionsSizeV1, "FiJobOptions shrank");
static_assert(sizeof(FiProbeResult) >= kProbeResultSizeV1, "FiProbeResult shrank");

struct Failure {
    int code;
    std::string message;
};

struct Cancelled {};

[[noreturn]] void fail(int code, const std::string& message) {
    throw Failure{code, message};
}

std::string av_error(int err) {
    char buf[AV_ERROR_MAX_STRING_SIZE] = {0};
    av_strerror(err, buf, sizeof(buf));
    return buf;
}

// 排查用：设了环境变量 FI_TRACE 才往 stderr 打阶段标记，平时一个字不出。
void trace(const char* stage) {
    static const bool enabled = getenv("FI_TRACE") != nullptr;
    if (enabled) {
        fprintf(stderr, "[frame_interp] %s\n", stage);
        fflush(stderr);
    }
}

// ---- Vulkan 设备 ---------------------------------------------------------

// 各种游戏浮层、录屏工具会往系统里注册「隐式」Vulkan 层，它们默认钩进每一个
// 创建 Vulkan 设备的进程。实测其中有的层在纯计算（没有交换链）的设备上直接
// 崩在 vkCreateDevice 里，把整个应用带走。补帧不出画面，这些层对它毫无用处，
// 在建实例之前整类关掉。只影响本进程，且只在这之后新建的实例上生效。
void disable_implicit_vulkan_layers() {
#ifdef _WIN32
    SetEnvironmentVariableW(L"VK_LOADER_LAYERS_DISABLE", L"~implicit~");
    _putenv_s("VK_LOADER_LAYERS_DISABLE", "~implicit~");
#else
    setenv("VK_LOADER_LAYERS_DISABLE", "~implicit~", 1);
#endif
}

std::mutex g_gpu_mutex;
int g_gpu_users = 0;

// ncnn 的 GPU 实例是进程级的。它必须在进程退出前显式销毁——留着不管，退出时
// 驱动的清理代码会崩（实测必现）。所以按引用计数管：有作业在跑就留着，最后一个
// 用完立刻销毁，这样应用任何时候退出都不会带着一个活的实例。
//
// 持有它的对象必须比所有 ncnn::Net / Pipeline 活得久（声明在它们前面）。
class GpuSession {
public:
    GpuSession() {
        std::lock_guard<std::mutex> lock(g_gpu_mutex);
        if (g_gpu_users == 0) {
            disable_implicit_vulkan_layers();
            if (ncnn::create_gpu_instance() != 0) return;
        }
        g_gpu_users++;
        held_ = true;
    }

    ~GpuSession() {
        if (!held_) return;
        std::lock_guard<std::mutex> lock(g_gpu_mutex);
        if (--g_gpu_users == 0) ncnn::destroy_gpu_instance();
    }

    GpuSession(const GpuSession&) = delete;
    GpuSession& operator=(const GpuSession&) = delete;

    // 真正的显卡（独显 / 核显）。Windows 上系统还会报出 D3D12 转译出来的设备和
    // 一个纯 CPU 的「Basic Render Driver」，那些跑不动推理，不算数。
    static bool is_real_gpu(int index) {
        const int type = ncnn::get_gpu_info(index).type();
        return type == 0 || type == 1;
    }

    int usable_count() const {
        if (!held_) return 0;
        int usable = 0;
        const int count = ncnn::get_gpu_count();
        for (int i = 0; i < count; i++) {
            if (is_real_gpu(i)) usable++;
        }
        return usable;
    }

    // 返回要用的设备下标；没有可用显卡时返回 -1。
    int pick(int requested) const {
        if (!held_) return -1;
        const int count = ncnn::get_gpu_count();
        if (requested >= 0 && requested < count && is_real_gpu(requested)) return requested;
        const int preferred = ncnn::get_default_gpu_index();
        if (preferred >= 0 && preferred < count && is_real_gpu(preferred)) return preferred;
        for (int i = 0; i < count; i++) {
            if (is_real_gpu(i)) return i;
        }
        return -1;
    }

private:
    bool held_ = false;
};

// ---- RAII 小壳 -----------------------------------------------------------

struct InputFile {
    AVFormatContext* p = nullptr;
    ~InputFile() {
        if (p) avformat_close_input(&p);
    }
};

struct OutputFile {
    AVFormatContext* p = nullptr;
    ~OutputFile() {
        if (!p) return;
        if (p->pb && !(p->oformat->flags & AVFMT_NOFILE)) avio_closep(&p->pb);
        avformat_free_context(p);
    }
};

struct CodecCtx {
    AVCodecContext* p = nullptr;
    ~CodecCtx() { avcodec_free_context(&p); }
};

struct FramePtr {
    AVFrame* p = av_frame_alloc();
    ~FramePtr() { av_frame_free(&p); }
};

struct PacketPtr {
    AVPacket* p = av_packet_alloc();
    ~PacketPtr() { av_packet_free(&p); }
};

struct Scaler {
    SwsContext* p = nullptr;
    ~Scaler() { sws_freeContext(p); }
    void reset(SwsContext* next) {
        sws_freeContext(p);
        p = next;
    }
};

struct BufferRef {
    AVBufferRef* p = nullptr;
    BufferRef() = default;
    BufferRef(const BufferRef&) = delete;
    BufferRef& operator=(const BufferRef&) = delete;
    ~BufferRef() { av_buffer_unref(&p); }
    void reset(AVBufferRef* next) {
        av_buffer_unref(&p);
        p = next;
    }
};

// ---- 色彩 ---------------------------------------------------------------

bool is_hdr_transfer(AVColorTransferCharacteristic trc) {
    return trc == AVCOL_TRC_SMPTE2084 || trc == AVCOL_TRC_ARIB_STD_B67;
}

// 片源没标矩阵时按分辨率猜：高清按 709，标清按 601。和播放器的默认猜法一致，
// 这样补帧前后的颜色在同一个播放器里看是一样的。
AVColorSpace resolve_colorspace(AVColorSpace declared, int height) {
    switch (declared) {
        case AVCOL_SPC_BT709:
        case AVCOL_SPC_BT470BG:
        case AVCOL_SPC_SMPTE170M:
        case AVCOL_SPC_BT2020_NCL:
            return declared;
        default:
            return height >= 720 ? AVCOL_SPC_BT709 : AVCOL_SPC_SMPTE170M;
    }
}

int sws_colorspace(AVColorSpace cs) {
    switch (cs) {
        case AVCOL_SPC_BT709:
            return SWS_CS_ITU709;
        case AVCOL_SPC_BT2020_NCL:
            return SWS_CS_BT2020;
        default:
            return SWS_CS_ITU601;
    }
}

bool is_full_range(const AVFrame* f) {
    if (f->color_range == AVCOL_RANGE_JPEG) return true;
    switch (f->format) {
        case AV_PIX_FMT_YUVJ420P:
        case AV_PIX_FMT_YUVJ422P:
        case AV_PIX_FMT_YUVJ444P:
        case AV_PIX_FMT_YUVJ440P:
            return true;
        default:
            return false;
    }
}

// rife-ncnn-vulkan 的预处理着色器在 Windows 上按 BGR 读、别处按 RGB 读
// （它原本直接吃 WIC / stb 解出来的像素）。跟着它走，省一次通道交换。
#ifdef _WIN32
const AVPixelFormat kPackedFormat = AV_PIX_FMT_BGR24;
#else
const AVPixelFormat kPackedFormat = AV_PIX_FMT_RGB24;
#endif

#ifdef _WIN32
std::wstring widen(const std::string& utf8) {
    if (utf8.empty()) return std::wstring();
    const int n = MultiByteToWideChar(CP_UTF8, 0, utf8.data(), (int)utf8.size(), nullptr, 0);
    std::wstring out(n, L'\0');
    MultiByteToWideChar(CP_UTF8, 0, utf8.data(), (int)utf8.size(), &out[0], n);
    return out;
}
#endif

bool file_exists(const std::string& utf8_path) {
#ifdef _WIN32
    FILE* f = _wfopen(widen(utf8_path).c_str(), L"rb");
#else
    FILE* f = fopen(utf8_path.c_str(), "rb");
#endif
    if (!f) return false;
    fclose(f);
    return true;
}

}  // namespace

// ---- 作业 ----------------------------------------------------------------

struct FiJob {
    std::string input;
    std::string output;
    std::string model_dir;
    std::string output_format;
    int gpu_index = -1;
    int codec = FI_CODEC_H264;
    int quality = FI_QUALITY_BALANCED;
    bool scene_detect = true;

    std::thread worker;
    std::atomic<int> state{FI_STATE_PENDING};
    std::atomic<bool> cancel{false};
    std::atomic<double> progress{0.0};
    std::atomic<int64_t> frames_written{0};
    std::atomic<int> error_code{FI_OK};

    // 这两个串只在作业线程里、状态翻成终态之前写；读的一方只在看到终态
    // （或 encoder 的情况下，容忍读到空串）之后才读。
    std::mutex text_mutex;
    std::string error_text;
    std::string encoder_name;
};

namespace {

class Pipeline {
public:
    explicit Pipeline(FiJob* job) : job_(job) {}

    void run() {
        trace("open_input");
        open_input();
        check_cancel();
        trace("open_model");
        open_model();
        check_cancel();
        trace("open_output");
        open_output();
        check_cancel();
        trace("pump");
        pump();
        trace("finish");
        finish();
        trace("done");
    }

private:
    FiJob* job_;

    InputFile in_;
    OutputFile out_;
    CodecCtx dec_;
    CodecCtx enc_;
    // 顺序有讲究：成员按声明的逆序析构，gpu_ 必须排在 rife_ 前面，
    // 这样模型先释放、GPU 实例后销毁。
    std::unique_ptr<GpuSession> gpu_;
    std::unique_ptr<RIFE> rife_;

    int video_index_ = -1;
    AVStream* in_video_ = nullptr;
    AVStream* out_video_ = nullptr;
    std::vector<int> stream_map_;

    int width_ = 0;   // 输出宽高：片源宽高向下取偶
    int height_ = 0;
    AVColorSpace colorspace_ = AVCOL_SPC_BT709;
    AVRational half_tb_{0, 1};  // 片源时间基的一半：中间帧的时间戳落在整数上
    int64_t frame_ticks_ = 1;   // 一帧在片源时间基下的长度（估算）
    int64_t duration_ticks_ = 0;

    Scaler to_packed_;
    int packed_src_w_ = 0, packed_src_h_ = 0, packed_src_fmt_ = -1;
    bool packed_src_full_ = false;
    Scaler to_encoder_;
    // 送进编码器之前，帧在内存里的像素格式。多数编码器直接收它；只收显存帧的
    // （VAAPI）另有 hw_frames_，每帧先转成它再整帧传上去。
    AVPixelFormat sw_format_ = AV_PIX_FMT_NONE;
    BufferRef hw_frames_;
    FramePtr enc_frame_;
    FramePtr hw_frame_;
    PacketPtr enc_packet_;

    std::vector<uint8_t> prev_, cur_, mid_;
    bool have_prev_ = false;
    int64_t prev_pts_ = 0;
    int64_t first_pts_ = 0;
    int64_t last_delta_ = 0;
    int64_t last_out_pts_ = AV_NOPTS_VALUE;

    void check_cancel() const {
        if (job_->cancel.load(std::memory_order_relaxed)) throw Cancelled{};
    }

    // ---- 输入 ----

    void open_input() {
        int r = avformat_open_input(&in_.p, job_->input.c_str(), nullptr, nullptr);
        if (r < 0) fail(FI_ERR_OPEN_INPUT, "avformat_open_input: " + av_error(r));
        r = avformat_find_stream_info(in_.p, nullptr);
        if (r < 0) fail(FI_ERR_OPEN_INPUT, "avformat_find_stream_info: " + av_error(r));

        const AVCodec* decoder = nullptr;
        video_index_ = av_find_best_stream(in_.p, AVMEDIA_TYPE_VIDEO, -1, -1, &decoder, 0);
        if (video_index_ < 0) fail(FI_ERR_NO_VIDEO, "no video stream");
        if (!decoder) fail(FI_ERR_DECODER, "no decoder for the video stream");
        in_video_ = in_.p->streams[video_index_];
        const AVCodecParameters* par = in_video_->codecpar;

        if (is_hdr_transfer(par->color_trc)) {
            fail(FI_ERR_HDR_UNSUPPORTED, "HDR transfer characteristics");
        }

        dec_.p = avcodec_alloc_context3(decoder);
        if (!dec_.p) fail(FI_ERR_DECODER, "avcodec_alloc_context3");
        r = avcodec_parameters_to_context(dec_.p, par);
        if (r < 0) fail(FI_ERR_DECODER, "avcodec_parameters_to_context: " + av_error(r));
        dec_.p->pkt_timebase = in_video_->time_base;
        dec_.p->thread_count = 0;
        r = avcodec_open2(dec_.p, decoder, nullptr);
        if (r < 0) fail(FI_ERR_DECODER, "avcodec_open2(decoder): " + av_error(r));

        // 4:2:0 编码器要偶数宽高。差的那一个像素靠缩放吃掉，肉眼不可辨。
        width_ = dec_.p->width & ~1;
        height_ = dec_.p->height & ~1;
        if (width_ < 32 || height_ < 32) fail(FI_ERR_DECODER, "video too small");
        colorspace_ = resolve_colorspace(par->color_space, height_);

        AVRational fps = av_guess_frame_rate(in_.p, in_video_, nullptr);
        if (fps.num <= 0 || fps.den <= 0) fps = AVRational{30, 1};
        frame_ticks_ = std::max<int64_t>(1, av_rescale_q(1, av_inv_q(fps), in_video_->time_base));

        int num = 0, den = 0;
        av_reduce(&num, &den, in_video_->time_base.num, (int64_t)in_video_->time_base.den * 2,
                  INT32_MAX);
        half_tb_ = AVRational{num, den};

        if (in_video_->duration > 0) {
            duration_ticks_ = in_video_->duration;
        } else if (in_.p->duration > 0) {
            duration_ticks_ = av_rescale_q(in_.p->duration, AV_TIME_BASE_Q, in_video_->time_base);
        }

        const size_t bytes = (size_t)width_ * height_ * 3 + 64;
        prev_.resize(bytes);
        cur_.resize(bytes);
        mid_.resize(bytes);
    }

    // ---- 模型 ----

    void open_model() {
        gpu_.reset(new GpuSession());
        const int gpu = gpu_->pick(job_->gpu_index);
        if (gpu < 0) fail(FI_ERR_NO_GPU, "no usable Vulkan device");

        // 上游封装用 256 个字符的定长缓冲拼模型路径，超了会被悄悄截断。
        if (job_->model_dir.size() > 200) fail(FI_ERR_MODEL, "model path too long");
        if (!file_exists(job_->model_dir + "/flownet.param") ||
            !file_exists(job_->model_dir + "/flownet.bin")) {
            fail(FI_ERR_MODEL, "model files missing in " + job_->model_dir);
        }

        // 超过 2K 的画面让光流在半分辨率上算：显存和耗时都降到四分之一上下，
        // 而大画面里的运动本来就平滑，几乎看不出差别。手机的显存与散热都紧得多，
        // 超过 720p 就这么算。
#if FI_MOBILE
        const int64_t uhd_pixels = (int64_t)1280 * 720;
#else
        const int64_t uhd_pixels = (int64_t)2560 * 1440;
#endif
        const bool uhd = (int64_t)width_ * height_ > uhd_pixels;
        rife_.reset(new RIFE(gpu, false, false, uhd, 1, false, true));
#ifdef _WIN32
        const int r = rife_->load(widen(job_->model_dir));
#else
        const int r = rife_->load(job_->model_dir);
#endif
        if (r != 0) fail(FI_ERR_MODEL, "RIFE::load failed");
    }

    // ---- 输出 ----

    int64_t target_bitrate() const {
        int64_t source = in_video_->codecpar->bit_rate;
        if (source <= 0 && in_.p->bit_rate > 0) source = in_.p->bit_rate;
        const AVRational fps = av_guess_frame_rate(in_.p, in_video_, nullptr);
        const double out_fps = fps.num > 0 && fps.den > 0 ? 2.0 * fps.num / fps.den : 60.0;
        // 帧数翻倍但多出来的帧和邻帧高度相似，码率不需要翻倍；硬件编码器的
        // 压缩效率又比片源常用的软件编码器差一截，两头一抵取 1.8 倍。
        const double scale = job_->quality == FI_QUALITY_HIGH ? 2.6 : 1.8;
        const double floor_bpp = job_->quality == FI_QUALITY_HIGH ? 0.10 : 0.07;
        const double floor_rate = (double)width_ * height_ * out_fps * floor_bpp;
        const double wanted = std::max(source > 0 ? source * scale : 0.0, floor_rate);
        return (int64_t)std::min(wanted, 200e6);
    }

    // 编码器直接收的内存像素格式，按偏好排。同一个名字的编码器在不同设备上
    // 能收的不一样（安卓的 MediaCodec 有的只认 YUV420P、有的只认 NV12），所以
    // 每一种都要拿出来试，而不是只挑第一个。拿不到清单时按最常见的 YUV420P 试。
    static std::vector<AVPixelFormat> software_formats(const AVCodec* codec) {
        AVCodecContext* probe = avcodec_alloc_context3(codec);
        if (!probe) return {};
        const void* list = nullptr;
        int count = 0;
        const int r = avcodec_get_supported_config(probe, codec, AV_CODEC_CONFIG_PIX_FORMAT, 0,
                                                   &list, &count);
        std::vector<AVPixelFormat> out;
        if (r < 0 || !list || count <= 0) {
            out.push_back(AV_PIX_FMT_YUV420P);
        } else {
            const AVPixelFormat* formats = (const AVPixelFormat*)list;
            for (AVPixelFormat want : {AV_PIX_FMT_NV12, AV_PIX_FMT_YUV420P}) {
                for (int i = 0; i < count; i++) {
                    if (formats[i] == want) {
                        out.push_back(want);
                        break;
                    }
                }
            }
        }
        avcodec_free_context(&probe);
        return out;
    }

    // 只收显存帧的编码器（Linux 的 VAAPI）：建好设备和帧池，帧在内存里先转成
    // NV12、再整帧传上去。返回编码器要的显存像素格式；这台机器建不出来时返回
    // NONE（例如没有对应的驱动），调用方接着试下一个编码器。
    AVPixelFormat open_hw_frames(const AVCodec* codec, BufferRef& frames_out) const {
        for (int i = 0;; i++) {
            const AVCodecHWConfig* config = avcodec_get_hw_config(codec, i);
            if (!config) return AV_PIX_FMT_NONE;
            if (!(config->methods & AV_CODEC_HW_CONFIG_METHOD_HW_FRAMES_CTX)) continue;
            BufferRef device;
            if (av_hwdevice_ctx_create(&device.p, config->device_type, nullptr, nullptr, 0) < 0) {
                continue;
            }
            BufferRef frames;
            frames.p = av_hwframe_ctx_alloc(device.p);
            if (!frames.p) continue;
            AVHWFramesContext* pool = (AVHWFramesContext*)frames.p->data;
            pool->format = config->pix_fmt;
            pool->sw_format = AV_PIX_FMT_NV12;
            pool->width = width_;
            pool->height = height_;
            pool->initial_pool_size = 16;
            if (av_hwframe_ctx_init(frames.p) < 0) continue;
            frames_out.reset(frames.p);
            frames.p = nullptr;
            return config->pix_fmt;
        }
    }

    // 把一帧内存里的画面交给编码器：显存编码器先传上去。
    static int send_frame(AVCodecContext* ctx, AVFrame* sw, AVBufferRef* hw_frames, AVFrame* hw) {
        if (!hw_frames) return avcodec_send_frame(ctx, sw);
        av_frame_unref(hw);
        int r = av_hwframe_get_buffer(hw_frames, hw, 0);
        if (r < 0) return r;
        r = av_hwframe_transfer_data(hw, sw, 0);
        if (r < 0) return r;
        hw->pts = sw->pts;
        hw->pict_type = sw->pict_type;
        return avcodec_send_frame(ctx, hw);
    }

    // 拿一帧灰画面真编一次。有的硬件编码器（QSV、Media Foundation 常见）
    // avcodec_open2 能过，要到送第一帧时才报错；只看「打不打得开」的话，就会
    // 选中一个实际不能用的，排在它后面的兜底编码器连试的机会都没有。
    static bool can_encode(AVCodecContext* ctx, AVPixelFormat sw_format, AVBufferRef* hw_frames) {
        FramePtr frame;
        FramePtr hw;
        PacketPtr packet;
        if (!frame.p || !hw.p || !packet.p) return false;
        frame.p->format = sw_format;
        frame.p->width = ctx->width;
        frame.p->height = ctx->height;
        if (av_frame_get_buffer(frame.p, 0) < 0) return false;
        for (int plane = 0; plane < AV_NUM_DATA_POINTERS && frame.p->data[plane]; plane++) {
            const int rows = plane == 0 ? ctx->height : (ctx->height + 1) / 2;
            memset(frame.p->data[plane], 128, (size_t)frame.p->linesize[plane] * rows);
        }
        frame.p->pts = 0;
        if (send_frame(ctx, frame.p, hw_frames, hw.p) < 0) return false;
        if (avcodec_send_frame(ctx, nullptr) < 0) return false;
        bool produced = false;
        while (true) {
            const int r = avcodec_receive_packet(ctx, packet.p);
            if (r == AVERROR_EOF) break;
            if (r < 0) return false;
            produced = true;
            av_packet_unref(packet.p);
        }
        return produced;
    }

    bool try_open_encoder(const char* name, int64_t bitrate, AVRational out_fps) {
        const AVCodec* codec = avcodec_find_encoder_by_name(name);
        if (!codec) return false;
        const std::vector<AVPixelFormat> formats = software_formats(codec);
        for (AVPixelFormat format : formats) {
            if (try_open_with(codec, name, format, format, nullptr, bitrate, out_fps)) return true;
        }
        if (!formats.empty()) return false;
        // 一种内存格式都不收：只能走显存。
        BufferRef frames;
        const AVPixelFormat hw_format = open_hw_frames(codec, frames);
        if (hw_format == AV_PIX_FMT_NONE) return false;
        if (!try_open_with(codec, name, hw_format, AV_PIX_FMT_NV12, frames.p, bitrate, out_fps)) {
            return false;
        }
        hw_frames_.reset(frames.p);
        frames.p = nullptr;
        return true;
    }

    bool try_open_with(const AVCodec* codec, const char* name, AVPixelFormat format,
                       AVPixelFormat sw_format, AVBufferRef* hw_frames, int64_t bitrate,
                       AVRational out_fps) {
        // 先开一个只为试编的，试过了再开正式的那个：编码器被 flush 过就
        // 不能再接着用了。
        AVCodecContext* trial = open_encoder_context(codec, name, format, hw_frames, bitrate, out_fps);
        if (!trial) return false;
        const bool usable = can_encode(trial, sw_format, hw_frames);
        avcodec_free_context(&trial);
        if (!usable) return false;

        AVCodecContext* ctx = open_encoder_context(codec, name, format, hw_frames, bitrate, out_fps);
        if (!ctx) return false;
        enc_.p = ctx;
        sw_format_ = sw_format;
        {
            std::lock_guard<std::mutex> lock(job_->text_mutex);
            job_->encoder_name = name;
        }
        return true;
    }

    AVCodecContext* open_encoder_context(const AVCodec* codec, const char* name,
                                         AVPixelFormat format, AVBufferRef* hw_frames,
                                         int64_t bitrate, AVRational out_fps) {
        AVCodecContext* ctx = avcodec_alloc_context3(codec);
        if (!ctx) return nullptr;
        if (hw_frames) {
            ctx->hw_frames_ctx = av_buffer_ref(hw_frames);
            if (!ctx->hw_frames_ctx) {
                avcodec_free_context(&ctx);
                return nullptr;
            }
        }

        ctx->width = width_;
        ctx->height = height_;
        ctx->pix_fmt = format;
        ctx->time_base = half_tb_;
        ctx->framerate = out_fps;
        ctx->sample_aspect_ratio = in_video_->sample_aspect_ratio;
        ctx->bit_rate = bitrate;
        ctx->rc_max_rate = bitrate + bitrate / 2;
        ctx->rc_buffer_size = (int)std::min<int64_t>(bitrate * 2, INT32_MAX);
        // 两秒一个关键帧：拖动进度条时 mpv 落点够密。
        ctx->gop_size = std::max(1, (int)(2.0 * out_fps.num / out_fps.den + 0.5));
        ctx->color_range = AVCOL_RANGE_MPEG;
        // 矩阵标记原样沿用片源的，片源没标就也不标。colorspace_ 只是内部
        // YUV→RGB→YUV 往返时两头用同一套系数的约定，往返之后 YUV 数值和原片
        // 一致；要是在这里把「猜的」矩阵写进成品，播放器对原片是猜、对成品是
        // 照标记来，两边一旦猜的不一样，颜色就偏了。
        ctx->colorspace = in_video_->codecpar->color_space;
        ctx->color_primaries = in_video_->codecpar->color_primaries;
        ctx->color_trc = in_video_->codecpar->color_trc;
        if (out_.p->oformat->flags & AVFMT_GLOBALHEADER) ctx->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;

        AVDictionary* options = nullptr;
        if (strstr(name, "nvenc")) {
            av_dict_set(&options, "preset", "p5", 0);
            av_dict_set(&options, "tune", "hq", 0);
            av_dict_set(&options, "rc", "vbr", 0);
        } else if (strstr(name, "amf")) {
            av_dict_set(&options, "quality", "quality", 0);
            av_dict_set(&options, "rc", "vbr_peak", 0);
        } else if (strstr(name, "videotoolbox")) {
            // 没有硬件编码单元的老 Mac 上退到苹果自带的软件编码器，而不是直接失败。
            av_dict_set(&options, "allow_sw", "1", 0);
        }
        const int r = avcodec_open2(ctx, codec, &options);
        av_dict_free(&options);
        if (r < 0) {
            avcodec_free_context(&ctx);
            return nullptr;
        }
        return ctx;
    }

    void open_encoder() {
        AVRational fps = av_guess_frame_rate(in_.p, in_video_, nullptr);
        if (fps.num <= 0 || fps.den <= 0) fps = AVRational{30, 1};
        const AVRational out_fps = av_mul_q(fps, AVRational{2, 1});
        const int64_t bitrate = target_bitrate();

        // 硬件编码器在没有对应显卡的机器上会在 avcodec_open2 这一步失败，于是
        // 顺着列表往下试就是「探测」。每个平台的 FFmpeg 只编进了自己用得上的那
        // 几个，别的名字查不到、直接跳过：
        //   Windows  nvenc → amf → Media Foundation（兜底，没有显卡也有软件编码器）
        //   Linux    nvenc → VAAPI（AMD / Intel，帧要先传进显存）
        //   Apple    VideoToolbox（允许退到苹果自己的软件编码器）
        //   Android  MediaCodec（CDD 要求每台设备都有 H.264 硬编）
        static const char* const kHevc[] = {
            "hevc_nvenc",      "hevc_amf", "hevc_qsv", "hevc_vaapi", "hevc_videotoolbox",
            "hevc_mediacodec", "hevc_mf",
        };
        static const char* const kH264[] = {
            "h264_nvenc",      "h264_amf", "h264_qsv",    "h264_vaapi", "h264_videotoolbox",
            "h264_mediacodec", "h264_mf",  "libopenh264",
        };
        if (job_->codec == FI_CODEC_HEVC) {
            for (const char* name : kHevc) {
                if (try_open_encoder(name, bitrate, out_fps)) return;
            }
        }
        for (const char* name : kH264) {
            if (try_open_encoder(name, bitrate, out_fps)) return;
        }
        fail(FI_ERR_ENCODER, "no usable video encoder");
    }

    void open_output() {
        const char* format = job_->output_format.empty() ? nullptr : job_->output_format.c_str();
        int r = avformat_alloc_output_context2(&out_.p, nullptr, format, job_->output.c_str());
        if (r < 0 || !out_.p) fail(FI_ERR_OPEN_OUTPUT, "unknown output container: " + av_error(r));

        open_encoder();

        stream_map_.assign(in_.p->nb_streams, -1);
        // 视频流放第一条，其余按原顺序跟在后面。
        out_video_ = avformat_new_stream(out_.p, nullptr);
        if (!out_video_) fail(FI_ERR_OPEN_OUTPUT, "avformat_new_stream(video)");
        r = avcodec_parameters_from_context(out_video_->codecpar, enc_.p);
        if (r < 0) fail(FI_ERR_OPEN_OUTPUT, "avcodec_parameters_from_context: " + av_error(r));
        out_video_->time_base = half_tb_;
        out_video_->sample_aspect_ratio = in_video_->sample_aspect_ratio;
        out_video_->avg_frame_rate = enc_.p->framerate;
        out_video_->disposition = in_video_->disposition;
        av_dict_copy(&out_video_->metadata, in_video_->metadata, 0);
        copy_display_matrix();
        stream_map_[video_index_] = out_video_->index;

        for (unsigned i = 0; i < in_.p->nb_streams; i++) {
            if ((int)i == video_index_) continue;
            const AVStream* src = in_.p->streams[i];
            const AVMediaType type = src->codecpar->codec_type;
            if (type != AVMEDIA_TYPE_AUDIO && type != AVMEDIA_TYPE_SUBTITLE) continue;
            const bool accepted =
                avformat_query_codec(out_.p->oformat, src->codecpar->codec_id,
                                     FF_COMPLIANCE_NORMAL) == 1;
            if (!accepted) {
                // 字幕轨容器不收就算了；音轨不能悄悄丢——丢了用户拿到的是一个
                // 没声音的成品，宁可整单失败让上层换容器。
                if (type == AVMEDIA_TYPE_AUDIO) {
                    fail(FI_ERR_OPEN_OUTPUT, std::string("container does not accept audio codec ") +
                                                 avcodec_get_name(src->codecpar->codec_id));
                }
                continue;
            }
            AVStream* dst = avformat_new_stream(out_.p, nullptr);
            if (!dst) fail(FI_ERR_OPEN_OUTPUT, "avformat_new_stream");
            r = avcodec_parameters_copy(dst->codecpar, src->codecpar);
            if (r < 0) fail(FI_ERR_OPEN_OUTPUT, "avcodec_parameters_copy: " + av_error(r));
            dst->codecpar->codec_tag = 0;
            dst->time_base = src->time_base;
            dst->disposition = src->disposition;
            av_dict_copy(&dst->metadata, src->metadata, 0);
            stream_map_[i] = dst->index;
        }

        av_dict_copy(&out_.p->metadata, in_.p->metadata, 0);

        if (!(out_.p->oformat->flags & AVFMT_NOFILE)) {
            r = avio_open(&out_.p->pb, job_->output.c_str(), AVIO_FLAG_WRITE);
            if (r < 0) fail(FI_ERR_OPEN_OUTPUT, "avio_open: " + av_error(r));
        }
        r = avformat_write_header(out_.p, nullptr);
        if (r < 0) fail(FI_ERR_OPEN_OUTPUT, "avformat_write_header: " + av_error(r));

        enc_frame_.p->format = sw_format_;
        enc_frame_.p->width = width_;
        enc_frame_.p->height = height_;
        r = av_frame_get_buffer(enc_frame_.p, 0);
        if (r < 0) fail(FI_ERR_ENCODER, "av_frame_get_buffer: " + av_error(r));

        to_encoder_.reset(sws_getContext(width_, height_, kPackedFormat, width_, height_,
                                         sw_format_,
                                         SWS_BILINEAR | SWS_ACCURATE_RND | SWS_FULL_CHR_H_INP,
                                         nullptr, nullptr, nullptr));
        if (!to_encoder_.p) fail(FI_ERR_ENCODER, "sws_getContext(encoder)");
        const int* table = sws_getCoefficients(sws_colorspace(colorspace_));
        sws_setColorspaceDetails(to_encoder_.p, table, 1, table, 0, 0, 1 << 16, 1 << 16);
    }

    // 手机竖拍的片子靠这块旋转矩阵才是正的；丢了它成品会横过来。
    void copy_display_matrix() {
        const AVCodecParameters* src = in_video_->codecpar;
        const AVPacketSideData* matrix = av_packet_side_data_get(
            src->coded_side_data, src->nb_coded_side_data, AV_PKT_DATA_DISPLAYMATRIX);
        if (!matrix) return;
        AVCodecParameters* dst = out_video_->codecpar;
        AVPacketSideData* copy =
            av_packet_side_data_new(&dst->coded_side_data, &dst->nb_coded_side_data,
                                    AV_PKT_DATA_DISPLAYMATRIX, matrix->size, 0);
        if (copy) memcpy(copy->data, matrix->data, matrix->size);
    }

    // ---- 主循环 ----

    void pump() {
        PacketPtr packet;
        FramePtr frame;
        while (true) {
            check_cancel();
            const int r = av_read_frame(in_.p, packet.p);
            if (r == AVERROR_EOF) break;
            if (r < 0) fail(FI_ERR_OPEN_INPUT, "av_read_frame: " + av_error(r));

            if (packet.p->stream_index == video_index_) {
                // 个别坏包解不出来不算致命：解码器会自己跳到下一个可解的位置。
                int sent = avcodec_send_packet(dec_.p, packet.p);
                if (sent == AVERROR(EAGAIN)) {
                    // 解码器要我们先把它手里的帧取走：取完把同一个包再送一次，
                    // 不然这个包就丢了。
                    drain_decoder(frame.p);
                    sent = avcodec_send_packet(dec_.p, packet.p);
                }
                if (sent < 0 && sent != AVERROR_INVALIDDATA && sent != AVERROR(EAGAIN)) {
                    fail(FI_ERR_DECODER, "avcodec_send_packet: " + av_error(sent));
                }
                drain_decoder(frame.p);
            } else if (packet.p->stream_index >= 0 &&
                       packet.p->stream_index < (int)stream_map_.size() &&
                       stream_map_[packet.p->stream_index] >= 0) {
                copy_packet(packet.p);
            }
            av_packet_unref(packet.p);
        }
        avcodec_send_packet(dec_.p, nullptr);
        drain_decoder(frame.p);
    }

    void drain_decoder(AVFrame* frame) {
        while (true) {
            const int r = avcodec_receive_frame(dec_.p, frame);
            if (r == AVERROR(EAGAIN) || r == AVERROR_EOF) return;
            if (r < 0) {
                if (r == AVERROR_INVALIDDATA) continue;
                fail(FI_ERR_DECODER, "avcodec_receive_frame: " + av_error(r));
            }
            on_frame(frame);
            av_frame_unref(frame);
            check_cancel();
        }
    }

    void copy_packet(AVPacket* packet) {
        const AVStream* src = in_.p->streams[packet->stream_index];
        AVStream* dst = out_.p->streams[stream_map_[packet->stream_index]];
        av_packet_rescale_ts(packet, src->time_base, dst->time_base);
        packet->pos = -1;
        packet->stream_index = dst->index;
        const int r = av_interleaved_write_frame(out_.p, packet);
        if (r < 0) fail(FI_ERR_WRITE, "av_interleaved_write_frame: " + av_error(r));
    }

    void to_packed(const AVFrame* frame, std::vector<uint8_t>& dst) {
        const bool full = is_full_range(frame);
        if (!to_packed_.p || packed_src_w_ != frame->width || packed_src_h_ != frame->height ||
            packed_src_fmt_ != frame->format || packed_src_full_ != full) {
            to_packed_.reset(sws_getContext(frame->width, frame->height,
                                            (AVPixelFormat)frame->format, width_, height_,
                                            kPackedFormat, SWS_BICUBIC | SWS_ACCURATE_RND |
                                                               SWS_FULL_CHR_H_INT,
                                            nullptr, nullptr, nullptr));
            if (!to_packed_.p) fail(FI_ERR_DECODER, "sws_getContext(decoder)");
            const int* table = sws_getCoefficients(sws_colorspace(colorspace_));
            sws_setColorspaceDetails(to_packed_.p, table, full ? 1 : 0, table, 1, 0, 1 << 16,
                                     1 << 16);
            packed_src_w_ = frame->width;
            packed_src_h_ = frame->height;
            packed_src_fmt_ = frame->format;
            packed_src_full_ = full;
        }
        uint8_t* planes[4] = {dst.data(), nullptr, nullptr, nullptr};
        int strides[4] = {width_ * 3, 0, 0, 0};
        sws_scale(to_packed_.p, frame->data, frame->linesize, 0, frame->height, planes, strides);
    }

    // 两帧差得太多就当作换了镜头。跨镜头硬插出来的是两个画面搅在一起的鬼影，
    // 比重复一帧难看得多。抽样比较就够：镜头切换是整幅画面的事。
    bool is_scene_cut() const {
        const int step = std::max(1, width_ / 160);
        uint64_t sum = 0;
        uint64_t samples = 0;
        for (int y = 0; y < height_; y += step) {
            const uint8_t* a = prev_.data() + (size_t)y * width_ * 3;
            const uint8_t* b = cur_.data() + (size_t)y * width_ * 3;
            for (int x = 0; x < width_; x += step) {
                const int i = x * 3;
                sum += (uint64_t)(std::abs(a[i] - b[i]) + std::abs(a[i + 1] - b[i + 1]) +
                                  std::abs(a[i + 2] - b[i + 2]));
                samples += 3;
            }
        }
        return samples > 0 && sum / samples >= 32;
    }

    void on_frame(const AVFrame* frame) {
        int64_t pts = frame->best_effort_timestamp;
        if (pts == AV_NOPTS_VALUE) pts = have_prev_ ? prev_pts_ + frame_ticks_ : 0;
        // 时间戳不往前走的帧没法放进输出（封装器要求严格递增），丢掉。
        if (have_prev_ && pts <= prev_pts_) return;

        to_packed(frame, cur_);
        if (!have_prev_) {
            have_prev_ = true;
            first_pts_ = pts;
            prev_pts_ = pts;
            last_delta_ = frame_ticks_;
            prev_.swap(cur_);
            return;
        }

        encode(prev_, 2 * prev_pts_);
        check_cancel();
        if (job_->scene_detect && is_scene_cut()) {
            encode(prev_, prev_pts_ + pts);
        } else {
            const ncnn::Mat a(width_, height_, (void*)prev_.data(), (size_t)3, 3);
            const ncnn::Mat b(width_, height_, (void*)cur_.data(), (size_t)3, 3);
            ncnn::Mat m(width_, height_, (void*)mid_.data(), (size_t)3, 3);
            if (rife_->process(a, b, 0.5f, m) != 0) {
                fail(FI_ERR_INTERPOLATE, "RIFE::process failed");
            }
            encode(mid_, prev_pts_ + pts);
        }

        last_delta_ = pts - prev_pts_;
        prev_pts_ = pts;
        prev_.swap(cur_);

        if (duration_ticks_ > 0) {
            const double done = (double)(pts - first_pts_) / (double)duration_ticks_;
            job_->progress.store(std::min(0.999, std::max(0.0, done)), std::memory_order_relaxed);
        }
    }

    void encode(const std::vector<uint8_t>& packed, int64_t pts) {
        if (last_out_pts_ != AV_NOPTS_VALUE && pts <= last_out_pts_) pts = last_out_pts_ + 1;
        last_out_pts_ = pts;

        int r = av_frame_make_writable(enc_frame_.p);
        if (r < 0) fail(FI_ERR_ENCODER, "av_frame_make_writable: " + av_error(r));
        const uint8_t* planes[4] = {packed.data(), nullptr, nullptr, nullptr};
        const int strides[4] = {width_ * 3, 0, 0, 0};
        sws_scale(to_encoder_.p, planes, strides, 0, height_, enc_frame_.p->data,
                  enc_frame_.p->linesize);
        enc_frame_.p->pts = pts;
        enc_frame_.p->pict_type = AV_PICTURE_TYPE_NONE;

        r = send_frame(enc_.p, enc_frame_.p, hw_frames_.p, hw_frame_.p);
        if (r < 0) fail(FI_ERR_ENCODER, "avcodec_send_frame: " + av_error(r));
        drain_encoder();
    }

    void drain_encoder() {
        while (true) {
            const int r = avcodec_receive_packet(enc_.p, enc_packet_.p);
            if (r == AVERROR(EAGAIN) || r == AVERROR_EOF) return;
            if (r < 0) fail(FI_ERR_ENCODER, "avcodec_receive_packet: " + av_error(r));
            av_packet_rescale_ts(enc_packet_.p, enc_.p->time_base, out_video_->time_base);
            enc_packet_.p->stream_index = out_video_->index;
            const int w = av_interleaved_write_frame(out_.p, enc_packet_.p);
            av_packet_unref(enc_packet_.p);
            if (w < 0) fail(FI_ERR_WRITE, "av_interleaved_write_frame: " + av_error(w));
            job_->frames_written.fetch_add(1, std::memory_order_relaxed);
        }
    }

    void finish() {
        if (!have_prev_) fail(FI_ERR_DECODER, "no decodable video frame");
        // 最后一帧后面没有下一帧可配对，重复一次，让帧数正好是原片的两倍、
        // 末尾的节奏和前面一致。
        encode(prev_, 2 * prev_pts_);
        encode(prev_, 2 * prev_pts_ + std::max<int64_t>(1, last_delta_));

        int r = avcodec_send_frame(enc_.p, nullptr);
        if (r < 0 && r != AVERROR_EOF) fail(FI_ERR_ENCODER, "flush encoder: " + av_error(r));
        drain_encoder();

        r = av_write_trailer(out_.p);
        if (r < 0) fail(FI_ERR_WRITE, "av_write_trailer: " + av_error(r));
        if (out_.p->pb && out_.p->pb->error < 0) {
            fail(FI_ERR_WRITE, "output io error: " + av_error(out_.p->pb->error));
        }
    }
};

void run_job(FiJob* job) {
    int final_state = FI_STATE_DONE;
    try {
        Pipeline pipeline(job);
        pipeline.run();
        job->progress.store(1.0);
    } catch (const Cancelled&) {
        final_state = FI_STATE_CANCELLED;
    } catch (const Failure& failure) {
        {
            std::lock_guard<std::mutex> lock(job->text_mutex);
            job->error_text = failure.message;
        }
        job->error_code.store(failure.code);
        final_state = FI_STATE_FAILED;
    } catch (const std::exception& e) {
        {
            std::lock_guard<std::mutex> lock(job->text_mutex);
            job->error_text = e.what();
        }
        job->error_code.store(FI_ERR_UNKNOWN);
        final_state = FI_STATE_FAILED;
    } catch (...) {
        job->error_code.store(FI_ERR_UNKNOWN);
        final_state = FI_STATE_FAILED;
    }
    job->state.store(final_state);
}

}  // namespace

// ---- C ABI ---------------------------------------------------------------

extern "C" {

FI_API int32_t fi_abi_version(void) {
    return FI_ABI_VERSION;
}

FI_API int32_t fi_gpu_count(void) {
    GpuSession session;
    return session.usable_count();
}

FI_API int32_t fi_probe(const char* input_path, FiProbeResult* out) {
    if (!input_path || !out || out->struct_size < kProbeResultSizeV1) {
        return FI_ERR_INVALID_ARGUMENT;
    }
    const uint32_t size = out->struct_size;
    memset(out, 0, kProbeResultSizeV1);
    out->struct_size = size;

    InputFile in;
    if (avformat_open_input(&in.p, input_path, nullptr, nullptr) < 0) return FI_ERR_OPEN_INPUT;
    if (avformat_find_stream_info(in.p, nullptr) < 0) return FI_ERR_OPEN_INPUT;
    const int index = av_find_best_stream(in.p, AVMEDIA_TYPE_VIDEO, -1, -1, nullptr, 0);
    if (index < 0) return FI_ERR_NO_VIDEO;
    const AVStream* stream = in.p->streams[index];
    const AVCodecParameters* par = stream->codecpar;

    out->width = par->width;
    out->height = par->height;
    const AVRational fps = av_guess_frame_rate(in.p, const_cast<AVStream*>(stream), nullptr);
    if (fps.num > 0 && fps.den > 0) {
        out->fps_num = fps.num;
        out->fps_den = fps.den;
    }
    out->is_hdr = is_hdr_transfer(par->color_trc) ? 1 : 0;
    if (in.p->duration > 0) {
        out->duration_us = av_rescale_q(in.p->duration, AV_TIME_BASE_Q, AVRational{1, 1000000});
    }
    if (stream->nb_frames > 0) {
        out->frame_count = stream->nb_frames;
    } else if (out->duration_us > 0 && out->fps_den > 0) {
        out->frame_count = av_rescale(out->duration_us, out->fps_num, (int64_t)out->fps_den * 1000000);
    }
    return FI_OK;
}

FI_API FiJob* fi_job_create(const FiJobOptions* options) {
    if (!options || options->struct_size < kJobOptionsSizeV1) return nullptr;
    if (!options->input_path || !options->output_path || !options->model_dir) return nullptr;
    FiJob* job = new FiJob();
    job->input = options->input_path;
    job->output = options->output_path;
    job->model_dir = options->model_dir;
    job->gpu_index = options->gpu_index;
    job->codec = options->codec;
    job->quality = options->quality;
    job->scene_detect = options->scene_detect != 0;
    if (options->output_format) job->output_format = options->output_format;
    return job;
}

FI_API int32_t fi_job_start(FiJob* job) {
    if (!job) return FI_ERR_INVALID_ARGUMENT;
    int expected = FI_STATE_PENDING;
    if (!job->state.compare_exchange_strong(expected, FI_STATE_RUNNING)) {
        return FI_ERR_INVALID_ARGUMENT;
    }
    job->worker = std::thread(run_job, job);
    return FI_OK;
}

FI_API void fi_job_cancel(FiJob* job) {
    if (job) job->cancel.store(true);
}

FI_API int32_t fi_job_state(FiJob* job) {
    return job ? job->state.load() : FI_STATE_FAILED;
}

FI_API double fi_job_progress(FiJob* job) {
    return job ? job->progress.load() : 0.0;
}

FI_API int64_t fi_job_frames_written(FiJob* job) {
    return job ? job->frames_written.load() : 0;
}

FI_API int32_t fi_job_error_code(FiJob* job) {
    return job ? job->error_code.load() : FI_ERR_INVALID_ARGUMENT;
}

FI_API const char* fi_job_error(FiJob* job) {
    if (!job) return "";
    std::lock_guard<std::mutex> lock(job->text_mutex);
    return job->error_text.c_str();
}

FI_API const char* fi_job_encoder(FiJob* job) {
    if (!job) return "";
    std::lock_guard<std::mutex> lock(job->text_mutex);
    return job->encoder_name.c_str();
}

FI_API void fi_job_destroy(FiJob* job) {
    if (!job) return;
    job->cancel.store(true);
    if (job->worker.joinable()) job->worker.join();
    delete job;
}

}  // extern "C"

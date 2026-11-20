// 离线补帧引擎的 C ABI。
//
// 这只库是单独构建、再整个目录打进安装包的，Dart 侧用 dart:ffi 的
// DynamicLibrary.open 加载——编译器不会替两边核对任何东西。所以这里的每一个
// 符号、每一个结构体布局都当作跨版本契约来对待：组件可以不重新构建就配着
// 新版应用发出去，谁也不能假设对方和自己是同一次构建出来的。
//
//   - 改了任何已有函数的签名或已有字段的含义，就把 FI_ABI_VERSION 加一；
//     Dart 侧只认自己写死的那个版本号，对不上就当作组件不可用。
//   - 结构体只许在末尾追加字段，并靠 struct_size 判断对方给了多少。
//   - 所有字符串都是 UTF-8；Windows 上的宽字符转换在库里做。
#ifndef FRAME_INTERP_H
#define FRAME_INTERP_H

#include <stdint.h>

#ifdef _WIN32
#  ifdef FI_BUILD
#    define FI_API __declspec(dllexport)
#  else
#    define FI_API __declspec(dllimport)
#  endif
#else
#  define FI_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define FI_ABI_VERSION 1

// 作业状态。
enum {
    FI_STATE_PENDING = 0,
    FI_STATE_RUNNING = 1,
    FI_STATE_DONE = 2,
    FI_STATE_FAILED = 3,
    FI_STATE_CANCELLED = 4,
};

// 失败原因。Dart 侧按这个码挑文案，fi_job_error 的文本只进日志。
enum {
    FI_OK = 0,
    FI_ERR_UNKNOWN = 1,
    FI_ERR_INVALID_ARGUMENT = 2,
    FI_ERR_OPEN_INPUT = 3,      // 打不开 / 读不懂输入文件
    FI_ERR_NO_VIDEO = 4,        // 文件里没有视频流
    FI_ERR_DECODER = 5,         // 找不到解码器或解码失败
    FI_ERR_HDR_UNSUPPORTED = 6, // HDR 片源（PQ / HLG）：当前流程会把它压成颜色错误的 SDR
    FI_ERR_NO_GPU = 7,          // 没有可用的 Vulkan 设备
    FI_ERR_MODEL = 8,           // 模型文件缺失或加载失败
    FI_ERR_ENCODER = 9,         // 没有任何可用的编码器，或编码失败
    FI_ERR_OPEN_OUTPUT = 10,    // 输出文件建不出来 / 容器不接受某条流
    FI_ERR_WRITE = 11,          // 写盘失败（多半是磁盘满）
    FI_ERR_INTERPOLATE = 12,    // 推理失败（多半是显存不足）
};

enum {
    FI_CODEC_H264 = 0,
    FI_CODEC_HEVC = 1,
};

enum {
    FI_QUALITY_BALANCED = 0,
    FI_QUALITY_HIGH = 1,
};

typedef struct FiJobOptions {
    uint32_t struct_size; // sizeof(FiJobOptions)，由调用方填
    int32_t gpu_index;    // -1 = 自动（优先独显）
    const char* input_path;
    const char* output_path; // 容器格式按扩展名推断
    const char* model_dir;   // 含 flownet.param / flownet.bin 的目录
    int32_t codec;           // FI_CODEC_*
    int32_t quality;         // FI_QUALITY_*
    int32_t scene_detect;    // 非 0：镜头切换处不插帧，改为重复上一帧
    int32_t reserved;
    // 容器格式名（"mp4" / "matroska"）。为空时按 output_path 的扩展名推断。
    // 调用方通常先写到一个不带视频扩展名的临时文件，跑完再改名——免得媒体库
    // 扫描把写到一半的文件当成视频收进去——所以需要单独指定格式。
    const char* output_format;
} FiJobOptions;

typedef struct FiProbeResult {
    uint32_t struct_size; // sizeof(FiProbeResult)，由调用方填
    int32_t width;
    int32_t height;
    int32_t fps_num; // 平均帧率；读不到时 fps_den 为 0
    int32_t fps_den;
    int32_t is_hdr;      // 非 0：HDR（PQ / HLG），补帧会被拒绝
    int64_t duration_us; // 读不到时为 0
    int64_t frame_count; // 估算值，读不到时为 0
} FiProbeResult;

typedef struct FiJob FiJob;

FI_API int32_t fi_abi_version(void);

// 可用的 Vulkan 设备数量。0 表示这台机器跑不了补帧。
FI_API int32_t fi_gpu_count(void);

// 读片源的基本参数，用来在排队前就把跑不了的片子挡在外面。返回 FI_OK 或 FI_ERR_*。
FI_API int32_t fi_probe(const char* input_path, FiProbeResult* out);

// 创建作业（不启动）。选项里的字符串会被拷贝，返回后调用方可以立刻释放。
// 参数不合法时返回 NULL。
FI_API FiJob* fi_job_create(const FiJobOptions* options);

// 在库自己的线程上开始跑。立即返回。
FI_API int32_t fi_job_start(FiJob* job);

// 请求取消。立即返回；作业会在处理完手头这一帧后收尾，状态变为 CANCELLED。
// 输出文件由调用方负责删。
FI_API void fi_job_cancel(FiJob* job);

FI_API int32_t fi_job_state(FiJob* job);
FI_API double fi_job_progress(FiJob* job);     // 0.0 ~ 1.0
FI_API int64_t fi_job_frames_written(FiJob* job);
FI_API int32_t fi_job_error_code(FiJob* job);  // FI_ERR_*，未失败时为 FI_OK

// 失败详情，只用于日志。指针在 fi_job_destroy 之前有效。
FI_API const char* fi_job_error(FiJob* job);

// 实际选中的编码器名（例如 "h264_nvenc"），开始编码前为空串。
FI_API const char* fi_job_encoder(FiJob* job);

// 销毁作业。仍在运行时会先取消并等它收尾，所以可能阻塞到手头这一帧处理完。
FI_API void fi_job_destroy(FiJob* job);

#ifdef __cplusplus
}
#endif

#endif // FRAME_INTERP_H

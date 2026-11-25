// 引擎的命令行外壳：只用来在不启动应用的情况下验证一次补帧能不能跑通、跑多快。
// 不进组件包。
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <thread>

#include "frame_interp.h"

int main(int argc, char** argv) {
    if (argc < 4) {
        fprintf(stderr, "usage: fi_cli <input> <output> <model_dir> [h264|hevc] [balanced|high]\n");
        return 2;
    }

    printf("abi=%d gpus=%d\n", fi_abi_version(), fi_gpu_count());

    FiProbeResult probe;
    memset(&probe, 0, sizeof(probe));
    probe.struct_size = sizeof(probe);
    const int probed = fi_probe(argv[1], &probe);
    printf("probe=%d %dx%d fps=%d/%d hdr=%d duration=%.2fs frames=%lld\n", probed, probe.width,
           probe.height, probe.fps_num, probe.fps_den, probe.is_hdr, probe.duration_us / 1e6,
           (long long)probe.frame_count);
    if (probed != FI_OK) return 1;

    FiJobOptions options;
    memset(&options, 0, sizeof(options));
    options.struct_size = sizeof(options);
    options.gpu_index = -1;
    options.input_path = argv[1];
    options.output_path = argv[2];
    options.model_dir = argv[3];
    options.codec = argc > 4 && strcmp(argv[4], "hevc") == 0 ? FI_CODEC_HEVC : FI_CODEC_H264;
    options.quality = argc > 5 && strcmp(argv[5], "high") == 0 ? FI_QUALITY_HIGH : FI_QUALITY_BALANCED;
    options.scene_detect = 1;
    options.output_format = nullptr;

    FiJob* job = fi_job_create(&options);
    if (!job) {
        fprintf(stderr, "fi_job_create failed\n");
        return 1;
    }
    const auto started = std::chrono::steady_clock::now();
    fi_job_start(job);
    while (fi_job_state(job) == FI_STATE_RUNNING) {
        std::this_thread::sleep_for(std::chrono::milliseconds(500));
        const double elapsed =
            std::chrono::duration<double>(std::chrono::steady_clock::now() - started).count();
        const long long frames = (long long)fi_job_frames_written(job);
        printf("\r%5.1f%%  %lld frames  %.1f fps out  [%s]   ", fi_job_progress(job) * 100.0,
               frames, elapsed > 0 ? frames / elapsed : 0.0, fi_job_encoder(job));
        fflush(stdout);
    }
    const int state = fi_job_state(job);
    const double elapsed =
        std::chrono::duration<double>(std::chrono::steady_clock::now() - started).count();
    printf("\nstate=%d error=%d (%s) frames=%lld elapsed=%.1fs\n", state, fi_job_error_code(job),
           fi_job_error(job), (long long)fi_job_frames_written(job), elapsed);
    fi_job_destroy(job);
    return state == FI_STATE_DONE ? 0 : 1;
}

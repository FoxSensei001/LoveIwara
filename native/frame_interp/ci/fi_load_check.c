/*
 * CI 用：把装进应用里的补帧引擎按清单的顺序加载起来，调一次 fi_abi_version。
 *
 * 验的是「装进应用之后，引擎和它依赖的库都找得到、符号都对得上」——Linux 靠
 * RPATH $ORIGIN，macOS 靠 framework 里的 @rpath / @loader_path，这些只有真的
 * 加载一次才知道对不对。用 RTLD_NOW，缺符号当场就报，不等到第一次调用。
 *
 * 不用 Python 的 ctypes：macOS 上系统自带的 python 开着库校验，加载不了没有
 * 苹果签名的 framework，会报一个和打包无关的错。自己编的这个小程序没有这层限制。
 *
 * 用法：fi_load_check <引擎库> [先加载的库...]
 *   环境变量 FI_LOAD_CHECK_GPU 非空时再调一次 fi_gpu_count（CI 的机器多半没有
 *   能用的 GPU，这一项只打印、不判对错）。
 * 输出：成功时 stdout 打 "fi_abi_version=<n>"，退出码 0。
 */
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef int32_t (*fi_int_fn)(void);

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s <library> [preload...]\n", argv[0]);
        return 2;
    }
    for (int i = 2; i < argc; ++i) {
        if (!dlopen(argv[i], RTLD_NOW | RTLD_GLOBAL)) {
            fprintf(stderr, "preload %s: %s\n", argv[i], dlerror());
            return 1;
        }
    }
    void* engine = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
    if (!engine) {
        fprintf(stderr, "load %s: %s\n", argv[1], dlerror());
        return 1;
    }
    fi_int_fn abi = (fi_int_fn)dlsym(engine, "fi_abi_version");
    if (!abi) {
        fprintf(stderr, "fi_abi_version not exported by %s\n", argv[1]);
        return 1;
    }
    printf("fi_abi_version=%d\n", (int)abi());
    fflush(stdout);

    if (getenv("FI_LOAD_CHECK_GPU")) {
        fi_int_fn gpus = (fi_int_fn)dlsym(engine, "fi_gpu_count");
        if (!gpus) {
            fprintf(stderr, "fi_gpu_count not exported by %s\n", argv[1]);
            return 1;
        }
        printf("fi_gpu_count=%d\n", (int)gpus());
    }
    return 0;
}

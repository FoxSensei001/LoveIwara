// 等距柱状（equirect）→ 透视投影的重映射。
//
// 走 Flutter 3.47 的 `ui.ImageFilter.shader`：把整只视频子树（media_kit 的
// Texture）当成一张输入贴图，逐像素反算「这个屏幕像素对应球面上哪个方向」，
// 再回到等距图上取色。于是用户看到的不再是被摊平拉烂的 2:1 全景，而是一个正常
// 比例的取景窗，拖动就等于转头。
//
// # 契约（dart:ui 的硬性要求，改 uniform 顺序前先读这段）
//
//  1. **第一个 uniform 必须是 vec2**，引擎会把它写成「输入贴图的尺寸」——
//     所以 uSize 由引擎下发，Dart 侧不要去 setFloat(0/1)。
//  2. 必须至少有一个 sampler2D，第一个 sampler 由引擎绑成滤镜输入。
//  3. 两条任一不满足，`ImageFilter.shader` 直接抛 StateError。
//
// # uniform 的浮点下标（Dart 侧 setFloat 按声明顺序排，别错位）
//
//     uSize     0,1      （引擎写，勿动）
//     uSrcRect  2,3,4,5
//     uView     6,7,8
//     uSpan     9,10
//
// # 为什么要 GLES 的 y 翻转
//
// Impeller 走 OpenGL(ES) 后端时帧缓冲是自下而上的，官方文档明说「自定义片元
// 着色器必须自己翻 y 轴，否则整幅上下颠倒」。翻转只加在**最终的贴图采样坐标**
// 上（等价于官方样例里那句 `uv.y = 1.0 - uv.y`），不能加在输出方向的推导上——
// 加错地方会得到一幅上下颠倒的全景，而不是修正。

#include <flutter/runtime_effect.glsl>

precision highp float;

/// 引擎下发：输入贴图（= 本滤镜作用的那块矩形）的尺寸，像素。
uniform vec2 uSize;

/// 单眼在整帧里的取景矩形，归一化 [x, y, w, h]。
/// 左右并排取左半幅 → (0,0,0.5,1)；上下堆叠取上半幅 → (0,0,1,0.5)；单目 → (0,0,1,1)。
/// 立体裁切因此与球面重映射合并在同一趟里完成，不必额外叠一层裁剪。
uniform vec4 uSrcRect;

/// 视角：x = yaw（弧度，正数向右转），y = pitch（弧度，正数抬头），
/// z = 竖直视野角 fovY（弧度）。
uniform vec3 uView;

/// 这一眼的等距图覆盖的角度跨度：x = 水平（180° 片为 π、360° 片为 2π），
/// y = 竖直（一律 π）。
///
/// VR180 的单眼是**正方形**（180°×180°），左右并排后整帧才是 2:1；
/// 360° 单目的整帧本身就是 2:1（360°×180°）。两者整帧宽高比撞在一起无法分辨，
/// 这也正是文档里「220:3，无信号时默认 180」那条实证的由来。
uniform vec2 uSpan;

/// 滤镜输入：整只视频子树渲染出来的那张贴图。
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    // 输出空间的归一化坐标，原点左上。
    vec2 outUv = FlutterFragCoord().xy / uSize;

    // 屏幕像素 → 相机空间光线。相机看向 +z，x 向右、y 向上。
    // outUv.y 向下增长，所以这里取负号把它翻成「向上为正」。
    vec2 ndc = (outUv - 0.5) * 2.0;
    float aspect = uSize.x / max(uSize.y, 1.0);
    float tanHalfV = tan(uView.z * 0.5);
    vec3 dir = normalize(vec3(ndc.x * aspect * tanHalfV, -ndc.y * tanHalfV, 1.0));

    // 先绕 x 轴俯仰，再绕 y 轴偏航。顺序不能换：先 yaw 后 pitch 会让抬头之后的
    // 左右拖动沿着倾斜的圆锥走，手感直接歪掉。
    float cp = cos(uView.y);
    float sp = sin(uView.y);
    dir = vec3(dir.x, dir.y * cp + dir.z * sp, -dir.y * sp + dir.z * cp);

    float cy = cos(uView.x);
    float sy = sin(uView.x);
    dir = vec3(dir.x * cy + dir.z * sy, dir.y, -dir.x * sy + dir.z * cy);

    // 方向 → 经纬。正前方（yaw=pitch=0）落在 lon=0/lat=0，即等距图正中心。
    float lon = atan(dir.x, dir.z);
    float lat = asin(clamp(dir.y, -1.0, 1.0));

    // 经纬 → 单眼等距图内的归一化坐标。
    vec2 sph = vec2(0.5 + lon / uSpan.x, 0.5 - lat / uSpan.y);

    // 越界＝这个方向上根本没有像素（180° 片的背后半球就是这样），涂黑而不是
    // 让 clamp 把边缘那一列拉成长条。
    if (sph.x < 0.0 || sph.x > 1.0 || sph.y < 0.0 || sph.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 落回整帧坐标：单眼取景矩形的偏移 + 缩放。
    vec2 frameUv = uSrcRect.xy + sph * uSrcRect.zw;

#ifdef IMPELLER_TARGET_OPENGLES
    frameUv.y = 1.0 - frameUv.y;
#endif

    fragColor = texture(uTexture, frameUv);
}

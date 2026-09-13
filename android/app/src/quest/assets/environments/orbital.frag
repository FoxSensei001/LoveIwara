#version 300 es
precision highp float;
#include "orbital.glsl"
uniform vec3 leftEye;
uniform vec3 rightEye;
uniform vec3 planeRight;
uniform vec3 planeUp;
uniform float planeSize;
in vec2 uv;
out vec4 color;
void main() {
    vec3 eye = uv.x < 0.5 ? leftEye : rightEye;
    vec2 p = vec2(fract(uv.x * 2.0), uv.y) - 0.5;
    vec3 point = bodyCenter + planeSize * (p.x * planeRight + p.y * planeUp);
    vec4 light = orbitalRadiance(eye, normalize(point - eye));
    // Native surfaces carry sRGB bytes, premultiplied in linear light, just as
    // the existing native_video.frag path does. EGL sRGB writes are disabled.
    color = vec4(orbitSrgb(light.rgb), light.a);
}

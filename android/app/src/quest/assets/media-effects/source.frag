#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
uniform samplerExternalOES source;
uniform mat4 sourceTransform;
uniform vec4 eyeRect;
uniform vec2 sourceSize;
uniform int operation;
in vec2 uv;
out vec4 color;

vec4 encodedSourceAt(vec2 p) {
    return texture(source, (sourceTransform * vec4(p, 0.0, 1.0)).xy);
}
vec4 linearTexel(vec2 pixel) {
    vec4 c = encodedSourceAt((pixel + 0.5) / sourceSize);
    c.rgb = mix(c.rgb / 12.92, pow((c.rgb + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c.rgb));
    return c;
}
vec4 sourceAt(vec2 p) {
    // The source has to be filtered in linear light, and external GLES textures
    // do not decode sRGB automatically. Decode four NEAREST texels before
    // interpolating, rather than decoding an already blurred RGB.
    vec2 texel = p * sourceSize - 0.5;
    vec2 base = floor(texel);
    vec2 f = fract(texel);
    return mix(mix(linearTexel(base), linearTexel(base + vec2(1.0, 0.0)), f.x),
               mix(linearTexel(base + vec2(0.0, 1.0)), linearTexel(base + vec2(1.0)), f.x), f.y);
}
void main() {
    if (operation == 0) {
        color = encodedSourceAt(uv);
        return;
    }
    if (operation == 2) {
        vec4 sum = vec4(0.0);
        // ScreenAverage samples the whole source (both stereo eyes).
        for (int x = 0; x < 16; ++x) for (int y = 0; y < 16; ++y)
            sum += sourceAt(vec2(x, y) * 0.0625) * 0.00390625;
        float remaining = 1.0 - max(sum.r, max(sum.g, sum.b));
        color = sum * (1.0 + 2.0 * remaining * remaining);
        return;
    }
    float t = uv.x;
    vec2 edge;
    if (t < 0.25) edge = vec2(0.06, t * 3.52 + 0.06);
    else if (t < 0.5) edge = vec2(t * 3.52 - 0.82, 0.94);
    else if (t < 0.75) edge = vec2(0.94, 2.7 - t * 3.52);
    else edge = vec2(3.58 - t * 3.52, 0.06);
    color = vec4(0.0);
    for (int ring = 1; ring <= 4; ++ring) for (int direction = 0; direction < 8; ++direction) {
        float angle = float(direction) * 0.78539812565 + 0.44879895449;
        vec2 p = edge + float(ring) * 0.015 * vec2(cos(angle), sin(angle));
        color += sourceAt(p * eyeRect.zw + eyeRect.xy) * (float(7 - ring) / 144.0);
    }
}

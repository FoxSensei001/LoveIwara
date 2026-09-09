#version 300 es
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
uniform samplerExternalOES source;
uniform sampler2D alphaMask;
uniform mat4 sourceTransform;
uniform vec4 profileDimensions;
uniform vec4 profileSettings;
uniform bool correctDisparity;
in vec2 uv;
out vec4 color;
void main() {
    vec2 sampleUv = uv;
    if (correctDisparity) {
        float eye = step(0.5, uv.x);
        sampleUv.x = clamp(uv.x + (1.0 - 2.0 * eye) * 0.01625 / (profileDimensions.z * profileDimensions.x),
            eye * 0.5, (eye + 1.0) * 0.5);
    }
    vec3 encoded = texture(source, (sourceTransform * vec4(sampleUv, 0.0, 1.0)).xy).rgb;
    float alpha = texture(alphaMask, uv).r;
    // Most pixels are opaque and pass through without colour conversions.
    // The feather is premultiplied in linear light, then stored as sRGB bytes.
    if (alpha < 1.0) {
        vec3 linear = mix(encoded / 12.92, pow((encoded + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), encoded)) * alpha;
        encoded = mix(linear * 12.92, 1.055 * pow(linear, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), linear));
    }
    color = vec4(encoded, alpha);
}

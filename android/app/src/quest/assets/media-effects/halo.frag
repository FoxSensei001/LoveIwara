#version 300 es
precision highp float;
uniform sampler2D source;
uniform vec4 profileDimensions;
uniform vec4 profileSettings;
in vec2 uv;
out vec4 color;
#include "media_profile.glsl"
void main() {
    // Concentrate radial samples around the feather, retaining the unbounded
    // rational tail. The scene shader uses the inverse mapping.
    float radial = uv.y * 2.0 - 1.0;
    float d = 0.25 * radial / (1.0 - abs(radial));
    vec3 profile = ambienceProfile(d, profileSettings.x, profileDimensions.w, profileSettings.y);
    // Align LUT texels with the 32-band sample centres. Otherwise interpolating
    // across a band knot introduces a first-order error at sharp colour changes.
    float bandOffset = 0.5 / float(textureSize(source, 0).x) - 0.5 * dFdx(uv.x);
    vec3 band = texture(source, vec2(uv.x + bandOffset, 0.5)).rgb;
    float brightness = 1.0 - 1.0 / (1.0 + 2.0 * min(band.r, band.g) + band.r + band.g);
    float alpha = profile.x * (1.0 - profile.y);
    vec3 linear = band * (1.0 - brightness * profile.z) * alpha;
    // SceneTexture is sRGB; encode RGB while leaving alpha linear.
    color = vec4(mix(linear * 12.92, 1.055 * pow(linear, vec3(1.0 / 2.4)) - 0.055,
        step(vec3(0.0031308), linear)), alpha);
}

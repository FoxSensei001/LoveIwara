#version 300 es
precision highp float;
uniform vec4 profileDimensions;
uniform vec4 profileSettings;
in vec2 uv;
out vec4 color;
#include "media_profile.glsl"
void main() {
    vec2 local = uv;
    if (profileSettings.z == 1.0) local.x = fract(local.x * 2.0);
    else if (profileSettings.z == 2.0) local.y = fract(local.y * 2.0);
    float d = profileSettings.w > 0.5
        ? -cos((local.x - 0.5) * 3.14159265359) * sin(local.y * 3.14159265359)
        : ambienceDistance((local - 0.5) * profileDimensions.xy, profileDimensions.xy * 0.5, profileDimensions.z);
    vec3 profile = ambienceProfile(d, profileSettings.x, profileDimensions.w, profileSettings.y);
    color = vec4(ambiencePictureAlpha(profile), 0.0, 0.0, 1.0);
}

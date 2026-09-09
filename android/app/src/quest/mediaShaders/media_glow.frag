#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#include <metaSpatialSdkFragmentBase.glsl>
#include <Uniforms.glsl>
#include "media_ambience.glsl"

void main() {
    vec4 stereo = g_MaterialUniform.stereoParams;
    vec2 meshUv = (vertexOut.albedoCoord - float(getStereoPassId()) * stereo.xy) / stereo.zw;
    vec2 uv = (meshUv - 0.5) * g_MaterialUniform.albedoFactor.xy + 0.5;
    float d = 0.0;
    if (g_MaterialUniform.emissiveFactor.w > 0.5) {
        float front = cos((meshUv.x - 0.5) * 6.28318530718) * sin(meshUv.y * 3.14159265359);
        d = -front;
        uv = vec2((meshUv.x - 0.5) * 2.0 + 0.5, meshUv.y);
    }
    outColor = mediaAmbience(uv, d);
}

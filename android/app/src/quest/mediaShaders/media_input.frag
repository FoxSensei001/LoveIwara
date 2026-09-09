#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#include <metaSpatialSdkFragmentBase.glsl>

// Input/resize geometry only. Its material disables colour and depth writes.
// Do not run the image/halo shader on this otherwise invisible panel.
void main() { outColor = vec4(0.0); }

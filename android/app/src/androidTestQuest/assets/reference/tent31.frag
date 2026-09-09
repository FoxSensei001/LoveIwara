#version 310 es
// Reference wide blur along the band: a 31-tap tent whose weights are
// (22 - |tap|) / 442. The band is one pixel tall, so y is fixed at its centre.
precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D source;

layout(location = 0) in vec2 uv;
layout(location = 0) out vec4 color;

const float TAP_STEP = 0.002;
const float WEIGHT_SCALE = 0.0022624435; // 1 / 442, the sum of (22 - |tap|)

void main() {
    color = vec4(0.0);
    for (int tap = -15; tap <= 15; ++tap) {
        float weight = float(22 - abs(tap)) * WEIGHT_SCALE;
        color += texture(source, vec2(uv.x + float(tap) * TAP_STEP, 0.5)) * weight;
    }
}

#version 310 es
// Reference nine-tap blur along the band. The weights are authored unnormalised
// and divided by their sum (3.56) at the end, so the centre tap stays legible.
precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D source;
uniform float texelWidth;

layout(location = 0) in vec2 uv;
layout(location = 0) out vec4 color;

const float NORMALISE = 0.28089887; // 1 / 3.56

void main() {
    float weights[9] = float[9](0.02, 0.06, 0.13, 0.34, 2.46, 0.34, 0.13, 0.06, 0.02);
    color = vec4(0.0);
    for (int tap = -4; tap <= 4; ++tap) {
        vec2 p = vec2(uv.x + float(tap) * texelWidth, 0.5);
        color += texture(source, p) * weights[tap + 4];
    }
    color *= NORMALISE;
}

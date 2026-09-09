#version 310 es
// Reference formulation of the screen-average pass, written straight from the
// equations rather than through the shipping source pipeline. A flat 16x16 grid
// over the whole picture, then a lift that opens up dark frames.
precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D source;

layout(location = 0) out vec4 color;

void main() {
    vec4 sum = vec4(0.0);
    for (int x = 0; x < 16; ++x) {
        for (int y = 0; y < 16; ++y) {
            sum += texture(source, vec2(float(x), float(y)) * 0.0625) * 0.0625;
        }
    }
    sum *= 0.0625;

    // Dark frames would otherwise light the room barely at all. The lift is
    // quadratic in the headroom left by the brightest channel.
    float headroom = 1.0 - max(sum.r, max(sum.g, sum.b));
    color = sum * (1.0 + 2.0 * headroom * headroom);
}

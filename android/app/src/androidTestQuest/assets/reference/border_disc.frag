#version 310 es
// Reference border sampler. uv.x walks the picture's perimeter once, inset by
// 0.06, and each step averages a four-ring, eight-direction disc of the left
// eye. Sampling a disc rather than a single texel is what keeps the band from
// crawling when the picture has fine detail near its edge.
precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D source;

layout(location = 0) in vec2 uv;
layout(location = 0) out vec4 color;

const float INSET = 0.06;
const float SPAN = 3.52;          // 0.88 of the picture per quarter turn
const float RING_STEP = 0.015;
const float ANGLE_STEP = 0.78539813;  // a quarter turn over the eight directions
const float ANGLE_BIAS = 0.44879895;  // rotated off-axis so no ring lines up
const float WEIGHT_SCALE = 0.0069444445; // 1 / 144, the sum of 8 * (6 + 5 + 4 + 3)

// Counter-clockwise from the bottom-left corner: left edge, top, right, bottom.
vec2 perimeter(float t) {
    if (t < 0.25) return vec2(INSET, t * SPAN + INSET);
    if (t < 0.50) return vec2(t * SPAN - 0.82, 1.0 - INSET);
    if (t < 0.75) return vec2(1.0 - INSET, 2.7 - t * SPAN);
    return vec2(3.58 - t * SPAN, INSET);
}

void main() {
    vec2 centre = perimeter(uv.x);
    color = vec4(0.0);
    for (int ring = 1; ring <= 4; ++ring) {
        // Inner rings carry more weight; the four of them sum to one.
        float weight = float(7 - ring) * WEIGHT_SCALE;
        for (int direction = 0; direction < 8; ++direction) {
            float angle = float(direction) * ANGLE_STEP + ANGLE_BIAS;
            vec2 p = centre + vec2(cos(angle), sin(angle)) * float(ring) * RING_STEP;
            // The source is side by side; the band is built from the left eye.
            color += texture(source, vec2(p.x * 0.5, p.y)) * weight;
        }
    }
}

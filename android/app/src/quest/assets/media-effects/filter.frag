#version 300 es
precision highp float;
uniform sampler2D source;
uniform sampler2D history;
uniform int operation;
in vec2 uv;
out vec4 color;
void main() {
    if (operation == 0) {
        color = texture(source, uv);
    } else if (operation == 1) {
        color = vec4(0.0);
        for (int tap = -15; tap <= 15; ++tap)
            color += texture(source, vec2(uv.x + float(tap) * 0.002, 0.5)) * (float(22 - abs(tap)) / 442.0);
    } else if (operation == 2) {
        const float weights[9] = float[9](0.02, 0.06, 0.13, 0.34, 2.46, 0.34, 0.13, 0.06, 0.02);
        color = vec4(0.0);
        for (int tap = -4; tap <= 4; ++tap)
            color += texture(source, vec2(uv.x + float(tap) / 64.0, 0.5)) * weights[tap + 4];
        color *= 0.28089886904;
    } else {
        color = texture(source, uv) * 0.75 + texture(history, uv) * 0.25;
    }
}

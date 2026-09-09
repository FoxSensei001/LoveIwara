#version 310 es
// Reference temporal filter: a quarter of the previous frame's band survives
// into this one, which is what stops the room flickering on hard cuts.
precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D source;
uniform sampler2D history;

layout(location = 0) in vec2 uv;
layout(location = 0) out vec4 color;

void main() {
    color = texture(source, uv) * 0.75 + texture(history, uv) * 0.25;
}

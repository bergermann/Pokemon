#version 460 core

uniform vec2 pos;
uniform vec2 scale;

layout(location=0) in vec2 coord;
layout(location=1) in vec2 texcoord;

out vec2 texCoord;

void main() {
    texCoord = texcoord;

    gl_Position = vec4((scale.x*coord.x+pos.x)/120,-(scale.y*coord.y+pos.y)/80,0.0,1.0);
}
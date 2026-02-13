#version 460 core

uniform vec2 pos;
uniform vec2 size;

layout(location=0) in vec2 coord;
layout(location=1) in vec2 texcoord;

out vec2 texCoord;

void main() {
    texCoord = texcoord;

    float dx = 8.0*(size.x-1.0)*float(coord.x >= 16.0);
    float dy = 8.0*(size.y-1.0)*float(coord.y >= 16.0);

    gl_Position = vec4((coord.x+dx+pos.x)/120,-(coord.y+dy+pos.y)/80,0.0,1.0);
}
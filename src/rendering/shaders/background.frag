#version 460 core

uniform sampler2D tex;
uniform vec4 color;

in vec2 texCoord;
out vec4 FragColor;

void main() {
    FragColor = color*texture(tex,texCoord);
    // FragColor = vec4(1.0,0.0,0.0,1.0);
}
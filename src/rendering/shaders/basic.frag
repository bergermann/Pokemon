#version 460 core

uniform sampler2D tex;

in vec2 texCoord;
out vec4 FragColor;

void main() {
    FragColor = texture(tex,texCoord);
    // FragColor = vec4(1.0,0.0,0.0,1.0);
}
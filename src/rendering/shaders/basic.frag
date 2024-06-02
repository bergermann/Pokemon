#version 330 core

uniform sampler2D tex;

in vec2 texCoord;
out vec4 FragColour;

void main() {
    FragColour = texture(tex,texCoord);
    // FragColour = vec4(1.0,0.0,0.0,1.0);
}
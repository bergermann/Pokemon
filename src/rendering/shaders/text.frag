#version 330 core

uniform mat3x4 colours;

uniform usampler2D font;

in vec2 texCoord;

out vec4 FragColour;

void main() {
    FragColour = colours[texture(font,texCoord)[0]];
    // FragColour = texture(font,texCoord);
    // FragColour = vec4(1.0,1.0,1.0,1.0);
}
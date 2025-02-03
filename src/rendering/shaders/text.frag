#version 330 core

uniform mat3x4 colors;

uniform usampler2D font;

in vec2 texCoord;

out vec4 FragColor;

void main() {
    FragColor = colors[texture(font,texCoord)[0]];
    // FragColor = texture(font,texCoord);
    // FragColor = vec4(1.0,1.0,1.0,1.0);
}
#version 330 core

uniform sampler2DArray tex;

in vec3 texCoord;
out vec4 FragColour;

void main() {
    FragColour = texture(tex,texCoord);
    // FragColour = vec4(vec3(gl_FragCoord.z),1.0);
    // FragColour = vec4(1.0,0.0,0.0,1.0);
}
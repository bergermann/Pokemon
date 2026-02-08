#version 460 core

uniform sampler2DArray tex;

in vec3 texCoord;
out vec4 FragColor;

void main() {
    FragColor = texture(tex,texCoord);
    // FragColor = vec4(vec3(gl_FragCoord.z),1.0);
    // FragColor = vec4(1.0,0.0,0.0,1.0);
}
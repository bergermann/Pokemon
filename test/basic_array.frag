#version 330 core
out vec4 FragColor;

in vec2 texCoord;

uniform sampler2DArray layers;

void main() {
    // FragColor = texture(tex,texCoord);
    // FragColor = vec4(vec3(gl_FragCoord.z),1.0);
    // FragColor = vec4(1.0,0.0,0.0,1.0);
    // vec4 c1;
    // vec4 c2;

    // c1 = texture(layers,vec3(texCoord,0.0));
    // c2 = texture(layers,vec3(texCoord,1.0));

    // FragColor = vec4(max(c1.r,c2.r),max(c1.g,c2.g),max(c1.b,c2.b),max(c1.a,c2.a));
    // FragColor = texture(layers,vec3(texCoord,2.0));
    FragColor = texture(layers,vec3(texCoord,1.0));
}
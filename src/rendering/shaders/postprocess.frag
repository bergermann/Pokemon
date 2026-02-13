#version 330 core

uniform sampler2DArray layers;
uniform vec4 colorw;
uniform vec4 colors;
uniform vec2 slider;

in vec2 texCoord;
out vec4 FragColor;

void main() {
    float alpha;
    vec4 c1;
    vec4 c2;

    c1 = texture(layers,vec3(texCoord,0.0));

    c2 = texture(layers,vec3(texCoord,1.0));
    alpha = max(0.0000000000001,c2.a + c1.a*(1.0-c2.a));
    c1.rgb = (c2.rgb*c2.a+c1.rgb*c1.a*(1.0-c2.a))/alpha; c1.a = alpha;

    c2 = texture(layers,vec3(texCoord,2.0));
    alpha = max(0.0000000000001,c2.a + c1.a*(1.0-c2.a));
    c1.rgb = (c2.rgb*c2.a+c1.rgb*c1.a*(1.0-c2.a))/alpha; c1.a = alpha;

    c2 = texture(layers,vec3(texCoord,3.0));
    alpha = max(0.0000000000001,c2.a + c1.a*(1.0-c2.a));
    c1.rgb = (c2.rgb*c2.a+c1.rgb*c1.a*(1.0-c2.a))/alpha; c1.a = alpha;

    c2 = texture(layers,vec3(texCoord,4.0));
    alpha = max(0.0000000000001,c2.a + c1.a*(1.0-c2.a));
    c1.rgb = (c2.rgb*c2.a+c1.rgb*c1.a*(1.0-c2.a))/alpha; c1.a = alpha;

    c2 = texture(layers,vec3(texCoord,5.0));
    alpha = max(0.0000000000001,c2.a + c1.a*(1.0-c2.a));
    c1.rgb = (c2.rgb*c2.a+c1.rgb*c1.a*(1.0-c2.a))/alpha; c1.a = alpha;

    // FragColor = vec4(colors.a*(colors.rgb*c1.rgb),c1.a);
    alpha = max(0.0000000000001,colorw.a + c1.a*(1.0-colorw.a));
    FragColor = vec4(
        colors.a*colors.rgb*(colorw.rgb*colorw.a+c1.rgb*c1.a*(1.0-colorw.a))/alpha,
        alpha
    );
}
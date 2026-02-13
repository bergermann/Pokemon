#version 460 core

uniform mat4 projection1;
uniform mat4 projection2;

in VS_OUT {
    uint tile;
} gs_in[];

out vec3 texCoord;

layout (points) in;
layout (triangle_strip,max_vertices=4) out;

void main() {
    uint tile = gs_in[0].tile;
    int z = int(6.0*gl_in[0].gl_Position.z);
    
    gl_Layer = z;
    gl_Position = projection2*projection1*(gl_in[0].gl_Position+vec4(0.0,0.0,0.0,0.0));
    texCoord = vec3(0.0,0.0,tile);
    EmitVertex();

    gl_Layer = z;
    gl_Position = projection2*projection1*(gl_in[0].gl_Position+vec4(1.0,0.0,0.0,0.0));
    texCoord = vec3(1.0,0.0,tile);
    EmitVertex();

    gl_Layer = z;
    gl_Position = projection2*projection1*(gl_in[0].gl_Position+vec4(0.0,1.0,0.0,0.0));
    texCoord = vec3(0.0,1.0,tile);
    EmitVertex();

    gl_Layer = z;
    gl_Position = projection2*projection1*(gl_in[0].gl_Position+vec4(1.0,1.0,0.0,0.0));
    texCoord = vec3(1.0,1.0,tile);
    EmitVertex();

    EndPrimitive();
}
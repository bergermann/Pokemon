#version 460 core

uniform uvec2 size;

in VS_OUT {
    uint texlayer;
    vec2 scale;
    float rot;
    float alpha;
    uvec2 rev;
} gs_in[];

out vec3 texCoord;

layout (points) in; 
layout (triangle_strip,max_vertices=4) out;

void main()
{
    uint tex = gs_in[0].texlayer;
    uvec2 rev = gs_in[0].rev;
    vec2 s = gs_in[0].scale;

    // mat4 R;
    float r = radians(gs_in[0].rot);
    mat2 R; R[0][0] = cos(r); R[1][1] = cos(r); R[0][1] = -sin(r); R[1][0] = sin(r);
    mat2 S; S[0][0] = size.x*s.x/240.0; S[1][1] = size.y*s.y/160.0;

    vec2 p0 = vec2(gl_in[0].gl_Position.x/120.,gl_in[0].gl_Position.y/80.);
    int z = int(6.0*gl_in[0].gl_Position.z);
    
    vec2 p1 = S*R*vec2(-1.0, 1.0)+p0;
    vec2 p2 = S*R*vec2( 1.0, 1.0)+p0;
    vec2 p3 = S*R*vec2(-1.0,-1.0)+p0;
    vec2 p4 = S*R*vec2( 1.0,-1.0)+p0;

    gl_Layer = z;
    gl_Position = vec4(p1.x,p1.y,0.0,1.0);
    texCoord = vec3(0.0+1.0*rev[0],0.0+1.0*rev[1],tex);
    // texCoord = vec3(0.0,0.0,tex);
    EmitVertex();
    
    gl_Layer = z;
    gl_Position = vec4(p2.x,p2.y,0.0,1.0);
    texCoord = vec3(1.0-1.0*rev[0],0.0+1.0*rev[1],tex);
    // texCoord = vec3(1.0,0.0,tex);
    EmitVertex();

    gl_Layer = z;
    gl_Position = vec4(p3.x,p3.y,0.0,1.0);
    texCoord = vec3(0.0+1.0*rev[0],1.0-1.0*rev[1],tex);
    // texCoord = vec3(0.0,1.0,tex);
    EmitVertex();

    gl_Layer = z;
    gl_Position = vec4(p4.x,p4.y,0.0,1.0);
    texCoord = vec3(1.0-1.0*rev[0],1.0-1.0*rev[1],tex);
    // texCoord = vec3(1.0,1.0,tex);
    EmitVertex();

    EndPrimitive();
}

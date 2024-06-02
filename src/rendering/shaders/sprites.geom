#version 330 core

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

    // mat4 R;
    // float r = radians(gs_in[0].rot);
    // R[0][0] = cos(r); R[1][1] = cos(r); R[0][1] = -sin(r); R[1][0] = sin(r);
    // R[2][2] = 1.0; R[3][3] = 1.0; 

    vec2 p0 = gl_in[0].gl_Position.xy;
    int z = int(6.0*gl_in[0].gl_Position.z);
    
    // probably should put actual matrix calcs here
    vec2 p1 = vec2((p0.x-size.x/2.0)/120,(p0.y+size.y/2.0)/80);
    vec2 p2 = vec2((p0.x+size.x/2.0)/120,(p0.y+size.y/2.0)/80);
    vec2 p3 = vec2((p0.x-size.x/2.0)/120,(p0.y-size.y/2.0)/80);
    vec2 p4 = vec2((p0.x+size.x/2.0)/120,(p0.y-size.y/2.0)/80);

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

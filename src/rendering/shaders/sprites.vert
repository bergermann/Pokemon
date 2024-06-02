#version 330 core

uniform uvec2 size;

layout (location = 0) in uvec2 idx; // id + frame offset 
layout (location = 1) in ivec4 position; // position.xy, position.z, layer
layout (location = 2) in vec2 scale; // wscale, hscale
layout (location = 3) in float rot; 
layout (location = 4) in float alpha;
layout (location = 5) in uvec2 rev; // wrev, hrev
layout (location = 6) in uint active;

out VS_OUT {
    uint texlayer;
    vec2 scale;
    float rot;
    float alpha;
    uvec2 rev;
} vs_out;

void main()
{
    vs_out.texlayer = active*(idx.x+idx.y-uint(1));
    vs_out.scale = scale;
    vs_out.rev = rev;
    vs_out.rot = rot;

    float z = float(position.w-1.0)/6.0;

    gl_Position = vec4(position.xy,z,1.0);
}
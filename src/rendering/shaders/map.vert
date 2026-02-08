#version 460 core

uniform uint frame;
uniform int r;

uniform isamplerBuffer idxs;
uniform isamplerBuffer animdata;

layout(location=0) in uint tile;

out VS_OUT {
    uint tile;
} vs_out;

void main() {
    uint anim = uint(texelFetch(animdata,int(tile))[0]);
    uint ntiles  =  anim & uint(0x000000ff);
    uint nframes = (anim & uint(0x0000ff00)) >> 8;
    uint xoffset = (anim & uint(0x00ff0000)) >> 16;
    uint yoffset = (anim & uint(0xff000000)) >> 24;

    uint tileoffset = (frame/nframes)%ntiles;

    int it = gl_VertexID % 256;
    float il = float((gl_VertexID % 1280)/256);
    int ic = gl_VertexID/1280;
    int cidx = texelFetch(idxs,ic)[0]-1;

    int x = it >> 4;
    int y = it & 15;

    int cx = cidx / r;
    int cy = cidx % r;

    gl_Position = vec4(x+16*(cx-(r-1)/2)+0.5,
                       y+16*(cy-(r-1)/2)+0.5,
                       il/6.0,1.0);

    vs_out.tile = tile+tileoffset;
}
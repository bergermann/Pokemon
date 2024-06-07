

mutable struct Background
    vao::UInt32
    vbo::UInt32

    tex::UInt32

    pos::MVector{3,Float32}
    scale::MVector{2,Float32}

    active::Bool

    function Background(x,y,l,sx=1,sy=1; active=true)
        vao = UInt32[0]; glGenVertexArrays(1,pointer(vao))
        vbo = UInt32[0]; glGenBuffers(1,pointer(vbo))
        tex = UInt32[0]; glGenTextures(1,pointer(tex))

        new(vao[1],vbo[1],tex[1],Float32[x,y,l],Float32[sx,sy],active)
    end
end

mutable struct Backgrounds
    backgrounds::Dict{Symbol,Background}

    ulocpos::Int32
    ulocscale::Int32

    function Backgrounds()
        new(Dict(),0,0)
    end
end

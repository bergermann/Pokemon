
mutable struct Frames
    vao::UInt32
    vbo::UInt32
    ebo::UInt32

    frames::Dict{Symbol,Tuple{Bool,MVector{5,Float32}}}

    frameid::Int

    ulocpos::Int32
    ulocsize::Int32

    function Frames()
        vao = UInt32[0]; glGenVertexArrays(1,pointer(vao))
        vbo = UInt32[0]; glGenBuffers(1,pointer(vbo))
        ebo = UInt32[0]; glGenBuffers(1,pointer(ebo))

        new(vao[1],vbo[1],ebo[1],Dict(),1,0,0)
    end
end

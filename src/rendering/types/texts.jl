

struct Font
    chars::Dict{Char,Tuple{UInt8,UInt8,UInt8}}

    charheight::Int
    imsize::Position
end

mutable struct Text
    vao::UInt32
    vbo::UInt32

    active::Bool
    pos::MVector{3,Float32}
    font::Int
    maxchar::Int
    nchar::Int
    wpad::Int
    hpad::Int

    colours::MMatrix{4,3,Float32}

    function Text(active,x,y,layer,font,maxchar,nchar,wpad,hpad)
        vao = UInt32[0]; glGenVertexArrays(1,pointer(vao))
        vbo = UInt32[0]; glGenBuffers(1,pointer(vbo))

        new(vao[1],vbo[1],active,[x,y,layer],font,maxchar,nchar,wpad,hpad,
            MMatrix{4,3,Float32}(undef))
    end
end

mutable struct Texts
    texs::MVector{4,UInt32}

    fonts::Vector{Font}

    texts::Dict{Symbol,Text}

    ulocpos::Int32
    uloccolours::Int32

    function Texts()
        texs = zeros(UInt32,4); glGenTextures(4,pointer(texs))

        new(texs,[],Dict(),0,0)
    end
end
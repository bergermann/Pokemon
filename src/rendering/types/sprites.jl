
mutable struct Sprite
    sheet::Symbol
    slot::UInt64
end

mutable struct SpriteSheet
    maxsprites::Int
    size::Vector{UInt32}
    nframes::UInt8

    vao::UInt32
    vbo::UInt32

    idx::Matrix{UInt32}     # 2 x n #  8 #  0
    pos::Matrix{Int32}      # 4 x n # 16 #  8
    scale::Matrix{Float32}  # 2 x n #  8 # 24
    rot::Matrix{Float32}    # 1 x n #  4 # 32
    alpha::Matrix{Float32}  # 1 x n #  4 # 36
    rev::Matrix{Bool}       # 2 x n #  2 # 40
    active::Matrix{Bool}    # 1 x n #  1 # 42

    slots::BitVector

    function SpriteSheet(width,height,nframes,maxsprites=128)
        vao = UInt32[0]; glGenVertexArrays(1,pointer(vao))
        vbo = UInt32[0]; glGenBuffers(1,pointer(vbo))

        new(
            maxsprites,
            UInt32[width,height],
            nframes,
            
            vao[1],
            vbo[1],

            zeros( UInt32,2,maxsprites),
            zeros(  Int32,4,maxsprites),
            zeros(Float32,2,maxsprites),
            zeros(Float32,1,maxsprites),
            zeros(Float32,1,maxsprites),
            zeros(   Bool,2,maxsprites),
            zeros(   Bool,1,maxsprites),

            falses(maxsprites)
        )
    end
end

mutable struct Sprites
    sprites::Dict{Symbol,Sprite}
    sheets::Dict{Symbol,SpriteSheet}

    ulocsize::Int32

    function Sprites()
        new(Dict(),Dict(),0)
    end
end


const Image = Matrix{UInt8}

const Palette = Vector{UInt32}

# const Palette{N} = NTuple{N,UInt32}

mutable struct ImageP
    im::Image
    palette::Palette
end



mutable struct Sprite
    id::Symbol

    active::Bool

    hreverse::Bool
    vreverse::Bool

    pos::Position
    size::Position

    frame::Int
    dict::Dict{Int,Image}
    palette::Palette

    im::Image

    colortransform::CallbackFunction
    shapetransform::CallbackFunction

    function Sprite()
        new(
            Symbol(),

            false,

            false,
            false,

            Position(0,0),
            Position(0,0),

            0,
            Dict{Int,Image}(),
            Palette(),

            zeros(UInt8,0,0),

            CallbackFunction(),
            CallbackFunction()
        )
    end

    function Sprite(id,active,hreverse,vreverse,pos,size,frame,dict,
            palette,im,colortransform,shapetransform)
        new(id,active,hreverse,vreverse,pos,size,frame,dict,
            palette,im,colortransform,shapetransform)
    end

    function Sprite(id,pos,dict,palette)
        new(id,true,false,false,pos,Position(0,0),0,dict,palette,
            zeros(UInt8,0,0),emptyCallback,emptyCallback)
    end
end


# mutable struct Layer
#     layer::Matrix{UInt32}
#     active::Bool
#     offset::Position

#     function Layer(layer)
#         new(layer,true,Position(0,0))
#     end

#     function Layer(layer,active,offset)
#         new(layer,active,offset)
#     end
# end

# mutable struct Layers
#     water::Matrix{UInt32}
#     layer1::Matrix{UInt32}
#     layer2::Matrix{UInt32}
#     layer3::Matrix{UInt32}
#     layer4::Matrix{UInt32}
#     layer5::Matrix{UInt32} #text?
#     layer6::Matrix{UInt32}

#     textbox::Matrix{UInt32}    

#     function Layers(; s=Settings())
#         new([zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
#             UInt16(s.Nw)*UInt16(s.tilesize)) for _ in eachindex(fieldnames(Layers))]...)
#     end
# end

mutable struct Font
    fonts::Tuple{Dict,Dict,Dict}
    heights::Tuple{UInt,UInt,UInt}
    h_::UInt
    w_::UInt
    h::UInt
    w::UInt
    char::Matrix{UInt32}

    function Font()
        new(getFont(),(12,15,14),12,5,0,0,zeros(UInt32,15,5))
    end
end

mutable struct Im
    font::Font
    frame::ImageP
    diabox::ImageP

    tiles::Dict{UInt16,Matrix{UInt32}}
    tilesets::BitVector
    animated::Vector
    tile::Matrix{UInt32}

    sprites::Vector{ArrayList{Sprite}}

    active::BitVector
    layers::Vector{Matrix{UInt32}}
    layer::Matrix{UInt32}

    weather::CallbackFunction
    postprocess::CallbackFunction

    function Im()
        new(
            Font(),
            loadFrame(1),
            loadDialogue(2),
            
            Dict{UInt16,Matrix{UInt32}}(),
            falses(64),
            [],
            zeros(UInt32,16,16),

            [ArrayList(Sprite,64) for _ in 1:6],

            falses(6),

            [zeros(UInt32,208,272) for _ in 1:6],
            zeros(UInt32,208,272),

            CallbackFunction(:weather,false,empty,()),
            CallbackFunction(:pp,false,empty,())
        )
    end
end





mutable struct DrawState
    map::Bool

    menu1::Bool

    pdex::Bool
    dexinfo::Bool

    pkmn::Bool
    pkmninfo::Bool

    bags::Bool

    pnav::Bool
    pnavinfo::Bool

    self::Bool

    save::Bool

    optn::Bool

    dialogue::Bool

    battleintro::Bool
    battleoutro::Bool
    battle::Bool
    battle1::Bool
    battle2::Bool
    battled::Bool

    worldmap::Bool

    sprites::Bool

    function DrawState()
        new([false for _ in eachindex(fieldnames(DrawState))]...)
    end
end






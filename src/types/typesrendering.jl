

const Palette{N} = NTuple{N,UInt32}

const Image = Matrix{UInt8}

mutable struct ImageP
    im::Image
    palette::Palette
end
    




mutable struct Layer
    layer::Matrix{UInt32}
    active::Bool
    offset::Position

    function Layer(layer)
        new(layer,true,Position(0,0))
    end

    function Layer(layer,active,offset)
        new(layer,active,offset)
    end
end

mutable struct Layers
    water::Matrix{UInt32}
    layer1::Matrix{UInt32}
    layer2::Matrix{UInt32}
    layer3::Matrix{UInt32}
    layer4::Matrix{UInt32}
    layer5::Matrix{UInt32} #text?
    layer6::Matrix{UInt32}

    textbox::Matrix{UInt32}    

    function Layers(; s::Settings=Settings())
        new([zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
            UInt16(s.Nw)*UInt16(s.tilesize)) for _ in eachindex(fieldnames(Layers))]...)
    end
end

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

mutable struct Frame
    frame::Dict{Int,Dict{Int,Matrix{UInt32}}}
end

mutable struct Im
    font::Font
    frame::Dict{Int,Matrix{UInt32}}
    diabox::Dict

    tilesext::Dict
    tilesint::Dict
    tile::Matrix{UInt32}

    sprites::ArrayList{Sprite}

    L::Vector{Symbol}

    layers::Layers
    layer::Matrix{UInt32}

    weather::CallbackFunction
    postprocess::CallbackFunction

    function Im()
        new(
            Font(),
            getFrame(1),
            getDialogueBox("dialogue"),
            
            getTiles("tiles_exterior"),
            Dict(),
            zeros(UInt32,16,16),

            ArrayList(Sprite,128),

            [:layer1,:layer2,:layer3,:layer4,:layer5,:layer6,:textbox],

            Layers(),
            copy(Layers().layer1),

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






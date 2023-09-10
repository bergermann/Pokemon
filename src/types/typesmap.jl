



mutable struct TileMap
    water::Matrix{UInt16}
    layer1::Matrix{UInt16}
    layer2::Matrix{UInt16}
    layer3::Matrix{UInt16}
    layer4::Matrix{UInt16}
    
    collision::Matrix{UInt16}

    function TileMap(; s::Settings=Settings())
        new([zeros(UInt32,s.Nh,s.Nw) for _ in eachindex(fieldnames(TileMap))]...)
    end
end

mutable struct Exit
    targetid::UInt8

    transition::UInt8

    transform::Position
    absolute::Bool

    callback::CallbackFunction

    function Exit()
        new(0x00,0x00,P(0,0),false,emptyCallback)
    end

    function Exit(targetid,transition,transform,absolute,callback)
        new(targetid,transition,transform,absolute,callback)
    end
end

mutable struct Neighbour
    id::UInt8
    offset::Position
end

mutable struct Map
    id::UInt8
    environment::Vector{Symbol}

    exits::Vector{Exit}
    tileset::String
    tilemap::TileMap
    
    neighbours::Vector{Neighbour}

    function Map(id::UInt8)
        new(
            id,                                                             # id
            [:layer1,:layer2,:layer3,:layer4],                              # env

            [],                                                             # exits
            "tiles_exterior",                                               # tiles
            getTileMap("$id",[:layer1,:layer2,:layer3,:layer4,:collision]), # tilemap

            []                                                              # neighbours
        )
    end

    function Map(id,environment,exits,tileset,tilemap,neighbours)
        new(id,environment,exits,tileset,tilemap,neighbours)
    end
end

mutable struct Maps
    map::Map
    neighbours::Vector{Map}
end
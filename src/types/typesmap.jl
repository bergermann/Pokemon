



mutable struct Exit
    targetid::UInt8

    transition::UInt8
    # 0x00 -> open map, none 
    # 0x01 -> building, fade out, fade in
    # 0x02 -> cave, fade out, bright fade in?

    transform::Position
    dir::Int
    absolute::Bool

    callback::CallbackFunction

    function Exit()
        new(0x00,0x00,P(0,0),0,false,CallbackFunction())
    end

    function Exit(targetid,transition,transform,dir,absolute,callback::Function)
        new(targetid,transition,transform,dir,absolute,CallbackFunction(callback))
    end

    function Exit(targetid,transition,transform,dir,absolute,
            callback::CallbackFunction)
        new(targetid,transition,transform,dir,absolute,callback)
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

    events::Vector{Event}

    function Map(id::UInt8)
        new(
            id,                                                             # id
            [:layer1,:layer2,:layer3,:layer4],                              # env

            [],                                                             # exits
            "tiles_exterior",                                               # tiles
            getTileMap("$id",[:layer1,:layer2,:layer3,:layer4,:collision]), # tilemap

            [],                                                             # neighbours

            []
        )
    end

    function Map(id,environment,exits,tileset,tilemap,neighbours,events)
        new(id,environment,exits,tileset,tilemap,neighbours,events)
    end
end

mutable struct Maps
    map::Map
    neighbours::Vector{NamedTuple{(:map,:offset),Tuple{Map,Position}}}
end



mutable struct TileMap
    map::Vector{Matrix{UInt16}}
    collision::Matrix{UInt8}
    height::Matrix{UInt8}

    tilesets::Vector{Bool}

    function TileMap(h::Integer,w::Integer)
        new(
            [zeros(UInt32,h,w) for _ in 1:5],
            zeros(UInt8,h,w),
            zeros(UInt8,h,w),
            fill(false,64)
        )
    end
end



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
    weather::UInt8

    exits::Vector{Exit}
    tilemap::TileMap
    
    neighbours::Vector{Neighbour}

    events::Vector{Event}

    function Map(id::UInt8)
        new(
            id,                                                  # id
            0x00,                                                # weather

            [],                                                  # exits
            getTileMap(id),                                      # tilemap

            [],                                                  # neighbours

            []                                                   # events
        )
    end

    function Map(id,weather,exits,tilemap,neighbours,events)
        new(id,weather,exits,tilemap,neighbours,events)
    end
end

mutable struct Maps
    map::Map
    neighbours::Vector{NamedTuple{(:map,:offset),Tuple{Map,Position}}}
end
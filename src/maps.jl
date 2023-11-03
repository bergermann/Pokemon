
function loadMap(game::GameState)
    # replace the map dict with these two functions
end

function getMap(id::UInt8)
    if game.maps.map.id == id
        return game.maps.map
    end

    idx = findfirst(x.id==id,game.maps.neighbours)

    if !isnothing(idx)
        return game.maps.neighbours[idx].map
    end

    return maps[id]
    # replace the map dict with these two functions
end

function getMap(game::GameState,id::UInt8)
    if game.maps.map.id == id
        return game.maps.map
    end

    idx = findfirst(x.id==id,game.maps.neighbours)

    if !isnothing(idx)
        return game.maps.neighbours[idx].map
    end
end



function getMaps(id::UInt8)
    map = maps[id]

    return Maps(map,[(map=maps[n.id],offset=n.offset) for n in map.neighbours])
end



function setNeighbours!(game)
    n = game.maps.map.neighbours
    n_ = game.maps.neighbours

    idstarget = (x->x.id).(n)
    idsstate = (x->x.map.id).(n_)

    for i in eachindex(idstarget)
        if !(idstarget[i] in idsstate)
            push!(n_,(
                map=getMap(idstarget[i]),
                offset=n[i].offset
            ))
        end
    end

    game.maps.neighbours = game.maps.neighbours[
        (x->findfirst(y->y.map.id==x.id,game.maps.neighbours)).(game.maps.map.neighbours)
    ]
end



function checkMapExit!(game::GameState,movepos::Position)
    println("Checking map exit")

    col = game.maps.map.tilemap.collision[movepos.h,movepos.w]

    if col ∈ 0x14:0x3b
        println("Exiting map at exit $(col-0x13).")
        return game.maps.map.exits[col-0x13]
    end
end



function enterMap!(game::GameState,exit::Exit)
    mapidx = findfirst(x->x.id==exit.targetid,
        game.maps.neighbours)

    if isnothing(mapidx)
        game.maps = getMaps(exit.targetid)

        return
    end

    game.maps.map = game.maps.neighbours[
            findfirst(x->x.id==exit.targetid,
                game.maps.neighbours)
        ]

    setNeighbours!(game)
end




map0 = Map(
    0x00,
    [:layer1,:layer2,:layer3,:layer4],
    [
        Exit(0x03,0x01,P(0,0),true,emptyCallback),
        Exit(0x03,0x01,P(0,0),true,emptyCallback),
        Exit(0x03,0x01,P(0,0),true,emptyCallback),
        Exit(0x01,0x00,P(100,16),false,emptyCallback)
    ],
    "tiles_exterior",
    getTileMap("0",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [Neighbour(0x01,P(-120,-28))]
)


map1 = Map(
    0x01,
    [:layer1,:layer2,:layer3,:layer4],
    [
        Exit(0x00,0x00,P(-112,-28),false,emptyCallback),
        Exit(0x02,0x01,P(0,0),true,emptyCallback),
    ],
    "tiles_exterior",
    getTileMap("1",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [Neighbour(0x00,P(120,28))]
)

maps = Base.ImmutableDict(
    0x00 => map0,
    0x01 => map1
)



















function loadMap(game::GameState)
    # replace the map dict with these two functions
end

function getMap(id::UInt8)
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

    return getMap(id)
end



function getMaps(id::UInt8)
    map = getMap(id)

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
    col = game.maps.map.tilemap.collision[movepos.h,movepos.w]

    if col ∉ 0x14:0x3b
        return
    end
    
    # print("Exiting map $(game.maps.map.id) at exit $(col-0x13)")

    exitMap!(game,game.maps.map.exits[col-0x13])

    return
end



function exitMap!(game::GameState,exit::Exit)
    if exit.transition == 0x01
        game.input.inputlock = true

        createCC!(game,:scenet,sceneTransition!,(16,8,
            stateMapTransition!,(exit,),x->x.input.inputlock=false,());
            active=true,n=1)

        return
    end

    enterMap!(game,exit)

    return
end

function enterMap!(game::GameState,exit::Exit)
    if game.maps.map.id != exit.targetid
        mapidx = findfirst(x->x.map.id==exit.targetid,
            game.maps.neighbours)

        if isnothing(mapidx)
            game.maps = getMaps(exit.targetid)
        else
            game.maps.map = game.maps.neighbours[mapidx].map
        end
    end

    if exit.absolute
        println("overwriting position with ",exit.transform)
        game.pos = copy(exit.transform)

        if exit.dir != 0
            game.direction = exit.dir
        end
    else
        posAdd!(game.pos,exit.transform)
    end

    resetMovePos!(game)
    
    setNeighbours!(game)

    loadMapStrings!(game; reset=false)

    game.flags.general[0xc8] = false

    # setMapSpecials!(game)

    return
end

function setMapSpecials(game::GameState)
    if 0xc8 <= game.maps.map.id <= 0xdc
        loadStaticNPC!(game,[200,P(8,3),2,200,:heal,0,0,0,0,0])
    end
end




map0 = Map(
    0x00,
    [:layer1,:layer2,:layer3,:layer4],
    [
        Exit(0x01,0x00,P(118,28),0,false,emptyCallback),
        Exit(0x03,0x01,P(0,0),0,true,emptyCallback),
        Exit(0x03,0x01,P(0,0),0,true,emptyCallback),
        Exit(0x03,0x01,P(0,0),0,true,emptyCallback),
    ],
    "tiles_exterior",
    getTileMap("0",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [Neighbour(0x01,P(118,28))],
    []
)


map1 = Map(
    0x01,
    [:layer1,:layer2,:layer3,:layer4],
    [
        Exit(0x00,0x00,P(-118,-28),0,false,emptyCallback),
        Exit(0xc8,0x01,P(9,8),1,true,emptyCallback),
    ],
    "tiles_exterior",
    getTileMap("1",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [Neighbour(0x00,P(-118,-28))],
    []
)

map200 = Map(
    0xc8,
    [:layer1,:layer2,:layer3,:layer4],
    [
        Exit(0x01,0x01,P(107,44),2,true,emptyCallback),
        Exit(0xc8,0x01,P(7,24),4,true,emptyCallback),
        Exit(0xc8,0x01,P(7,2),4,true,emptyCallback),
    ],
    "tiles_interior1",
    getTileMap("200",[:layer1,:layer2,:layer3,:layer4,:collision]),
    [],
    [
        Event(0xc8,(0xc8,),(false,),(:general,),(),(),true,1),
    ]
)

maps = Base.ImmutableDict(
    0x00 => map0,
    0x01 => map1,
    0xc8 => map200,
)


















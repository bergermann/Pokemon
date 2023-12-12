
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
    loadTiles!(game)

    game.flags.general[0xc8] = false

    # setMapSpecials!(game)

    return
end

function setMapSpecials(game::GameState)
    if 0xc8 <= game.maps.map.id <= 0xdc
        loadStaticNPC!(game,[200,P(8,3),2,200,:heal,0,0,0,0,0])
    end
end






const map1 = Map(
    0x01,
    0x00,
    [
        Exit(0x02,0x00,P(1-39,18-26),0,false,emptyCallback),
        Exit(0xc8,0x01,P(9,8),1,true,emptyCallback),
    ],
    getTileMap(0x01),
    [Neighbour(0x02,P(1-39,18-26))],
    []
)

const map2 = Map(
    0x02,
    0x00,
    [
        Exit(0x01,0x00,P(39-1,26-18),0,false,emptyCallback),
        Exit(0x03,0x01,P(0,0),0,true,emptyCallback),
        Exit(0x03,0x01,P(0,0),0,true,emptyCallback),
        Exit(0x03,0x01,P(0,0),0,true,emptyCallback),
    ],
    getTileMap(0x02),
    [Neighbour(0x01,P(39-1,26-18))],
    []
)

const map200 = Map(
    0xc8,
    0x00,
    [
        Exit(0x01,0x01,P(25,29),2,true,emptyCallback),
        Exit(0xc8,0x01,P(7,24),4,true,emptyCallback),
        Exit(0xc8,0x01,P(7,2),4,true,emptyCallback),
    ],
    getTileMap(0xc8),
    [],
    [
        Event(0xc8,(),(),(:general,),(),(),true,1),
    ]
)

const maps = Base.ImmutableDict(
    0x01 => map1,
    0x02 => map2,
    0xc8 => map200,
)


















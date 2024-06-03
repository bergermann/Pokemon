
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




















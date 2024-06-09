





const walkable::Vector{UInt16} = [0x0000,0x0005,0x00006,0x00007]
const bikeable::Vector{UInt16} = [0x0000,0x0005,0x00006]
const swimmable::Vector{UInt16} = [0x0002,0x0003]

function checkWalkable(game::GameState,movepos::Position)
    for i in 1:game.npcstatic.idx
        if isequal(game.npcstatic[i].pos,movepos)
            return false
        end
    end

    for i in 1:game.npcmove.idx
        if isequal(game.npcmove[i].pos,movepos)
            return false
        end
    end

    return |(game.maps.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable,
        (0x14 <= game.maps.map.tilemap.collision[movepos.h,movepos.w] <= 0x3b),
        (0xa0 <= game.maps.map.tilemap.collision[movepos.h,movepos.w] <= 0xb3),
        (0xc8 <= game.maps.map.tilemap.collision[movepos.h,movepos.w] <= 0xdb))
end

function updateMovePos!(game::GameState,dir::Int)
    game.movepos.h = game.pos.h+dirs[dir].h
    game.movepos.w = game.pos.w+dirs[dir].w

    return
end

function resetMovePos!(game::GameState)
    game.movepos = posAdd(game.pos,dirs[game.direction])

    return
end

function checkEncounter!(game::GameState)
    if !(game.maps.map.tilemap.collision[game.pos.h,game.pos.w] == 0x06)
        return
    end

    if rand(0x00:0xff) > 0x80
        return
    end

    game.callbacks[:movemain].active = true
    game.callbacks[:movemain].args = (game.direction,-1)

    initBattleWild!(game)

    return
end

function moveMain!(game::GameState,dir::Int,type::Int)
    if type == -1
        moveStop!(game,dir)
    elseif type == 0
        moveTurn!(game,dir)
    elseif type == 1
        moveWalk!(game,dir)
    elseif type == 2
        moveRun!(game,dir)
    elseif type == 3
        moveWalkWall!(game,dir)
    end

    return
end




function inputMap!(game::GameState,inputs::Inputs)
    if game.ctrl.move
        inputMove!(game,inputs)
    end

    if game.ctrl.move && inputs.start.press
        game.ctrl.move = false
        game.ctrl.map = false
        game.ctrl.menu.main = true

        game.im.f.frames[:menu].active = true
        game.im.text.texts[:menu].active = true
        switchSprite!(game,:cursor)
        return
    end

    if game.ctrl.move && inputs.A.press
        mapAction!(game)
    end

    return
end

function inputMove!(game::GameState,inputs::Inputs)
    if !(inputs.up.press || inputs.down.press || inputs.left.press || inputs.right.press)
        if game.n[:movemain].c != 0
            game.callbacks[:movemain].active = true
            game.callbacks[:movemain].args = (game.ctrl.dir,-1)
        end

        return
    end

    dir = finddir(inputs)
    
    updateMovePos!(game,dir)

    if !checkWalkable(game,game.ctrl.movepos)
        if game.n.c[:movemain].c == 0
            game.callbacks[:movemain].active = true
            game.callbacks[:movemain].args = (game.ctrl.dir,3)
        end

        return
    end

    checkTeleport!(game,game.ctrl.movepos)

    game.n[:movemain].c = 0

    game.callbacks[:movemain].active = true
    game.ctrl.move = false

    if !input.B.hold
        if game.ctrl.dir == dir
            game.callbacks[:movemain].args = (game.ctrl.dir,1)
        else
            game.ctrl.dir = dir
            game.callbacks[:movemain].args = (game.ctrl.dir,0)
        end
    else
        game.ctrl.dir = dir
        game.callbacks[:movemain].args = (game.ctrl.dir,2)
    end

    return
end

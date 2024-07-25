


function getCollision(game::GameState,movepos::Position,l::Int)
    return game.m.chunkdata[game.m.idxs[
            game.im.c.renderdistance+1+modc.(movepos[1]),
            game.im.c.renderdistance+1+modc.(movepos[2])]
        ].collision[movepos[1],movepos[2],l]
end


const walkable::Vector{UInt16} = [0x0000,0x0005,0x00006,0x00007]
const bikeable::Vector{UInt16} = [0x0000,0x0005,0x00006]
const swimmable::Vector{UInt16} = [0x0002,0x0003]

function checkWalkable(game::GameState,movepos::Position,l::Int)
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

    col = getCollision(game,movepos,l)

    return |(col ∈ walkable,
        (0x14 <= col <= 0x3b),
        (0xa0 <= col <= 0xb3),
        (0xc8 <= col <= 0xdb))
end

function checkEncounter!(game::GameState)
    if !(game.m.chunkdata[game.m.idxs[r+1,r+1]].collision[game.ctrl.pos[1],game.ctrl.pos[2],1] == 0x06)
        return
    end

    if rand(0x00:0xff) > 0x80
        return
    end

    game.callbacks[:movemain].active = true
    game.callbacks[:movemain].args = (game.ctrl.dir,-1)

    initBattleWild!(game)

    return
end

function moveMain!(game::GameState,(dir,type)::Tuple{Int,Int})
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
    if game.ctrl.input.move
        if !(inputs.up.hold || inputs.down.hold || inputs.left.hold || inputs.right.hold)
            if game.n[:movemain].c != 1
                setSpriteIdx!(game,:mc,1)
                game.callbacks[:movemain].active = true
                game.callbacks[:movemain].args = (game.ctrl.dir,-1)
            end
        else
            inputMove!(game,inputs)

            return
        end

        if inputs.start.press
            stateMenuMainOpen!(game)
        elseif inputs.A.press
            mapAction!(game)
        end
    end

    return
end

function inputMove!(game::GameState,inputs::Inputs)
    dir = getDirection(inputs)
    game.ctrl.mpos = game.ctrl.pos + dirs[dir]

    if !checkWalkable(game,game.ctrl.mpos,game.ctrl.height)
        setSpriteIdx!(game,:mc,1)

        if game.ctrl.dir != dir
            game.ctrl.dir = dir
            
            game.im.s.sheets[:mc].rev[1,1] = (dir == 4)
            setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1)

            game.callbacks[:movemain].args = (dir,3)
        end

        if game.n[:movemain].c <= 1
            game.n[:movemain].c = 1
            game.callbacks[:movemain].active = true
            game.callbacks[:movemain].args = (dir,3)
        end

        checkTeleport!(game,game.ctrl.mpos)

        return
    end
    
    game.im.s.sheets[:mc].rev[1,1] = (dir == 4)

    game.n[:movemain].c = 1

    game.callbacks[:movemain].active = true
    game.ctrl.input.move = false

    if !inputs.B.hold
        if game.ctrl.dir == dir
            game.callbacks[:movemain].args = (game.ctrl.dir,1)
        else
            game.ctrl.dir = dir
            game.callbacks[:movemain].args = (game.ctrl.dir,0)
        end
    else
        setSpriteIdx!(game,:mc,2)
        game.ctrl.dir = dir
        game.callbacks[:movemain].args = (game.ctrl.dir,2)
    end

    return
end

function getDirection(inputs::Inputs)
    if inputs.up.hold
        return 1
    elseif inputs.down.hold
        return 3
    elseif inputs.right.hold
        return 2
    elseif inputs.left.hold
        return 4
    end

    return 0
end

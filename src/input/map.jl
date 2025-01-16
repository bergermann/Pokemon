
const walkable::Vector{UInt16}  = UInt8[0,5,6,7,20,22,23]
const bikeable::Vector{UInt16}  = UInt8[0,5,6,  20,22,23]
const swimmable::Vector{UInt16} = UInt8[  2,3,  20,22,23]



function getCollision(game::GameState,mpos::Pos,mchunk::Pos,l::Int)::UInt8
    return game.m.chunkdata[game.m.idxs[mchunk]].collision[mpos[1],mpos[2],l]
end

function checkWalkable(game::GameState,mpos::Pos,mchunk::Pos,l::Int,col::UInt8)::Bool
    if !(1 <= mchunk[1] <= game.im.c.r2) || !(1 <= mchunk[2] <= game.im.c.r2)
        return false
    end

    for npc in game.m.chunkdata[game.m.idxs[mchunk]].npcs
        if isequal(npc[].fg,game.ctrl.fg) && 
                (isequal(npc[].pos1,mpos) || isequal(npc[].pos2,mpos))
            return false
        end
    end

    for object in game.m.chunkdata[game.m.idxs[mchunk]].objects
        if isequal(object[].fg,game.ctrl.fg) && isequal(object[].pos,mpos)
            return false
        end
    end

    for item in game.m.chunkdata[game.m.idxs[mchunk]].items
        if isequal(item[].fg,game.ctrl.fg) && isequal(item[].pos,mpos)
            return false
        end
    end

    return col ∈ walkable
end

checkWalkable(game::GameState,mpos::Pos,mchunk::Pos,l::Int) = 
    checkWalkable(game,mpos,mchunk,l,getCollision(game,mpos,mchunk,l))

function checkEncounter!(game::GameState)
    if !(getCollision(game,game.ctrl.mpos,game.ctrl.mchunk,game.ctrl.fg+1)==0x06) ||
            rand(UInt8) < 0x80

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
    @. game.ctrl.mpos = game.ctrl.pos1+dirs[dir]
    @. game.ctrl.mchunk = modc(game.ctrl.mpos)+(game.im.c.renderdistance+1)
    @. game.ctrl.mpos = (game.ctrl.mpos+15)%16+1

    col = getCollision(game,game.ctrl.mpos,game.ctrl.mchunk,1+game.ctrl.fg)

    if !checkWalkable(game,game.ctrl.mpos,game.ctrl.mchunk,1+game.ctrl.fg,col)
        setSpriteIdx!(game,:mc,1)

        if game.ctrl.dir != dir
            game.ctrl.dir = dir
            
            reverseSpriteW!(game,:mc,dir==4)

            setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir==4))+1)

            game.callbacks[:movemain].args = (dir,3)
        end

        if game.n[:movemain].c <= 1
            game.n[:movemain].c = 1
            game.callbacks[:movemain].active = true
            game.callbacks[:movemain].args = (dir,3)
        end

        return
    end

    if col == 0x14
        checkTeleport!(game)
    end
    
    reverseSpriteW!(game,:mc,dir==4)

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

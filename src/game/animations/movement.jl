


function moveStop!(game::GameState)
    setSpriteFrame!(game,:mc,1+3*(game.ctrl.dir-1-2*(game.ctrl.dir == 4)))

    game.ctrl.input.move = true

    game.ctrl.movec = 1
    game.ctrl.movea = false

    return
end

function moveTurn!(game::GameState)
    dir = game.ctrl.dir

    if game.ctrl.movec == 1
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1)
    elseif game.ctrl.movec == 6   
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    elseif game.ctrl.movec == 10
        game.ctrl.input.move = true

        game.ctrl.movec = -1
        game.ctrl.movea = false
        
        checkEncounter!(game)

        return
    end

    game.ctrl.movec += 1

    return
end

function moveWalk!(game::GameState)
    dir = game.ctrl.dir
    moveScreen!(game,dir,1)

    if game.ctrl.movec%16 == 1
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1+sum(game.ctrl.pos1)%2)
        @. game.ctrl.pos2 = game.ctrl.pos1+dirs[dir]
    elseif game.ctrl.movec%16 == 9
        game.ctrl.pos1 += dirs[dir]
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    elseif game.ctrl.movec >> 4 == game.ctrl.movel
        game.ctrl.input.move = true

        game.ctrl.movec = -1
        game.ctrl.movea = false

        checkChunks!(game,dir)
        checkEncounter!(game)

        return
    end

    game.ctrl.movec += 1

    return
end

function moveWalkWall!(game::GameState)
    dir = game.ctrl.dir
    
    if game.ctrl.movec%32 == 1
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1+div(game.ctrl.movec,32)%2)
    elseif game.ctrl.movec%32 == 16
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    end

    game.ctrl.movec += 1

    return
end

function moveRun!(game::GameState)
    dir = game.ctrl.dir
    moveScreen!(game,dir,2)

    if game.ctrl.movec%8 == 1
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1+sum(game.ctrl.pos1)%2)
        @. game.ctrl.pos2 = game.ctrl.pos1+dirs[dir]
    elseif game.ctrl.movec%8 == 5
        game.ctrl.pos1 += dirs[dir]
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    elseif game.ctrl.movec >> 3 == game.ctrl.movel
        game.ctrl.input.move = true

        game.ctrl.movec = -1
        game.ctrl.movea = false

        checkChunks!(game,dir)
        checkEncounter!(game)

        return
    end

    game.ctrl.movec += 1

    return
end


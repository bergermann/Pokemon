


function moveStop!(game::GameState,dir::Int)
    setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))

    game.ctrl.input.move = true

    game.n[:movemain].c = 1
    game.callbacks[:movemain].active = false

    return
end

function moveTurn!(game::GameState,dir::Int)
    if game.n[:movemain].c == 1
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1)
    elseif game.n[:movemain].c == 6   
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    elseif game.n[:movemain].c == 10
        game.ctrl.input.move = true

        game.n[:movemain].c = -1
        game.callbacks[:movemain].active = false
        
        # checkEncounter!(game)

        return
    end

    game.n[:movemain].c += 1

    return
end

function moveWalk!(game::GameState,dir::Int)
    moveScreen!(game,dir,1)

    if game.n[:movemain].c == 1
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1+sum(game.ctrl.pos1)%2)
        game.ctrl.pos2 = game.ctrl.pos1+dirs[dir]
    elseif game.n[:movemain].c == 9
        game.ctrl.pos1 += dirs[dir]
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    elseif game.n[:movemain].c == 16
        # game.ctrl.mpos = game.ctrl.pos + dirs[dir]

        game.ctrl.input.move = true

        game.n[:movemain].c = -1
        game.callbacks[:movemain].active = false

        checkChunks!(game,dir)

        # checkEncounter!(game)

        return
    end

    game.n[:movemain].c += 1

    return
end

function moveWalkWall!(game::GameState,dir::Int)
    if game.n[:movemain].c%32 == 1
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1+div(game.n[:movemain].c,32)%2)
    elseif game.n[:movemain].c%32 == 16
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    end

    game.n[:movemain].c += 1

    return
end

function moveRun!(game::GameState,dir::Int)
    moveScreen!(game,dir,2)

    if game.n[:movemain].c == 1
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1+sum(game.ctrl.pos1)%2)
        game.ctrl.pos2 = game.ctrl.pos1+dirs[dir]
    elseif game.n[:movemain].c == 5
        game.ctrl.pos1 += dirs[dir]
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))
    elseif game.n[:movemain].c == 8
        # game.ctrl.mpos = game.ctrl.pos + dirs[dir]

        game.ctrl.input.move = true

        game.n[:movemain].c = -1
        game.callbacks[:movemain].active = false

        checkChunks!(game,dir)

        # checkEncounter!(game)

        return
    end

    game.n[:movemain].c += 1

    return
end


include("transformations.jl")

function animEmpty!(game::GameState)
    return
end

function animBattleEntry1!(game::GameState)
    if game.n.c[:battleintro].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = combine!
        game.im.postprocess.args = (0x999999,0x10,0x00)
    elseif game.n.c[:battleintro].c < 45
        game.im.postprocess.args = (0x999999,0x10,
            round(UInt8,8*(1-cospi(game.n.c[:battleintro].c/7.5))))
    elseif game.n.c[:battleintro].c == 45
        game.im.postprocess.func = horizontalShifts!
        game.im.postprocess.args = (0,2)
    elseif 45 < game.n.c[:battleintro].c < 115
        game.im.postprocess.args = (4*(game.n.c[:battleintro].c-45),2)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()

        game.battle.active = true
        game.draw.battleintro = true

        initDrawBattle!(game)

        game.n.c[:battleintro].c = 0
        killCallback!(game,:battleintro)

        return
    end

    game.n.c[:battleintro].c += 1
end

function moveStop!(game::GameState,dir::Int)
    updateSprite!(game.im.sprites[:main],(dir-1)*10+1)

    game.input.move = true

    game.n.c[:movemain].c = 0
    game.callbacks[:movemain].active = false
end

function moveTurn!(game::GameState,dir::Int)
    if game.n.c[:movemain].c == 0
        updateSprite!(game.im.sprites[:main],(dir-1)*10+2)
    elseif game.n.c[:movemain].c == 5
        updateSprite!(game.im.sprites[:main],(dir-1)*10+1)
    elseif game.n.c[:movemain].c == 9
        game.input.move = true

        game.n.c[:movemain].c = -1
        game.callbacks[:movemain].active = false
        
        checkEncounter!(game)

        return
    end

    game.n.c[:movemain].c += 1
end

function moveWalk!(game::GameState,dir::Int)
    posAdd!(game.screenoffset,dirs[dir])

    posAdd!(game.im.sprites[:main].pos,dirs[dir])

    if game.n.c[:movemain].c == 0
        if (game.pos.h%2 == 0 && game.pos.w%2 == 0) || (game.pos.h%2 == 1 && game.pos.w%2 == 1)
            updateSprite!(game.im.sprites[:main],(dir-1)*10+2)
        else
            updateSprite!(game.im.sprites[:main],(dir-1)*10+3)
        end
    elseif game.n.c[:movemain].c == 8
        updateSprite!(game.im.sprites[:main],(dir-1)*10+1)
    elseif game.n.c[:movemain].c == 15
        posAddMult!(game.screenoffset,dirs[dir],-16)
        posAddMult!(game.im.sprites[:main].pos,dirs[dir],-16)

        posAdd!(game.pos,dirs[dir])

        game.input.move = true

        game.n.c[:movemain].c = -1
        game.callbacks[:movemain].active = false

        checkEncounter!(game)

        return
    end

    game.n.c[:movemain].c += 1
end

function moveWalkWall!(game::GameState,dir::Int)
    if game.n.c[:movemain].c%32 == 0
        if div(game.n.c[:movemain].c,32)%2 == 0
            updateSprite!(game.im.sprites[:main],(dir-1)*10+2)
        else
            updateSprite!(game.im.sprites[:main],(dir-1)*10+3)
        end
    elseif game.n.c[:movemain].c%32 == 15
        updateSprite!(game.im.sprites[:main],(dir-1)*10+1)
    end

    game.n.c[:movemain].c += 1
end

function moveRun!(game::GameState,dir::Int)
    posAddMult!(game.screenoffset,dirs[dir],2)

    posAddMult!(game.im.sprites[:main].pos,dirs[dir],2)

    if game.n.c[:movemain].c == 0
        if (game.pos.h%2 == 0 && game.pos.w%2 == 0) || (game.pos.h%2 == 1 && game.pos.w%2 == 1)
            updateSprite!(game.im.sprites[:main],(dir+3)*10+2)
        else
            updateSprite!(game.im.sprites[:main],(dir+3)*10+3)
        end
    elseif game.n.c[:movemain].c == 4
        updateSprite!(game.im.sprites[:main],(dir+3)*10+1)
    elseif game.n.c[:movemain].c == 7
        posAddMult!(game.screenoffset,dirs[dir],-16)
        posAddMult!(game.im.sprites[:main].pos,dirs[dir],-16)

        posAdd!(game.pos,dirs[dir])

        game.input.move = true
        
        game.n.c[:movemain].c = -1
        game.callbacks[:movemain].active = false

        checkEncounter!(game)

        return
    end

    game.n.c[:movemain].c += 1
end

function fadeIn!(game::GameState,len::Int)
    if game.n.c[:fadein].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (len,len,)
    elseif game.n.c[:fadein].c <= len
        game.im.postprocess.args = (len,len-game.n.c[:fadein].c,)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()
        #
        killCC!(game,fadein)

        return
    end

    game.n.c[:fadein].c += 1
end

function fadeOut!(game::GameState,len::Int)
    if game.n.c[:fadein].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (len,0,)
    elseif game.n.c[:fadein].c <= len
        game.im.postprocess.args = (len,game.n.c[:fadein].c,)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()
        
        killCC!(game,fadein)

        return
    end

    game.n.c[:fadein].c += 1
end

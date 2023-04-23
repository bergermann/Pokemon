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

        stateInitDrawBattle!(game)

        game.n.c[:battleintro].c = 0
        killCallback!(game,:battleintro)

        return
    end

    game.n.c[:battleintro].c += 1
end

function animWiggleBattle!(game::GameState)
    if !(game.input.battle1 || game.input.battle2)
        if game.n.c[:wiggle].c == 0
            return
        end

        game.n.c[:wiggle].c = 0
        game.im.sprites[:pkmn1].pos.h = 90
        game.im.sprites[:tagown].pos.h = 72+24
    end

    if game.n.c[:wiggle].c == 7
        game.im.sprites[:pkmn1].pos.h -= 1
    elseif game.n.c[:wiggle].c == 15
        game.im.sprites[:tag1].pos.h -= 1
    elseif game.n.c[:wiggle].c == 23
        game.im.sprites[:pkmn1].pos.h += 1
    elseif game.n.c[:wiggle].c == 31
        game.im.sprites[:tag1].pos.h += 1
    elseif game.n.c[:wiggle].c == 32
        game.n.c[:wiggle].c = 0
    end

    game.n.c[:wiggle].c += 1
end

function animBattlePhaseWild!(game::GameState)
    # println("stage: ",game.battle.state.stage)
    # -1: set up
    # -2: advance queue
    # -3: exit queue

    if game.n.c[:animbattle].c == -1
        F = queueCheckStatus!(game.battle.state)

        if F
            game.n.c[:animbattle].c = 0

            return
        end

        if game.battle.state.stage == 250 || game.battle.state.stage == 251
            game.input.inputlock = true

            stateQuitBattlePhase!(game)

            createCC!(game,:scenet,sceneTransition!,
                (32,8,stateEndBattle!,(),stateInitMapCtrls!,()); active=true,n=1)


            return
        end

        if game.battle.state.actionqueue.idx == 0
            stateEndBattlePhase!(game)

            return
        end

        queueSetupAnimation!(game,game.battle.state)

        game.n.c[:animbattle].c = 1
    elseif game.n.c[:animbattle].c == -2
        popfirst!(game.battle.state.animqueue)

        if game.battle.state.animqueue.idx == 0
    
            game.n.c[:animbattle].c = -1

            if game.battle.state.actionqueue.idx != 0
                popfirst!(game.battle.state.actionqueue)
            end

            return
        end

        game.n.c[:animbattle].c = 1
    elseif game.n.c[:animbattle].c == -3
        stateEndBattlePhase!(game)

        return
    end

    queueCheckStatus!(game.battle.state)

    if game.n.c[:animbattle].c == 1
        if game.battle.state.animqueue[1].str != ""
            drawText!(
                game,:layer4,game.battle.state.animqueue[1].str,UInt(2),
                P(144,32),0xffffff,0x6b5a73
            )
        end
        
        game.battle.state.animqueue[1].anim(game,game.battle.state.animqueue[1].target)
    elseif game.n.c[:animbattle].c == game.battle.state.animqueue[1].l
        if game.battle.state.animqueue[1].str != ""
            flushLayer!(game,:layer4,P(144,32),P(32,200))
        end

        game.n.c[:animbattle].c = -2

        return
    end

    game.n.c[:animbattle].c += 1
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

        drawMapUpdate!(game,dir)

        updateMovePos!(game,dir)

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

        updateMovePos!(game,dir)
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

        drawMapUpdate!(game,dir)

        updateMovePos!(game,dir)

        checkEncounter!(game)

        return
    end

    game.n.c[:movemain].c += 1
end

function fadeIn!(game::GameState,len::Int)
    if game.n.c[:fadein].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (UInt8(len),UInt8(len),)
    elseif game.n.c[:fadein].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(len-game.n.c[:fadein].c),)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()
        
        killCC!(game,:fadein)

        return
    end

    game.n.c[:fadein].c += 1
end

function fadeOut!(game::GameState,len::Int)
    if game.n.c[:fadeout].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (UInt8(len),0x00,)
    elseif game.n.c[:fadeout].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(game.n.c[:fadeout].c),)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()
        
        killCC!(game,:fadeout)

        return
    end

    game.n.c[:fadeout].c += 1
end

function sceneTransition!(game::GameState,len::Int,pause::Int,  # pause >= 1!
        state1::Function,state1args::Tuple,
        state2::Function,state2args::Tuple)
    
    if game.n.c[:scenet].c == 1
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (UInt8(len),0x01,)
    elseif game.n.c[:scenet].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(game.n.c[:scenet].c),)
    elseif game.n.c[:scenet].c == len+1
        Base.GC.gc()
        flushLayers!(game)
        flushLayer!(game)

        state1(game,state1args...)
    elseif len+pause+1 <= game.n.c[:scenet].c <= 2*len+pause
        game.im.postprocess.args = (UInt8(len),UInt8(2*len+pause-game.n.c[:scenet].c),)
    elseif game.n.c[:scenet].c == 2*len+pause+1
        game.im.postprocess.active = false
        game.im.postprocess.func = emptyCallback
        state2(game,state2args...)

        killCC!(game,:scenet)

        return
    end
   
    game.n.c[:scenet].c += 1
end

function animArrowsMenu!(game::GameState)
    if (game.n.frame%48) < 24
        game.im.sprites[:arrowleft].pos = P(24+8,16+22-div((game.n.frame%24),6))
        game.im.sprites[:arrowright].pos = P(24+8,16+90+div((game.n.frame%24),6))
    else
        game.im.sprites[:arrowleft].pos = P(24+8,16+22-4+div((game.n.frame%24),6))
        game.im.sprites[:arrowright].pos = P(24+8,16+90+4-div((game.n.frame%24),6))
    end
end

function animBagSwitch!(game::GameState)
    if game.n.c[:bagswitch].c == 1
        updateSprite!(game.im.sprites[:slot],game.input.menu.menubags.bag)
        setPos!(game.im.sprites[:slotmarker].pos,24+27,16+34+game.input.menu.menubags.bag*8)

        updateSprite!(game.im.sprites[:bag],6)

        game.im.sprites[:arrowleft].active = false
        game.im.sprites[:arrowright].active = false
    end

    if game.n.c[:bagswitch].c < 4
        setPos!(game.im.sprites[:bag].pos,24+34-game.n.c[:bagswitch].c+1,16+40)
    elseif game.n.c[:bagswitch].c == 4
        updateSprite!(game.im.sprites[:bag],game.input.menu.menubags.bag)
    elseif game.n.c[:bagswitch].c <= 8
        setPos!(game.im.sprites[:bag].pos,24+34-4+game.n.c[:bagswitch].c-4,16+40)
    end

    if game.n.c[:bagswitch].c == 8
        game.im.sprites[:arrowleft].active = true
        game.im.sprites[:arrowright].active = true

        game.input.inputlock = false
        game.n.c[:bagswitch].c = 1
        game.callbacks[:bagswitch].active = false

        return
    end

    game.n.c[:bagswitch].c += 1
end

function animMenuPkmnWiggle!(game::GameState)
    return

    for i in 1:game.trainer.pokemon.idx
        if i == game.input.menu.menupkmn.select
            updateSprite!(game.im.sprites[0+i],2*div(game.n.frame%30,15)+1)

            continue
        end

        updateSprite!(game.im.sprites[0+i],div(game.n.frame%30,15)+1)   #fix this
    end
end
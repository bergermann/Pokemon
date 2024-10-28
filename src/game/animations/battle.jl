


function animBattleEntry1!(game::GameState,args::Tuple{})
    if game.n[:introb].c < 36
        game.im.l.color[4] = 1.0 - 0.75*sinpi((game.n[:introb].c+1)/6.0)
    elseif game.n[:introb].c < 60
        # replace this with horizontal slider effect
        game.im.l.color[4] = (59-game.n[:introb].c)/24.0
    elseif game.n[:introb].c == 60
        stateCloseMap!(game)
        stateOpenBattle!(game)
        
        Base.GC.gc()
    elseif game.n[:introb].c < 80
        # replace this with vertical slider effect
        game.im.l.color[4] = (game.n[:introb].c-60)/20.0
    elseif game.n[:introb].c == 80
        game.im.l.color[4] = 1.0

        game.battle.active = true

        killCC!(game,:introb)

        error("here")

        return
    end
   
    game.n[:introb].c += 1

    return
end

function animWiggleBattle!(game::GameState)
    if game.frame%0x20 == 0x08
        moveSpriteH!(game,:pkmn1,9,true)
        # game.im.sprites[2][:pkmn1].pos.h = 89
    elseif game.frame%0x20 == 0x10
        moveSpriteH!(game,:tag1,15,true)
        # game.im.sprites[3][:tag1].pos.h = 95
    elseif game.frame%0x20 == 0x18
        moveSpriteH!(game,:pkmn1,10,true)
        # game.im.sprites[2][:pkmn1].pos.h = 90
    elseif game.frame%0x20 == 0x00
        moveSpriteH!(game,:tag1,16,true)
        # game.im.sprites[3][:tag1].pos.h = 96
    end

    return
end

function animBattlePhaseWild!(game::GameState)
    # println("stage: ",game.battle.state.stage)
    # -1: set up
    # -2: advance queue
    # -3: exit queue

    if game.n[:animbattle].c == -1
        F = queueCheckStatus!(game,game.battle.state)

        if F
            game.n[:animbattle].c = 0

            return
        end

        if game.battle.state.stage == 250 || game.battle.state.stage == 251 ||
                game.battle.state.stage == 252
            game.ctrl.input.inputlock = true

            stateQuitBattlePhase!(game)

            createCC!(game,:scenet,sceneTransition!,
                (32,8,stateEndBattle!,(),stateInitMapCtrls!,());
                active=true,n=1)

            return
        end

        if game.battle.state.actionqueue.idx == 0
            stateEndBattlePhase!(game)

            return
        end

        queueSetupAnimation!(game,game.battle.state)

        game.n[:animbattle].c = 1
    elseif game.n[:animbattle].c == -2
        popfirst!(game.battle.state.animqueue)

        if game.battle.state.animqueue.idx == 0
    
            game.n[:animbattle].c = -1

            if game.battle.state.actionqueue.idx != 0
                popfirst!(game.battle.state.actionqueue)
            end

            return
        end

        game.n[:animbattle].c = 1
    elseif game.n[:animbattle].c == -3
        stateEndBattlePhase!(game)

        return
    end

    queueCheckStatus!(game,game.battle.state)

    if game.n[:animbattle].c == 1
        if game.battle.state.animqueue[1].str != ""
            drawText!(
                game,4,game.battle.state.animqueue[1].str,UInt(2),
                P(144,32),0xffffff,0x6b5a73
            )
        end
        
        game.battle.state.animqueue[1].anim(game,game.battle.state.animqueue[1].target)
    elseif game.n[:animbattle].c == game.battle.state.animqueue[1].l
        if game.battle.state.animqueue[1].str != ""
            flushLayer!(game,4,P(144,32),P(32,200))
        end

        game.n[:animbattle].c = -2

        return
    end

    game.n[:animbattle].c += 1

    return
end


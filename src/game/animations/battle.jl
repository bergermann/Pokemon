


function animBattleEntry1!(game::GameState)
    if game.n[:battleintro].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = combine!
        game.im.postprocess.args = (0x999999,0x10,0x00)
    elseif game.n[:battleintro].c < 45
        game.im.postprocess.args = (0x999999,0x10,
            round(UInt8,8*(1-cospi(game.n[:battleintro].c/7.5))))
    elseif game.n[:battleintro].c == 45
        game.im.postprocess.func = horizontalShifts!
        game.im.postprocess.args = (0,2)
    elseif 45 < game.n[:battleintro].c < 115
        game.im.postprocess.args = (4*(game.n[:battleintro].c-45),2)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()

        game.battle.active = true
        game.draw.battleintro = true

        stateInitDrawBattle!(game)

        game.n[:battleintro].c = 0
        killCallback!(game,:battleintro)

        return
    end

    game.n[:battleintro].c += 1

    return
end

function animWiggleBattle!(game::GameState)
    if game.frame%0x20 == 0x08
        game.im.sprites[2][:pkmn1].pos.h = 89
    elseif game.frame%0x20 == 0x10
        game.im.sprites[3][:tag1].pos.h = 95
    elseif game.frame%0x20 == 0x18
        game.im.sprites[2][:pkmn1].pos.h = 90
    elseif game.frame%0x20 == 0x00
        game.im.sprites[3][:tag1].pos.h = 96
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
            game.input.inputlock = true

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


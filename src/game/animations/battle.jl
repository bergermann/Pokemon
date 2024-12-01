


function animBattleIntro1!(game::GameState,args::Tuple{})
    if game.n[:introb].c < 48
        game.im.l.color[4] = 0.5+cospi((game.n[:introb].c+1)/8.0)/2
    elseif game.n[:introb].c < 64
        # replace this with horizontal slider effect
        game.im.l.color[4] = (59-game.n[:introb].c)/16.0
    elseif game.n[:introb].c == 64
        game.im.l.color[4] = 1.0
        
        stateCloseMap!(game)
        stateOpenBattleIntro!(game)
        
        Base.GC.gc()
    elseif game.n[:introb].c < 80

    elseif game.n[:introb].c < 112
        game.im.b.backgrounds[:s1].pos[2] -= 1
        game.im.b.backgrounds[:s2].pos[2] += 1

        moveSpriteW!(game,:grass1,-4)
        moveSpriteW!(game,:grass2,-4)
    elseif game.n[:introb].c < 140
        game.im.b.backgrounds[:s1].pos[2] -= 2
        game.im.b.backgrounds[:s2].pos[2] += 2

        moveSpriteW!(game,:grass1,-4)
        moveSpriteW!(game,:grass2,-4)
    elseif game.n[:introb].c < 260
        moveSpriteW!(game,:grass1,-4)
        moveSpriteW!(game,:grass2,-4)
        moveSpriteH!(game,:grass1, 1)
        moveSpriteH!(game,:grass2, 1)

        moveSpriteW!(game,:pad1,-2)
        moveSpriteW!(game,:pad2, 2)
        moveSpriteW!(game,:mc, -2)
        moveSpriteW!(game,:pkmn2, 2)
    elseif game.n[:introb].c < 260+16
        moveSpriteW!(game,:tagopp, 8)
        moveText!(game,:name2, 8, 0)
        moveText!(game,:lvl2, 8, 0)
    elseif game.n[:introb].c < 260+16+8
        moveSpriteH!(game,:pkmn2, -2)
    elseif game.n[:introb].c < 260+16+16
        moveSpriteH!(game,:pkmn2, 2)
    elseif game.n[:introb].c < 260+16+24
        moveSpriteH!(game,:pkmn2, -2)
    elseif game.n[:introb].c < 260+16+32
        moveSpriteH!(game,:pkmn2, 2)
    elseif game.n[:introb].c == 260+16+32
        game.battle.active = true
        unlockInput!(game)

        killSprite!(game,:grass1); killSprite!(game,:grass2)
        deleteBackground!(game,:s1); deleteBackground!(game,:s2)

        game.callbacks[:introb].active = false

        stateSetDialogue!(game,
            game.str[1][11]*pkmnName(game,game.battle.state.pkmn2.pkmn)*game.str[1][12],
            Callback(stateThrowBattle!))

        return
    end

    if 80 < game.n[:introb].c <= 300
        if getSpritePosW(game,:grass1) <= -240
            moveSpriteW!(game,:grass1,512)
        end
        
        if getSpritePosW(game,:grass2) <= -240
            moveSpriteW!(game,:grass2,512)
        end
    end

    game.n[:introb].c += 1

    return
end

function animThrowBall!(game::GameState,args::Tuple{})
    if game.n[:introb].c == 0
        setSpriteFrame!(game,:mc,2)
    elseif game.n[:introb].c == 20
        setSpriteFrame!(game,:mc,3)
    elseif game.n[:introb].c == 30
        setSpriteFrame!(game,:mc,4)
    elseif game.n[:introb].c == 80
        killSprite!(game,:mc); killSprite!(game,:ball)
        
        stateInitBattleChoice!(game,())

        killCallback!(game,:introb)

        return
    end
    
    moveSpriteW!(game,:mc,-3)

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





function animBattleIntroW!(game::GameState,args::Tuple{})
    if game.n[:introb].c < 48
        game.im.l.colors[4] = 0.5+cospi((game.n[:introb].c+1)/8.0)/2
    elseif game.n[:introb].c < 64
        # replace this with horizontal slider effect
        game.im.l.colors[4] = (59-game.n[:introb].c)/16.0
    elseif game.n[:introb].c == 64
        game.im.l.colors[4] = 1.0
        
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
        moveSpriteW!(game,:tag2, 8)
        moveSpriteW!(game, :hp2, 8)
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
        deleteSpriteSheet!(game,:fol)

        game.callbacks[:introb].active = false

        stateSetDialogue!(game,game.str[1][11]*game.battle.state[2].name*game.str[1][12],
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

function animBattleIntroT!(game::GameState,args::Tuple{})
    if game.n[:introb].c < 48
        game.im.l.colors[4] = 0.5+cospi((game.n[:introb].c+1)/8.0)/2
    elseif game.n[:introb].c < 64
        # replace this with proper trainer battle intro effect
        game.im.l.colors[4] = (59-game.n[:introb].c)/16.0
    elseif game.n[:introb].c == 64
        game.im.l.colors[4] = 1.0
        
        stateCloseMap!(game)
        stateOpenBattleIntro!(game)
        
        Base.GC.gc()
    # elseif game.n[:introb].c < 80

    elseif game.n[:introb].c < 112
        game.im.b.backgrounds[:s1].pos[2] -= 1
        game.im.b.backgrounds[:s2].pos[2] += 1
    elseif game.n[:introb].c < 140
        game.im.b.backgrounds[:s1].pos[2] -= 2
        game.im.b.backgrounds[:s2].pos[2] += 2
    elseif game.n[:introb].c < 260
        moveSpriteW!(game,:pad1,-2)
        moveSpriteW!(game,:pad2, 2)
        moveSpriteW!(game,:mc, -2)
        moveSpriteW!(game,:opp, 2)
    elseif game.n[:introb].c == 260+16
        game.battle.active = true
        unlockInput!(game)

        deleteBackground!(game,:s1); deleteBackground!(game,:s2)

        game.callbacks[:introb].active = false

        stateSetDialogue!(game,
            game.str[1][7]*game.battle.state.trainer1.name*game.str[1][8],
            Callback(stateDropBattle!))

        return
    end

    game.n[:introb].c += 1

    return
end



function animThrowBall!(game::GameState,args::Tuple{})
    if game.n[:introb].c == 0
        setSpriteFrame!(game,:mc,2)
        activateSprite!(game,:ball)
    elseif game.n[:introb].c == 16
        setSpriteFrame!(game,:mc,3)
        moveSprite!(game,:ball,-118,-2,true)
    elseif game.n[:introb].c == 24
        setSpriteFrame!(game,:mc,4)
        moveSprite!(game,:ball,-84,-2,true)
    elseif 24 < game.n[:introb].c < 64
        moveSpriteW!(game,:ball,1)
        t = game.n[:introb].c-24
        moveSpriteH!(game,:ball,round(Int,-2-3*t+0.5*0.1875*t^2),true)
        rotateSprite!(game,:ball,18.)
    elseif game.n[:introb].c == 64
        setSpriteFrame!(game,:ball,2)
    elseif game.n[:introb].c == 72
        activateSprite!(game,:pkmn1)
        for i in 1:10; activateSprite!(game,Symbol(:spark,i)); end
    elseif 72+1 <= game.n[:introb].c <= 72+32
        t = game.n[:introb].c-72
        scaleSprite!(game,:pkmn1,t/32,t/32,true)
        for i in 1:10
            moveSprite!(game,Symbol(:spark,i),
                round(Int,1.5t*cospi(t/32+i/5))-48,round(Int,-1.5t*sinpi(t/32+i/5))+24,true)
        end
    elseif game.n[:introb].c == 72+32+1
        killSprites!(game,:particles)
        moveSpriteH!(game,:ball,3)
    elseif 72+32+1 < game.n[:introb].c <= 72+32+8
        moveSpriteH!(game,:ball,3)
    elseif 120 < game.n[:introb].c <= 120+16
        moveSpriteW!(game,:tag1,-8)
        moveSpriteW!(game, :hp1,-8)
        moveSpriteW!(game,  :xp,-8)
        moveText!(game,:name1,-8,0)
        moveText!(game, :lvl1,-8,0)
    elseif game.n[:introb].c == 120+32
        killSprite!(game,:mc); killSprite!(game,:ball)
        
        stateAdvanceDialogue!(game)

        killCC!(game,:introb)

        return
    end
    
    moveSpriteW!(game,:mc,-3)

    if game.n[:introb].c <= 24; moveSpriteW!(game,:ball,-3); end

    game.n[:introb].c += 1

    return
end

function animDropBall!(game::GameState,args::Tuple{})
    if game.n[:introb].c == 0
        activateSprite!(game,:ballopp)
    elseif game.n[:introb].c == 32
        setSpriteFrame!(game,:ballopp,2)
    elseif game.n[:introb].c == 64
        activateSprite!(game,:pkmn2)
        for i in 1:10; activateSprite!(game,Symbol(:spark,i)); end
    elseif 64 < game.n[:introb].c <= 96
        t = game.n[:introb].c-64
        scaleSprite!(game,:pkmn2,t/32,t/32,true)
        for i in 1:10
            moveSprite!(game,Symbol(:spark,i),
                round(Int,1.5t*cospi(t/32+i/5))+56,round(Int,-1.5t*sinpi(t/32+i/5))-28,true)
        end
    elseif game.n[:introb].c == 96+1
        for i in 1:10; deactivateSprite!(game,Symbol(:spark,i)); end
    elseif 100 < game.n[:introb].c <= 100 + 16 # 16 frames
        moveSpriteW!(game,:tag2, 8)
        moveSpriteW!(game, :hp2, 8)
        moveText!(game,:name2, 8, 0)
        moveText!(game,:lvl2, 8, 0)
    elseif game.n[:introb].c == 128
        killSprite!(game,:opp); killSprite!(game,:ballopp)

        stateThrowBattle!(game,())

        return
    end

    moveSpriteW!(game,:opp,2)

    game.n[:introb].c += 1

    return
end



function animWiggleBattle!(game::GameState,args::Tuple{})
    if game.frame%0x20 == 0x08
        moveSpriteH!(game,:pkmn1,23,true)
    elseif game.frame%0x20 == 0x10
        moveSpriteH!(game,:tag1,11,true)
        moveSpriteH!(game, :hp1,11,true)
        moveSpriteH!(game,  :xp,27,true)
        moveTextH!(game,:name1,-5,true)
        moveTextH!(game,:lvl1,-5,true)
    elseif game.frame%0x20 == 0x18
        moveSpriteH!(game,:pkmn1,24,true)
    elseif game.frame%0x20 == 0x00
        moveSpriteH!(game,:tag1,12,true)
        moveSpriteH!(game, :hp1,12,true)
        moveSpriteH!(game,  :xp,28,true)
        moveTextH!(game,:name1,-4,true)
        moveTextH!(game,:lvl1,-4,true)
    end

    return
end

function resetWiggle!(game)
    moveSpriteH!(game,:pkmn1,24,true)
    moveSpriteH!(game,:tag1,12,true)
    moveSpriteH!(game,  :xp,28,true)
    moveSpriteH!(game, :hp1,12,true)
    moveTextH!(game,:name1,-4,true)
    moveTextH!(game,:lvl1,-4,true)

    return
end

function animBattlePhase!(game::GameState,args::Tuple{})
    # -1: set up
    # -2: advance queue
    # -3: exit queue

    if game.n[:animbattle].c == -1      # set up animation queue
        queueSetupAnimation!(game,game.battle.state); game.n[:animbattle].c = 1
        # display(game.battle.state.animqueue)
    elseif game.n[:animbattle].c == -2  # advance queue
        popfirst!(game.battle.state.animqueue)

        if game.battle.state.animqueue.idx == 0 && !queueCheckStatus!(game,game.battle.state)
            if game.battle.state.actionqueue.idx == 0
                stateEndBattlePhase!(game,game.battle.state)
            else
                game.n[:animbattle].c = -1
            end

            return
        end

        game.n[:animbattle].c = 1
    elseif game.n[:animbattle].c == -3  # exit queue, end battle
        deactivateCallback!(game,:animbattle)

        lockInput!(game)

        if checkContinueFight(game)
            stateVictory!(game)
        else
            stateDefeat!(game)
        end

        return
    end

    if game.n[:animbattle].c == 1       # play animqueue
        setText!(game,:dialogue,game.battle.state.animqueue[1].str)
        
        game.battle.state.animqueue[1].anim(game,game.battle.state.animqueue[1].target)
    elseif game.n[:animbattle].c == game.battle.state.animqueue[1].l
        game.n[:animbattle].c = -2

        return
    end

    game.n[:animbattle].c += 1

    return
end

function animVictory!(game::GameState,args::Tuple{})
    if game.n[:victory].c <= 20
        s = 1-game.n[:victory].c/20
        scaleSprite!(game,:pkmn1,s,s,true)
    elseif game.n[:victory].c == 28
        setSpriteFrame!(game,:ball,1)
        killSprite!(game,:pkmn1)
    elseif game.n[:victory].c < 48
        moveSpriteH!(game,:ball,3)
    elseif game.n[:victory].c < 48
        killSprite!(game,:tag1)
        killSprite!(game,:hp1)
        killSprite!(game,:xp)
        killSprite!(game,:ball)

        deleteText!(game,:name1); deleteText!(game,:lvl1)
    
    elseif 96+60 <= game.n[:victory].c < 96+60
        moveSpriteW!(game,:opp,-1)
        moveSpriteW!(game,:mc,2)
    elseif game.n[:victory].c == 96+60
        killCC!(game,:victory)

        unlockInput!(game)

        return
    end

    game.n[:victory].c += 1

    return
end

function animDefeat!(game::GameState,args::Tuple{})
    if game.n[:defeat].c <= 48
        moveSpriteW!(game,:opp,-1)
        moveSpriteW!(game,:mc,2)
    elseif 48+60 < game.n[:defeat].c <= 68+60
        s = 1-(game.n[:defeat].c-(48+60))/20
        scaleSprite!(game,:pkmn2,s,s,true)
    elseif game.n[:defeat].c == 76+60
        setSpriteFrame!(game,:ballopp,1)

        killSprite!(game,:pkmn2)
        killSprite!(game,:tag2)
        killSprite!(game,:hp2)

        deleteText!(game,:name2); deleteText!(game,:lvl2)    
    elseif 76+60 < game.n[:defeat].c <= 96+60
        a = 1-(game.n[:defeat].c-76+60)/20
        setSpriteAlpha!(game,:ballopp,a)
    elseif game.n[:defeat].c == 96+60+1
        killSprite!(game,:ballopp)

        killCC!(game,:defeat)

        unlockInput!(game)

        return
    end

    game.n[:defeat].c += 1

    return
end

function animDefeatWild!(game::GameState,args::Tuple{})
    if game.n[:defeat].c <= 48
        moveSpriteW!(game,:mc,2)
    else
        killCC!(game,:defeat)

        unlockInput!(game)

        return
    end

    game.n[:defeat].c += 1    

    return
end
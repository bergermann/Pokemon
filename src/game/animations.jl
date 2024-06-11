


function animEmpty!(game::GameState)
    return
end

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
    if game.n.frame%0x20 == 0x08
        game.im.sprites[2][:pkmn1].pos.h = 89
    elseif game.n.frame%0x20 == 0x10
        game.im.sprites[3][:tag1].pos.h = 95
    elseif game.n.frame%0x20 == 0x18
        game.im.sprites[2][:pkmn1].pos.h = 90
    elseif game.n.frame%0x20 == 0x00
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
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1+sum(game.ctrl.pos)%2)
    elseif game.n[:movemain].c == 9
        game.ctrl.pos += dirs[dir]
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
        setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4))+1+sum(game.ctrl.pos)%2)
    elseif game.n[:movemain].c == 5
        game.ctrl.pos += dirs[dir]
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



function fadeIn!(game::GameState,len::Int)
    if game.n[:fadein].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (UInt8(len),UInt8(len),)
    elseif game.n[:fadein].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(len-game.n[:fadein].c),)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()
        
        killCC!(game,:fadein)

        return
    end

    game.n[:fadein].c += 1

    return
end

function fadeOut!(game::GameState,len::Int)
    if game.n[:fadeout].c == 0
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (UInt8(len),0x00,)
    elseif game.n[:fadeout].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(game.n[:fadeout].c),)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()
        
        killCC!(game,:fadeout)

        return
    end

    game.n[:fadeout].c += 1
end



function sceneTransition!(game::GameState,len::Int,pause::Int,  # pause >= 1!
        state1::Function,state1args::Tuple,
        state2::Function,state2args::Tuple)
    
    if game.n[:scenet].c == 1
        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (UInt8(len),0x01,)
    elseif game.n[:scenet].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(game.n[:scenet].c),)
    elseif game.n[:scenet].c == len+1
        Base.GC.gc()
        flushLayers!(game)
        flushLayer!(game)

        state1(game,state1args...)
    elseif len+pause+1 <= game.n[:scenet].c <= 2*len+pause
        game.im.postprocess.args = (UInt8(len),UInt8(2*len+pause-game.n[:scenet].c),)
    elseif game.n[:scenet].c == 2*len+pause+1
        game.im.postprocess.active = false
        game.im.postprocess.func = emptyCallback
        state2(game,state2args...)

        killCC!(game,:scenet)

        return
    end
   
    game.n[:scenet].c += 1

    return
end

function sceneTransition!(game::GameState,len::Int,pause::Int,  # pause >= 1!
        state1::Function,state1args::Tuple,
        state2::Function,state2args::Tuple,
        fade1::Function,fade2::Function)
    
    if game.n[:scenet].c == 1
        game.im.postprocess.active = true
        game.im.postprocess.func = fade1
        game.im.postprocess.args = (UInt8(len),0x01,)
    elseif game.n[:scenet].c <= len
        game.im.postprocess.args = (UInt8(len),UInt8(game.n[:scenet].c),)
    elseif game.n[:scenet].c == len+1
        Base.GC.gc()
        flushLayers!(game)
        flushLayer!(game)

        state1(game,state1args...)
    elseif len+pause+1 <= game.n[:scenet].c <= 2*len+pause
        game.im.postprocess.func = fade2
        game.im.postprocess.args = (UInt8(len),UInt8(2*len+pause-game.n[:scenet].c),)
    elseif game.n[:scenet].c == 2*len+pause+1
        game.im.postprocess.active = false
        game.im.postprocess.func = emptyCallback
        state2(game,state2args...)

        killCC!(game,:scenet)

        return
    end
   
    game.n[:scenet].c += 1

    return
end

function animArrowsMenu!(game::GameState)
    if (game.n.frame%48) < 24
        game.im.sprites[1][:arrowleft].pos = P(24+8,16+22-div((game.n.frame%24),6))
        game.im.sprites[1][:arrowright].pos = P(24+8,16+90+div((game.n.frame%24),6))
    else
        game.im.sprites[1][:arrowleft].pos = P(24+8,16+22-4+div((game.n.frame%24),6))
        game.im.sprites[1][:arrowright].pos = P(24+8,16+90+4-div((game.n.frame%24),6))
    end
end

function animBagSwitch!(game::GameState)
    if game.n[:bagswitch].c == 1
        updateSprite!(game.im.sprites[1][:slot],game.input.menu.menubags.bag)
        setPos!(game.im.sprites[1][:slotmarker].pos,
            24+27,16+34+game.input.menu.menubags.bag*8)

        updateSprite!(game.im.sprites[1][:bag],6)

        game.im.sprites[1][:arrowleft].active = false
        game.im.sprites[1][:arrowright].active = false
    end

    if game.n[:bagswitch].c < 4
        setPos!(game.im.sprites[1][:bag].pos,24+34-game.n[:bagswitch].c+1,16+40)
    elseif game.n[:bagswitch].c == 4
        updateSprite!(game.im.sprites[1][:bag],game.input.menu.menubags.bag)
    elseif game.n[:bagswitch].c <= 8
        setPos!(game.im.sprites[1][:bag].pos,24+34-4+game.n[:bagswitch].c-4,16+40)
    end

    if game.n[:bagswitch].c == 8
        game.im.sprites[1][:arrowleft].active = true
        game.im.sprites[1][:arrowright].active = true
        game.im.sprites[1][:cursor].active = true
        game.im.sprites[1][:icon].active = true

        game.input.inputlock = false
        game.n[:bagswitch].c = 1
        game.callbacks[:bagswitch].active = false

        drawInventoryText!(game,game.input.menu.menubags)
        drawItemText!(game,game.input.menu.menubags)

        return
    end

    game.n[:bagswitch].c += 1

    return
end

function animBattleBagSwitch!(game::GameState)
    if game.n[:bagswitch].c == 1
        updateSprite!(game.im.sprites[1][:slot],game.input.battlebags.bag)
        setPos!(game.im.sprites[1][:slotmarker].pos,
            24+27,16+34+game.input.battlebags.bag*8)

        updateSprite!(game.im.sprites[1][:bag],6)

        game.im.sprites[1][:arrowleft].active = false
        game.im.sprites[1][:arrowright].active = false
    end

    if game.n[:bagswitch].c < 4
        setPos!(game.im.sprites[1][:bag].pos,24+34-game.n[:bagswitch].c+1,16+40)
    elseif game.n[:bagswitch].c == 4
        updateSprite!(game.im.sprites[1][:bag],game.input.battlebags.bag)
    elseif game.n[:bagswitch].c <= 8
        setPos!(game.im.sprites[1][:bag].pos,24+34-4+game.n[:bagswitch].c-4,16+40)
    end

    if game.n[:bagswitch].c == 8
        game.im.sprites[1][:arrowleft].active = true
        game.im.sprites[1][:arrowright].active = true
        game.im.sprites[1][:cursor].active = true
        game.im.sprites[1][:icon].active = true

        game.input.inputlock = false
        game.n[:bagswitch].c = 1
        game.callbacks[:bagswitch].active = false

        drawInventoryText!(game,game.input.battlebags)
        drawItemText!(game,game.input.battlebags)

        return
    end

    game.n[:bagswitch].c += 1

    return
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

    return
end

function animMenuPkmnSwap!(game::GameState)
    p1 = game.input.menu.menupkmn.swap
    p2 = game.input.menu.menupkmn.select
    
    if game.n[:pkmnswap].c == 1
        swap!(game.trainer.pokemon,p1,p2)

        if p1 == 1 || p2 == 1
            killSprite!(game,1,Symbol("slot$p1"))
            killSprite!(game,1,Symbol("slot$p2"))
            killSprite!(game,1,Symbol("ball$p1"))
            killSprite!(game,1,Symbol("ball$p2"))

            b = getSprite("im/menu/pkmn/pokeballs",2)

            drawSlotMain!(game,b)
            drawSlotSide!(game,p1 == 1 ? p2 : p1,b)
        else
            swapfields!(game.im.sprites[1],:dict,Symbol("slot$p1"),Symbol("slot$p2"))
            swapfields!(game.im.sprites[1],:im,Symbol("slot$p1"),Symbol("slot$p2"))
        end
    elseif game.n[:pkmnswap].c == 2
        killCC!(game,:pkmnswap)

        updateSlots!(game)

        game.input.menu.menupkmn.swap = 0
        game.input.inputlock = false

        return
    end

    game.n[:pkmnswap].c += 1

    return
end
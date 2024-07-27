


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

    return
end

function sceneTransition!(game::GameState, # pause >= 1!
        (len,pause,state1,state2)::Tuple{Int,Int,Callback,Callback})
    
    if game.n[:scenet].c <= len
        game.im.l.color[4] = 1.0 - game.n[:scenet].c/len
    elseif game.n[:scenet].c == len+1
        Base.GC.gc()

        # evalCallback(game,state1)
        state1.func(game,state1.args...)
    elseif len+pause+1 <= game.n[:scenet].c <= 2*len+pause
        game.im.l.color[4] = 1.0 - (2*len+pause-game.n[:scenet].c)/len
    elseif game.n[:scenet].c == 2*len+pause+1
        game.im.l.color[4] = 1.0

        # evalCallback(game,state2)
        state2.func(game,state2.args...)

        killCC!(game,:scenet)

        return
    end
   
    game.n[:scenet].c += 1

    return
end

# function sceneTransition!(game::GameState,len::Int,pause::Int,  # pause >= 1!
#         (len,pause,state1,state2,fade1,fade2)::Tuple{Int,Int,Callback,Callback,Function,Function})
    
#     if game.n[:scenet].c == 1
#         game.im.postprocess.args = (UInt8(len),0x01,)
#     elseif game.n[:scenet].c <= len
#         game.im.postprocess.args = (UInt8(len),UInt8(game.n[:scenet].c),)
#     elseif game.n[:scenet].c == len+1
#         Base.GC.gc()

#         state1(game,state1args...)
#     elseif len+pause+1 <= game.n[:scenet].c <= 2*len+pause
#         game.im.postprocess.args = (UInt8(len),UInt8(2*len+pause-game.n[:scenet].c),)
#     elseif game.n[:scenet].c == 2*len+pause+1
#         state2(game,state2args...)

#         killCC!(game,:scenet)

#         return
#     end
   
#     game.n[:scenet].c += 1

#     return
# end

function animArrowsMenu!(game::GameState)
    if (game.n.frame%48) < 24
        game.im.sprites[1][:arrowleft].pos = P(24+8,16+22-div((game.n.frame%24),6))
        game.im.sprites[1][:arrowright].pos = P(24+8,16+90+div((game.n.frame%24),6))
    else
        game.im.sprites[1][:arrowleft].pos = P(24+8,16+22-4+div((game.n.frame%24),6))
        game.im.sprites[1][:arrowright].pos = P(24+8,16+90+4-div((game.n.frame%24),6))
    end

    return
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

function animMenuPkmnWiggle!(game::GameState,args::Tuple{})
    for i in 1:game.p.pokemon.idx
        if i == game.ctrl.input.menu.menupkmn.select
            setSpriteFrame!(game,mplabels[i].ic,Int(div(game.frame%16,8)+1))

            if i == 1
                moveSpriteH!(game,mplabels[i].ic,
                    -44-2*Int(div(game.frame%16,8)),true)
            else
                moveSpriteH!(game,mplabels[i].ic,
                    -63+24*(i-2)-2*Int(div(game.frame%16,8)),true)
            end

            continue
        end

        setSpriteFrame!(game,mplabels[i].ic,Int(div((game.frame+2i)%20,10)+1))
    end

    return
end

function animMenuPkmnSwap!(game::GameState,(p1,p2)::Tuple{Int,Int})
    if game.n[:pkmnswap].c <= 30
        moveSprite!(game,mplabels[p1].s,8-12*(p1==1),0)
        moveSprite!(game,mplabels[p1].b,8-12*(p1==1),0)
        moveSprite!(game,mplabels[p1].st,8-12*(p1==1),0)
        moveSprite!(game,mplabels[p1].i,8-12*(p1==1),0)
        moveSprite!(game,mplabels[p1].ic,8-12*(p1==1),0)
        # moveSprite!(game,mplabels[p1].h,8-12*(p1==1),0)
        # moveSprite!(game,mplabels[p1].g,8-12*(p1==1),0)
        moveText!(game,mplabels[p1].n,8-12*(p1==1),0)
        moveText!(game,mplabels[p1].h,8-12*(p1==1),0)

        moveSprite!(game,mplabels[p2].s,8-12*(p2==1),0)
        moveSprite!(game,mplabels[p2].b,8-12*(p2==1),0)
        moveSprite!(game,mplabels[p2].st,8-12*(p2==1),0)
        moveSprite!(game,mplabels[p2].i,8-12*(p2==1),0)
        moveSprite!(game,mplabels[p2].ic,8-12*(p2==1),0)
        # moveSprite!(game,mplabels[p2].h,8-12*(p2==1),0)
        # moveSprite!(game,mplabels[p2].g,8-12*(p2==1),0)   
        moveText!(game,mplabels[p2].n,8-12*(p2==1),0)
        moveText!(game,mplabels[p2].h,8-12*(p2==1),0)
    elseif game.n[:pkmnswap].c == 31
        swap!(game.p.pokemon,p1,p2)

        setText!(game,mplabels[p1].n,
            pkmnName(game,game.p.pokemon[p1])*"\\   Lv.$(game.p.pokemon[p1].stats.level)")
        setText!(game,mplabels[p1].h,
            string(game.p.pokemon[p1].stats.hp)*"/"*string(game.p.pokemon[p1].stats.rv[1]))
        
        setText!(game,mplabels[p2].n,
            pkmnName(game,game.p.pokemon[p2])*"\\   Lv.$(game.p.pokemon[p2].stats.level)")
        setText!(game,mplabels[p2].h,
            string(game.p.pokemon[p2].stats.hp)*"/"*string(game.p.pokemon[p2].stats.rv[1]))

        game.im.s.sprites[mplabels[p1].ic], game.im.s.sprites[mplabels[p2].ic] = 
            game.im.s.sprites[mplabels[p2].ic], game.im.s.sprites[mplabels[p1].ic]
        game.im.s.sprites[mplabels[p1].i], game.im.s.sprites[mplabels[p2].i] = 
            game.im.s.sprites[mplabels[p2].i], game.im.s.sprites[mplabels[p1].i]
        game.im.s.sprites[mplabels[p1].st], game.im.s.sprites[mplabels[p2].st] = 
            game.im.s.sprites[mplabels[p2].st], game.im.s.sprites[mplabels[p1].st]
        # game.im.s.sprites[mplabels[p1].h], game.im.s.sprites[mplabels[p2].h] = 
        #     game.im.s.sprites[mplabels[p2].h], game.im.s.sprites[mplabels[p1].h]
        # game.im.s.sprites[mplabels[p1].g], game.im.s.sprites[mplabels[p2].g] = 
        #     game.im.s.sprites[mplabels[p2].g], game.im.s.sprites[mplabels[p1].g]
    elseif game.n[:pkmnswap].c <= 61
        moveSprite!(game,mplabels[p1].s,12*(p1==1)-8,0)
        moveSprite!(game,mplabels[p1].b,12*(p1==1)-8,0)
        moveSprite!(game,mplabels[p1].st,12*(p1==1)-8,0)
        moveSprite!(game,mplabels[p1].i,12*(p1==1)-8,0)
        moveSprite!(game,mplabels[p1].ic,12*(p1==1)-8,0)
        # moveSprite!(game,mplabels[p1].h,12*(p1==1)-8,0)
        # moveSprite!(game,mplabels[p1].g,12*(p1==1)-8,0)
        moveText!(game,mplabels[p1].n,12*(p1==1)-8,0)
        moveText!(game,mplabels[p1].h,12*(p1==1)-8,0)

        moveSprite!(game,mplabels[p2].s,12*(p2==1)-8,0)
        moveSprite!(game,mplabels[p2].b,12*(p2==1)-8,0)
        moveSprite!(game,mplabels[p2].st,12*(p2==1)-8,0)
        moveSprite!(game,mplabels[p2].i,12*(p2==1)-8,0)
        moveSprite!(game,mplabels[p2].ic,12*(p2==1)-8,0)
        # moveSprite!(game,mplabels[p2].h,12*(p2==1)-8,0)
        # moveSprite!(game,mplabels[p2].g,12*(p2==1)-8,0)   
        moveText!(game,mplabels[p2].n,12*(p2==1)-8,0)
        moveText!(game,mplabels[p2].h,12*(p2==1)-8,0)
    elseif game.n[:pkmnswap].c == 62
        killCC!(game,:pkmnswap)

        setSprite!(game,mplabels[p1].s,1,1)
        setSprite!(game,mplabels[p1].b,1,1)
        
        setSprite!(game,mplabels[p2].s,1,2)
        setSprite!(game,mplabels[p2].b,1,2)

        game.ctrl.input.menu.menupkmn.swap = 0
        game.ctrl.input.inputlock = false

        return
    end

    game.n[:pkmnswap].c += 1

    return
end
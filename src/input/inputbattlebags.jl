

function inputBattleInventory!(game::GameState,input::Input)
    if game.input.battlebags.sub
        inputBattleBagsSub!(game,input)

        return
    end

    if game.input.choice.sel == -1
        game.input.choice.sel = 0

        game.im.sprites[:cursor].palette[1] = 0x010101

        return
    end

    inputBattleBags!(game,input)
end

function inputBattleBags!(game::GameState,input::Input)
    if input._A
        if getSelect(game.input.battlebags) == getAmountItems(game,game.input.battlebags)+1
            game.input.inputlock = true
            game.input.battlebag = false
    
            createCC!(game,:scenet,sceneTransition!,(16,8,
                stateBattleBagsClose!,(),stateBattleCtrls!,()); active=true,n=1)
    
            return
        end

        game.im.sprites[:cursor].palette[1] = 0xd0d0c8
        setChoice!(game,true,1,itemBattleAction!,())

        drawChoiceMenu!(game,:layer4,getInvChoiceStr(game),7,P(120,192))
    elseif input._B
        game.input.inputlock = true
        game.input.battlebag = false

        createCC!(game,:scenet,sceneTransition!,(16,8,
            stateBattleBagsClose!,(),stateBattleCtrls!,()); active=true,n=1)

        return
    elseif input._down
        if getSelect(game.input.battlebags) == getAmountItems(game,game.input.battlebags)+1
            game.input.battlebags.select[game.input.battlebags.bag] = 1
            game.input.battlebags.slot = 1

            setVisibleItems!(game,game.input.battlebags)
            setPos!(game.im.sprites[:cursor].pos,24+22,16+114)

            flushLayer!(game,:layer2)
            drawInventoryText!(game,game.input.battlebags)
        elseif game.input.battlebags.slot == 6 &&
                getSelect(game.input.battlebags)+1 < getAmountItems(game,game.input.battlebags)
            
            game.input.battlebags.select[game.input.battlebags.bag] += 1

            game.input.battlebags.vis[1:7,:] = game.input.battlebags.vis[2:8,:]
            game.input.battlebags.vis[8,:] .= getSelect(game.input.battlebags)+1 < getAmountItems(game,game.input.battlebags) ?
                getInvSlot(game,game.input.battlebags.bag,getSelect(game.input.battlebags)+2) : (-1,0)

            drawSlotSwitchDown!(game,game.input.battlebags)
        else
            game.input.battlebags.slot += 1
            game.input.battlebags.select[game.input.battlebags.bag] += 1

            posAdd!(game.im.sprites[:cursor].pos,15,0)
        end

        setInventoryItemIcon!(game,game.input.battlebags)
        drawItemText!(game,game.input.battlebags)
    elseif input._up
        if getSelect(game.input.battlebags) == 1
            game.input.battlebags.select[game.input.battlebags.bag] = getAmountItems(game,game.input.battlebags)+1
            game.input.battlebags.slot = min(8,getAmountItems(game,game.input.battlebags))+1

            setVisibleItems!(game,game.input.battlebags)
            game.input.battlebags.vis[8,1] = -1
            setPos!(game.im.sprites[:cursor].pos,
                24+22+15*(game.input.battlebags.slot-1),16+114)

            flushLayer!(game,:layer2)
            drawInventoryText!(game,game.input.battlebags)
        elseif game.input.battlebags.slot == 3 &&
                getSelect(game.input.battlebags) > 3
            
            game.input.battlebags.select[game.input.battlebags.bag] -= 1

            game.input.battlebags.vis[2:8,:] = game.input.battlebags.vis[1:7,:]
            game.input.battlebags.vis[1,:] .= getInvSlot(game,
                game.input.battlebags.bag,getSelect(game.input.battlebags)-2)

            drawSlotSwitchUp!(game,game.input.battlebags)
        else
            game.input.battlebags.slot -= 1
            game.input.battlebags.select[game.input.battlebags.bag] -= 1

            posAdd!(game.im.sprites[:cursor].pos,-15,0)
        end

        setInventoryItemIcon!(game,game.input.battlebags)
        drawItemText!(game,game.input.battlebags)
    elseif input._left
        if game.input.battlebags.bag == 1
            game.input.battlebags.bag = 5
        else
            game.input.battlebags.bag -= 1
        end
        
        setVisibleItems!(game,game.input.battlebags)
        flushLayer!(game,:layer2)

        game.im.sprites[:cursor].active = false
        setPos!(game.im.sprites[:cursor].pos,
            24+7+15*game.input.battlebags.slot,16+114)

        game.im.sprites[:icon].active = false
        setInventoryItemIcon!(game,game.input.battlebags)

        game.input.inputlock = true
        game.callbacks[:bagswitch].active = true
    elseif input._right
        if game.input.battlebags.bag == 5
            game.input.battlebags.bag = 1
        else
            game.input.battlebags.bag += 1
        end

        setVisibleItems!(game,game.input.battlebags)
        flushLayer!(game,:layer2)

        game.im.sprites[:cursor].active = false
        setPos!(game.im.sprites[:cursor].pos,
            24+7+15*game.input.battlebags.slot,16+114)

        game.im.sprites[:icon].active = false
        setInventoryItemIcon!(game,game.input.battlebags)

        game.input.inputlock = true
        game.callbacks[:bagswitch].active = true
    end
end

function itemBattleAction!(game::GameState)
    if game.input.battlebags.bag == 1
        itemBattleActionItems!(game)
    elseif game.input.battlebags.bag == 2
        itemBattleActionBalls!(game)
    elseif game.input.battlebags.bag == 3
        resetChoice!(game)
    elseif game.input.battlebags.bag == 4
        itemBattleActionBerries!(game)
    else
        resetChoice!(game)
    end
end

function itemBattleActionItems!(game::GameState)
    if game.input.choice.sel == 1
        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,());
            active=true,n=1)

        game.input.inputlock = true
        game.input.battlebags.submode = 1
    end
    
    resetChoice!(game)
end

function itemBattleActionBalls!(game::GameState)
    game.input.battlebag = false
    game.input.inputlock = true

    if game.input.choice.sel == 1
        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateBattleBagsClose!,(),stateBattleItemSelected!,
            (UInt(0),getItem(game,game.input.battlebags)));
            active=true,n=1)
    end
    
    resetChoice!(game)
end

function itemBattleActionBerries!(game::GameState)
    if game.input.choice.sel == 1
        return
    elseif game.input.choice.sel == 2
        return
    end
    
    resetChoice!(game)
end

function itemBattleActionKeys!(game::GameState)    
    resetChoice!(game)
end



function applyItem!(game::GameState)
    item = getItem(getInvSlotID(game))
    target = game.trainer.pokemon[game.input.battlebags.subslot]

    applyItem!(target,item)
end

function applyItem!(target::Pkmn,item::MedicineHealth)
    if !checkItemApplicable(target,item)
        return
    end

    if target.status == 0x07
        target.stats.rv[1] = floor(UInt16,target.stats.hp*item.amount/100)
        target.status = 0x00

        return
    end

    (target.status == target.item || item.status == 0x06) &&
        (target.status = 0x00)
    
    target.stats.rv[1] = max(target.hp,target.stats.rv[1] + (item.fraction ? 
        floor(UInt16,target.stats.hp*item.amount/100) : item.amount))
end

function checkItemApplicable(target::Pkmn,item::MedicineHealth)
    if target.status == 0x07
        return item.status == 0x07
    elseif item.status != 0 && item.amount == 0
        return target.status == item.status || item.status == 0x06
    elseif item.status != 0 && item.amount != 0
        return target.status == item.status || item.status == 0x06 ||
            target.stats.hp != target.stats.rv[1]
    else
        return target.stats.hp != target.stats.rv[1]
    end
end
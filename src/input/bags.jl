

function inputInventory!(game::GameState,input::Input)
    if game.input.menu.menubags.sub
        inputBagsSub!(game,input)

        return
    end

    if game.input.choice.sel == -1
        game.input.choice.sel = 0

        game.im.sprite[1][:cursor].palette[1] = 0x010101

        return
    end

    inputBags!(game,input)

    return
end

function inputBags!(game::GameState,input::Input)
    if input._A
        if getSelect(game) == getAmountItems(game)+1
            game.input.inputlock = true
            game.input.menu.bags = false
    
            createCC!(game,:scenet,sceneTransition!,(16,8,
                stateMenuBagsClose!,(),stateMenuMainOpen!,()); active=true,n=1)
    
            return
        end

        game.im.sprites[1][:cursor].palette[1] = 0xd0d0c8
        setChoice!(game,true,1,itemAction!,())

        drawChoiceMenu!(game,4,getInvChoiceStr(game),7,P(120,192))
    elseif input._B
        game.input.inputlock = true
        game.input.menu.bags = false

        createCC!(game,:scenet,sceneTransition!,(16,8,
            stateMenuBagsClose!,(),stateMenuMainOpen!,()); active=true,n=1)

        return
    elseif input._down
        if getSelect(game) == getAmountItems(game)+1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] = 1
            game.input.menu.menubags.slot = 1

            setVisibleItems!(game,game.input.menu.menubags)
            setPos!(game.im.sprites[:cursor].pos,24+22,16+114)

            flushLayer!(game,:layer2)
            drawInventoryText!(game,game.input.menu.menubags)
        elseif game.input.menu.menubags.slot == 6 &&
                getSelect(game)+1 < getAmountItems(game)
            
            game.input.menu.menubags.select[game.input.menu.menubags.bag] += 1

            game.input.menu.menubags.vis[1:7,:] = game.input.menu.menubags.vis[2:8,:]
            game.input.menu.menubags.vis[8,:] .= getSelect(game)+1 < getAmountItems(game) ?
                getInvSlot(game,game.input.menu.menubags.bag,getSelect(game)+2) : (-1,0)

            drawSlotSwitchDown!(game,game.input.menu.menubags)
        else
            game.input.menu.menubags.slot += 1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] += 1

            posAdd!(game.im.sprites[:cursor].pos,15,0)
        end

        setInventoryItemIcon!(game,game.input.menu.menubags)
        drawItemText!(game,game.input.menu.menubags)
    elseif input._up
        if getSelect(game) == 1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] = getAmountItems(game)+1
            game.input.menu.menubags.slot = min(8,getAmountItems(game)+1)

            setVisibleItems!(game,game.input.menu.menubags)
            game.input.menu.menubags.vis[8,1] = -1
            setPos!(game.im.sprites[1][:cursor].pos,
                24+22+15*(game.input.menu.menubags.slot-1),16+114)

            flushLayer!(game,2)
            drawInventoryText!(game,game.input.menu.menubags)
        elseif game.input.menu.menubags.slot == 3 &&
                getSelect(game) > 3
            
            game.input.menu.menubags.select[game.input.menu.menubags.bag] -= 1

            game.input.menu.menubags.vis[2:8,:] = game.input.menu.menubags.vis[1:7,:]
            game.input.menu.menubags.vis[1,:] .= getInvSlot(game,
                game.input.menu.menubags.bag,getSelect(game)-2)

            drawSlotSwitchUp!(game,game.input.menu.menubags)
        else
            game.input.menu.menubags.slot -= 1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] -= 1

            posAdd!(game.im.sprites[1][:cursor].pos,-15,0)
        end

        setInventoryItemIcon!(game,game.input.menu.menubags)
        drawItemText!(game,game.input.menu.menubags)
    elseif input._left
        if game.input.menu.menubags.bag == 1
            game.input.menu.menubags.bag = 5
        else
            game.input.menu.menubags.bag -= 1
        end
        
        setVisibleItems!(game,game.input.menu.menubags)
        flushLayer!(game,2)

        game.im.sprites[1][:cursor].active = false
        setPos!(game.im.sprites[1][:cursor].pos,
            24+7+15*game.input.menu.menubags.slot,16+114)

        game.im.sprites[1][:icon].active = false
        setInventoryItemIcon!(game,game.input.menu.menubags)

        game.input.inputlock = true
        game.callbacks[:bagswitch].active = true
    elseif input._right
        if game.input.menu.menubags.bag == 5
            game.input.menu.menubags.bag = 1
        else
            game.input.menu.menubags.bag += 1
        end

        setVisibleItems!(game,game.input.menu.menubags)
        flushLayer!(game,2)

        game.im.sprites[1][:cursor].active = false
        setPos!(game.im.sprites[1][:cursor].pos,
            24+7+15*game.input.menu.menubags.slot,16+114)

        game.im.sprites[1][:icon].active = false
        setInventoryItemIcon!(game,game.input.menu.menubags)

        game.input.inputlock = true
        game.callbacks[:bagswitch].active = true
    end
end

function inputBagsSub!(game::GameState,input::Input)
    if input._A
        if game.input.menu.menubags.subslot == game.trainer.pokemon.idx+1
            game.input.inputlock = true
            game.input.menu.menubags.sub = false
            game.input.menu.menubags.subslot = 1

            createCC!(game,:scenet,sceneTransition!,(16,8,
                stateMenuPkmnSubClose!,(),stateMenuBagsCtrls!,()); active=true,n=1)

            return
        end

        applyItem!(game::GameState)
    elseif input._B
        game.input.inputlock = true
        game.input.menu.menubags.sub = false
        game.input.menu.menubags.subslot = 1

        createCC!(game,:scenet,sceneTransition!,(16,8,
            stateMenuPkmnSubClose!,(),stateMenuBagsCtrls!,()); active=true,n=1)

        return
    elseif input._down
        if game.input.menu.menubags.subslot == game.trainer.pokemon.idx+1
            switchSlot!(game,game.input.menu.menubags.subslot,1)
    
            game.input.menu.menubags.subslot = 1
        else
            switchSlot!(game,game.input.menu.menubags.subslot,
                game.input.menu.menubags.subslot+1)
    
            game.input.menu.menubags.subslot += 1
        end
    elseif input._up
        if game.input.menu.menubags.subslot == 1
            switchSlot!(game,1,game.trainer.pokemon.idx+1)
    
            game.input.menu.menubags.subslot = game.trainer.pokemon.idx+1
        else
            switchSlot!(game,game.input.menu.menubags.subslot,
                game.input.menu.menubags.subslot-1)
    
            game.input.menu.menubags.subslot -= 1
        end
    elseif input._left || input._right
        if game.input.menu.menubags.subslot == 1
            switchSlot!(game,1,2)
    
            game.input.menu.menubags.subslot = 2
        else
            switchSlot!(game,game.input.menu.menubags.subslot,1)
    
            game.input.menu.menubags.subslot = 1
        end
    end
end

function itemAction!(game::GameState)
    if game.input.menu.menubags.bag == 1
        itemActionItems!(game)
    elseif game.input.menu.menubags.bag == 2
        itemActionBalls!(game)
    elseif game.input.menu.menubags.bag == 3
        itemActionsMachines!(game)
    elseif game.input.menu.menubags.bag == 4
        itemActionBerries!(game)
    else
        itemActionKeys!(game)
    end
end

function itemActionItems!(game::GameState)
    if game.input.choice.sel == 1
        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

        game.input.inputlock = true
        game.input.menu.menubags.submode = 1
    elseif game.input.choice.sel == 2
        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

        game.input.inputlock = true
        game.input.menu.menubags.submode = 2

        return
    end
    
    resetChoice!(game)
end

function itemActionBalls!(game::GameState)
    if game.input.choice.sel == 1
        return
    elseif game.input.choice.sel == 2
        return
    end
    
    resetChoice!(game)
end

function itemActionMachines!(game::GameState)
    if game.input.choice.sel == 1
        return
    elseif game.input.choice.sel == 2
        return
    end
    
    resetChoice!(game)
end

function itemActionBerries!(game::GameState)
    if game.input.choice.sel == 1
        return
    elseif game.input.choice.sel == 2
        return
    end
    
    resetChoice!(game)
end

function itemActionKeys!(game::GameState)
    if game.input.choice.sel == 1
        return
    elseif game.input.choice.sel == 2
        return
    end
    
    resetChoice!(game)
end



function applyItem!(game::GameState)
    item = getItem(getInvSlotID(game))
    target = game.trainer.pokemon[game.input.menu.menubags.subslot]

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
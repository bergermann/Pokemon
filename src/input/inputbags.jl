

function inputInventory!(game::GameState,input::Input)
    if game.input.choice.sel != 0
        println("choice!")

        return
    end

    inputBags!(game,input)
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

        updateSprite!(game,:cursor,2)
        setChoice!(game,true,1,itemAction,())

        drawChoiceMenu!(game,:layer4,getInvChoiceStr(game),7,P(120,192))
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

            setVisibleItems!(game)
            setPos!(game.im.sprites[:cursor].pos,24+22,16+114)

            flushLayer!(game,:layer2)
            drawInventoryText!(game)
        elseif game.input.menu.menubags.slot == 6 &&
                getSelect(game)+1 < getAmountItems(game)
            
            game.input.menu.menubags.select[game.input.menu.menubags.bag] += 1

            game.input.menu.menubags.vis[1:7,:] = game.input.menu.menubags.vis[2:8,:]
            game.input.menu.menubags.vis[8,:] .= getSelect(game)+1 < getAmountItems(game) ?
                getInvSlot(game,game.input.menu.menubags.bag,getSelect(game)+2) : (-1,0)

            drawSlotSwitchDown!(game)
        else
            game.input.menu.menubags.slot += 1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] += 1

            posAdd!(game.im.sprites[:cursor].pos,15,0)
        end

        setInventoryItemIcon!(game)
        drawItemText!(game)
    elseif input._up
        if getSelect(game) == 1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] = getAmountItems(game)+1
            game.input.menu.menubags.slot = min(8,getAmountItems(game)+1)

            setVisibleItems!(game)
            game.input.menu.menubags.vis[8,1] = -1
            setPos!(game.im.sprites[:cursor].pos,
                24+22+15*(game.input.menu.menubags.slot-1),16+114)

            flushLayer!(game,:layer2)
            drawInventoryText!(game)
        elseif game.input.menu.menubags.slot == 3 &&
                getSelect(game) > 3
            
            game.input.menu.menubags.select[game.input.menu.menubags.bag] -= 1

            game.input.menu.menubags.vis[2:8,:] = game.input.menu.menubags.vis[1:7,:]
            game.input.menu.menubags.vis[1,:] .= getInvSlot(game,
                game.input.menu.menubags.bag,getSelect(game)-2)

            drawSlotSwitchUp!(game)
        else
            game.input.menu.menubags.slot -= 1
            game.input.menu.menubags.select[game.input.menu.menubags.bag] -= 1

            posAdd!(game.im.sprites[:cursor].pos,-15,0)
        end

        setInventoryItemIcon!(game)
        drawItemText!(game)
    elseif input._left
        if game.input.menu.menubags.bag == 1
            game.input.menu.menubags.bag = 5
        else
            game.input.menu.menubags.bag -= 1
        end
        
        setVisibleItems!(game)
        flushLayer!(game,:layer2)

        game.im.sprites[:cursor].active = false
        setPos!(game.im.sprites[:cursor].pos,
            24+7+15*game.input.menu.menubags.slot,16+114)

        game.im.sprites[:icon].active = false
        filter!(p -> p.first < 0, game.im.sprites[:icon].dict)
        merge!(game.im.sprites[:icon].dict,getItemIcons(game))
            
        setInventoryItemIcon!(game)

        game.input.inputlock = true
        game.callbacks[:bagswitch].active = true
    elseif input._right
        if game.input.menu.menubags.bag == 5
            game.input.menu.menubags.bag = 1
        else
            game.input.menu.menubags.bag += 1
        end

        setVisibleItems!(game)
        flushLayer!(game,:layer2)

        game.im.sprites[:cursor].active = false
        setPos!(game.im.sprites[:cursor].pos,
            24+7+15*game.input.menu.menubags.slot,16+114)

        game.im.sprites[:icon].active = false
        filter!(p -> p.first < 0, game.im.sprites[:icon].dict)
        merge!(game.im.sprites[:icon].dict,getItemIcons(game))
            
        setInventoryItemIcon!(game)

        game.input.inputlock = true
        game.callbacks[:bagswitch].active = true
    end
end

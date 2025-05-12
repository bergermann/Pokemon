

function inputInventory!(game::GameState,inputs::Inputs)
    if game.ctrl.input.choice.sel == -1
        game.ctrl.input.choice.sel = 0

        setSpriteFrame!(game,:cursor,3)

        return
    end

    if game.battle.active
        inputBags!(game,inputs,game.ctrl.input.menu.battlebags)
    else
        inputBags!(game,inputs,game.ctrl.input.menu.menubags)
    end

    return
end

function inputBags!(game::GameState,inputs::Inputs,m::MenuBags)
    display(m)
    if inputs.A.press
        if getSelectedItem(game,m) == 500
            lockInput!(game)
            game.ctrl.input.menu.bags = false
    
            createCC!(game,:scenet,sceneTransition!,(16,8,
                F(stateBagsClose!),F0); active=true,n=1)
    
            return
        end

        setChoice!(game,true,1,F(itemAction!,(m,)))    
        drawChoiceMenu!(game,6,getInvChoiceStr(game,m),7,0,0)
    elseif inputs.B.press
        lockInput!(game)
        game.ctrl.input.menu.bags = false

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateBagsClose!),F0); active=true,n=1)
        return
    elseif inputs.down.press
        if m.select[m.bag] == game.p.inventory[-m.bag]+1
            m.select[m.bag] = 1
            m.cursor[m.bag] = 1
        else
            m.select[m.bag] += 1

            if m.cursor[m.bag] < 6 || (game.p.inventory[-m.bag]-m.select[m.bag]) < 1
                m.cursor[m.bag] += 1
            end
        end

        moveSpriteH!(game,:cursor,-71+16*m.cursor[m.bag],true)

        moveText!(game,:items,0,-63+16*(m.cursor[m.bag]-m.select[m.bag]),true)
        moveText!(game,:amounts,90,-63+16*(m.cursor[m.bag]-m.select[m.bag]),true)

        setText!(game,:info,game.str[3][getSelectedItem(game,m)])
        setSpriteIdx!(game,:item,getSelectedItem(game,m))
    elseif inputs.up.press
        if m.select[m.bag] == 1
            m.select[m.bag] = game.p.inventory[-m.bag]+1
            m.cursor[m.bag] = min(game.p.inventory[-m.bag]+1,8)
        else
            m.select[m.bag] -= 1

            if m.cursor[m.bag] > 3 || (m.select[m.bag]) < 3
                m.cursor[m.bag] -= 1
            end
        end

        moveSpriteH!(game,:cursor,-71+16*m.cursor[m.bag],true)

        moveText!(game,:items,0,-63+16*(m.cursor[m.bag]-m.select[m.bag]),true)
        moveText!(game,:amounts,90,-63+16*(m.cursor[m.bag]-m.select[m.bag]),true)
        
        setText!(game,:info,game.str[3][getSelectedItem(game,m)])
        setSpriteIdx!(game,:item,getSelectedItem(game,m))
    elseif inputs.left.press
        if m.bag == 1
            m.bag = 5
        else
            m.bag -= 1
        end
        
        lockInput!(game)
        activateCallback!(game,:bagswitch)
        game.callbacks[:bagswitch].args = (m,-1,)
    elseif inputs.right.press
        if m.bag == 5
            m.bag = 1
        else
            m.bag += 1
        end

        lockInput!(game)
        activateCallback!(game,:bagswitch)
        game.callbacks[:bagswitch].args = (m,1,)
    end

    if m.select[m.bag]-m.cursor[m.bag] <= 0
        deactivateSprite!(game,:up)
    else
        activateSprite!(game,:up)
    end

    if (game.p.inventory[-m.bag]-(m.select[m.bag]-m.cursor[m.bag])) < 8
        deactivateSprite!(game,:down)
    else
        activateSprite!(game,:down)
    end

    return
end

function itemAction!(game::GameState,(m,)::Tuple{MenuBags})
    if m.bag == 1
        itemActionItems!(game)
    elseif m.bag == 2
        itemActionBalls!(game)
    elseif m.bag == 3
        itemActionsMachines!(game)
    elseif m.bag == 4
        itemActionBerries!(game)
    else
        itemActionKeys!(game)
    end

    return
end

function itemActionItems!(game::GameState)
    if game.battle.active   # battle bags
        if game.ctrl.input.choice.sel == 1
            createCC!(game,:scenet,sceneTransition!,
                (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,());
                active=true,n=1)

            lockInput!(game)
            game.ctrl.input.battlebags.submode = 1
        end
    elseif game.ctrl.input.menu.menupkmn.sub
        
    else    # standard bags
        if game.ctrl.input.choice.sel == 1
            createCC!(game,:scenet,sceneTransition!,
                (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

            lockInput!(game)
            game.ctrl.input.menu.menubags.submode = 1
        elseif game.ctrl.input.choice.sel == 2
            createCC!(game,:scenet,sceneTransition!,
                (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

            lockInput!(game)
            game.ctrl.input.menu.menubags.submode = 2

            return
        end
    end
    
    resetChoice!(game)

    return
end

function itemActionBalls!(game::GameState)
    if game.battle.active   # battle bags
        lockInput!(game)

        if game.ctrl.input.choice.sel == 1
            stateBattleItemSelected!(game,UInt(2),getItem(game,game.ctrl.input.menu.battlebags))

            createCC!(game,:scenet,sceneTransition!,
                (16,8,F(stateBagsClose!),F(stateStartBattleAnim!)); active=true,n=1)
        end
    elseif game.ctrl.input.menu.menupkmn.sub

    else    # standard bags
        if game.ctrl.input.choice.sel == 1
            return
        elseif game.ctrl.input.choice.sel == 2
            return
        end
    end
    
    resetChoice!(game)

    return
end

function itemActionMachines!(game::GameState)
    if game.ctrl.input.choice.sel == 1
        return
    elseif game.ctrl.input.choice.sel == 2
        return
    end
    
    resetChoice!(game)
end

function itemActionBerries!(game::GameState)
    if game.ctrl.input.choice.sel == 1
        return
    elseif game.ctrl.input.choice.sel == 2
        return
    end
    
    resetChoice!(game)
end

function itemActionKeys!(game::GameState)
    if game.ctrl.input.choice.sel == 1
        return
    elseif game.ctrl.input.choice.sel == 2
        return
    end
    
    resetChoice!(game)
end



function applyItem!(game::GameState)
    item = getItem(getSelectedItem(game,game.ctrl.input.menu.menubags))
    target = game.p.pokemon[game.ctrl.input.menu.menubags.subslot]

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
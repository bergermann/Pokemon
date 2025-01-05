
function inputDex!(game::GameState,inputs::Inputs)
    if game.ctrl.input.menu.menudex.info
        inputDexPage!(game,inputs)
    else
        inputDexScroll!(game,inputs)
    end

    return
end

function inputDexScroll!(game::GameState,inputs::Inputs)
    if inputs.A.press
        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateDexInfo!),F()); active=true,n=1)
    elseif inputs.B.press
        lockInput!(game)
        game.ctrl.input.menu.dex = false

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateDexClose!),F()); active=true,n=1)
    elseif inputs.down.press && game.ctrl.input.menu.menudex.speed == 0
        if game.ctrl.input.menu.menudex.select == 151
            game.ctrl.input.menu.menudex.select = 1
        else
            game.callbacks[:scroll].active = true
            game.ctrl.input.menu.menudex.speed = 1
            lockInput!(game)
        end
    elseif inputs.up.press && game.ctrl.input.menu.menudex.speed == 0
        if game.ctrl.input.menu.menudex.select == 1 && !inputs..press
            game.ctrl.input.menu.menudex.select = 1
        else
            game.callbacks[:scroll].active = true
            game.ctrl.input.menu.menudex.speed = -1
            lockInput!(game)
        end
    elseif inputs.down.hold
        if game.ctrl.input.menu.menudex.select == 151
            game.callbacks[:scroll].active = false
        else
            game.callbacks[:scroll].active = true
            game.ctrl.input.menu.menudex.speed = min(8,2*game.ctrl.input.menu.menudex.speed)
        end
    elseif inputs.up.hold
        if game.ctrl.input.menu.menudex.select == 1
            game.callbacks[:scroll].active = false
        else
            game.callbacks[:scroll].active = true
            game.ctrl.input.menu.menudex.speed = max(-8,2*game.ctrl.input.menu.menudex.speed)
        end
    else
        game.ctrl.input.menu.menudex.speed = 0
    end

    return
end

function inputDexPage!(game::GameState,inputs::Inputs)
    if inputs.A.press

    elseif inputs.B.press
        lockInput!(game)
        game.ctrl.input.menu.menudex.info = false

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateDexInfoClose!),F()); active=true,n=1)
    elseif inputs.down.press
        if game.ctrl.input.menu.menudex.select == 151
            game.ctrl.input.menu.menudex.select = 1
        else
            game.ctrl.input.menu.menudex.select += 1
        end

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateDexInfoSwitch!),F()); active=true,n=1)
    elseif inputs.up.press
        if game.ctrl.input.menu.menudex.select == 1
            game.ctrl.input.menu.menudex.select = 1
        else
            game.ctrl.input.menu.menudex.select -= 1
        end

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateDexInfoSwitch!),F()); active=true,n=1)
    elseif inputs.left.press
        if game.ctrl.input.menu.menudex.page > 1
            game.ctrl.input.menu.menudex.page -= 1

            lockInput!(game)
            game.callbacks[:pageswitch].active = true
            game.callbacks[:pageswitch].args = (-1,)
        end
    elseif inputs.right.press
        if game.ctrl.input.menu.menudex.page < 3
            game.ctrl.input.menu.menudex.page += 1

            lockInput!(game)
            game.callbacks[:pageswitch].active = true
            game.callbacks[:pageswitch].args = (1,)
        end
    end

    return
end

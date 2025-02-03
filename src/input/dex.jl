
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
        lockInput!(game)
        deactivateCallback!(game,:scroll)
        deactivateCallback!(game,:arrows)
        # createCC!(game,:scenet,sceneTransition!,(16,8,
        #     F(stateDexInfo!),F()); active=true,n=1)
        createCC!(game,:infot,animDexInfo!,(); active=true)
    elseif inputs.B.press
        lockInput!(game)
        game.ctrl.input.menu.dex = false

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateMenuDexClose!),F()); active=true,n=1)
    elseif inputs.down.press && game.ctrl.input.menu.menudex.speed == 0
        if game.ctrl.input.menu.menudex.select == 649
            game.ctrl.input.menu.menudex.select = 1
            s = game.ctrl.input.menu.menudex.select

            moveSpritesH!(game,:dexball,16*(649-1))
            moveSpriteH!(game,:slider,-60,true)
            rotateSprite!(game,:wheel,0.,true)
            moveTextH!(game,:numbers,-7,true)
            moveTextH!(game,  :names,-7,true)

            for i in 1:5
                setSpriteIdx!(game,mdlabels[i],
                        game.p.dex[clamp(s+i-3,1,649),1]*clamp(s+i-3,1,151)+1)
                activateSprite!(game,mdlabels[i],649+1>s+i-3>0)
            end
        else
            lockInput!(game); activateCallback!(game,:scroll)
            game.ctrl.input.menu.menudex.speed = 1
        end
    elseif inputs.up.press && game.ctrl.input.menu.menudex.speed == 0
        if game.ctrl.input.menu.menudex.select == 1
            game.ctrl.input.menu.menudex.select = 649
            s = game.ctrl.input.menu.menudex.select
            
            moveSpritesH!(game,:dexball,-16*(649-1))
            moveSpriteH!(game,:slider,-60+120,true)
            rotateSprite!(game,:wheel,22.5*(649-1),true)
            moveTextH!(game,:numbers,-7-648*16,true)
            moveTextH!(game,  :names,-7-648*16,true)

            for i in 1:5
                setSpriteIdx!(game,mdlabels[i],
                        game.p.dex[clamp(s+i-3,1,649),1]*clamp(s+i-3,1,151)+1)
                activateSprite!(game,mdlabels[i],649+1>s+i-3>0)
            end
        else
            lockInput!(game); activateCallback!(game,:scroll)
            game.ctrl.input.menu.menudex.speed = -1
        end
    elseif inputs.down.hold && game.ctrl.input.menu.menudex.speed > 0
        if game.ctrl.input.menu.menudex.select == 649
            game.ctrl.input.menu.menudex.speed = 0
        else
            lockInput!(game); activateCallback!(game,:scroll)
            game.ctrl.input.menu.menudex.speed = min(8,2*game.ctrl.input.menu.menudex.speed)
        end
    elseif inputs.up.hold && game.ctrl.input.menu.menudex.speed < 0
        if game.ctrl.input.menu.menudex.select == 1
            game.ctrl.input.menu.menudex.speed = 0
        else
            lockInput!(game); activateCallback!(game,:scroll)
            game.ctrl.input.menu.menudex.speed = max(-8,2*game.ctrl.input.menu.menudex.speed)
        end
    else
        game.ctrl.input.menu.menudex.speed = 0
    end

    return
end

function inputDexPage!(game::GameState,inputs::Inputs)
    if inputs.A.press
        return
    elseif inputs.B.press
        lockInput!(game)
        game.ctrl.input.menu.menudex.info = false

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateDexInfoClose!),F()); active=true,n=1)
    elseif inputs.down.press
        if game.ctrl.input.menu.menudex.select == 649
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

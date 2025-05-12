


function inputMenu!(game::GameState,inputs::Inputs)
    if inputs.down.press
        game.ctrl.input.menu.select = (game.ctrl.input.menu.select+0x01)%0x08
        moveSprite!(game,:cursor,59,-56+game.ctrl.input.menu.select*16,true)
    elseif inputs.up.press
        if game.ctrl.input.menu.select == 0x00
            game.ctrl.input.menu.select = 0x07
        else
            game.ctrl.input.menu.select -= 0x01
        end

        moveSprite!(game,:cursor,59,-56+game.ctrl.input.menu.select*16,true)
    elseif inputs.A.press
        inputMenuSelector!(game)
    elseif (inputs.start.press || inputs.B.press)
        game.ctrl.input.move = true
        game.ctrl.input.map = true
        game.ctrl.input.menu.main = false
        game.ctrl.input.menu.select = 0x01
        
        switchFrame!(game,:menu)
        switchText!(game,:menu)
        switchSprite!(game,:cursor)
    end

    return
end



function inputMenuSelector!(game::GameState)
    lockInput!(game)

    game.ctrl.input.map = false
    game.ctrl.input.menu.main = false

    if game.ctrl.input.menu.select == 0x00
        createCC!(game,:scenet,sceneTransition!,
            (16,8,F(stateMenuDexOpen!),F(stateMenuDexCtrls!)); active=true,n=1)
    elseif game.ctrl.input.menu.select == 0x01
        createCC!(game,:scenet,sceneTransition!,
            (16,8,F(statePkmnOpen!),F(statePkmnCtrls!)); active=true,n=1)
    elseif game.ctrl.input.menu.select == 0x02
        createCC!(game,:scenet,sceneTransition!,
            (16,8,F(stateBagsOpen!,(game.ctrl.input.menu.menubags,)),
                F(stateBagsCtrls!)); active=true,n=1)
    elseif game.ctrl.input.menu.select == 0x03
        game.ctrl.input.menu.pnav = true
    elseif game.ctrl.input.menu.select == 0x04
        game.ctrl.input.menu.self = true
    elseif game.ctrl.input.menu.select == 0x05
        game.ctrl.input.menu.save = true
    elseif game.ctrl.input.menu.select == 0x06
        game.ctrl.input.menu.optn = true
    else
        unlockInput!(game)

        game.ctrl.input.move = true
        game.ctrl.input.map = true
        game.ctrl.input.menu.select = 0x01

        switchFrame!(game,:menu)
        switchText!(game,:menu)
        switchSprite!(game,:cursor)
    end

    return
end

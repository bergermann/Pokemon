


function inputMenu!(game::GameState,inputs::Inputs)
    if inputs.down.press
        game.ctrl.input.menu.select = (game.ctrl.input.menu.select+0x01)%0x08
        moveSprite!(game,:cursor,58,-59+game.ctrl.input.menu.select*16,true)
    elseif inputs.up.press
        if game.ctrl.input.menu.select == 0x00
            game.ctrl.input.menu.select = 0x07
        else
            game.ctrl.input.menu.select -= 0x01
        end

        moveSprite!(game,:cursor,58,-59+game.ctrl.input.menu.select*16,true)
    elseif inputs.A.press
        inputMenuSelector!(game)
    elseif (inputs.start.press || inputs.B.press)
        game.ctrl.input.move = true
        game.ctrl.input.map = true
        game.ctrl.input.menu.main = false
        game.ctrl.input.menu.select = 0x01
        moveSprite!(game,:cursor,58,-59+game.ctrl.input.menu.select*16,true)
        
        switchFrame!(game,:menu)
        switchText!(game,:menu)
        switchSprite!(game,:cursor)
    end

    return
end



function inputMenuSelector!(game::GameState)
    if game.ctrl.input.menu.select == 0x00
        game.ctrl.input.menu.pdex = true
        game.ctrl.input.map = false
    elseif game.ctrl.input.menu.select == 0x01
        game.ctrl.input.map = false
        game.ctrl.input.menu.main = false
        game.ctrl.input.inputlock = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuPkmnOpen!,(),stateMenuPkmnCtrls!,()); active=true,n=1)
    elseif game.ctrl.input.menu.select == 0x02
        game.ctrl.input.map = false
        game.ctrl.input.menu.main = false
        game.ctrl.input.inputlock = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuBagsOpen!,(),stateMenuBagsCtrls!,()); active=true,n=1)
    elseif game.ctrl.input.menu.select == 0x03
        game.ctrl.input.menu.pnav = true
        game.ctrl.input.map = false
    elseif game.ctrl.input.menu.select == 0x04
        game.ctrl.input.menu.self = true
        game.ctrl.input.map = false
    elseif game.ctrl.input.menu.select == 0x05
        game.ctrl.input.menu.save = true
        game.ctrl.input.map = false
    elseif game.ctrl.input.menu.select == 0x06
        game.ctrl.input.menu.optn = true
        game.ctrl.input.map = false
    else
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

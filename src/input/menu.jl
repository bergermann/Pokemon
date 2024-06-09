


function inputMenu!(game::GameState,inputs::Inputs)
    if inputs.down.press
        game.ctrl.menu.select = (game.ctrl.menu.select+0x01)%0x08
        moveSprite!(game,:cursor,58,-58+(game.ctrl.input.menu.select-1)*17,true)
    elseif inputs.up.press
        if game.ctrl.menu.select == 0x00
            game.ctrl.menu.select = 0x07
        else
            game.ctrl.menu.select -= 0x01
        end

        moveSprite!(game,:cursor,58,-58+(game.ctrl.input.menu.select-1)*17,true)
    elseif input.A.press
        inputMenuSelector!(game)
    elseif (input.A.press || input.B.press)
        flushLayer!(game,6)
        killSprite!(game,6,:cursor)

        game.ctrl.move = true
        game.ctrl.map = true
        game.ctrl.menu.main = false
        game.ctrl.menu.select = 0x01
    end

    return
end



function inputMenuSelector!(game::GameState)
    if game.ctrl.menu.select == 0x00
        game.ctrl.menu.pdex = true
        game.ctrl.map = false
    elseif game.ctrl.menu.select == 0x01
        game.ctrl.map = false
        game.ctrl.menu.main = false
        game.ctrl.inputlock = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuPkmnOpen!,(),stateMenuPkmnCtrls!,()); active=true,n=1)
    elseif game.ctrl.menu.select == 0x02
        game.ctrl.map = false
        game.ctrl.menu.main = false
        game.ctrl.inputlock = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuBagsOpen!,(),stateMenuBagsCtrls!,()); active=true,n=1)
    elseif game.ctrl.menu.select == 0x03
        game.ctrl.menu.pnav = true
        game.ctrl.map = false
    elseif game.ctrl.menu.select == 0x04
        game.ctrl.menu.self = true
        game.ctrl.map = false
    elseif game.ctrl.menu.select == 0x05
        game.ctrl.menu.save = true
        game.ctrl.map = false
    elseif game.ctrl.menu.select == 0x06
        game.ctrl.menu.optn = true
        game.ctrl.map = false
    else
        game.ctrl.move = true
        game.ctrl.map = true
        game.ctrl.menu.main = false
        game.ctrl.menu.select = 0x01

        game.draw.menu1 = false

        flushLayer!(game,6)
        killSprite!(game,6,:cursor)
    end
end

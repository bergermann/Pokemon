


function inputMenu!(game::GameState,input::Input)
    if !input._input
        return
    end

    if input._down
        game.input.menu.select = (game.input.menu.select+0x01)%0x08
        game.im.sprites[:cursor].pos = P(40+(game.input.menu.select)*17,185)
    elseif input._up
        if game.input.menu.select == 0x00
            game.input.menu.select = 0x07
        else
            game.input.menu.select -= 0x01
        end

        game.im.sprites[:cursor].pos = P(40+(game.input.menu.select)*17,185)
    elseif input._A
        inputMenuSelector!(game)
    elseif (input._start || input._B)
        flushLayer!(game,:layer5)
        killSprite!(game,:cursor)

        game.input.move = true
        game.input.map = true
        game.input.menu.main = false
        game.input.menu.select = 0x01
    end
end



function inputMenuSelector!(game::GameState)
    if game.input.menu.select == 0x00
        game.input.menu.pdex = true
        game.input.map = false
    elseif game.input.menu.select == 0x01
        game.input.map = false
        game.input.menu.main = false
        game.input.inputlock = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuPkmnOpen!,(),stateMenuPkmnCtrls!,()); active=true,n=1)
    elseif game.input.menu.select == 0x02
        game.input.map = false
        game.input.menu.main = false
        game.input.inputlock = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateMenuBagsOpen!,(),stateMenuBagsCtrls!,()); active=true,n=1)
    elseif game.input.menu.select == 0x03
        game.input.menu.pnav = true
        game.input.map = false
    elseif game.input.menu.select == 0x04
        game.input.menu.self = true
        game.input.map = false
    elseif game.input.menu.select == 0x05
        game.input.menu.save = true
        game.input.map = false
    elseif game.input.menu.select == 0x06
        game.input.menu.optn = true
        game.input.map = false
    else
        game.input.move = true
        game.input.map = true
        game.input.menu.main = false
        game.input.menu.select = 0x01

        game.draw.menu1 = false

        flushLayer!(game,:layer5)
        killSprite!(game,:cursor)
    end
end

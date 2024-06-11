


function inputManager!(game::GameState,inputs::Inputs)
    if game.ctrl.input.inputlock
        return
    elseif game.ctrl.input.choice.active
        inputChoice!(game,inputs)
    elseif game.ctrl.input.dialogue
        inputDialogue!(game,inputs)
    elseif game.ctrl.input.map
        inputMap!(game,inputs)
    elseif game.ctrl.input.menu.main
        inputMenu!(game,inputs)
    elseif game.ctrl.input.menu.pdex
        
    elseif game.ctrl.input.menu.pkmn
        inputMenuPkmn!(game,inputs)
    elseif game.ctrl.input.menu.bags
        inputInventory!(game,inputs)
    elseif game.ctrl.input.menu.pnav
        
    elseif game.ctrl.input.menu.self
        
    elseif game.ctrl.input.menu.save
        
    elseif game.ctrl.input.menu.optn
        
    elseif game.ctrl.input.battle
        inputBattle!(game,inputs)
    end

    resetInputs!(inputs)

    return
end



function inputChoice!(game::GameState,inputs::Inputs)
    if inputs.A.press
        game.ctrl.choice.active = false

        killSprite!(game,:ccursor)

        game.ctrl.choice.func(game,game.ctrl.choice.args)
    elseif input.B.press
        if game.ctrl.choice.exit
            resetChoice!(game)

            killSprite!(game,:ccursor)

            return
        end

        game.im.sprites[game.ctrl.choice.layer][:ccursor].pos.h += 
            16*(game.ctrl.choice.max-game.ctrl.choice.sel)

        game.ctrl.choice.sel = game.ctrl.choice.max
    elseif input._up
        if game.ctrl.choice.sel == 1
            game.im.sprites[game.ctrl.choice.layer][:ccursor].pos.h +=
                16*(game.ctrl.choice.max-1)

            game.ctrl.choice.sel = game.ctrl.choice.max

            return
        end

        game.ctrl.choice.sel -= 1
        game.im.sprites[game.ctrl.choice.layer][:ccursor].pos.h -= 16
    elseif input._down
        if game.ctrl.choice.sel == game.ctrl.choice.max
            game.im.sprites[game.ctrl.choice.layer][:ccursor].pos.h -=
                16*(game.ctrl.choice.max-1)

            game.ctrl.choice.sel = 1

            return
        end
        
        game.ctrl.choice.sel += 1
        game.im.sprites[game.ctrl.choice.layer][:ccursor].pos.h += 16
    end
end



function inputDialogue!(game::GameState,inputs::Inputs)
    if !(inputs.A.press || inputs.B.press || inputs.down.press)
        return
    end

    if game.dialogue.n < length(game.dialogue.str)
        game.dialogue.n += 1
        
        drawDialogueUpdate!(game)
    else
        game.dialogue.d = false
        game.dialogue.n = 1
        game.ctrl.move = true
        game.ctrl.map = true
        game.ctrl.dialogue = false
        game.ctrl.npclock = false

        evalCallback(game,game.dialogue.callback)
        
        flushLayer!(game,6,P(24+112,16),P(48,240))
    end
end



function resetInputs!(inputs::Inputs)
    inputs.A.press = false
    inputs.B.press = false
    inputs.L.press = false
    inputs.R.press = false
    inputs.up.press = false
    inputs.right.press = false
    inputs.down.press = false
    inputs.left.press = false
    inputs.start.press = false
    inputs.select.press = false

    return
end
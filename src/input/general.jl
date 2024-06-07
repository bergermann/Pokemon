


function inputManager!(game::GameState,inputs::Inputs)
    if game.ctrl.inputlock
        return
    elseif game.ctrl.choice.active
        inputChoice!(game,inputs)
    elseif game.ctrl.dialogue
        inputDialogue!(game,inputs)
        return
    elseif game.ctrl.map
        inputMap!(game,inputs)
        return
    elseif game.ctrl.menu.main
        inputMenu!(game,inputs)
        return
    elseif game.ctrl.menu.pdex
        return
    elseif game.ctrl.menu.pkmn
        inputMenuPkmn!(game,inputs)
        return
    elseif game.ctrl.menu.bags
        inputInventory!(game,inputs)
        return
    elseif game.ctrl.menu.pnav
        return
    elseif game.ctrl.menu.self
        return
    elseif game.ctrl.menu.save
        return
    elseif game.ctrl.menu.optn
        return
    elseif game.ctrl.battle
        inputBattle!(game,inputs)
        return
    end
end



function inputChoice!(game::GameState,inputs::Inputs)
    if input._A
        game.ctrl.choice.active = false

        flushLayer!(game,game.ctrl.choice.layer)
        killSprite!(game,:ccursor)

        game.ctrl.choice.func(game,game.ctrl.choice.args...)
    elseif input._B
        if game.ctrl.choice.exit
            resetChoice!(game)

            flushLayer!(game,game.ctrl.choice.layer)
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
    if !(input._A || input._B || input._down)
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
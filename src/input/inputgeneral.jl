


function inputManager!(game::GameState,input::Input)
    if game.input.inputlock
        return
    elseif game.input.choice.active
        inputChoice!(game,input)
    elseif game.input.dialogue
        inputDialogue!(game,input)
        return
    elseif game.input.map
        inputMap!(game,input)
        return
    elseif game.input.menu.main
        inputMenu!(game,input)
        return
    elseif game.input.menu.pdex
        return
    elseif game.input.menu.pkmn
        inputMenuPkmn!(game,input)
        return
    elseif game.input.menu.bags
        inputInventory!(game,input)
        return
    elseif game.input.menu.pnav
        return
    elseif game.input.menu.self
        return
    elseif game.input.menu.save
        return
    elseif game.input.menu.optn
        return
    elseif game.input.battle
        inputBattle!(game,input)
        return
    end
end



function inputChoice!(game::GameState,input::Input)
    if input._A
        game.input.choice.active = false

        flushLayer!(game,game.input.choice.layer)
        killSprite!(game,:ccursor)

        game.input.choice.callback.func(game,game.input.choice.callback.args...)
    elseif input._B
        if game.input.choice.exit
            game.input.choice.active = false
            game.input.choice.sel = 0

            flushLayer!(game,game.input.choice.layer)
            killSprite!(game,:ccursor)

            return
        end

        game.im.sprites[:ccursor].pos.h += 16*(game.input.choice.max-game.input.choice.sel)

        game.input.choice.sel = game.input.choice.max
    elseif input._up
        if game.input.choice.sel == 1
            game.im.sprites[:ccursor].pos.h += 16*(game.input.choice.max-1)

            game.input.choice.sel = game.input.choice.max

            return
        end

        game.input.choice.sel -= 1
        game.im.sprites[:ccursor].pos.h -= 16
    elseif input._down
        if game.input.choice.sel == game.input.choice.max
            game.im.sprites[:ccursor].pos.h -= 16*(game.input.choice.max-1)

            game.input.choice.sel = 1

            return
        end
        
        game.input.choice.sel += 1
        game.im.sprites[:ccursor].pos.h += 16
    end
end


function inputDialogue!(game::GameState,input::Input)
    if !(input._A || input._B || input._down)
        return
    end

    if game.dialogue.n < length(game.dialogue.str)
        game.dialogue.n += 1
        
        drawDialogueUpdate!(game)
    else
        game.dialogue.d = false
        game.dialogue.n = 1
        game.input.move = true
        game.input.map = true
        game.input.dialogue = false
        game.input.npclock = false
        
        flushLayer!(game,:textbox,P(24+112,16),P(48,240))
    end
end


function stateSetDialogue!(game::GameState,str::AbstractString,callback::Callback)
    if !game.battle.active
        activateBackground!(game,:textbox)
        game.ctrl.input.npclock = true
        game.ctrl.input.map = false
        game.ctrl.input.move = false
    end
    
    game.ctrl.input.dialogue = true
    game.ctrl.dialogue.n = 1
    game.ctrl.dialogue.str = displit(str,'\\')
    game.ctrl.dialogue.l = length(game.ctrl.dialogue.str)
    game.ctrl.dialogue.callback = callback

    setText!(game,:dialogue,game.ctrl.dialogue.str[1])
    activateText!(game,:dialogue)

    return
end

function stateSetDialogue!(game::GameState,str::Vector{<:AbstractString},callback::Callback)
    if !game.battle.active
        activateBackground!(game,:textbox)
        game.ctrl.input.npclock = true
        game.ctrl.input.map = false
        game.ctrl.input.move = false
    end
    
    game.ctrl.input.dialogue = true
    game.ctrl.dialogue.n = 1
    game.ctrl.dialogue.str = str
    game.ctrl.dialogue.l = length(game.ctrl.dialogue.str)
    game.ctrl.dialogue.callback = callback

    setText!(game,:dialogue,game.ctrl.dialogue.str[1])
    activateText!(game,:dialogue)

    return
end

stateSetDialogue!(game::GameState,str,f::Function) = stateSetDialogue!(game,str,F(f))
stateSetDialogue!(game::GameState,str) = stateSetDialogue!(game,str,F0)



function stateAdvanceDialogue!(game::GameState)
    if game.ctrl.dialogue.n == game.ctrl.dialogue.l
        if !game.battle.active
            deactivateBackground!(game,:textbox)
            game.ctrl.input.npclock = false
            game.ctrl.input.map = true
            game.ctrl.input.move = true
        end

        game.ctrl.input.dialogue = false
        deactivateText!(game,:dialogue)

        evalCallback(game,game.ctrl.dialogue.callback)
    else
        game.ctrl.dialogue.n += 1
        
        setText!(game,:dialogue,game.ctrl.dialogue.str[game.ctrl.dialogue.n])
    end

    return
end


function stateSetDialogue!(game::GameState,set::Int,idx::Int,len::Int,
        callback::Callback)
        
    game.ctrl.input.npclock = true
    game.ctrl.input.map = false
    game.ctrl.input.move = false
    game.ctrl.input.dialogue = true
    game.ctrl.dialogue.n = 1
    game.ctrl.dialogue.str = game.str[set][idx:idx+len-1]
    game.ctrl.dialogue.callback = callback

    drawDialogue!(game)
end

const stateSetDialogue!(game::GameState,set::Int,idx::Int,len::Int) = 
    stateSetDialogue!(game::GameState,set::Int,idx::Int,len::Int,Callback())
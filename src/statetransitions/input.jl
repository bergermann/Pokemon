

function stateSetDialogue!(game::GameState,set::Int,idx::Int,len::Int,
        callback::CallbackFunction)
    game.input.npclock = true
    game.input.map = false
    game.input.move = false
    game.input.dialogue = true
    game.dialogue.n = 1
    game.dialogue.str = game.map.str[set][idx:idx+len-1]
    game.dialogue.callback = callback

    drawDialogue!(game)
end

const stateSetDialogue!(game::GameState,set::Int,idx::Int,len::Int) = 
    stateSetDialogue!(game::GameState,set::Int,idx::Int,len::Int,CallbackFunction())
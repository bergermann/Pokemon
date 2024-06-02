


function loadDialogue(id::Int)
    return deserialize("im/menu/dialogue/$id.imp")
end

function drawDialogue!(game::GameState)
    @views drawView!(game.im.layers[6][end-48-24+1:end-24,16+1:end-16],
        game.im.diabox.im[:,:],game.im.diabox.palette)

    drawText!(game,6,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32))
end

function drawDialogueUpdate!(game::GameState)
    flushLayer!(game,6,P(144,32),P(32,200),0xffffff)
    drawText!(game,6,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32))
end

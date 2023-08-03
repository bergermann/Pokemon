



function loadDialogue(id::Int)
    return deserialize("im/menu/dialogue/$id.imp")
end

function drawDialogue!(game::GameState)
    # game.im.layers.textbox[end-48-24+1:end-24,16+1:end-16] = 
    #     game.im.diabox.palette[game.im.diabox.im]

    @views drawView!(game.im.layers.textbox[end-48-24+1:end-24,16+1:end-16],
        game.im.diabox.im[:,:],game.im.diabox.palette)

    drawText!(game,:textbox,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32))
end

function drawDialogueUpdate!(game::GameState)
    flushLayer!(game,:textbox,P(144,32),P(32,160),0xffffff)
    drawText!(game,:textbox,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32))
end

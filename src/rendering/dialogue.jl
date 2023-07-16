

function getDialogueBox(set::String; s=Settings())
    boxes = mfb_rgb.(load("im/$set.png"))

    key::Vector{Tuple{Int,Int,UInt8}} = [
        (1,48,0x01),
        (49,48,0x02)
    ]

    return Dict{UInt8,Matrix{UInt32}}(
        zip([k[3] for k in key],[boxes[k[1]:k[1]+k[2]-1,:] for k in key])
    )
end

function getDialogue(str::String; s=Settings())
    return mfb_rgb.(load("im/dialogue/$str.png"))
end

function drawDialogue!(game::GameState)
    game.im.layers.textbox[end-48-24+1:end-24,16+1:end-16] = 
        game.im.diabox[game.options.diabox]
    drawText!(game,:textbox,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32))
end

function drawDialogueUpdate!(game::GameState)
    flushLayer!(game,:textbox,P(144,32),P(32,160),0xffffff)
    drawText!(game,:textbox,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32))
end

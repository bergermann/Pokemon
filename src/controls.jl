#using MiniFB

include("input/inputgeneral.jl")
include("input/inputmap.jl")
include("input/inputmenu.jl")
include("input/inputpkmn.jl")
include("input/inputbags.jl")
include("input/inputbattle.jl")
include("input/inputbattlebags.jl")





function onpress(window, button, mod, isPressed)::Cvoid
    global input

    if Bool(isPressed)
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,:input,true)
            setfield!(input,:_input,true)
            setfield!(input,c,true)
            setfield!(input,get(_ctrls,button,:null),true)
        end
    else
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,:input,false)
            setfield!(input,:input_,true)
            setfield!(input,c,false)
            setfield!(input,get(ctrls_,button,:null),true)
        end
    end

    return nothing
end

function resetInput!(input::Input)
    input._input    = false
    input.input_    = false
    input._A        = false
    input.A_        = false
    input._B        = false
    input.B_        = false
    input._L        = false
    input.L_        = false
    input._R        = false
    input.R_        = false
    input._up       = false
    input.up_       = false
    input._down     = false
    input.down_     = false
    input._left     = false
    input.left_     = false
    input._right    = false
    input.right_    = false
    input._start    = false
    input.start_    = false
    input._select   = false
    input.select_   = false
end






function mapAction!(game::GameState)
    b, npc = checkTileNPC(game)

    if b
        if npc.dialogue == 0    # FIX
            return
        end

        game.input.npclock = true
        game.input.map = false
        game.input.move = false
        game.input.dialogue = true
        game.dialogue.n = 1
        game.dialogue.str = game.map.str[npc.dialogue:npc.dialogue+npc.dialoguelen-1]

        drawDialogue!(game)

        return
    end

    tile = game.map.tilemap.collision[game.movepos.h,game.movepos.w]

    if tile ∈ [0x0000,0x0001,0x0005,0x0006,0x0007]
        return
    elseif 0x003c <= tile <= 0x004f
        game.input.npclock = true
        game.input.map = false
        game.input.move = false
        game.input.dialogue = true
        game.dialogue.str = game.map.str[tile-59]

        drawDialogue!(game)

        return
    end
end





function updateGame!(game::GameState,input::Input; s=Settings())
    inputManager!(game,input)

    if game.overworld
        checkProximityNPCs!(game)
        sortHorizontal!(game.im.sprites)

        manageNPCs!(game)
    end

    for i in 1:game.callbacks.idx
        if game.callbacks[i].active
            game.callbacks[i].func(game,game.callbacks[i].args...)
        end
    end

end

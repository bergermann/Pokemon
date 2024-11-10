
function lockInput!(game::GameState)
    game.ctrl.input.inputlock = true; return
end

function unlockInput!(game::GameState)
    game.ctrl.input.inputlock = false; return
end

function inputManager!(game::GameState,inputs::Inputs)
    if !game.ctrl.input.inputlock
        if game.ctrl.input.choice.active
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
            
        elseif game.battle.active
            inputBattle!(game,inputs)
        end
    end

    resetInputs!(inputs)

    return
end


function drawChoiceMenu!(game::GameState,layer::Int,strs::Vector{String},
        width::Int,px::Int,py::Int;
        c1::Vector{UInt8}=[0x63,0x63,0x63,0xff],c2::Vector{UInt8}=[0xd6,0xd6,0xce,0xff])

    game.ctrl.input.choice.max = length(strs)
    game.ctrl.input.choice.layer = layer

    createFrame!(game,:choice,2+length(strs)*2,width,px,py,layer)
    createSprite!(game,:ccursor,:cursors,1,3,px+12,py+16*game.ctrl.input.choice.sel,
        100,layer; active=true)

    createText!(game,:choice,4,px+16,py+8,layer,*(strs.*"\\"...),c1,c2; hpad=3)

    return
end



function inputChoice!(game::GameState,inputs::Inputs)
    if inputs.A.press
        game.ctrl.input.choice.active = false

        killSprite!(game,:ccursor)
        deleteFrame!(game,:choice)
        deleteText!(game,:choice)

        evalCallback(game,game.ctrl.input.choice.func)
    elseif inputs.B.press
        if game.ctrl.input.choice.exit
            resetChoice!(game)

            killSprite!(game,:ccursor)
            deleteFrame!(game,:choice)
            deleteText!(game,:choice)

            return
        end

        moveSprite!(game,:ccursor,0,
            16*(game.ctrl.input.choice.max-game.ctrl.input.choice.sel))

        game.ctrl.input.choice.sel = game.ctrl.input.choice.max
    elseif inputs.up.press
        if game.ctrl.input.choice.sel == 1
            moveSprite!(game,:ccursor,0,16*(game.ctrl.input.choice.max-1))

            game.ctrl.input.choice.sel = game.ctrl.input.choice.max

            return
        end

        moveSprite!(game,:ccursor,0,-16)
        
        game.ctrl.input.choice.sel -= 1
    elseif inputs.down.press
        if game.ctrl.input.choice.sel == game.ctrl.input.choice.max
            moveSprite!(game,:ccursor,0,-16*(game.ctrl.input.choice.max-1))

            game.ctrl.input.choice.sel = 1

            return
        end
        
        moveSprite!(game,:ccursor,0,16)

        game.ctrl.input.choice.sel += 1
    end

    return
end



function inputDialogue!(game::GameState,inputs::Inputs)
    if !(inputs.A.press || inputs.B.press || inputs.down.press); return; end

    stateAdvanceDialogue!(game)

    return
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
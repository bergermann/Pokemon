


function stateBattleStage!(game::GameState,stage::Int)
    game.battle.stage = stage
end

function stateBattleIntroDialogue!(game::GameState)
    game.battle.stage = 1
    game.dialogue.callback.func = emptyCallback
    game.dialogue.callback.args = ()

    game.input.battle1 = true
    game.draw.battle1 = true

    game.im.sprites[:cursor].active = true
end

function stateSetInput!(game::GameState,args::Tuple{Symbol,Bool}...)
    for arg in args
        setfield!(game.input,arg[1],arg[2])
    end
end
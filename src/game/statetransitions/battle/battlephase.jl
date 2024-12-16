


function stateBattleStage!(game::GameState,stage::Int)
    game.battle.state.stage = stage

    return
end

function stateEndBattlePhase!(game::GameState)
    stateBattleStage!(game,1)

    game.ctrl.input.inputlock = false
    game.ctrl.input.battle1 = true
    game.draw.battle1 = true
    
    game.im.sprites[4][:cursor1].active = true
    game.callbacks[:wiggle].active = true
    game.callbacks[:animbattle].active = false

    return
end



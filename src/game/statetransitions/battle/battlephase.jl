


function stateBattleStage!(game::GameState,stage::Int)
    game.battle.state.stage = stage

    return
end

function stateEndBattlePhase!(game::GameState)
    stateBattleStage!(game,1)

    unlockInput!(game)
    game.ctrl.input.battle.m1 = true
    
    activateSprite!(game,:cursor1)
    activateFrame!(game,:choice)

    activateText!(game,:choice1)
    activateText!(game,:choice2)

    activateCallback!(game,:wiggle)
    deactivateCallback!(game,:animbattle)

    return
end



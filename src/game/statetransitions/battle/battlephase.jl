


function stateBattleStage!(game::GameState,stage::Int)
    game.battle.state.stage = stage

    return
end

function stateEndBattlePhase!(game::GameState)
    stateBattleStage!(game,1)

    game.battle.state.pkmn1.command = CC0
    game.battle.state.pkmn2.command = CC0
    
    deactivateCallback!(game,:animbattle)
    stateInitBattleChoice!(game,())

    return
end






function stateBattleFlee!(game::GameState)
    game.ctrl.input.battle.m1 = false

    switchFrame!(game,:choice)
    switchSprite!(game,:cursor1)
    switchText!(game,:choice1)
    switchText!(game,:choice2)
    switchBackground!(game,:t1)
    
    flee!(game,game.battle.state)

    return
end

function flee!(game::GameState,state::BattleStateWild)
    if !checkFlee(state)
        stateSetDialogue!(game,game.str[1][20],stateBattleFleeBlocked!)

        return
    end
    
    stateBattleStage!(game,10)

    state.pkmn1.command = CommandFlee(
        (state.pkmn1.pkmn.stats.rv[6]*128/max(state.pkmn2.pkmn.stats.rv[6],1)+
            30*state.counters.flee)%256 > 0*rand(UInt8)
    )
    state.pkmn2.command = battleChoiceWild(game)

    deactivateCallback!(game,:wiggle); resetWiggle!(game)
    activateCallback!(game,:animbattle)
    game.n[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

    return
end

function flee!(game::GameState,state::BattleStateTrainerSolo)
    stateSetDialogue!(game,game.str[1][21],stateBattleFleeBlocked!)

    return
end

function stateBattleFleeBlocked!(game::GameState,args::Tuple)
    stateBattleStage!(game,1)

    game.ctrl.input.battle.m1 = true

    switchSprite!(game,:cursor1)
    switchFrame!(game,:choice)
    switchText!(game,:choice1)
    switchText!(game,:choice2)
    switchBackground!(game,:t1)
    switchText!(game,:dialogue)
    setText!(game,:dialogue,game.str[1][14]*pkmnName(game,game.battle.state.pkmn1.pkmn)*
        game.str[1][15])

    activateCallback!(game,:wiggle)

    return
end
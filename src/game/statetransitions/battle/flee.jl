


function stateBattleFlee!(game::GameState)
    switchFrame!(game,:choice)
    switchSprite!(game,:cursor1)
    switchText!(game,:choice1)
    switchText!(game,:choice2)
    switchBackground!(game,:t1)
    
    flee!(game,game.battle.state)

    return
end

function flee!(game::GameState,state::BattleState)
    if !checkFlee(state)
        stateSetDialogue!(game,game.str[1][46],stateBattleFleeBlocked!)

        return
    end
    
    state[1].command = CommandFlee(
        (state.pkmn1.pkmn.stats.rv[6]*128/max(state.pkmn2.pkmn.stats.rv[6],1)+
            30*state.counters.flee)%256 > 0*rand(UInt8)
    )
    state[2].command = battleChoiceOpp(game.battle.state,2)

    deactivateCallback!(game,:wiggle); resetWiggle!(game)
    activateCallback!(game,:animbattle)
    game.n[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

    return
end

function stateBattleFleeBlocked!(game::GameState,args::Tuple)
    game.ctrl.input.battle.m1 = true

    switchSprite!(game,:cursor1)
    switchFrame!(game,:choice)
    switchText!(game,:choice1)
    switchText!(game,:choice2)
    switchBackground!(game,:t1)
    switchText!(game,:dialogue)
    setText!(game,:dialogue,game.str[1][14]*game.battle.state[1].name*game.str[1][15])

    activateCallback!(game,:wiggle)

    return
end

function ()
    
end
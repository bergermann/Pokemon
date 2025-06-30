


function stateEndBattlePhase!(game::GameState,state::BattleStateWild)
    # if state[1].pkmn.stats.hp < 0
    if state.forceswitch1
        if checkContinueFight(game)
            deactivateCallback!(game,:animbattle)

            lockInput!(game)

            createCC!(game,:scenet,sceneTransition!,
                (16,8,F(stateBattlePkmnOpen!),F(statePkmnCtrls!)); active=true,n=1)
        else
            # stateBattleLost!(game)
            game.n[:animbattle].c = -3
        end
    elseif state[2].pkmn.stats.hp < 0 || state.caught2
        game.n[:animbattle].c = -3
    else
        deactivateCallback!(game,:animbattle)

        game.battle.state.pkmn1.command = CC0
        game.battle.state.pkmn2.command = CC0

        stateInitBattleChoice!(game,())
    end

    return
end



function stateForceSwitch!(game::GameState)
    deactivateCallback!(game,:animqueue)
    deactivateCallback!(game,:actionqueue)

    lockInput!(game)

    createCC!(game,:scenet,sceneTransition!,
        (16,8,F(stateBagsOpen!,(game.ctrl.input.menu.battlebags,)),
            F(stateBagsCtrls!)); active=true,n=1)
    
    return
end

function checkContinueFight(game::GameState)
    c = false

    for i in eachindex(game.p.pokemon)
        if game.p.pokemon[i].status != 0x06; c = true; end
    end

    return c
end
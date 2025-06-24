


function stateEndBattlePhase!(game::GameState)
    deactivateCallback!(game,:animbattle)

    if game.battle.state[1].forceswitch
        if !checkContinueFight(game)
            lockInput!(game)

            createCC!(game,:scenet,sceneTransition!,
                (16,8,F(stateBattlePkmnOpen!),F(statePkmnCtrls!)); active=true,n=1)
        else
            stateBattleLost!(game)
        end
    else
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

# function checkSwitch(game::GameState)
    
#     return 
# end

function checkContinueFight(game::GameState)
    c = false

    for i in eachindex(game.p.pokemon)
        if game.p.pokemon[i].status != 0x06; c = true; end
    end

    return c
end
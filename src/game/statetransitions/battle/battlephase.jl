


function stateEndBattlePhase!(game::GameState,state::BattleState)
    if state.counters.flee == -1
            game.n[:animbattle].c = -3
    elseif fs(state,1)
        if checkContinueFight(game)
            deactivateCallback!(game,:animbattle)

            lockInput!(game)

            createCC!(game,:scenet,sceneTransition!,
                (16,8,F(stateBattlePkmnOpen!),F(statePkmnCtrls!)); active=true,n=1)
        else
            game.n[:animbattle].c = -3
        end
    elseif state[2].pkmn.stats.hp < 0 || state.caught1
        if state.iswild
            game.n[:animbattle].c = -3
        else
            if any(p->p.status!=0x06,game.battle.state.trainer1.pokemon)
                idx = findfirst(p->p.status!=0x06,game.battle.state.trainer1.pokemon)

                game.battle.state[2] = PkmnBattle(game.battle.state.trainer1.pokemon[idx])

                game.battle.state[2].command = CN0

                push!(game.battle.state.animqueue,BattleAnimation(
                    :p1,128,game.str[1][7]*game.battle.state.trainer1.name*game.str[1][9]*
                        pkmnName(game,game.battle.state[2].pkmn)*game.str[1][10],
                    bswitchIn!,2
                ))

                game.n[:animbattle].c = 1
            else
                game.n[:animbattle].c = -3
            end
        end
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
    return any(p->p.status!=0x06,game.p.pokemon)
end
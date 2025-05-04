
const alabels = [:attack1,:attack2,:attack3,:attack4]

function inputBattle!(game::GameState,inputs::Inputs)
    if game.ctrl.input.battle.m1
        if inputs.A.press
            inputBattleMenuSelector!(game::GameState); return
        end

        if inputs.B.press
            game.ctrl.input.battle.s1 = 3
        elseif inputs.left.press || inputs.right.press
            game.ctrl.input.battle.s1 += 1+2*isodd(game.ctrl.input.battle.s1)
        elseif inputs.up.press || inputs.down.press
            game.ctrl.input.battle.s1 += 2
        end

        game.ctrl.input.battle.s1 %= 4

        moveSprite!(game,:cursor1,12+56*(game.ctrl.input.battle.s1%2),
            49+15*div(game.ctrl.input.battle.s1,2),true)
    elseif game.ctrl.input.battle.m2
        if inputs.A.press
            inputBattleAttackSelector!(game::GameState); return
        end

        if inputs.B.press
            game.ctrl.input.battle.m1 = true
            game.ctrl.input.battle.m2 = false

            switchBackground!(game,:t2)
            activateSprite!(game,:cursor1); deactivateSprite!(game,:cursor2)
            switchFrame!(game,:choice); switchFrame!(game,:attacks); switchFrame!(game,:info)
            switchText!(game,:choice1); switchText!(game,:choice2)
            switchText!(game,:info1); switchText!(game,:info2)
            for l in alabels; switchText!(game,l); end

            return
        end

        if inputs.left.press || inputs.right.press
            game.ctrl.input.battle.s2 += 1+2*isodd(game.ctrl.input.battle.s2)
        elseif inputs.up.press || inputs.down.press
            game.ctrl.input.battle.s2 += 2
        end

        game.ctrl.input.battle.s2 %= 4

        moveSprite!(game,:cursor2,-107+64*(game.ctrl.input.battle.s2%2),
            49+15*div(game.ctrl.input.battle.s2,2),true)
    end

    return
end



function inputBattleMenuSelector!(game::GameState)
    game.ctrl.input.battle.m1 = false

    if game.ctrl.input.battle.s1 == 0
        game.ctrl.input.battle.m2 = true

        switchBackground!(game,:t2)
        deactivateSprite!(game,:cursor1); activateSprite!(game,:cursor2)
        switchFrame!(game,:choice); switchFrame!(game,:attacks); switchFrame!(game,:info)
        switchText!(game,:choice1); switchText!(game,:choice2)
        switchText!(game,:info1); switchText!(game,:info2)
        for l in alabels; switchText!(game,l); end
    elseif game.ctrl.input.battle.s1 == 1
        lockInput!(game)

        createCC!(game,:scenet,sceneTransition!,
            (16,8,F(stateBagsOpen!,(game.ctrl.input.menu.battlebags,)),
                F(stateBagsCtrls!)); active=true,n=1)
    elseif game.ctrl.input.battle.s1 == 2
        lockInput!(game)
        game.ctrl.input.battle.pkmn = true

        createCC!(game,:scenet,sceneTransition!,
            (16,8,F(stateBattlePkmnOpen!),F(stateMenuPkmnCtrls!)); active=true,n=1)
    else
        stateBattleFlee!(game)
    end

    return
end

function inputBattleAttackSelector!(game::GameState)
    if !checkAttack!(game)
        return
    end

    stateBattleAttackSelected!(game)

    return
end

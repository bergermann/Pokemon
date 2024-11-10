
const alabels = [:attack1,:attack2,:attack3,:attack4]

function inputBattle!(game::GameState,inputs::Inputs)
    if game.ctrl.input.battle.m1
        if inputs.A.press
            inputBattleMenuSelector!(game::GameState); return
        end

        if inputs.B.press
            game.ctrl.input.battle.s1 = 3
        elseif inputs.up.press || inputs.down.press
            game.ctrl.input.battle.s1 += 2
        elseif inputs.left.press || inputs.right.press
            game.ctrl.input.battle.s1 += 1+2*isodd(game.ctrl.input.battle.s1)
        end

        game.ctrl.input.battle.s1 %= 4

        moveSprite!(game,:cursor1,12+48*div(game.ctrl.input.battle.s1,2),
            46+16*(game.ctrl.input.battle.s1%2),true)
    elseif game.ctrl.input.battle.m2
        if inputs.A.press
            inputBattleAttackSelector!(game::GameState); return
        end

        if inputs.B.press
            game.ctrl.input.battle.m1 = true
            game.ctrl.input.battle.m2 = false    

            switchSprite!(game,:cursor1); switchSprite!(game,:cursor2)
            switchFrame!(game,:choice); switchFrame!(game,:attacks); switchFrame!(game,:info)
            switchText!.(game,alabels)

            return
        end

        if inputs.up.press || inputs.down.press
            game.ctrl.input.battle.s2 += 2
        elseif inputs.left.press || inputs.right.press
            game.ctrl.input.battle.s2 += 1+2*isodd(game.ctrl.input.battle.s2)
        end

        game.ctrl.input.battle.s2 %= 4

        moveSprite!(game,:cursor2,-70+48*div(game.ctrl.input.battle.s2,2),
            46+16*(game.ctrl.input.battle.s2%2),true)
    elseif game.ctrl.input.battle.bag
        inputBattleInventory!(game,input)
    end

    return
end


function inputBattleMenuSelector!(game::GameState)
    if game.ctrl.input.battle1menu.select == 0
        game.ctrl.input.battle1 = false
        game.ctrl.input.battle2 = true

        game.draw.battle1 = false
        game.draw.battle2 = true

        game.im.sprites[4][:cursor1].active = false
        game.im.sprites[5][:cursor2].active = true    
                
        flushLayer!(game,4,Position(24+1+112,16+1),Position(48,240),
            0x4a4252)
    elseif game.ctrl.input.battle1menu.select == 1
        game.ctrl.input.inputlock = true
        game.ctrl.input.battle1 = false

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateBattleBagsOpen!,(),stateBattleBagsCtrls!,());
            active=true,n=1)
    elseif game.ctrl.input.battle1menu.select == 2
        game.ctrl.input.inputlock = true
        game.ctrl.input.battle1 = false

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateBattlePkmnOpen!,(),stateMenuPkmnCtrls!,());
            active=true,n=1)
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

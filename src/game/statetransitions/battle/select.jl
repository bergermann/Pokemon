

function stateStartBattleAnim!(game::GameState,args::Tuple{})
    deactivateCallback!(game,:wiggle); resetWiggle!(game)

    activateCallback!(game,:animbattle)
    game.n[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

    return
end

function stateBattleAttackSelected!(game::GameState)
    stateBattleStage!(game,10)

    game.battle.state.pkmn1.command = CommandAttack(game.ctrl.input.battle.s2+1)
    game.battle.state.pkmn2.command = battleChoiceWild(game)
    
    game.ctrl.input.battle.m1 = false
    game.ctrl.input.battle.m2 = false

    deactivateBackground!(game,:t1); deactivateBackground!(game,:t2)
    switchFrame!(game,:attacks); switchFrame!(game,:info)
    deactivateSprite!(game,:cursor2)
    switchText!(game,:info1); switchText!(game,:info2)
    for l in alabels; switchText!(game,l); end

    stateStartBattleAnim!(game,())

    return
end

function stateBattleItemSelected!(game::GameState,target::UInt,item::ItemType)
    stateBattleStage!(game,10)

    game.battle.state.pkmn1.command = CommandItem(target,item)
    game.battle.state.pkmn2.command = battleChoiceWild(game)
    
    game.ctrl.input.battle1 = false
    game.ctrl.input.battle2 = false

    return
end

function stateBattlePkmnSelected!(game::GameState)
    stateBattleStage!(game,10)
    
    game.battle.state.pkmn1.command = 
        CommandSwitch(Int(game.ctrl.input.menu.menupkmn.select))

    game.battle.state.pkmn2.command = battleChoiceWild(game)
    
    game.ctrl.input.battle1 = false
    game.ctrl.input.battle2 = false
    game.ctrl.input.battle1menu.select = 0
    
    deactivateCallback!(game,:wiggle); resetWiggle!(game)
    activateCallback!(game,:animbattle)
    game.n[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

    return
end





function stateBattlePkmnOpen!(game::GameState,args::Tuple{})
    stateCloseBattle!(game)
    stateMenuPkmnOpen!(game,())

    return
end

function stateBattlePkmnClose!(game::GameState,args::Tuple{})
    stateMenuPkmnClose!(game,())
    stateOpenBattle!(game)

    return
end


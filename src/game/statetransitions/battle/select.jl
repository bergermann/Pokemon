

function stateStartBattleAnim!(game::GameState,args::Tuple{})
    deactivateCallback!(game,:wiggle); resetWiggle!(game)
    activateCallback!(game,:animbattle); game.n[:animbattle].c = -1

    activateText!(game,:dialogue); setText!(game,:dialogue,"")

    queueSetupActions!(game,game.battle.state)

    return
end

function stateResumeBattleAnim!(game::GameState,args::Tuple{})
    deactivateCallback!(game,:wiggle); resetWiggle!(game)
    activateCallback!(game,:animbattle); game.n[:animbattle].c = 1

    activateText!(game,:dialogue); setText!(game,:dialogue,"")

    return
end

function stateBattleAttackSelected!(game::GameState)
    state = game.battle.state

    state[1].command = CommandAttack(game.ctrl.input.battle.s2+1)
    state[2].command = battleChoiceOpp(state,2)
    
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
    state = game.battle.state

    state[1].command = CommandItem(target,item)
    state[2].command = battleChoiceOpp(state,2)
    
    game.ctrl.input.battle.m1 = false
    game.ctrl.input.battle.m2 = false

    return
end

function stateBattlePkmnSelected!(game::GameState)
    state = game.battle.state

    state[1].command = CommandSwitch(Int(game.ctrl.input.menu.menupkmn.select))
    state[2].command = battleChoiceOpp(state,2)
    
    
    game.ctrl.input.battle.m1 = false
    game.ctrl.input.battle.m2 = false
    game.ctrl.input.battle.s1 = 0

    return
end





function stateBattlePkmnOpen!(game::GameState,args::Tuple{})
    stateCloseBattle!(game)
    statePkmnOpen!(game,())

    return
end

function stateBattlePkmnClose!(game::GameState,args::Tuple{})
    stateMenuPkmnClose!(game,())
    stateOpenBattle!(game)

    return
end


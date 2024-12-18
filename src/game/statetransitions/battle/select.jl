

function stateBattleAttackSelected!(game::GameState)
    stateBattleStage!(game,10)

    game.battle.state.pkmn1.command = CommandAttack(game.ctrl.input.battle2menu.select+1)
    game.battle.state.pkmn2.command = battleChoiceWild(game)
    
    game.ctrl.input.battle.m1 = false
    game.ctrl.input.battle.m2 = false

    deactivateBackground!(game,:t1); deactivateBackground!(game,:t2)
    switchFrame!(game,:attacks); switchFrame!(game,:info)
    switchSprite!(game,:cursor1)
    switchText!(game,:info1); switchText!(game,:info2)
    for l in alabels; switchText!(game,l); end

    game.callbacks[:wiggle].active = false; resetWiggle!(game)
    game.callbacks[:animbattle].active = true
    game.n[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

    return
end

function stateBattleItemSelected!(game::GameState,target::UInt,item::ItemType)
    stateBattleStage!(game,10)

    game.battle.state.pkmn1.command = CommandItem(target,item)
    game.battle.state.pkmn2.command = battleChoiceWild(game)
    
    game.ctrl.input.battle1 = false
    game.ctrl.input.battle2 = false
    # game.ctrl.input.battle1menu.select = 0

    game.draw.battle1 = false
    game.draw.battle2 = false

    game.im.sprites[4][:cursor1].active = false
    game.im.sprites[5][:cursor2].active = false 
            
    flushLayer!(game,4,Position(24+1+112,16+1),Position(48,240))
    flushLayer!(game,5,Position(24+1+112,16+1),Position(48,240))

    game.callbacks[:wiggle].active = false; resetWiggle!(game)
    game.callbacks[:animbattle].active = true
    game.n[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

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

    game.draw.battle1 = false
    game.draw.battle2 = false

    game.im.sprites[4][:cursor1].active = false
    game.im.sprites[5][:cursor2].active = false 
            
    flushLayer!(game,4,Position(24+1+112,16+1),Position(48,240))
    flushLayer!(game,5,Position(24+1+112,16+1),Position(48,240))

    game.callbacks[:wiggle].active = false; resetWiggle!(game)
    game.callbacks[:animbattle].active = true
    game.n[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

    return
end


function stateBattleBagsOpen!(game::GameState)
    game.draw.battle1 = false

    killCC!(game,:animbattle)
    killCallback!(game,:wiggle)
    
    killSpriteAll!(game)
    flushLayer!(game,4)

    createCC!(game,:bagswitch,animBattleBagSwitch!,(); n=1)
    createCallback!(game,:arrows,true,animArrowsMenu!,())

    loadStringsInventory!(game)
    drawInventory!(game,game.ctrl.input.battlebags)

    return
end

function stateBattleBagsCtrls!(game::GameState)
    game.ctrl.input.inputlock = false
    game.ctrl.input.battlebag = true

    return
end

function stateBattleBagsClose!(game::GameState)
    killSpriteAll!(game)
    flushLayer!(game,4)

    killCC!(game,:bagswitch)
    killCallback!(game,:arrows)

    drawBattleBase!(game)

    return
end





function stateBattlePkmnOpen!(game::GameState)
    game.draw.battle1 = false
    # game.ctrl.input.menupkmn = MenuPkmn()

    killCC!(game,:animbattle)
    killCallback!(game,:wiggle)
    
    killSpriteAll!(game)
    flushLayer!(game,4)

    createCallback!(game,:wiggle,animMenuPkmnWiggle!,(); active=true)

    loadStringsTeam!(game)
    drawMenuPkmn!(game)

    return
end

# function stateBattlePkmnCtrls!(game::GameState)
#     game.ctrl.input.inputlock = false
#     game.ctrl.input.menu.pkmn = true
# end

function stateBattlePkmnClose!(game::GameState)
    killSpriteAll!(game)

    killCallback!(game,:wiggle)

    drawBattleBase!(game)

    return
end


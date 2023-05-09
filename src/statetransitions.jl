# general functions that transition some state into another


function stateSetInput!(game::GameState,args::Tuple{Symbol,Bool}...)
    for arg in args
        setfield!(game.input,arg[1],arg[2])
    end
end

function stateBattleStage!(game::GameState,stage::Int)
    game.battle.state.stage = stage
end

function stateInitBattle!(game::GameState)
    game.input.inputlock = true
    game.input.map = false
    game.input.move = false

    createCounter!(game,:battleintro)
    createCallback!(game,:battleintro,true,animBattleEntry1!,())
end



function stateInitDrawBattle!(game::GameState)
    for i in eachindex(fieldnames(DrawState))
        setfield!(game.draw,i,false)
    end

    game.draw.battleintro = true
end

function stateSetupBattle!(game::GameState)
    game.input.move = false

    popall!(game.im.sprites)

    game.im.postprocess.active = true
    game.im.postprocess.func = shutterHorizontal!
    game.im.postprocess.args = (24+80,0)

    createCC!(game,:wiggle,animWiggleBattle!,(); active=true)
    createCC!(game,:animbattle,animBattlePhaseWild!,(); active=false,n=-1)
end

function stateBattleIntroDialogue!(game::GameState)
    game.battle.state.stage = 1
    game.dialogue.callback.func = emptyCallback
    game.dialogue.callback.args = ()

    game.input.battle1 = true
    game.draw.battle1 = true

    game.im.sprites[:cursor1].active = true
end

function stateBattleOutroDialogue!(game::GameState)
    game.dialogue.callback.func = stateEndBattle!
    game.dialogue.callback.args = ()
end

function stateBattleAttackSelected!(game::GameState)
    stateBattleStage!(game,10)

    game.battle.state.pkmn1.command = CommandAttack(game.input.battle2menu.select+1)
    game.battle.state.pkmn2.command = battleChoiceWild(game)
    
    game.input.battle1 = false
    game.input.battle2 = false
    game.input.battle1menu.select = 0

    game.draw.battle1 = false
    game.draw.battle2 = false

    game.im.sprites[:cursor1].active = false
    game.im.sprites[:cursor2].active = false 
            
    flushLayer!(game,:layer4,Position(24+1+112,16+1),Position(48,240))
    flushLayer!(game,:layer5,Position(24+1+112,16+1),Position(48,240))

    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = true
    game.n.c[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)
    # createCC!(game,:animbattle,animBattlePhaseWild!,(); active=true,n=-1)
end

function stateEndBattlePhase!(game::GameState)
    stateBattleStage!(game,1)

    game.input.battle1 = true
    game.draw.battle1 = true
    
    game.im.sprites[:cursor1].active = true
    game.callbacks[:wiggle].active = true
    game.callbacks[:animbattle].active = false
end

function stateQuitBattlePhase!(game::GameState)
    stateBattleStage!(game,0)

    game.input.battle1 = false
    
    game.im.sprites[:cursor1].active = false
    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = false
    
    killCC!(game,:animbattle)
    killCC!(game,:wiggle)
end

function stateBattleFlee!(game::GameState)

    game.input.battle1 = false

    game.im.sprites[:cursor1].active = false

    flushLayer!(game,:layer4,P(24+1+112,16+1),P(48,240))
    
    flee!(game,game.battle.state)
end

function flee!(game::GameState,state::BattleStateWild)
    if !checkFlee(state)
        game.dialogue.str = ["Flucht unmöglich."]
        game.dialogue.n = 1
        game.dialogue.callback.func = stateBattleFleeBlocked!
        game.dialogue.callback.args = ()

        game.input.battled = true
        game.draw.battled = true

        game.im.sprites[:cursor1].active = false

        return
    end
    
    stateBattleStage!(game,10)

    game.callbacks[:wiggle].active = false

    state.pkmn1.command = CommandFlee(
        (state.pkmn1.pkmn.stats.rv[6]*128/max(state.pkmn2.pkmn.stats.rv[6],1)+
            30*state.counters.flee)%256 > rand(UInt8)
    )
    state.pkmn2.command = battleChoiceWild(game)
    
    game.input.battle1 = false
    game.input.battle2 = false
    game.input.battle1menu.select = 0

    game.draw.battle1 = false
    game.draw.battle2 = false

    game.im.sprites[:cursor1].active = false
    game.im.sprites[:cursor2].active = false 
            
    flushLayer!(game,:layer4,Position(24+1+112,16+1),Position(48,240))
    flushLayer!(game,:layer5,Position(24+1+112,16+1),Position(48,240))

    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = true
    game.n.c[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)
end

function flee!(game::GameState,state::BattleStateTrainerSolo)
    game.dialogue.str = ["Aus Trainerkämpfen kannst du\\nicht fliehen."]
    game.dialogue.n = 1
    game.dialogue.callback.func = stateBattleFleeBlocked!
    game.dialogue.callback.args = ()

    game.input.battled = true
    game.draw.battled = true

    game.im.sprites[:cursor1].active = false
end

function stateBattleFleeBlocked!(game::GameState)
    game.battle.state.stage = 1
    game.dialogue.callback.func = emptyCallback

    game.input.battle1 = true
    game.draw.battle1 = true

    game.im.sprites[:cursor1].active = true
    game.callbacks[:wiggle].active = true
end

function stateEndBattle!(game::GameState)   #,state::BattleStateWild)
    killSprite!(game,:pkmn1)
    killSprite!(game,:tag1)
    killSprite!(game,:pkmn2)
    killSprite!(game,:tag2)
    
    killSprite!(game,:cursor1)
    killSprite!(game,:cursor2)

    flushLayers!(game)
    flushLayer!(game)

    game.battle.active = false
    game.battle.state.stage = 0

    popall!(game.battle.state.actionqueue)
    popall!(game.battle.state.animqueue)

    stateInitDrawMap!(game)
    
    game.im.sprites[:main].active = true
end





function stateInitMapCtrls!(game::GameState)
    game.input.inputlock = false

    game.input.map = true
    game.input.move = true
end

function stateInitDrawMap!(game::GameState)
    drawMap!(game)
    
    createSprite!(game,:main,:layer2,getSpriteMain("sprite"),Position(80,128),
        11; active=true)

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.direction,-1))

    loadNPCs!(game,game.map.id)
end

function stateMenuMainOpen!(game::GameState)
    game.input.inputlock = false
    game.input.menu.main = true
end

function stateMenuPkmnOpen!(game::GameState)
    game.draw.map = false

    killSprite!(game,:main)
    killSprite!(game,:cursor)
    killCC!(game,:movemain)

    createCallback!(game,:wiggle,animMenuPkmnWiggle!,(); active=true)

    drawMenuPkmn!(game)
end

function stateMenuPkmnCtrls!(game::GameState)
    game.input.inputlock = false
    game.input.menu.pkmn = true
end

function stateMenuPkmnClose!(game::GameState)
    game.input.inputlock = true

    killSpriteAll!(game)
    killCallback!(game,:wiggle)

    createSprite!(game,:main,:layer2,getSpriteMain("sprite"),P(80,128),
        (game.direction-1)*10+1; active=true)

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,moveMain!,(game.direction,-1))

    drawMap!(game)
    drawMenu!(game)
end



function stateMenuBagsOpen!(game::GameState)
    killSprite!(game,:main)
    killSprite!(game,:cursor)
    killCC!(game,:movemain)

    createCC!(game,:bagswitch,animBagSwitch!,(); n=1)
    createCallback!(game,:wiggle,true,animArrowsMenu!,())

    drawInventory!(game)
end

function stateMenuBagsCtrls!(game::GameState)
    game.input.inputlock = false
    game.input.menu.bags = true
end

function stateMenuBagsClose!(game::GameState)
    game.input.inputlock = true
    
    killSpriteAll!(game)
    killCallback!(game,:wiggle)
    killCC!(game,:bagswitch)

    createSprite!(game,:main,:layer2,getSpriteMain("sprite"),Position(80,128),
        (game.direction-1)*10+1; active=true)

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.direction,-1))

    drawMap!(game)
    drawMenu!(game)
end
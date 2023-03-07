# general functions that transition some state into another


function stateSetInput!(game::GameState,args::Tuple{Symbol,Bool}...)
    for arg in args
        setfield!(game.input,arg[1],arg[2])
    end
end

function stateBattleStage!(game::GameState,stage::Int)
    game.battle.stage = stage
end

function stateSetupBattle!(game::GameState)
    game.im.sprites[:main].active = false

    game.im.postprocess.active = true
    game.im.postprocess.func = shutterHorizontal!
    game.im.postprocess.args = (24+80,0)

    createCC!(game,:wiggle,animWiggleBattle!,(); active=true)
    createCC!(game,:animbattle,animBattlePhaseWild!,(); active=false,n=-1)
end

function stateBattleIntroDialogue!(game::GameState)
    game.battle.stage = 1
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
    # createCC!(game,:animbattle,animBattlePhaseWild!,(); active=true,n=-1)
end

function stateEndBattlePhase!(game::GameState)
    stateBattleStage!(game,1)

    game.input.battle1 = true
    game.draw.battle1 = true
    
    game.im.sprites[:cursor1].active = true
    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = false
end

# function stateEndBattle!(game::GameState)
#     stateEndBattle!(game,game.battle.state)
# end

function stateEndBattle!(game::GameState)   #,state::BattleStateWild)
    killSprite!(game,:pkmn1)
    killSprite!(game,:pkmn2)
    killSprite!(game,:cursor1)
    killSprite!(game,:cursor2)

    game.im.postprocess.active = false

    game.battle.active = false
    game.battle.outro = false

    initDrawMap!(game)
    game.input.map = true
    
    game.im.sprites[:main].active = true
end



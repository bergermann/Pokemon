
function stateBattleStage!(game::GameState,stage::Int)
    game.battle.state.stage = stage

    return
end

function stateInitBattle!(game::GameState)
    game.ctrl.input.inputlock = true
    game.ctrl.input.map = false
    game.ctrl.input.move = false
    game.ctrl.input.battle

    game.battle.teamperm = collect(1:game.p.pokemon.idx)

    activePkmn!(game)

    createCounter!(game,:introb)
    createCallback!(game,:introb,true,animBattleIntro1!,())

    return
end

function stateOpenBattleIntro!(game::GameState)
    loadStringsBattle!(game)

    createCallback!(game,:wiggle,animWiggleBattle!,())
    createCC!(game,:animbattle,animBattlePhaseWild!,(); n=-1)

    createBackground!(game,:battle,"backgrounds/battle/grass1.png",-120,-80,1;)
    createBackground!(game,:text,"textboxes/battle.png",-120,32,5;)
    createBackground!(game,:s1,"backgrounds/black.png",-120,-80,6; sx=240,sy=80)
    createBackground!(game,:s2,"backgrounds/black.png",-120,  0,6; sx=240,sy=80)
    createBackground!(game,:t1,"backgrounds/grey1.png",   0, 32,5; sx=120,sy=48,active=false)
    createBackground!(game,:t2,"backgrounds/grey1.png",-120, 32,6; sx=240,sy=48,active=false)

    loadSpriteSheet!(game,"battle/battlers/mc1.png",:battlermc,64,64,4; maxsprites=1)
    loadSpriteSheet!(game,"battle/pads/grass1.png",:pads,128,32,1; maxsprites=2)
    loadSpriteSheet!(game,"battle/intro/grass1.png",:fol,256,80,1; maxsprites=2)
    loadSpriteSheet!(game,"battle/balls.png",:balls,16,16,2; maxsprites=2)
    loadSpriteSheet!(game,"battle/ballicons.png",:ballicons,7,7,4; maxsprites=12)
    loadSpriteSheet!(game,"battle/tagown.png",:tagown,104,37,1; maxsprites=1)
    loadSpriteSheet!(game,"battle/tagopp.png",:tagopp,100,29,1; maxsprites=1)

    p1 = game.battle.state.pkmn1.pkmn
    path1 = "battle/battlers/back/$(p1.shiny ? "shiny" : "normal")/$(p1.id).png"
    p2 = game.battle.state.pkmn2.pkmn
    path2 = "battle/battlers/front/$(p2.shiny ? "shiny" : "normal")/$(p2.id).png"

    loadSpriteSheet!(game,path1,:pkmn1,64,64,2; maxsprites=1)
    loadSpriteSheet!(game,path2,:pkmn2,64,64,2; maxsprites=1)

    createSprite!(game,:grass1,:fol,1,1,  0,-8,10,3; active=true)
    createSprite!(game,:grass2,:fol,1,1,256,-8,10,3; active=true)

    createSprite!(game,:pad1,:pads,2,1, 120+64, 16,10,2; active=true)
    createSprite!(game,:pad2,:pads,1,1,-120-64,-16,10,2; active=true)

    createSprite!(game,   :mc,:battlermc,1,1,120+80+3,  0,10,2; active=true)
    createSprite!(game, :ball,    :balls,1,1,     -62, 11,10,2; active=false)
    createSprite!(game,:pkmn1,    :pkmn1,1,1,     -48, 24,10,2; active=false)
    createSprite!(game,:pkmn2,    :pkmn2,1,1, -120-64,-28,10,2; active=true)
    
    createSprite!(game,:cursor1,:cursors,1,1,-94,66,10,2; active=true)
    createSprite!(game,:cursor2,:cursors,1,1, 16,66,10,2; active=true)
    
    createSprite!(game,:tagown,:tagown,1,1, 60+128, 12,10,3; active=true)
    createSprite!(game,:tagopp,:tagopp,1,1,-58-128,-50,10,3; active=true)
    
    createFrame!(game, :choice,13,4,   0,32,5; active=false)
    createFrame!(game,   :info, 8,4,  40,32,6; active=false)
    createFrame!(game,:attacks,18,4,-120,32,6; active=false)

    createText!(game,:dialogue,4,-103,41,5,"",
        [0xff,0xff,0xff,0xff],[0x6b,0x5a,0x73,0xff]; active=false,maxchar=128)

    createText!(game,:name1,1,24+128,-4,4,pkmnName(game,p1),
        [0x42,0x42,0x42,0xff],[0xde,0xd6,0xb5,0xff]; maxchar=16)
    createText!(game,:lvl1, 1,93+128,-4,4,string(p1.stats.level),
        [0x42,0x42,0x42,0xff],[0xde,0xd6,0xb5,0xff]; maxchar=3)

    createText!(game,:name2,1,-101-128,-62,4,pkmnName(game,p2),
        [0x42,0x42,0x42,0xff],[0xde,0xd6,0xb5,0xff]; maxchar=16)
    createText!(game,:lvl2, 1, -33-128,-62,4,string(p2.stats.level),
        [0x42,0x42,0x42,0xff],[0xde,0xd6,0xb5,0xff]; maxchar=3)

    createText!(game,:choice1,4,16,41,5,game.str[1][1]*"\\"*game.str[1][3],
        [0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=2,maxchar=32)
    createText!(game,:choice2,4,72,41,5,game.str[1][2]*"\\"*game.str[1][4],
        [0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=2,maxchar=32)

    for i in eachindex(p1.attacks)
        createText!(game,Symbol(:attack,i),4,-103+64*((i-1)%2),41+16*div(i-1,2),6,
            p1.attacks[i].name,[0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff];
            active=false,maxchar=16)
    end
    
    for i in length(p1.attacks)+1:4
        createText!(game,Symbol(:attack,i),4,-103+64*((i-1)%2),41+16*div(i-1,2),6,
            "---", [0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff];
            active=false,hpad=0,maxchar=16)
    end

    createText!(game,:info1,4,48,41,6,game.str[1][5]*"\\"*game.str[1][6],
        [0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=2,maxchar=16)
        
    a = p1.attacks[1]

    createText!(game,:info2,4,72,41,6,
        string(a.ap)*"/"*string(a.apmax)*"\\"*game.str[2][a.type+1],
        [0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=2,maxchar=16)

    return
end

function stateThrowBattle!(game::GameState,args::Tuple{})
    lockInput!(game)

    stateSetDialogue!(game,game.str[1][13]*pkmnName(game,game.battle.state.pkmn1.pkmn)*"!",
        F(stateInitBattleChoice!))

    game.callbacks[:introb].func = animThrowBall!
    game.callbacks[:introb].active = true
    game.n[:introb].c = 0

    return
end

function stateInitBattleChoice!(game::GameState,args::Tuple{})
    unlockInput!(game)

    activateFrame!(game,:choice)
    activateBackground!(game,:t1)
    activateSprite!(game,:cursor1)

    setText!(game,:dialogue,game.str[1][14]*pkmnName(game,game.battle.state.pkmn1.pkmn)*
        game.str[1][15])

    return    
end





function stateBattleAttackSelected!(game::GameState)
    stateBattleStage!(game,10)

    game.battle.state.pkmn1.command = CommandAttack(game.ctrl.input.battle2menu.select+1)
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

    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = true
    game.n.c[:animbattle].c = -1

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

    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = true
    game.n.c[:animbattle].c = -1

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

    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = true
    game.n.c[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

    return
end





function stateEndBattlePhase!(game::GameState)
    stateBattleStage!(game,1)

    game.ctrl.input.inputlock = false
    game.ctrl.input.battle1 = true
    game.draw.battle1 = true
    
    game.im.sprites[4][:cursor1].active = true
    game.callbacks[:wiggle].active = true
    game.callbacks[:animbattle].active = false

    return
end

function stateQuitBattlePhase!(game::GameState)
    stateBattleStage!(game,0)

    game.ctrl.input.inputlock = true
    game.ctrl.input.battle1 = false
    
    game.im.sprites[4][:cursor1].active = false
    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = false
    
    killCC!(game,:animbattle)
    killCallback!(game,:wiggle)

    return
end

function stateBattleFlee!(game::GameState)
    game.ctrl.input.battle1 = false

    game.im.sprites[4][:cursor1].active = false

    flushLayer!(game,4,P(24+1+112,16+1),P(48,240))
    
    flee!(game,game.battle.state)

    return
end

function flee!(game::GameState,state::BattleStateWild)
    if !checkFlee(state)
        game.dialogue.str = ["Flucht unmöglich."]
        game.dialogue.n = 1
        game.dialogue.callback.func = stateBattleFleeBlocked!
        game.dialogue.callback.args = ()

        game.ctrl.input.battled = true
        game.draw.battled = true

        game.im.sprites[4][:cursor1].active = false

        return
    end
    
    stateBattleStage!(game,10)

    state.pkmn1.command = CommandFlee(
        (state.pkmn1.pkmn.stats.rv[6]*128/max(state.pkmn2.pkmn.stats.rv[6],1)+
            30*state.counters.flee)%256 > rand(UInt8)
    )
    state.pkmn2.command = battleChoiceWild(game)
    
    game.ctrl.input.battle1 = false
    game.ctrl.input.battle2 = false
    game.ctrl.input.battle1menu.select = 0

    game.draw.battle1 = false
    game.draw.battle2 = false

    game.im.sprites[4][:cursor1].active = false
    game.im.sprites[5][:cursor2].active = false 
            
    flushLayer!(game,4,Position(24+1+112,16+1),Position(48,240))
    flushLayer!(game,5,Position(24+1+112,16+1),Position(48,240))

    game.callbacks[:wiggle].active = false
    game.callbacks[:animbattle].active = true
    game.n.c[:animbattle].c = -1

    queueSetupActions!(game,game.battle.state)

    return
end

function flee!(game::GameState,state::BattleStateTrainerSolo)
    game.dialogue.str = ["Aus Trainerkämpfen kannst du\\nicht fliehen."]
    game.dialogue.n = 1
    game.dialogue.callback.func = stateBattleFleeBlocked!
    game.dialogue.callback.args = ()

    game.ctrl.input.battled = true
    game.draw.battled = true

    game.im.sprites[4][:cursor1].active = false

    return
end

function stateBattleFleeBlocked!(game::GameState)
    game.battle.state.stage = 1
    game.dialogue.callback.func = emptyCallback

    game.ctrl.input.battle1 = true
    game.draw.battle1 = true

    game.im.sprites[4][:cursor1].active = true
    game.callbacks[:wiggle].active = true

    return
end

function stateEndBattle!(game::GameState)   #,state::BattleStateWild)
    killSpriteAll!(game)

    flushLayers!(game)
    flushLayer!(game)

    game.battle.active = false
    game.battle.state.stage = 0

    popall!(game.battle.state.actionqueue)
    popall!(game.battle.state.animqueue)

    println("resetting team order")
    println(game.p.pokemon)
    # permute!(game.p.pokemon,game.battle.teamperm)

    game.p.pokemon.data = game.p.pokemon.data[game.battle.teamperm]

    println(game.p.pokemon)

    stateInitDrawMap!(game)
    
    game.im.sprites[3][:main].active = true

    return
end

function stateBattleCtrls!(game::GameState)
    stateBattleStage!(game,1)

    game.ctrl.input.inputlock = false
    game.ctrl.input.battle1 = true

    game.draw.battle1 = true
    
    game.im.sprites[4][:cursor1].active = true
    game.callbacks[:wiggle].active = true

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


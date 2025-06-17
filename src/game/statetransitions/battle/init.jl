


function stateInitBattle!(game::GameState)
    lockInput!(game)
    game.ctrl.input.map = false
    game.ctrl.input.move = false
    game.ctrl.input.battle

    game.battle.teamperm = collect(1:6)

    activePkmn!(game)

    createCounter!(game,:introb)
    createCallback!(game,:introb,true,animBattleIntro1!,())

    return
end



function stateOpenBattle!(game::GameState)
    loadStringsBattle!(game)

    createCallback!(game,:wiggle,animWiggleBattle!,())
    createCC!(game,:animbattle,animBattlePhaseWild!,(); n=-1)

    createBackground!(game,:battle,"backgrounds/battle/grass1.png",-120,-80,1;)
    createBackground!(game,:text,"textboxes/battle.png",-120,32,5;)
    createBackground!(game,:t1,"backgrounds/grey1.png",   0, 32,5; sx=120,sy=48,active=false)
    createBackground!(game,:t2,"backgrounds/grey1.png",-120, 32,6; sx=240,sy=48,active=false)

    loadSpriteSheets!(game,
        :battlermc,
        :pads,
        :ballsb,
        :ballicons,
        :tagown,
        :tagopp,
        :particles,
        :health1,
        :xp
    )

    p1 = game.battle.state.pkmn1.pkmn
    path1 = "battle/battlers/back/$(p1.shiny ? "shiny" : "normal")/$(p1.id).png"
    p2 = game.battle.state.pkmn2.pkmn
    path2 = "battle/battlers/front/$(p2.shiny ? "shiny" : "normal")/$(p2.id).png"

    loadSpriteSheet!(game,path1,:pkmn1,64,64,2; maxsprites=1)
    loadSpriteSheet!(game,path2,:pkmn2,64,64,2; maxsprites=1)

    createSprite!(game,:pad1,:pads,2,1,-56, 16,10,1; active=true)
    createSprite!(game,:pad2,:pads,1,1, 56,-16,10,1; active=true)

    createSprite!(game,:pkmn1,    :pkmn1,1,1,-48, 24,10,3; active=true)
    createSprite!(game,:pkmn2,    :pkmn2,1,1, 56,-28,10,3; active=true)
    
    createSprite!(game,:cursor1,:cursors,1,4,  12,49,10,5; active=false)
    createSprite!(game,:cursor2,:cursors,1,4,-107,49,10,6; active=false)
    
    createSprite!(game,:tag1, :tagown,1,1, 60, 12,10,3; active=true)
    createSprite!(game,:tag2, :tagopp,1,1,-58,-50,10,3; active=true)

    b1 = getHealthBar(p1); b2 = getHealthBar(p2)
    createSprite!(game, :hp1,:health1,3,1, 56, 12,10,4; wscale=0.,active=true)
    createSprite!(game, :hp2,:health1,3,1,-69,-46,10,4; wscale=0.,active=true)
    setHPBar!(game,:hp1,b1,56); setHPBar!(game,:hp2,b2,-69)

    createSprite!(game,  :xp,     :xp,1,1, 40, 28,10,4; wscale=0.,hscale=2.,active=true)
    setXPBar!(game,:xp,getXPBar(p1,0),40)
    
    createFrame!(game, :choice,13,4,   0,32,5; active=false)
    createFrame!(game,   :info, 8,4,  40,32,6; active=false)
    createFrame!(game,:attacks,18,4,-120,32,6; active=false)

    createText!(game,:dialogue,4,-103,41,5,"",
        [0xff,0xff,0xff,0xff],[0x6b,0x5a,0x73,0xff]; active=false,maxchar=128)

    createText!(game,:name1,1,24,-4,4,pkmnName(game,p1),
        [0x42,0x42,0x42,0xff],[0xde,0xd6,0xb5,0xff]; maxchar=16)
    createText!(game, :lvl1,1,93,-4,4,string(p1.stats.level),
        [0x42,0x42,0x42,0xff],[0xde,0xd6,0xb5,0xff]; maxchar=3)

    createText!(game,:name2,1,-101,-62,4,pkmnName(game,p2),
        [0x42,0x42,0x42,0xff],[0xde,0xd6,0xb5,0xff]; maxchar=16)
    createText!(game,:lvl2, 1, -33,-62,4,string(p2.stats.level),
        [0x42,0x42,0x42,0xff],[0xde,0xd6,0xb5,0xff]; maxchar=3)

    createText!(game,:choice1,4,16,41,5,game.str[1][1]*"\\"*game.str[1][3],
        [0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=2,maxchar=32)
    createText!(game,:choice2,4,72,41,5,game.str[1][2]*"\\"*game.str[1][4],
        [0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=2,maxchar=32)

    for i in eachindex(p1.attacks)
        createText!(game,blabels[i].attack,4,-103+64*((i-1)%2),41+16*div(i-1,2),6,
            p1.attacks[i].name,[0x4a,0x4a,0x4a,0xff],[0xd6,0xd6,0xce,0xff];
            active=false,maxchar=16)
    end
    
    for i in length(p1.attacks)+1:4
        createText!(game,blabels[i].attack,4,-103+64*((i-1)%2),41+16*div(i-1,2),6,
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


function stateOpenBattleIntro!(game::GameState)
    stateOpenBattle!(game)

    loadSpriteSheets!(game,:fol)

    createBackground!(game,:s1,"backgrounds/black.png",-120,-80,6; sx=240,sy=80)
    createBackground!(game,:s2,"backgrounds/black.png",-120,  0,6; sx=240,sy=80)

    createSprite!(game,:grass1,:fol,1,1,  0,-8,10,3; active=true)
    createSprite!(game,:grass2,:fol,1,1,256,-8,10,3; active=true)

    createSprite!(game,:mc,:battlermc,1,1,120+80+3,0,10,3; active=true)
    bid = Int(game.battle.state.pkmn1.pkmn.ball)
    createSprite!(game,:ball,:ballsb,bid,1,-62, 11,10,2; active=false,rot=18.)

    for i in 1:10
        createSprite!(game,Symbol(:spark,i),:particles,1,1,-48,24,10,4; active=false)
    end

    scaleSprite!(game,:pkmn1,0.,0.,true)

    moveSpriteW!(game,:pad1, 240)
    moveSpriteW!(game,:pad2,-240)

    moveSpriteW!(game,:pkmn2,-240)

    moveSpriteW!(game,:tag1, 128); moveSpriteW!(game,:tag2,-128)

    moveSpriteW!(game,:hp1, 128); moveSpriteW!(game,:hp2,-128)
    moveSpriteW!(game, :xp, 128);

    moveTextW!(game,:name1, 128); moveTextW!(game,:lvl1, 128)
    moveTextW!(game,:name2,-128); moveTextW!(game,:lvl2,-128)

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
    game.ctrl.input.battle.m1 = true

    activateCallback!(game,:wiggle)

    activateFrame!(game,:choice)
    activateBackground!(game,:t1)
    
    activateSprite!(game,:cursor1)
    moveSprite!(game,:cursor1,12+56*(game.ctrl.input.battle.s1%2),
        49+15*div(game.ctrl.input.battle.s1,2),true)

    activateText!(game,:choice1)
    activateText!(game,:choice2)

    activateText!(game,:dialogue)
    setText!(game,:dialogue,game.str[1][14]*pkmnName(game,game.battle.state.pkmn1.pkmn)*
        game.str[1][15])

    return    
end



function stateCloseBattle!(game::GameState)
    deleteBackgrounds!(game,:battle,:text,:t1,:t2)
    deleteSpriteSheets!(game,
        :battlermc,:pads,:ballsb,:ballicons,:tagown,:tagopp,:particles,:pkmn1,:pkmn2,
        :health1,:xp,)

    killSprites!(game,:cursors)

    deleteFramesAll!(game)
    deleteTextsAll!(game)

    killCallback!(game,:wiggle)
    killCC!(game,:animbattle)

    return
end

function stateEndBattle!(game::GameState,args::Tuple)   #,state::BattleStateWild)
    stateCloseBattle!(game)

    game.battle.active = false
    stateBattleStage!(game,0)
    game.ctrl.input.battle.m1 = false
    game.ctrl.input.battle.m2 = false
    game.ctrl.input.battle.s1 = 0
    game.ctrl.input.battle.s2 = 0
    game.ctrl.input.menu.bags = false
    game.ctrl.input.battle.pkmn = false

    empty!(game.battle.state.actionqueue)
    empty!(game.battle.state.animqueue)

    idx = game.p.pokemon.idx
    game.p.pokemon.data[1:idx] .= @view game.p.pokemon.data[game.battle.teamperm[1:idx]]

    stateOpenMap!(game)

    return
end

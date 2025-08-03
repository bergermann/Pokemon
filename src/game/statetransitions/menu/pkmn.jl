

const mplabels = Base.ImmutableDict(
    [i => (
            s=Symbol(:slot,i),
            b=Symbol(:ball,i),
            st=Symbol(:status,i),
            i=Symbol(:item,i),
            h=Symbol(:hp,i),
            g=Symbol(:gender,i),
            ic=Symbol(:icon,i),
            n=Symbol(:name,i),
        )
    for i in 1:6]...
)

function drawSlotMain!(game::GameState)
    p = game.p.pokemon[1]; l = mplabels[1]

    createSprite!(game,l.s,  :smain,1+2*isfainted(p),2,-73,-30,0,1; active=true)
    createSprite!(game,l.st,:status,   Int(p.status),1,-88,-11,1,2; active=true)
    createSprite!(game,l.g, :gender,   Int(p.gender),1,-82,-28,3,3; active=true)
    createSprite!(game,l.b, :ballsm,1,2,-108,-50,0,2; active=true)
    createSprite!(game,l.i,   :item,1,1, -99,-29,2,4; active=hasitem(p))
    createSprite!(game,l.h,:health1,1,1, -88,-20,3,2; active=true)
    createSprite!(game,l.ic, :icons,1,1,-104,-44,3,3; active=true)
    setHPBar!(game,l.h,getHPBar(p),-88)
    
    createText!(game,l.n,1,-86,-44,2,pkmnName(game,p)*"\\   Lv.$(p.stats.level)",
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; hpad=-3)

    createText!(game,l.h,1,-42,-18,2,string(p.stats.hp)*"/"*string(p.stats.rv[1]),
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; align=1)

    createSprite!(game,:exit,:exit,1,1,92,64,0,1; active=true)
    createSprite!(game,:ballexit,:ballsm,1,1,74,64,0,2; active=true)

    createText!(game,:exit,1,84,58,2,game.str[1][1],
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff])

    return
end

function drawSlotSide!(game::GameState)
    for i in 2:length(game.p.pokemon)
        p = game.p.pokemon[i]; l = mplabels[i]
    
        createSprite!(game,l.s,  :sside,1+2*isfainted(p),1,47,-59+24*(i-2),0,1; active=true)
        createSprite!(game,l.st,:status,Int(p.status),   1,59,-53+24*(i-2),1,2; active=true)
        createSprite!(game,l.g, :gender,   Int(p.gender),1, 4,-54+24*(i-2),3,3; active=true)
        createSprite!(game,l.b, :ballsm,1,1,-22,-59+24*(i-2),0,2; active=true)
        createSprite!(game,l.i,   :item,1,1,-11,-51+24*(i-2),2,4; active=hasitem(p))
        createSprite!(game,l.h,:health1,1,1, 64,-61+24*(i-2),3,2; active=true)
        createSprite!(game,l.ic, :icons,i,1,-18,-63+24*(i-2),3,3; active=true)
        setHPBar!(game,l.h,getHPBar(p),64)
        
        createText!(game,l.n,1,0,-70+24*(i-2),2,pkmnName(game,p)*"\\   Lv.$(p.stats.level)",
            [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; hpad=-3)

        createText!(game,l.h,1,110,-59+24*(i-2),2,string(p.stats.hp)*"/"*string(p.stats.rv[1]),
            [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; align=1)
    end

    for i in length(game.p.pokemon)+1:6
        l = mplabels[i]
        
        createSprite!(game,l.s,:sside,4,1,47,-59+24*(i-2),0,1; active=true)
    end

    return
end

function loadIcons!(game::GameState)
    icons = [string(p.id,".png") for p in game.p.pokemon]

    loadSpriteSheet!(game,joinpath("menupkmn","icons"),icons,:icons,32,32,2; maxsprites=6)

    return
end

function statePkmnOpen!(game::GameState,args::Tuple{})
    if !game.battle.active
        stateCloseMap!(game)
    end

    loadStringsTeam!(game)

    loadSpriteSheets!(game,
        :smain,
        :sside,
        :exit,
        :ballsm,
        :status,
        :item,
        :gender,
        :health1,
    )
    
    loadIcons!(game)
    
    createBackground!(game,:menupkmn,"backgrounds/menupkmn.png",-120,-80,1; active=true)
    
    createFrame!(game,:choose,21,2,-120,48,1; active=true)
    createFrame!(game,:info,16,2,-120,48,1; active=false)

    createText!(game,:choose,4,-112,57,5,game.str[1][2],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=true,hpad=0,maxchar=32)
    createText!(game,:info,4,-112,57,5,game.str[1][3],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=0,maxchar=32)

    drawSlotMain!(game)
    drawSlotSide!(game)
    
    createCallback!(game,:wiggle,animMenuPkmnWiggle!,(); active=true)

    return
end

function statePkmnCtrls!(game::GameState,args::Tuple{})
    unlockInput!(game); game.ctrl.input.menu.pkmn = true

    return
end

function statePkmnClose!(game::GameState,args::Tuple{})
    killCallback!(game,:wiggle)
    killSpritesAll!(game)
    
    deleteSpriteSheets!(game,:smain,:sside,:exit,:ballsm,:status,:item,:gender,:health1,:icons)

    deleteBackground!(game,:menupkmn)
    deleteTextsAll!(game)
    deleteFramesAll!(game)

    game.ctrl.input.menu.pkmn = false
    game.ctrl.input.menu.menupkmn.select = 1

    if game.battle.active
        stateOpenBattle!(game)

        if game.battle.state.pkmn1.command isa CommandChoose
            stateInitBattleChoice!(game,())
        end
    else
        stateOpenMap!(game)
        stateMenuMainOpen!(game,())
    end

    return
end






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
    createSprite!(game,mplabels[1].s,:smain,1,2,-73,-30,0,1; active=true)
    createSprite!(game,mplabels[1].b,:ballsm,1,2,-108,-50,0,2; active=true)
    createSprite!(game,mplabels[1].st,:status,1,1,-88,-11,1,2; active=false)
    createSprite!(game,mplabels[1].i,:item,1,1,-99,-29,2,4; active=true)
    createSprite!(game,mplabels[1].h,:health1,1,1,-88,-20,3,2; active=true)
    createSprite!(game,mplabels[1].ic,:icons,1,1,-104,-44,3,3; active=true)
    setHPBar!(game,mplabels[1].h,getHealthBar(game.p.pokemon[1]),-88)
    
    createText!(game,mplabels[1].n,1,-86,-44,2,
        pkmnName(game,game.p.pokemon[1])*"\\   Lv.$(game.p.pokemon[1].stats.level)",
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; hpad=-3)

    createText!(game,mplabels[1].h,1,-42,-18,2,
        string(game.p.pokemon[1].stats.hp)*"/"*
        string(game.p.pokemon[1].stats.rv[1]),
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; align=1)

    createSprite!(game,:exit,:exit,1,1,92,64,0,1; active=true)
    createSprite!(game,:ballexit,:ballsm,1,1,74,64,0,2; active=true)

    createText!(game,:exit,1,84,58,2,game.str[1][1],
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff])

    return
end

function drawSlotSide!(game::GameState)
    for i in 2:length(game.p.pokemon)
        createSprite!(game,mplabels[i].s,:sside,1,1,47,-59+24*(i-2),0,1; active=true)
        createSprite!(game,mplabels[i].b,:ballsm,1,1,-22,-59+24*(i-2),0,2; active=true)
        createSprite!(game,mplabels[i].st,:status,1,1,59,-53+24*(i-2),1,2; active=false)
        createSprite!(game,mplabels[i].i,:item,1,1,-11,-51+24*(i-2),2,4; active=true)
        createSprite!(game,mplabels[i].h,:health1,1,1,64,-61+24*(i-2),3,2; active=true)
        createSprite!(game,mplabels[i].ic,:icons,i,1,-18,-63+24*(i-2),3,3; active=true)
        setHPBar!(game,mplabels[i].h,getHealthBar(game.p.pokemon[i]),64)
        
        createText!(game,mplabels[i].n,1,0,-70+24*(i-2),2,
            pkmnName(game,game.p.pokemon[i])*"\\   Lv.$(game.p.pokemon[i].stats.level)",
            [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; hpad=-3)

        createText!(game,mplabels[i].h,1,110,-59+24*(i-2),2,
            string(game.p.pokemon[i].stats.hp)*"/"*
            string(game.p.pokemon[i].stats.rv[1]),
            [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; align=1)
    end

    for i in length(game.p.pokemon)+1:6
        createSprite!(game,mplabels[i].s,:sside,4,1,47,-59+24*(i-2),0,1; active=true)
    end

    return
end

function loadIcons!(game::GameState)
    icons = [string(p.id,".png") for p in game.p.pokemon]

    loadSpriteSheet!(game,joinpath("menupkmn","icons"),icons,:icons,32,32,2; maxsprites=6)

    return
end

function stateMenuPkmnOpen!(game::GameState,args::Tuple{})
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
        # :gender,
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

function stateMenuPkmnCtrls!(game::GameState,args::Tuple{})
    unlockInput!(game)
    game.ctrl.input.menu.pkmn = true

    return
end

function stateMenuPkmnClose!(game::GameState,args::Tuple{})
    lockInput!(game)

    killCallback!(game,:wiggle)
    killSpritesAll!(game)
    
    deleteSpriteSheets!(game,:smain,:sside,:exit,:ballsm,:status,:item,:health1,:icons)

    deleteBackground!(game,:menupkmn)
    deleteTextsAll!(game)
    deleteFramesAll!(game)

    stateOpenMap!(game)
    stateMenuMainOpen!(game)

    return
end


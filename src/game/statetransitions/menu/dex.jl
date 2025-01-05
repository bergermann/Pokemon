
mdlabels = Base.ImmutableDict([i => Symbol(:p,i) for i in 1:5]...)

function stateMenuDexOpen!(game::GameState,args::Tuple{})
    stateCloseMap!(game)

    loadStringsDex!(game)

    loadSpriteSheets!(game,
        :dexwheel,:dexslider,:dexarrow,#:pokemons
    )
    
    createBackground!(game,:dex0,"backgrounds/dex0.png",-120,-80,1; active=true)
    createBackground!(game,:dex1,"backgrounds/dex1.png",-120,-80,2; active=true)

    s = game.ctrl.input.menu.menudex.select

    createSprite!(game, :wheel, :dexwheel,1,1,-120,  0,0,2; active=true,rot=22.5*(s-1))
    createSprite!(game,:slider,:dexslider,1,1, 110,
        -60+round(Int,120*(s-1)/151),0,2; active=true)
    createSprite!(game,:arrow1, :dexarrow,1,1,  64,-72,0,2; active=s!=1)
    createSprite!(game,:arrow2, :dexarrow,1,1,  64, 72,0,2; active=s!=151,hreverse=true)

    # createText!(game,:names,4,-112,57,5,game.str[1][2],
    #     [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=true,hpad=0)
    # createText!(game,:info,4,-112,57,5,game.str[1][3],
    #     [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=0)
    
    createCallback!(game,:arrows,animDexWiggle!,(); active=true)
    createCC!(game,:scroll,animDexScroll!,(); active=false)

    return
end

function stateMenuDexCtrls!(game::GameState,args::Tuple{})
    unlockInput!(game)
    game.ctrl.input.menu.dex = true

    return
end

function stateMenuDexClose!(game::GameState,args::Tuple{})
    killCallback!(game,:arrows)
    killCC!(game,:scroll)
    killSpritesAll!(game)
    
    deleteBackgrounds!(game,:dex0,:dex1)
    deleteSpriteSheets!(game,:dexwheel,:dexslider,:dexarrow)

    deleteTextsAll!(game)
    deleteFramesAll!(game)

    stateOpenMap!(game)
    stateMenuMainOpen!(game)

    return
end

function animDexWiggle!(game::GameState,args::Tuple{})
    s = (game.frame%32) >= 16
    offset = Int((game.frame%16) >> 1)

    moveSpriteH!(game,:arrow1,-72-8*s-!s*offset+s*offset,true)
    moveSpriteH!(game,:arrow2, 72+8*s+!s*offset-s*offset,true)

    return
end

function animDexScroll!(game::GameState,args::Tuple{})
    game.n[:scroll].c += 1
    
    # moveTextH!(game,:names,game.ctrl.input.menu.menudex.speed)
    rotateSprite!(game,:wheel,
        22.5*(game.ctrl.input.menu.menudex.select+game.ctrl.input.menu.menudex.speed/16),true)

    if game.n[:scroll].c >= div(16,game.ctrl.input.menu.menudex.speed)   
        moveSpriteH!(game,:slider,
            -60+round(Int,120*game.ctrl.input.menu.menudex.select/151),true)
        
        game.callbacks[:scroll].active = false
        game.ctrl.input.menu.menudex.select += sign(game.ctrl.input.menu.menudex.speed)
        game.n[:scroll].c = -1
        
        unlockInput!(game)
    end

    return
end
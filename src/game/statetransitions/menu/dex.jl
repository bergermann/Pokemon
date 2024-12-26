
mdlabels = Base.ImmutableDict([i => Symbol(:p,i) for i in 1:5]...)

function stateMenuDexOpen!(game::GameState,args::Tuple{})
    stateCloseMap!(game)

    loadStringsDex!(game)

    loadSpriteSheets!(game,
        :dexwheel,:dexslider,:dexarrow,#:pokemons
    )
    
    createBackground!(game,:menudex0,"backgrounds/dex0.png",-120,-80,1; active=true)
    createBackground!(game,:menudex1,"backgrounds/dex1.png",-120,-80,2; active=true)

    createSprite!(game, :wheel, :dexwheel,1,1,-120,  0,0,2; active=true)
    createSprite!(game,:slider,:dexslider,1,1, 108,-60,0,2; active=true)
    createSprite!(game,:arrow1, :dexarrow,1,1,  64,-72,0,2; active=true)
    createSprite!(game,:arrow2, :dexarrow,1,1,  64, 72,0,2; active=true,hreverse=true)

    # createText!(game,:names,4,-112,57,5,game.str[1][2],
    #     [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=true,hpad=0)
    # createText!(game,:info,4,-112,57,5,game.str[1][3],
    #     [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=0)
    
    # createCallback!(game,:scroll,animDexScroll!,(); active=true)

    return
end

function stateMenuDexCtrls!(game::GameState,args::Tuple{})

    return
end

function stateMenuDexClose!(game::GameState,args::Tuple{})

    return
end
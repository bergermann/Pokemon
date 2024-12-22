
mdlabels = Base.ImmutableDict([i => Symbol(:p,i) for i in 1:5]...)

function stateMenuDexOpen!(game::GameState)
    stateCloseMap!(game)

    loadStringsDex!(game)

    loadSpriteSheets!(game,
        :dex,:pokemons
    )
    
    createBackground!(game,:menupkmn,"backgrounds/menupdex.png",-120,-80,1; active=true)

    for i in 1:5
        createSprite!(game,mdlabels[i],:pokemons,i,1,0,0,0,1)
    end

    createText!(game,:names,4,-112,57,5,game.str[1][2],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=true,hpad=0)
    createText!(game,:info,4,-112,57,5,game.str[1][3],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=0)
    
    createCallback!(game,:scroll,animDexScroll!,(); active=true)

    return
end

function stateMenuDexCtrls!(game::GameState)

    return
end

function stateMenuDexClose!(game::GameState)

    return
end
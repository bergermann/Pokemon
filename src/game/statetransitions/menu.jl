


function stateMenuMainOpen!(game::GameState)
    game.input.inputlock = false
    game.input.menu.main = true

    return
end





function stateMenuPkmnOpen!(game::GameState)
    stateCloseMap!(game)

    loadTeamStrings!(game)
    
    createBackground!(game,:menupkmn,"backgrounds/menupkmn.png",-120,-80,1; active=true)
    
    createFrame!(game,:choose,23,2,-120,56,1; active=true)
    createFrame!(game,:info,23,2,-120,56,1; active=false)

    createText!(game,:choose,2,62,-120,56,game.str[1][2],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=true,hpad=0)
    createText!(game,:info,2,62,-120,56,game.str[1][3],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=true,hpad=0)
    
    drawText!(game,2,"Wähle ein Pokémon.",UInt(2),Position(24+138,24))
    
    createCallback!(game,:wiggle,animMenuPkmnWiggle!,(); active=true)

    return
end

function stateMenuPkmnCtrls!(game::GameState)
    game.input.inputlock = false
    game.input.menu.pkmn = true

    return
end

function stateMenuPkmnClose!(game::GameState)
    game.input.inputlock = true

    killSpritesAll!(game)
    killCallback!(game,:wiggle)

    stateInitDrawMap!(game)
    drawMenu!(game)

    return
end





function stateMenuBagsOpen!(game::GameState)
    killSpriteAll!(game)
    game.overworld = false

    killCC!(game,:movemain)

    createCC!(game,:bagswitch,animBagSwitch!,(); n=1)
    createCallback!(game,:arrows,true,animArrowsMenu!,())

    loadInventoryStrings!(game)
    drawInventory!(game)

    return
end

function stateMenuBagsCtrls!(game::GameState)
    game.input.inputlock = false
    game.input.menu.bags = true

    return
end

function stateMenuBagsClose!(game::GameState)
    game.input.inputlock = true
    
    killSpriteAll!(game)

    killCallback!(game,:arrows)
    killCC!(game,:bagswitch)

    stateInitDrawMap!(game)
    drawMenu!(game)

    return
end



function stateMenuPkmnSubOpen!(game::GameState)
    killSpriteAll!(game)

    killCC!(game,:bagswitch)

    killCallback!(game,:wiggle)
    createCallback!(game,:wiggle,animMenuPkmnWiggle!,(); active=true)

    drawMenuPkmn!(game)

    return
end

function stateMenuPkmnSubCtrls!(game::GameState)
    game.input.inputlock = false
    game.input.menu.menubags.sub = true
    game.input.menu.menubags.subslot = 1

    return
end

function stateMenuPkmnSubClose!(game::GameState)
    game.input.inputlock = true

    killSpriteAll!(game)
    killCallback!(game,:wiggle)

    createCC!(game,:bagswitch,animBagSwitch!,(); n=1)
    createCallback!(game,:wiggle,true,animArrowsMenu!,())

    drawInventory!(game)

    return
end


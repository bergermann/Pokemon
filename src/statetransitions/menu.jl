


function stateMenuMainOpen!(game::GameState)
    game.input.inputlock = false
    game.input.menu.main = true
end





function stateMenuPkmnOpen!(game::GameState)
    popall!(game.im.sprites)
    game.overworld = false

    killCC!(game,:movemain)

    createCallback!(game,:wiggle,animMenuPkmnWiggle!,(); active=true)

    loadTeamStrings!(game)
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

    stateInitDrawMap!(game)
    drawMenu!(game)
end





function stateMenuBagsOpen!(game::GameState)
    popall!(game.im.sprites)
    game.overworld = false

    killCC!(game,:movemain)

    createCC!(game,:bagswitch,animBagSwitch!,(); n=1)
    createCallback!(game,:arrows,true,animArrowsMenu!,())

    loadInventoryStrings!(game)
    drawInventory!(game)
end

function stateMenuBagsCtrls!(game::GameState)
    game.input.inputlock = false
    game.input.menu.bags = true
end

function stateMenuBagsClose!(game::GameState)
    game.input.inputlock = true
    
    popall!(game.im.sprites)

    killCallback!(game,:arrows)
    killCC!(game,:bagswitch)

    stateInitDrawMap!(game)
    drawMenu!(game)
end



function stateMenuPkmnSubOpen!(game::GameState)
    popall!(game.im.sprites)

    killCC!(game,:bagswitch)

    killCallback!(game,:wiggle)
    createCallback!(game,:wiggle,animMenuPkmnWiggle!,(); active=true)

    drawMenuPkmn!(game)
end

function stateMenuPkmnSubCtrls!(game::GameState)
    game.input.inputlock = false
    game.input.menu.menubags.sub = true
    game.input.menu.menubags.subslot = 1
end

function stateMenuPkmnSubClose!(game::GameState)
    popall!(game.im.sprites)
    game.input.inputlock = true

    killSpriteAll!(game)
    killCallback!(game,:wiggle)

    createCC!(game,:bagswitch,animBagSwitch!,(); n=1)
    createCallback!(game,:wiggle,true,animArrowsMenu!,())

    drawInventory!(game)
end
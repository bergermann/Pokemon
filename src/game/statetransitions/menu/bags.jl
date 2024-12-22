
const mbslots = Base.ImmutableDict([i => Symbol(:slot,i) for i in 1:5]...)

function correctBags!(game::GameState,m::MenuBags)
    for i in 1:5
        m.select[i] = min(game.p.inventory[-i]+1,m.select[i])
        m.cursor[i] = min(game.p.inventory[-i]+1,m.cursor[i])
    end

    return
end

function drawSlots!(game::GameState,m::MenuBags)
    for i in 1:5
        p = (i-m.bag)
        p += 5*(p<-2)-5*(p>2)
        
        createText!(game,mbslots[i],4,-56+64*p,-72,1,game.str[1][i],
            [0x00,0x00,0x00,0xff],[0xbd,0x9c,0x5a,0xff]; active=true,align=0)
    end

    return
end

function getItemsStr(game::GameState,m::MenuBags)
    if game.p.inventory[-m.bag] > 0
        return *(game.str[2][game.p.inventory[m.bag][1:game.p.inventory[-m.bag],1]].*"\\"...)*
            game.str[1][6]
    else
        return game.str[1][6]
    end
end

function getAmountsStr(game::GameState,m::MenuBags)
    if game.p.inventory[-m.bag] > 0
        return *("×".*string.(game.p.inventory[m.bag][1:game.p.inventory[-m.bag],2]).*"\\"...)
    else
        return ""
    end
end

function stateMenuBagsOpen!(game::GameState,m::MenuBags)
    stateCloseMap!(game)

    correctBags!(game,m)

    loadStringsInventory!(game)
    
    loadSpriteSheets!(game,:arrows,:bags,:items,:markers)

    createBackground!(game,:bag1,"backgrounds/bag01.png",-88,-70,1; active=true)
    createBackground!(game,:bag2,"backgrounds/bag02.png",-16,-80,2; active=true)
    createBackground!(game,:bag3,"backgrounds/bag1.png",-120,-80,3; active=true)

    createSprite!(game,:marker,:markers,1,1,-84+8*m.bag,-51,0,3; active=true)
    createSprite!(game,:bag,:bags,1,m.bag,-50,-14,1,5; active=true)
    createSprite!(game,:left,:arrows,1,4,-90,-64,1,4; active=true)
    createSprite!(game,:right,:arrows,1,2,-22,-64,1,4; active=true)
    createSprite!(game,:ball,:arrows,1,5,-104,-64,1,3; active=true)
    createSprite!(game,:up,:arrows,1,1,54,-66,1,3)
    createSprite!(game,:down,:arrows,1,3,54,66,1,3)
    createSprite!(game,:cursor,:cursors,1,1,-4,-71+16*m.cursor[m.bag],0,3; active=true)
    createSprite!(game,:item,:items,getSelectedItem(game,m),1,-100,4,1,3; active=true)

    if m.select[m.bag]-m.cursor[m.bag] <= 0
        deactivateSprite!(game,:up)
    else
        activateSprite!(game,:up)
    end

    if (game.p.inventory[-m.bag]-(m.select[m.bag]-m.cursor[m.bag])) < 8
        deactivateSprite!(game,:down)
    else
        activateSprite!(game,:down)
    end

    drawSlots!(game,m)
    createText!(game,:items,2,0,-63+16*(m.cursor[m.bag]-m.select[m.bag]),2,
        getItemsStr(game,m),[0x00,0x00,0x00,0xff],[0xd6,0xd6,0xce,0xff];
        active=true,hpad=1,maxchar=12*150)
    createText!(game,:amounts,2,90,-63+16*(m.cursor[m.bag]-m.select[m.bag]),2,
        getAmountsStr(game,m),[0x00,0x00,0x00,0xff],[0xd6,0xd6,0xce,0xff];
        active=true,hpad=1,maxchar=4*150)
    createText!(game,:info,2,-117,25,4,game.str[3][getSelectedItem(game,m)],
        [0x00,0x00,0x00,0xff],[0xd6,0xd6,0xce,0xff]; active=true)

    createCC!(game,:bagswitch,animBagSwitch!,(m,0); n=1)
    createCallback!(game,:arrows,true,animArrowsMenu!,())

    return
end

function stateMenuBagsCtrls!(game::GameState)
    unlockInput!(game)
    game.ctrl.input.menu.bags = true

    return
end

function stateMenuBagsClose!(game::GameState)
    lockInput!(game)

    killCallback!(game,:arrows)
    killCC!(game,:bagswitch)
    killSpritesAll!(game)
    
    deleteSpriteSheet!(game,:arrows)
    deleteSpriteSheet!(game,:bags)
    deleteSpriteSheet!(game,:items)
    deleteSpriteSheet!(game,:markers)

    deleteBackground!(game,:bag1)
    deleteBackground!(game,:bag2)
    deleteBackground!(game,:bag3)

    deleteTextsAll!(game)
    deleteFramesAll!(game)

    stateOpenMap!(game)
    stateMenuMainOpen!(game)

    return
end

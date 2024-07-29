
const mplabels = Base.ImmutableDict(
    [i => (
            s=Symbol(:slot,i),
            b=Symbol(:ball,i),
            st=Symbol(:status,i),
            i=Symbol(:item,i),
            h=Symbol(:health,i),
            g=Symbol(:gender,i),
            ic=Symbol(:icon,i),
            n=Symbol(:name,i),
        )
    for i in 1:6]...
)

function stateMenuMainOpen!(game::GameState)
    game.ctrl.input.move = false
    game.ctrl.input.map = false
    game.ctrl.input.menu.main = true
    game.ctrl.input.inputlock = false

    switchFrame!(game,:menu)
    switchText!(game,:menu)
    switchSprite!(game,:cursor)
    moveSprite!(game,:cursor,59,-56+game.ctrl.input.menu.select*16,true)

    return
end

function drawSlotMain!(game::GameState)
    createSprite!(game,mplabels[1].s,:smain,1,2,-73,-30,0,1; active=true)
    createSprite!(game,mplabels[1].b,:balls,1,2,-108,-50,0,2; active=true)
    createSprite!(game,mplabels[1].st,:status,1,1,-88,-11,1,2; active=true)
    createSprite!(game,mplabels[1].i,:item,1,1,-99,-29,2,4; active=true)
    # createSprite!(game,mplabels[1].h,:health,1,1,-96,-56,3,2; active=true)
    createSprite!(game,mplabels[1].ic,:icons,1,1,-104,-44,3,3; active=true)
    
    createText!(game,mplabels[1].n,1,-86,-44,2,
        pkmnName(game,game.p.pokemon[1])*"\\   Lv.$(game.p.pokemon[1].stats.level)",
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; hpad=-3)

    createText!(game,mplabels[1].h,1,-68,-18,2,
        string(game.p.pokemon[1].stats.hp)*"/"*
        string(game.p.pokemon[1].stats.rv[1]),
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff])

    createSprite!(game,:exit,:exit,1,1,92,64,0,1; active=true)
    createSprite!(game,:ballexit,:balls,1,1,74,64,0,2; active=true)

    createText!(game,:exit,1,84,58,2,game.str[1][1],
        [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff])

    return
end

function drawSlotSide!(game::GameState)
    for i in 2:length(game.p.pokemon)
        createSprite!(game,mplabels[i].s,:sside,1,1,47,-59+24*(i-2),0,1; active=true)
        createSprite!(game,mplabels[i].b,:balls,1,1,-22,-59+24*(i-2),0,2; active=true)
        createSprite!(game,mplabels[i].st,:status,1,1,59,-53+24*(i-2),1,2; active=true)
        createSprite!(game,mplabels[i].i,:item,1,1,-11,-51+24*(i-2),2,4; active=true)
        # createSprite!(game,mplabels[i].h,:health,1,1,-96,-56,3,2; active=true)
        createSprite!(game,mplabels[i].ic,:icons,i,1,-18,-63+24*(i-2),3,3; active=true)
        
        createText!(game,mplabels[i].n,1,0,-70+24*(i-2),2,
            pkmnName(game,game.p.pokemon[i])*"\\   Lv.$(game.p.pokemon[i].stats.level)",
            [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff]; hpad=-3)

        createText!(game,mplabels[i].h,1,78,-59+24*(i-2),2,
            string(game.p.pokemon[i].stats.hp)*"/"*
            string(game.p.pokemon[i].stats.rv[1]),
            [0xff,0xff,0xff,0xff],[0x73,0x73,0x73,0xff])
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

function stateMenuPkmnOpen!(game::GameState)
    stateCloseMap!(game)

    loadTeamStrings!(game)

    loadSpriteSheet!(game,"menupkmn/slotmain.png",:smain,78,49,2; maxsprites=1)
    loadSpriteSheet!(game,"menupkmn/slotside.png",:sside,142,22,2; maxsprites=5)
    loadSpriteSheet!(game,"menupkmn/exit.png",:exit,52,16,2; maxsprites=1)
    loadSpriteSheet!(game,"menupkmn/pokeballs.png",:balls,20,24,2; maxsprites=7)
    loadSpriteSheet!(game,"menupkmn/status.png",:status,20,8,1; maxsprites=6)
    loadSpriteSheet!(game,"menupkmn/item.png",:item,8,8,1; maxsprites=6)
    # loadSpriteSheet!(game,"menupkmn/gender.png",:gender,8,8,1; maxsprites=6)
    # loadSpriteSheet!(game,"menupkmn/health.png",:health,1,3,3; maxsprites=6)
    loadIcons!(game)
    
    createBackground!(game,:menupkmn,"backgrounds/menupkmn.png",-120,-80,1; active=true)
    
    createFrame!(game,:choose,21,2,-120,48,1; active=true)
    createFrame!(game,:info,16,2,-120,48,1; active=false)

    createText!(game,:choose,4,-112,57,5,game.str[1][2],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=true,hpad=0)
    createText!(game,:info,4,-112,57,5,game.str[1][3],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=0)
    
    createCallback!(game,:wiggle,animMenuPkmnWiggle!,(); active=true)

    drawSlotMain!(game)
    drawSlotSide!(game)

    return
end

function stateMenuPkmnCtrls!(game::GameState)
    game.ctrl.input.inputlock = false
    game.ctrl.input.menu.pkmn = true

    return
end

function stateMenuPkmnClose!(game::GameState)
    game.ctrl.input.inputlock = true

    killCallback!(game,:wiggle)
    killSpritesAll!(game)
    
    deleteSpriteSheet!(game,:smain)
    deleteSpriteSheet!(game,:sside)
    deleteSpriteSheet!(game,:exit)
    deleteSpriteSheet!(game,:balls)
    deleteSpriteSheet!(game,:status)
    deleteSpriteSheet!(game,:item)
    # deleteSpriteSheet!(game,:health)
    deleteSpriteSheet!(game,:icons)

    deleteBackground!(game,:menupkmn)
    deleteTextsAll!(game)
    deleteFramesAll!(game)

    stateInitMap!(game)
    stateMenuMainOpen!(game)

    return
end




function setVisibleItems!(game::GameState,m::MenuBags)
    nitems = game.p.inventory[-m.bag]

    m.vis .= 0
    s = m.select[m.bag]

    i0 = max(1,(s-min(2,s)+(min(5,nitems-s+1)-5)))

    m.slot = 1  # fix?

    for i in 0:7
        if i0+i == s
            m.slot = i+1
        end
        
        if i0+i > nitems
            m.vis[i+1,1] = -1

            break
        end

        m.vis[i+1,:] = getInvSlot(game,m.bag,i0+i)
    end

    return
end


# function getItemIcon(m::MenuBags)
#     id = Int(m.vis[m.slot])

#     if id == -1
#         return getSprite("im/menu/bag/arrowback.imp")
#     elseif m.bag == 1
#         return getSprite("im/menu/bag/items/$(id-20).imp")
#     elseif m.bag == 2
#         return getSprite("im/menu/bag/balls/$id.imp")
#     elseif m.bag == 3
#         return getSprite("im/menu/bag/machines/$(id-100).imp")
#     elseif m.bag == 4
#         return getSprite("im/menu/bag/berries/$(id-200).imp")
#     elseif m.bag == 5
#         return getSprite("im/menu/bag/keys/$(id-200).imp")
#     end
# end

function stateMenuBagsOpen!(game::GameState)
    stateCloseMap!(game)

    loadInventoryStrings!(game)
    
    loadSpriteSheet!(game,"menubag/arrows.png",:arrows,16,16,5; maxsprites=5)
    loadSpriteSheet!(game,"menubag/bags.png",:bags,64,64,6; maxsprites=1)
    loadSpriteSheet!(game,"menubag/items.png",:items,24,24,8; maxsprites=1)
    loadSpriteSheet!(game,"menubag/marker.png",:markers,4,4,2; maxsprites=1)

    createBackground!(game,:bag1,"backgrounds/bag01.png",-88,-70,1; active=true)
    createBackground!(game,:bag2,"backgrounds/bag02.png",-16,-80,2; active=true)
    createBackground!(game,:bag3,"backgrounds/bag1.png",-120,-80,3; active=true)

    m = game.ctrl.input.menu.menubags#; setVisibleItems!(game,m)
    createSprite!(game,:marker,:markers,1,1,-84+8*m.bag,-51,0,3; active=true)
    createSprite!(game,:bag,:bags,1,m.bag,-48,-12,1,5; active=true)
    createSprite!(game,:left,:arrows,1,4,-90,-64,1,4; active=true)
    createSprite!(game,:right,:arrows,1,2,-22,-64,1,4; active=true)
    createSprite!(game,:ball,:arrows,1,5,-104,-64,1,3; active=true)
    createSprite!(game,:up,:arrows,1,1,54,-66,1,3; active=true)
    createSprite!(game,:down,:arrows,1,3,54,66,1,3; active=true)
    createSprite!(game,:cursor,:cursors,1,1,-4,-55,0,3; active=true)
    createSprite!(game,:item,:items,1,1,-100,4,1,3; active=true)

    createText!(game,:slot,4,-56,-72,4,"slot",[0x00,0x00,0x00,0xff],[0xbd,0x9c,0x5a,0xff];
        active=true,align=0)
    createText!(game,:items,2,0,-63,2,"Items",[0x00,0x00,0x00,0xff],[0xd6,0xd6,0xce,0xff];
        active=true)
    createText!(game,:amounts,2,90,-60,2,"×99",[0x00,0x00,0x00,0xff],[0xd6,0xd6,0xce,0xff];
        active=true)
    createText!(game,:info,2,-117,25,4,"Info1",[0x00,0x00,0x00,0xff],[0xd6,0xd6,0xce,0xff];
        active=true)

    createCC!(game,:bagswitch,animBagSwitch!,(); n=1)
    createCallback!(game,:arrows,true,animArrowsMenu!,())

    return
end

function stateMenuBagsCtrls!(game::GameState)
    game.ctrl.input.inputlock = false
    game.ctrl.input.menu.bags = true

    return
end

function stateMenuBagsClose!(game::GameState)
    game.ctrl.input.inputlock = true
    
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


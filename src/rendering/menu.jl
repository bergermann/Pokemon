


function loadFrame(id::Int)
    return deserialize("im/menu/frames/$id.imp")
end

function drawFrame!(game::GameState,layer::Symbol,height::Int,width::Int,pos::P)
    v = view(getfield(game.im.layers,layer),
        pos.h+1:pos.h+8*height,pos.w+1:pos.w+8*width)

    @views begin
        drawView!(v[1:8,1:8],game.im.frame.im[1:8,1:8],game.im.frame.palette)
        drawView!(v[1:8,end-8+1:end],game.im.frame.im[1:8,17:24],
            game.im.frame.palette)
        drawView!(v[end-8+1:end,1:8],game.im.frame.im[17:24,1:8],
            game.im.frame.palette)
        drawView!(v[end-8+1:end,end-8+1:end],game.im.frame.im[17:24,17:24],
            game.im.frame.palette)

        for i in 2:width-1
            drawView!(v[1:8,8*(i-1)+1:8*i],game.im.frame.im[1:8,9:16],
                game.im.frame.palette)
            drawView!(v[end-8+1:end,8*(i-1)+1:8*i],game.im.frame.im[17:24,9:16],
                game.im.frame.palette)
        end

        for i in 2:height-1
            drawView!(v[8*(i-1)+1:8*i,1:8],game.im.frame.im[9:16,1:8],
                game.im.frame.palette)
            drawView!(v[8*(i-1)+1:8*i,end-8+1:end],game.im.frame.im[9:16,17:24],
                game.im.frame.palette)
        end

        v[8+1:end-8,8+1:end-8] .= game.im.frame.palette[game.im.frame.im[9,9]]
    end
end





function drawMenu!(game::GameState)
    drawFrame!(game,:layer5,20,10,Position(24,176))

    drawText!(game,:layer5,"Pokedex\\Pokemon\\Beutel\\Pokenav\
        \\$(game.trainer.name)\\Speichern\\Optionen\\Beenden",
        UInt(2),Position(38,194); lineoffset=2)

    createSprite!(game,:cursor,:layer5,
        P(41+(game.input.menu.select)*17,185),1,
        getSprite("im/sprites/cursor",1,"black"); active=true)
end





function drawMenuPkmn!(game::GameState)
    bg = deserialize("im/menu/pkmn/background")

    game.im.layers.layer1[24+1:24+160,16+1:16+240] = bg.palette[bg.im]

    b = getSprite("im/menu/pkmm/pokeballs",2)

    drawSlotMain!(game,b)

    for i in 2:game.trainer.pokemon.idx
        drawSlotSide!(game,i,b)
    end

    for i in game.trainer.pokemon.idx+1:6
        game.im.layers.layer1[24+10+1+(i-2)*24:24+10+22+(i-2)*24,
            16+96+1:16+96+142] = mfb_rgb.(load("im/menupokemon/slotempty.png"))
    end

    createSprite!(game,:exit,:layer1,P(24+136,16+186),1,
        getSprite("im/menu/pkmn/exit",2); active=true)
    
    createSprite!(game,:ballexit,:layer1,P(24+132,16+184),1,copy(b); active=true)

    drawText!(game,game.im.sprites[:exit].dict[1][1],game.str[1][1],UInt(1),
        Position(2,18),0xffffff,0x737373)
    drawText!(game,game.im.sprites[:exit].dict[2][1],game.str[1][1],UInt(1),
        Position(2,18),0xffffff,0x737373)

    updateSprite!(game.im.sprites[:exit])
    
    drawFrame!(game,:layer2,4,23,Position(24+128,16))
    drawText!(game,:layer2,"Wähle ein Pokémon.",UInt(2),Position(24+138,24))
end

function drawSlotMain!(game::GameState,b::Tuple{Dict,Palette})
    createSprite!(game,:slot1,:layer1,getMenuStuff("menupokemon/slotmain",6),
        P(24+24,16+8),2; active=true)

    for i in 1:6
        drawHealthBar!(game.im.sprites[:slot1].dict[i][1],
            getHealthBar(game.trainer.pokemon[1]),Position(34,24))
        
        drawText!(game,game.im.sprites[:slot1].dict[i][1],
            pkmnName(game,game.trainer.pokemon[1])*"\\  Lv."*
            string(game.trainer.pokemon[1].stats.level),UInt(1),
            P(10,24),0xffffff,0x737373; lineoffset = -3)
        
        drawText!(game,game.im.sprites[:slot1].dict[i][1],
            string(game.trainer.pokemon[1].stats.hp)*"/"*
            string(game.trainer.pokemon[1].stats.rv[1]),UInt(1),
            P(36,36),0xffffff,0x737373)
    end

    createSprite!(game,:ball1,:layer1,copy(b),P(24+16,16+2),2; active=true)

    updateSprite!(game.im.sprites[:slot1])
end

function drawSlotSide!(game::GameState,slot::Int,b)
    createSprite!(game,Symbol("slot$slot"),:layer1,getMenuStuff("menupokemon/slotside",6),
        P(24+10+(slot-2)*24,16+96),1; active=true)

    for i in 1:6
        drawHealthBar!(game.im.sprites[Symbol("slot$slot")].dict[i][1],
            getHealthBar(game.trainer.pokemon[slot]),P(9,88))

        drawText!(game,game.im.sprites[Symbol("slot$slot")].dict[i][1],
            pkmnName(game,game.trainer.pokemon[slot])*"\\  Lv."*
            string(game.trainer.pokemon[slot].stats.level),UInt(1),
            P(2,20),0xffffff,0x737373; lineoffset = -3)
        
        drawText!(game,game.im.sprites[Symbol("slot$slot")].dict[i][1],
            string(game.trainer.pokemon[slot].stats.hp)*"/"*
            string(game.trainer.pokemon[slot].stats.rv[1]),UInt(1),
            P(11,100),0xffffff,0x737373)
    end
        
    createSprite!(game,Symbol("ball$slot"),:layer1,copy(b),
        P(24+9+(slot-2)*24,16+88),1; active=true)

    updateSprite!(game.im.sprites[Symbol("slot$slot")])
end

function switchSlot!(game::GameState,from::Int,to::Int)
    if from == game.trainer.pokemon.idx+1
        updateSprite!(game.im.sprites[:exit],1)
        updateSprite!(game.im.sprites[:ballexit],1)
    else
        updateSprite!(game.im.sprites[Symbol(:slot,from)],1+2*(
            game.input.menu.menupkmn.swap==from))
        updateSprite!(game.im.sprites[Symbol(:ball,from)],1)
    end

    if to == game.trainer.pokemon.idx+1
        updateSprite!(game.im.sprites[:exit],2)
        updateSprite!(game.im.sprites[:ballexit],2)
    else
        updateSprite!(game.im.sprites[Symbol(:slot,to)],2+2*(
            game.input.menu.menupkmn.swap!=0))
        updateSprite!(game.im.sprites[Symbol(:ball,to)],2)
    end
end

function updateSlots!(game::GameState)
    for i in 1:game.trainer.pokemon.idx
        updateSprite!(game.im.sprites[Symbol(:slot,i)],1+
            1*(i==game.input.menu.menupkmn.select)+
            4*(game.trainer.pokemon[i].stats.rv[1]<=0))

        updateSprite!(game.im.sprites[Symbol(:ball,i)],1+
            1*(i==game.input.menu.menupkmn.select))
    end

    updateSprite!(game.im.sprites[:exit],1+
        1*(game.trainer.pokemon.idx+1==game.input.menu.menupkmn.select))
    
    updateSprite!(game.im.sprites[:ballexit],1+
        1*(game.trainer.pokemon.idx+1==game.input.menu.menupkmn.select))
end

function drawHealthBar!(im::Matrix{UInt32},value::Int,pos::Position)
    if value > 24
        im[pos.h,pos.w+1:pos.w+value] .= 0x5ad684
        im[pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= 0x73ffad
    elseif value > 12
        im[pos.h,pos.w+1:pos.w+value] .= 0xcead08
        im[pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= 0xffe739
    else
        im[pos.h,pos.w+1:pos.w+value] .= 0xad424a
        im[pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= 0xff5a39
    end

    im[pos.h,pos.w+value+1:pos.w+48] .= 0x4a425a
    im[pos.h+1:pos.h+2,pos.w+value+1:pos.w+48] .= 0x526b5a
end

function drawXpBar!(game::GameState,im::Matrix{UInt32},value::Int,pos::Position)
    im[pos.h:pos.h+1,pos.w+1:pos.w+value] .= 0x42ceff
    # im[pos.h:pos.h+1,pos.w+64:-2:pos.w+value+1] .= 0xd8d0b0
    # im[pos.h:pos.h+1,pos.w+63:-2:pos.w+value+1] .= 0xc0b870
end





function getItemIcon(m::MenuBags)
    id = Int(m.vis[m.slot])

    if id == -1
        return getSprite("im/menu/bag/arrowback.imp")
    elseif m.bag == 1
        return getSprite("im/menu/bag/items/$(id-20).imp")
    elseif m.bag == 2
        return getSprite("im/menu/bag/balls/$id.imp")
    elseif m.bag == 3
        return getSprite("im/menu/bag/machines/$(id-100).imp")
    elseif m.bag == 4
        return getSprite("im/menu/bag/berries/$(id-200).imp")
    elseif m.bag == 5
        return getSprite("im/menu/bag/keys/$(id-200).imp")
    end
end

function drawInventory!(game::GameState)
    bg = deserialize("im/menu/bag/background1.imp")

    game.im.layers.layer1[24+1:24+160,16+1:16+240] = bg.palette[bg.im]

    m = game.input.menu.menubags

    createSprite!(game,:slotmarker,:layer1,P(24+27,16+34+m.bag*8),1,
        getSprite("im/menu/bag/slotmarker1.imp"); active=true)

    createSprite!(game,:slot,:layer1,P(24+8,16+24),m.bag,
        getSprite("im/menu/bag/slots",5); active=true)

    createSprite!(game,:bag,:layer1,P(24+34,16+40),m.bag,
        getSprite("im/menu/bag/bag1",6); active=true)

    createSprite!(game,:arrowleft,:layer1,P(24+8,16+22),1,
        getSprite("im/menu/bag/arrowhor.imp"); active=true)
    
    createSprite!(game,:arrowright,:layer1,P(24+8,16+90),1,
        getSprite("im/menu/bag/arrowhor.imp"); active=true,hreverse=true)

    createSprite!(game,:arrowup,:layer1,P(24+26,16+40),1,
        getSprite("im/menu/bag/arrowvert.imp"); active=false)

    createSprite!(game,:arrowdown,:layer1,P(24+26,16+40),1,
        getSprite("im/menu/bag/arrowvert.imp"); active=false,vreverse=true)
    
    setVisibleItems!(game)
    drawInventoryText!(game)
    drawItemText!(game)

    createSprite!(game,:icon,:layer1,P(96,16+8),1,getItemIcon(m); active=true)

    createSprite!(game,:cursor,:layer1,P(24+7+15*m.slot,16+114),1,
        getSprite("im/sprites/cursor",1,"black"); active=true)
end

function setInventoryItemIcon!(game::GameState)
    s = game.im.sprites[:icon]
    
    s.dict, s.palette = getItemIcon(game.input.menu.menubags)

    updateSprite!(s)
end

function setVisibleItems!(game::GameState)
    m = game.input.menu.menubags
    nitems = game.trainer.inventory[-m.bag]

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
end

function drawInventoryText!(game::GameState)
    vis = game.input.menu.menubags.vis

    for i in 1:8
        if vis[i,1] == -1
            drawText!(game,:layer2,game.str[1][6],UInt(2),
                P(24+19+15*(i-1),16+121),0x010101,0xd6d6ce)

            break
        end

        drawText!(game,:layer2,game.str[2][vis[i,1]],UInt(2),
            P(24+19+15*(i-1),16+121),0x010101,0xd6d6ce)

        drawText!(game,:layer2,"×",UInt(1),
            P(24+22+15*(i-1),16+210),0x010101,0xd6d6ce)

        drawText!(game,:layer2,string(vis[i,2]),UInt(2),
            P(24+19+15*(i-1),16+217),0x010101,0xd6d6ce)
    end
end

function drawItemText!(game::GameState)
    vis = game.input.menu.menubags.vis[game.input.menu.menubags.slot,1]

    flushLayer!(game,:layer3,P(24+100,16+2),P(50,103))

    if vis == -1
        drawText!(game,:layer3,game.str[1][7],UInt(2),
            P(24+103,16+4),0x010101,0xd6d6ce)
    else
        drawText!(game,:layer3,game.str[3][vis],UInt(2),
            P(24+103,16+4),0x010101,0xd6d6ce)
    end
end

function drawSlotSwitchDown!(game::GameState)
    vis = game.input.menu.menubags.vis

    flushLayer!(game,:layer2,P(24+21,16+120),P(14,110))
    shiftLayerUp!(game.im.layers.layer2,15)

    if vis[8,1] == -1
        drawText!(game,:layer2,game.str[1][6],UInt(2),
            P(24+19+105,16+121),0x010101,0xd6d6ce)
    else
        drawText!(game,:layer2,game.str[2][vis[8,1]],UInt(2),
            P(24+19+105,16+121),0x010101,0xd6d6ce)
    
        drawText!(game,:layer2,"×",UInt(1),
            P(24+22+105,16+210),0x010101,0xd6d6ce)
    
        drawText!(game,:layer2,string(vis[8,2]),UInt(2),
            P(24+19+105,16+217),0x010101,0xd6d6ce)
    end
end

function drawSlotSwitchUp!(game::GameState)
    vis = game.input.menu.menubags.vis

    flushLayer!(game,:layer2,P(24+21+105,16+120),P(14,130))
    shiftLayerDown!(game.im.layers.layer2,15)

    drawText!(game,:layer2,game.str[2][vis[1,1]],UInt(2),
        P(24+19,16+121),0x010101,0xd6d6ce)

    drawText!(game,:layer2,"×",UInt(1),
        P(24+22,16+210),0x010101,0xd6d6ce)

    drawText!(game,:layer2,string(vis[1,2]),UInt(2),
        P(24+19,16+217),0x010101,0xd6d6ce)
end





function drawChoiceMenu!(game::GameState,layer::Symbol,strs::Vector{String},
        width::Int,pos::Position; c1::UInt32=0x010101,c2::UInt32=0xd6d6ce)

    game.input.choice.max = length(strs)
    game.input.choice.layer = layer
    
    drawFrame!(game,layer,2+length(strs)*2,width,pos)

    createSprite!(game,:ccursor,layer,getMenuStuff("menubag/cursor",2),
        posAdd(pos,P(11,9)),1; active=true)
    
    game.im.sprites[:ccursor].pos.h += 16*(game.input.choice.sel-1)
    
    posAdd!(pos,-8,17)

    for i in eachindex(strs)
        pos.h += 16

        drawText!(game,layer,strs[i],UInt(2),pos,c1,c2)
    end
end








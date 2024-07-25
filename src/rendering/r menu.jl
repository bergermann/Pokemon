





function updateSlots!(game::GameState)
    for i in 1:game.trainer.pokemon.idx
        updateSprite!(game.im.sprites[1][Symbol(:slot,i)],1+
            1*(i==game.input.menu.menupkmn.select)+
            4*(game.trainer.pokemon[i].stats.rv[1]<=0))

        updateSprite!(game.im.sprites[1][Symbol(:ball,i)],1+
            1*(i==game.input.menu.menupkmn.select))
    end

    updateSprite!(game.im.sprites[1][:exit],1+
        1*(game.trainer.pokemon.idx+1==game.input.menu.menupkmn.select))
    
    updateSprite!(game.im.sprites[1][:ballexit],1+
        1*(game.trainer.pokemon.idx+1==game.input.menu.menupkmn.select))

    return
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
    
    return
end

function drawHealthBar!(sprite::Sprite,value::Int,pos::Position,
        frames::Vector{Int})
        
    idx = expandPalette!(sprite,0x5ad684,0x73ffad,0xcead08,0xffe739,
        0xad424a,0xff5a39,0x4a425a,0x526b5a)

    @views for frame in frames
        if value > 24
            sprite.dict[frame][pos.h,pos.w+1:pos.w+value] .= idx[1]
            sprite.dict[frame][pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= idx[2]
        elseif value > 12
            sprite.dict[frame][pos.h,pos.w+1:pos.w+value] .= idx[3]
            sprite.dict[frame][pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= idx[4]
        else
            sprite.dict[frame][pos.h,pos.w+1:pos.w+value] .= idx[5]
            sprite.dict[frame][pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= idx[6]
        end
    
        sprite.dict[frame][pos.h,pos.w+value+1:pos.w+48] .= idx[7]
        sprite.dict[frame][pos.h+1:pos.h+2,pos.w+value+1:pos.w+48] .= idx[8]
    end

    return
end


function drawHealthBar!(sprite::Sprite,value::Int,pos::Position)
    idx = expandPalette!(sprite,0x5ad684,0x73ffad,0xcead08,0xffe739,
        0xad424a,0xff5a39,0x4a425a,0x526b5a)

    if value > 24
        sprite.im[pos.h,pos.w+1:pos.w+value] .= idx[1]
        sprite.im[pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= idx[2]
    elseif value > 12
        sprite.im[pos.h,pos.w+1:pos.w+value] .= idx[3]
        sprite.im[pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= idx[4]
    else
        sprite.im[pos.h,pos.w+1:pos.w+value] .= idx[5]
        sprite.im[pos.h+1:pos.h+2,pos.w+1:pos.w+value] .= idx[6]
    end

    sprite.im[pos.h,pos.w+value+1:pos.w+48] .= idx[7]
    sprite.im[pos.h+1:pos.h+2,pos.w+value+1:pos.w+48] .= idx[8]

    return
end

function drawXpBar!(im::Matrix{UInt32},value::Int,pos::Position)
    im[pos.h:pos.h+1,pos.w+1:pos.w+value] .= 0x42ceff
    # im[pos.h:pos.h+1,pos.w+64:-2:pos.w+value+1] .= 0xd8d0b0
    # im[pos.h:pos.h+1,pos.w+63:-2:pos.w+value+1] .= 0xc0b870

    return
end

function drawXpBar!(sprite::Sprite,value::Int,pos::Position)
    idx = expandPalette!(sprite,0x42ceff)

    sprite.im[pos.h:pos.h+1,pos.w+1:pos.w+value] .= idx[1]
    # im[pos.h:pos.h+1,pos.w+64:-2:pos.w+value+1] .= 0xd8d0b0
    # im[pos.h:pos.h+1,pos.w+63:-2:pos.w+value+1] .= 0xc0b870

    return
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

function drawInventory!(game::GameState,m::MenuBags)
    bg = deserialize("im/menu/bag/background1.imp")

    game.im.layers[1][24+1:24+160,16+1:16+240] = bg.palette[bg.im]

    createSprite!(game,:slotmarker,1,P(24+27,16+34+m.bag*8),1,
        getSprite("im/menu/bag/slotmarker1.imp"); active=true)

    createSprite!(game,:slot,1,P(24+8,16+24),m.bag,
        getSprite("im/menu/bag/slots",5); active=true)

    createSprite!(game,:bag,1,P(24+34,16+40),m.bag,
        getSprite("im/menu/bag/bag1",6); active=true)

    createSprite!(game,:arrowleft,1,P(24+8,16+22),1,
        getSprite("im/menu/bag/arrowhor.imp"); active=true)
    
    createSprite!(game,:arrowright,1,P(24+8,16+90),1,
        getSprite("im/menu/bag/arrowhor.imp"); active=true,hreverse=true)

    createSprite!(game,:arrowup,1,P(24+26,16+40),1,
        getSprite("im/menu/bag/arrowvert.imp"); active=false)

    createSprite!(game,:arrowdown,1,P(24+26,16+40),1,
        getSprite("im/menu/bag/arrowvert.imp"); active=false,vreverse=true)
    
    setVisibleItems!(game,m)
    drawInventoryText!(game,m)
    drawItemText!(game,m)

    createSprite!(game,:icon,1,P(96,16+8),1,getItemIcon(m); active=true)

    createSprite!(game,:cursor,1,P(24+7+15*m.slot,16+114),1,
        getSprite("im/sprites/cursor",1,"black"); active=true)

    return
end

drawInventory!(game::GameState) = drawInventory!(game,game.input.menu.menubags)

function setInventoryItemIcon!(game::GameState,m::MenuBags)
    s = game.im.sprites[1][:icon]
    
    s.dict, s.palette = getItemIcon(m)

    updateSprite!(s)

    return
end

function setVisibleItems!(game::GameState,m::MenuBags)
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

    return
end

function drawInventoryText!(game::GameState,m::MenuBags)
    vis = m.vis

    for i in 1:8
        if vis[i,1] == -1
            drawText!(game,2,game.str[1][6],UInt(2),
                P(24+19+15*(i-1),16+121),0x010101,0xd6d6ce)

            break
        end

        drawText!(game,2,game.str[2][vis[i,1]],UInt(2),
            P(24+19+15*(i-1),16+121),0x010101,0xd6d6ce)

        drawText!(game,2,"×",UInt(1),
            P(24+22+15*(i-1),16+210),0x010101,0xd6d6ce)

        drawText!(game,2,string(vis[i,2]),UInt(2),
            P(24+19+15*(i-1),16+217),0x010101,0xd6d6ce)
    end

    return
end

function drawItemText!(game::GameState,m::MenuBags)
    vis = m.vis[m.slot,1]

    flushLayer!(game,3,P(24+100,16+2),P(50,103))

    if vis == -1
        drawText!(game,3,game.str[1][7],UInt(2),
            P(24+103,16+4),0x010101,0xd6d6ce)
    else
        drawText!(game,3,game.str[3][vis],UInt(2),
            P(24+103,16+4),0x010101,0xd6d6ce)
    end

    return
end

function drawSlotSwitchDown!(game::GameState,m::MenuBags)
    vis = m.vis

    flushLayer!(game,2,P(24+21,16+120),P(14,110))
    shiftLayerUp!(game.im.layers[2],15)

    if vis[8,1] == -1
        drawText!(game,2,game.str[1][6],UInt(2),
            P(24+19+105,16+121),0x010101,0xd6d6ce)
    else
        drawText!(game,2,game.str[2][vis[8,1]],UInt(2),
            P(24+19+105,16+121),0x010101,0xd6d6ce)
    
        drawText!(game,2,"×",UInt(1),
            P(24+22+105,16+210),0x010101,0xd6d6ce)
    
        drawText!(game,2,string(vis[8,2]),UInt(2),
            P(24+19+105,16+217),0x010101,0xd6d6ce)
    end

    return
end

function drawSlotSwitchUp!(game::GameState,m::MenuBags)
    vis = m.vis

    flushLayer!(game,2,P(24+21+105,16+120),P(14,130))
    shiftLayerDown!(game.im.layers[2],15)

    drawText!(game,2,game.str[2][vis[1,1]],UInt(2),
        P(24+19,16+121),0x010101,0xd6d6ce)

    drawText!(game,2,"×",UInt(1),
        P(24+22,16+210),0x010101,0xd6d6ce)

    drawText!(game,2,string(vis[1,2]),UInt(2),
        P(24+19,16+217),0x010101,0xd6d6ce)

    return
end











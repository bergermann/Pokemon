





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











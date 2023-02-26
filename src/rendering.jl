#240x160
using MiniFB, Images, DelimitedFiles

include("parser.jl")
#include("animations.jl")

#=
struct Settings
    width::UInt16
    height::UInt16
    fps::Float16

    Nh::UInt8
    Nw::UInt8
    tilesize::UInt8

    offseth::UInt16
    offsetw::UInt16

    function Settings()
        new(0x00f0,0x00a0,60.,0x0d,0x11,0x10,0x0000,0x0000)
    end

    function Settings(width::UInt16,height::UInt16,fps::Float16,
            Nh::UInt8,Nw::UInt8,tilesize::UInt8,offseth::UInt16,offsetw::UInt16)
        new(width,height,fps,Nh,Nw,tilesize,offseth,offsetw)
    end
end

mutable struct Layers
    water::Matrix{UInt32}
    layer1::Matrix{UInt32}
    layer2::Matrix{UInt32}
    layer3::Matrix{UInt32}
    layer4::Matrix{UInt32}

    textbox::Matrix{UInt32}

    menu::Matrix{UInt32}

    menu1::Matrix{UInt32}
    menu2::Matrix{UInt32}
    menu3::Matrix{UInt32}
    
    #text::Matrix{UInt32}
    

    function Layers(; s::Settings=Settings())
        new([zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
            UInt16(s.Nw)*UInt16(s.tilesize)) for _ in eachindex(fieldnames(Layers))]...)
    end
end
=#

function flushLayer!(game::GameState,layer::Symbol)
    getfield(game.im.layers,layer) .= 0x000000
end

function flushLayer!(game::GameState,layer::Symbol,pos::Position,size::Position)
    v = view(getfield(game.im.layers,layer),
        pos.h+1:pos.h+size.h,pos.w+1:pos.w+size.w)
    
    v .= 0x000000
end

function flushLayer!(game::GameState,layer::Symbol,pos::Position,size::Position,
        color::UInt32)
    v = view(getfield(game.im.layers,layer),
        pos.h+1:pos.h+size.h,pos.w+1:pos.w+size.w)
    
    v .= color
end

function flushLayer!(game::GameState)
    game.im.layer .= 0x000000
end

function flushLayers!(game::GameState)
    for f in fieldnames(Layers)
        flushLayer!(game,f)
    end
end





function getTiles(tileset::String; s=Settings())
    tileset = mfb_rgb.(load(string("maps/",tileset,".png")))

    height::UInt16,width::UInt16  = size(tileset)

    if height%0x0010 != 0x0000 || width%0x0010 != 0x0000
        return error("Wrong tileset format.")
    end

    
    h_tiles = div(height,s.tilesize)
    w_tiles = div(width,s.tilesize)
    n_tiles = h_tiles*w_tiles

    return Dict(zip(collect(0x0000:n_tiles),
                [tileset[0x0001+(h-1)*0x0010:h*0x0010,
                        0x001+(w-1)*0x0010:w*0x0010] for w in 0x0001:w_tiles,
                                                        h in 0x0001:h_tiles]))
end

function getTileMap(dir::String,key::Vector{Symbol}; s=Settings())
    tm = TileMap(; s=s)

    for k in key
        setfield!(tm,k,readdlm(string("maps/",dir,"/",k,".csv"),',',UInt16,'\n'))
    end

    return tm
end





function drawMap!(game::GameState; s=Settings())
    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    @inbounds for k in game.map.environment
        @inbounds for i in 1:s.Nh, j in 1:s.Nw
            tile = game.map.tiles[
                getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
                game.pos.w+j-dw-1]]

            v = view(getfield(game.im.layers,k),
                1+(i-1)*s.tilesize:i*s.tilesize,
                1+(j-1)*s.tilesize:j*s.tilesize)
            
            @inbounds for t in eachindex(v)
                v[t] = tile[t]
            end
        end
    end
end

function combineLayers!(game::GameState,layers::Vector{Symbol};
    s::Settings=Settings())

    l = game.im.layer

    @inbounds for k in layers
        ls = getproperty(game.im.layers,k)

        @inbounds for i in eachindex(l)
            @views if ls[i] != 0x000000
                l[i] = ls[i]
            end
        end
    end

    return
end

function combineLayers!(game::GameState; s::Settings=Settings())

    l = game.im.layer

    @inbounds for k in fieldnames(Layers)
        ls = getproperty(game.im.layers,k)

        if !ls.active
            continue
        end

        @inbounds for i in eachindex(l)
            @views if ls.layer[i] != 0x000000
                l[i] = ls.layer[i]
            end
        end
    end

    return
end





function Sprites(n::Int)
    S = ArrayList(Sprite,n)

    for i in 1:n
        push!(S,Sprite())
    end

    S.idx = 0

    return S
end

function getSpriteMain(set::String; s=Settings())
    spriteset = mfb_rgb.(load("sprites/$set.png"))

    key::Vector{Tuple{Int,Int,Int,Int,Int,Int}} = [
        (1,1,32,16,3,10),    #walk
        (1,17,32,16,3,0),
        (1,33,32,16,3,20),

        (97,1,32,16,3,50),  #run
        (97,17,32,16,3,40),
        (97,33,32,16,3,60),

        (1,49,32,32,9,90),  #bike
        (1,81,32,32,9,80),
        (1,113,32,32,9,100),

        (1,145,32,32,2,120),
        (1,177,32,32,2,130),
        (1,209,32,32,2,140),

        (97,145,32,32,2,120),
        (97,177,32,32,2,130),
        (97,209,32,32,2,140),

        (1,241,32,32,5,150),
    
        (1,273,32,32,4,160),
        (1,305,32,32,4,170),
        (1,337,32,32,4,180),

        (1,369,32,32,1,190),
        (1,401,32,32,1,200),
        (1,433,32,32,1,210),

        (33,369,32,32,1,220),
        (33,401,32,32,1,230),
        (33,433,32,32,1,240),

        (1,465,32,32,1,250),
        (1,497,64,64,4,260),
        (97,401,64,64,1,270)
    ]

    d = Dict{Int,Matrix{UInt32}}()

    for k in key
        if k[5] > 1
            for i in 1:k[5]
                s = k[6]+i

                d[s] = spriteset[k[1]+(i-1)*k[3]:k[1]+i*k[3]-1,
                    k[2]:k[2]+k[4]-1]
            end
        else
            d[k[6]] = spriteset[k[1]:k[1]+k[3]-1,k[2]:k[2]+k[4]-1]
        end
    end

    d[31] = reverse(d[21]; dims=2)
    d[32] = reverse(d[22]; dims=2)
    d[33] = reverse(d[23]; dims=2)
    
    d[71] = reverse(d[61]; dims=2)
    d[72] = reverse(d[62]; dims=2)
    d[73] = reverse(d[63]; dims=2)
    
    #=
    d[:walkright] = reverse.(d[:walkleft]; dims=2)
    d[:runright] = reverse.(d[:runleft]; dims=2)
    d[:bikeright] = reverse.(d[:bikeleft]; dims=2)
    d[:sitright] = reverse.(d[:sitleft]; dims=2)
    d[:waterright] = reverse.(d[:waterleft]; dims=2)
    d[:fishright] = reverse.(d[:fishleft]; dims=2)
    d[:surfright] = reverse.(d[:surfleft]; dims=2)
    d[:diveright] = reverse.(d[:diveleft]; dims=2)
    =#

    return d
end

function updateSprite!(sprite::Sprite,frame::Int)
    sprite.frame = frame
    sprite.im = sprite.dict[frame]
    sprite.size = Position(size(sprite.im)...)
end

function updateSprite!(sprite::Sprite)
    sprite.im = sprite.dict[sprite.frame]
    sprite.size = Position(size(sprite.im)...)
end

function drawSprites!(game::GameState; s=Settings())
    @inbounds for i in 1:game.im.sprites.idx
        if !game.im.sprites[i].active
            continue
        end
        
        sprite = game.im.sprites.data[i]
        l = getfield(game.im.layers,sprite.layer)

        v = view(l, sprite.pos.h+1:sprite.pos.h+sprite.size.h,
            sprite.pos.w+1:sprite.pos.w+sprite.size.w)

        @inbounds for i in eachindex(v)
            if sprite.im[i] != 0x000000
                v[i] = sprite.im[i]
            end
        end
    end

    #=
    id::Symbol

    layer::Symbol
    pos::Position
    size::Position

    frame::Symbol
    dict::Dict{Symbol,Matrix{UInt32}}

    im::Matrix{UInt32}
    =#
end





function getDialogueBox(set::String; s=Settings())
    boxes = mfb_rgb.(load("im/$set.png"))

    key::Vector{Tuple{Int,Int,UInt8}} = [
        (1,48,0x01),
        (49,48,0x02)
    ]

    return Dict{UInt8,Matrix{UInt32}}(
        zip([k[3] for k in key],[boxes[k[1]:k[1]+k[2]-1,:] for k in key])
    )
end

function getDialogue(str::String; s=Settings())
    return mfb_rgb.(load("im/dialogue/$str.png"))
end

function drawDialogue!(game::GameState)
    game.im.layers.textbox[end-48-24+1:end-24,16+1:end-16] = game.im.diabox[game.options.diabox]
    drawText!(game,:textbox,game.dialogue.str[game.dialogue.n],UInt(2),Position(144,32))
end





function getFrames(set::String)
    frames = mfb_rgb.(load("im/$set.png"))

    return Dict{Int,Dict{Int,Matrix{UInt32}}}(
        zip(
            collect(1:30),
            [
                Dict{Int,Matrix{UInt32}}(
                    zip(collect(1:9),
                    [frames[
                            1+(i-1)*8+rows*24:i*8+rows*24,
                            1+(j-1)*8+cols*24:j*8+cols*24
                        ] for j in 1:3, i in 1:3
                    ])
                ) for cols in 0:9, rows in 0:2
            ]
        )
    )
end

function drawFrame!(game::GameState,layer::Symbol,height::UInt,width::UInt,
        pos::Position)
    
    l = getfield(game.im.layers,layer)
    f = game.im.frames[game.options.frame]
    
    @inbounds for i in 1:height, j in 1:width
        if i != 1 && i != height && j != 1 && j != width
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[5]
        elseif i == 1 && j == 1
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[1]
        elseif i == 1 && j != 1 && j != width
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[2]
        elseif i == 1 && j == width
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[3]
        elseif i != 1 && i != height && j == 1
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[4]
        elseif i != 1 && i != height && j == width
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[6]
        elseif i == height && j == 1
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[7]
        elseif i == height && j != 1 && j != width
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[8]
        else
            l[1+pos.h+(i-1)*8:pos.h+i*8,
                1+pos.w+(j-1)*8:pos.w+j*8] = f[9]
        end
    end
end

function drawFrame1!(game::GameState,layer::Symbol,height::Int,width::Int,
        pos::Position)
    
    l = getproperty(game.im.layers,layer)
    f = game.im.frames[game.options.frame]
    
    @time @inbounds for i in 1:height, j in 1:width
        @views l_ = l[1+pos.h+(i-1)*8:pos.h+i*8,1+pos.w+(j-1)*8:pos.w+j*8]
        if i == 1
            if j == 1
                @views l_ = f[1:8,1:8]
            elseif j == width
                @views l_ = f[1:8,1:8]
            else
                @views l_ = f[1:8,1:8]
            end
        elseif i == height
            if j == 1
                @views l_ = f[1:8,1:8]
            elseif j == width
                @views l_ = f[1:8,1:8]
            else
                @views l_ = f[1:8,1:8]
            end
        else
            if j == 1
                @views l_ = f[1:8,1:8]
            elseif j == width
                @views l_ = f[1:8,1:8]
            else
                @views l_ = f[1:8,1:8]
            end
        end
    end
end

function drawMenu!(game::GameState)
    drawFrame!(game,:menu,UInt(20),UInt(10),Position(24,176))

    drawText!(game,:menu,"POKEDEX\\POKEMON\\BEUTEL\\POKENAV\
        \\$(game.trainer.name)\\SICHERN\\OPTION\\BEENDEN",
        UInt(2),Position(38,194); lineoffset=2)

    drawText!(game,:menu,"▷",UInt(2),Position(38+(game.input.menu.select)*17,186))
end





function getMenuPkmn()
    img = mfb_rgb.(load("im/menupkmn.png"))

    parts::Vector{String} = [
        "bg","slotmain0","slotmain1","slotmainswap0","slotmainswap1",
        "slotside0","slotside1","slotsideswap0","slotsideswap1","slotempty",
        "ball0","ball1","letter","item","faint","frozen","poison","burn",
        "paralysed","sleep","pokerus","exit0","exit1"
    ]

    key::Matrix{Int} = [
        1 1 160 240;    #background
        1 241 49 78;    #slotmain0
        1 319 49 78;    #slotmain1
        50 241 49 78;   #slotmainswap0
        50 319 49 78;   #slotmainswap1
        99 241 22 142;   #slotside0
        121 241 22 142;  #slotside1
        143 241 22 142;  #slotsideswap0
        165 241 22 142;  #slotsideswap1
        187 241 22 142;  #slotempty
        161 1 24 20;    #ball0
        161 21 24 20;   #ball1
        161 41 6 7;     #letter
        169 41 7 7;     #item
        161 49 8 20;    #faint
        169 49 8 20;    #frozen
        161 73 8 20;    #poison
        169 73 8 20;    #burn
        161 97 8 20;    #para
        169 97 8 20;    #sleep
        161 121 8 20;   #pokerus
        161 185 16 52;  #exit0
        177 185 16 52;  #exit1
    ]

    return Dict{String,Matrix{UInt32}}(zip(parts,[img[key[i,1]:key[i,1]+key[i,3]-1,
        key[i,2]:key[i,2]+key[i,4]-1] for i in eachindex(parts)]))
end

function drawMenuPkmn!(game::GameState)
    game.im.layers.menu1[24+1:24+160,16+1:16+240] = game.im.menupkmn["bg"]
    

    for i in eachindex(game.trainer.pokemon)
        if i == 1
            if game.menu.pkmn.select == 0x00
                game.im.layers.menu1[24+24+1:24+24+49,
                    16+8+1:16+8+78] = game.im.menupkmn["slotmain1"]
                
                game.im.layers.menu2[24+16+1:24+16+24,
                    16+2+1:16+2+20] = game.im.menupkmn["ball1"]
            else
                game.im.layers.menu1[24+24+1:24+24+49,
                    16+8+1:16+8+78] = game.im.menupkmn["slotmain0"]
                
                game.im.layers.menu2[24+16+1:24+16+24,
                    16+2+1:16+2+20] = game.im.menupkmn["ball0"]
            end
            
            drawText!(game,:menu1,pkmnName(game,game.trainer.pokemon[1])*"\\  Lv."*
                string(game.trainer.pokemon[1].stats.level),UInt(1),
                Position(24+34,16+34); lineoffset = -3)
            
            drawText!(game,:menu1,string(game.trainer.pokemon[1].stats.hp)*"/"*
                string(game.trainer.pokemon[1].stats.rv[1]),UInt(1),
                Position(24+60,16+58))
            
            drawHealthBar!(game,:menu1,getHealthBar(game.trainer.pokemon[1]),
                Position(24+58,16+33))
        else
            if game.menu.pkmn.select == UInt8(i-1)
                game.im.layers.menu1[24+10+1+(i-2)*24:24+10+22+(i-2)*24,
                    16+96+1:16+96+142] = game.im.menupkmn["slotside1"]
                
                game.im.layers.menu2[24+9+1+(i-2)*24:24+9+24+(i-2)*24,
                    16+88+1:16+88+20] = game.im.menupkmn["ball1"]
            else
                game.im.layers.menu1[24+10+1+(i-2)*24:24+10+22+(i-2)*24,
                    16+96+1:16+96+142] = game.im.menupkmn["slotside0"]
                
                game.im.layers.menu2[24+9+1+(i-2)*24:24+9+24+(i-2)*24,
                    16+88+1:16+88+20] = game.im.menupkmn["ball0"]
            end
            
            drawText!(game,:menu1,pkmnName(game,game.trainer.pokemon[i])*"\\  Lv."*
                string(game.trainer.pokemon[i].stats.level),UInt(1),
                Position(24+11+(i-2)*24,16+121); lineoffset = -3)
            
            drawText!(game,:menu1,string(game.trainer.pokemon[i].stats.hp)*"/"*
                string(game.trainer.pokemon[i].stats.rv[1]),UInt(1),
                Position(24+21+(i-2)*24,16+211))

            drawHealthBar!(game,:menu1,getHealthBar(game.trainer.pokemon[i]),
                Position(24+19+(i-2)*24,16+185))
        end
    end

    for i in length(game.trainer.pokemon)+1:6
        game.im.layers.menu1[24+10+1+(i-2)*24:24+10+22+(i-2)*24,
            16+96+1:16+96+142] = game.im.menupkmn["slotempty"]
    end

    if game.menu.pkmn.select == length(game.trainer.pokemon)
        game.im.layers.menu1[24+136+1:24+136+16,
            16+186+1:16+186+52] = game.im.menupkmn["exit1"]
        
        game.im.layers.menu2[24+132+1:24+132+24,
            16+184+1:16+184+20] = game.im.menupkmn["ball1"]
    else
        game.im.layers.menu1[24+136+1:24+136+16,
            16+186+1:16+186+52] = game.im.menupkmn["exit0"]
        
        game.im.layers.menu2[24+132+1:24+132+24,
            16+184+1:16+184+20] = game.im.menupkmn["ball0"]
    end

    drawFrame!(game,:menu2,UInt(4),UInt(23),Position(24+128,16))

    drawText!(game,:menu2,"Wähle ein Pokémon.",UInt(2),Position(24+136,24))
    drawText!(game,:menu2,"ZURUCK",UInt(1),Position(24+137,16+204))
end

function drawHealthBar!(game::GameState,layer::Symbol,value::Int,pos::Position)
    getfield(game.im.layers,layer)[pos.h,pos.w:pos.w+value] .= 0x5ad684
    getfield(game.im.layers,layer)[pos.h+1:pos.h+2,pos.w:pos.w+value] .= 0x73ffad
end









function getInventory()
    img = mfb_rgb.(load("im/inventory.png"))

    parts::Vector{String} = [
        "bgblue","bgred","items","balls","machines","berries","key","marker1","marker0","`?",
        "up","down","left","right","back","slotred","slotblue","bag1","bag2",
        "bag3","bag4","bag5","belt1","belt2","belt3","belt4","belt5"
    ]

    key::Matrix{Int} = [
        1 1 160 240;    #bgblue
        1 241 160 240;  #bgred
        1 481 16 80;    #items
        17 481 16 80;   #balls
        33 481 16 80;   #machines
        49 481 16 80;   #berries
        65 481 16 80;   #key
        81 481 16 8;    #marker1
        81 489 16 8;    #marker0
        81 497 16 16;   #?
        81 513 16 16;   #up
        81 529 16 16;   #down
        97 513 16 16;   #left
        97 529 16 16;   #right
        81 545 24 24;   #back
        105 481 8 8;    #slotred
        105 489 8 8;    #slotblue
        161 1 64 64;    #bag1
        161 65 64 64;   #bag2
        161 129 64 64;  #bag3
        161 193 64 64;  #bag4
        161 257 64 64;  #bag5
        161 321 64 64;  #belt1
        161 385 64 64;  #belt2
        161 449 64 64;  #belt3
        161 513 64 64;  #belt4
        161 577 64 64;  #belt5
    ]

    return Dict{String,Matrix{UInt32}}(zip(parts,[img[key[i,1]:key[i,1]+key[i,3]-1,
        key[i,2]:key[i,2]+key[i,4]-1] for i in eachindex(parts)]))
end

function drawInventory!(game::GameState)
    game.im.layers.menu1[24+1:24+160,16+1:16+240] = game.im.inv["bgblue"]

    for i in 0:4
        game.im.layers.menu2[24+24+1:24+24+8,16+40+1+i*8:16+40+8+i*8] .= 0x000000
    end

    game.im.layers.menu2[24+24+1:24+24+8,
        16+40+1+game.menu.bags.slot*8:16+40+8+game.menu.bags.slot*8] = game.im.inv["slotred"]

    if game.menu.bags.slot == 0x00
        game.im.layers.menu1[24+8+1:24+8+16,16+24+1:16+24+80] = game.im.inv["items"]
        game.im.layers.menu2[24+36+1:24+36+64,16+40+1:16+40+64] = game.im.inv["bag1"]
    elseif game.menu.bags.slot == 0x01
        game.im.layers.menu1[24+8+1:24+8+16,16+24+1:16+24+80] = game.im.inv["balls"]
        game.im.layers.menu2[24+36+1:24+36+64,16+40+1:16+40+64] = game.im.inv["bag2"]
    elseif game.menu.bags.slot == 0x02
        game.im.layers.menu1[24+8+1:24+8+16,16+24+1:16+24+80] = game.im.inv["machines"]
        game.im.layers.menu2[24+36+1:24+36+64,16+40+1:16+40+64] = game.im.inv["bag3"]
    elseif game.menu.bags.slot == 0x03
        game.im.layers.menu1[24+8+1:24+8+16,16+24+1:16+24+80] = game.im.inv["berries"]
        game.im.layers.menu2[24+36+1:24+36+64,16+40+1:16+40+64] = game.im.inv["bag4"]
    elseif game.menu.bags.slot == 0x04
        game.im.layers.menu1[24+8+1:24+8+16,16+24+1:16+24+80] = game.im.inv["key"]
        game.im.layers.menu2[24+36+1:24+36+64,16+40+1:16+40+64] = game.im.inv["bag5"]
    end

    if game.n.frame%0x1e < 0x0f
        game.im.layers.menu2[
            24+8+1:24+8+16,16+22+1-div(game.n.frame%0x1e,0x05):16+22+16-div(game.n.frame%0x1e,0x05)
        ] = game.im.inv["left"]
        
        game.im.layers.menu2[
            24+8+1:24+8+16,16+90+1+div(game.n.frame%0x1e,0x05):16+90+16+div(game.n.frame%0x1e,0x05)
        ] = game.im.inv["right"]
    else
        game.im.layers.menu2[
            24+8+1:24+8+16,16+19+1+div(game.n.frame%0x1e,0x05):16+19+16+div(game.n.frame%0x1e,0x05)
        ] = game.im.inv["left"]
        
        game.im.layers.menu2[
            24+8+1:24+8+16,16+93+1-div(game.n.frame%0x1e,0x05):16+93+16-div(game.n.frame%0x1e,0x05)
        ] = game.im.inv["right"]
    end

end





function getBattlers()
    img = mfb_rgb.(load("im/battlers gen1.png"))

    d1 = Dict{UInt,Matrix{UInt32}}(
        zip(Vector{UInt}(1:151),[img[
            1+64*div(i,10):64+64*div(i,10),1+64*i%10:64+64*i%10
        ] for i in 0:150])
    )

    return merge(d1,)
end

function getBattlerFront(id::Int)
    img = mfb_rgb.(load("im/battlers/front/normal/$id.png"))

    return Dict{Int,Matrix{UInt32}}(1=>img[:,1:64],2=>img[:,65:128])
end

function getBattlerFront(pkmn::Pkmn)
    if !pkmn.shiny
        img = mfb_rgb.(load("im/battlers/front/normal/$(pkmn.id).png"))

        return Dict{Int,Matrix{UInt32}}(1=>img[:,1:64],2=>img[:,65:128])
    else
        img = mfb_rgb.(load("im/battlers/front/shiny/$(pkmn.id).png"))

        return Dict{Int,Matrix{UInt32}}(1=>img[:,1:64],2=>img[:,65:128])
    end
end

function getBattlerBack(id::Int)
    img = mfb_rgb.(load("im/battlers/back/normal/$id.png"))

    return Dict{Int,Matrix{UInt32}}(1=>img[:,1:64])
end

function getBattlerBack(pkmn::Pkmn)
    if !pkmn.shiny
        img = mfb_rgb.(load("im/battlers/back/normal/$(pkmn.id).png"))

        return Dict{Int,Matrix{UInt32}}(1=>img)
    else
        img = mfb_rgb.(load("im/battlers/back/shiny/$(pkmn.id).png"))

        return Dict{Int,Matrix{UInt32}}(1=>img)
    end
end

function getBattleBack(str::String)
    return mfb_rgb.(load("im/battlebacks/$str.png"))
end

function getBattleIntro(str::String)
    return mfb_rgb.(load("im/battleintro/$str.png"))
end

function getBattleTags()
    img = mfb_rgb.(load("im/battlestuff.png"))

    tagopp = img[1:32,1:102]
    tagown = img[33:72,1:106]

    return Dict(1=>tagown), Dict(1=>tagopp)
end

function getBattleTagOwn()
    img = mfb_rgb.(load("im/battlestuff.png"))

    tagown = img[33:72,1:106]

    return Dict(1=>tagown)
end

function getBattleTagOpp()
    img = mfb_rgb.(load("im/battlestuff.png"))

    tagopp = img[1:32,1:102]

    return Dict(1=>tagopp)
end

function getCursor()
    img = mfb_rgb.(load("im/battlestuff.png"))

    cursor = img[17:30,113:120]

    return Dict(1=>cursor)
end






function drawBattleIntro!(game::GameState; s=Settings())
    if game.n.c[:battleintro].c == 0
        flushLayer!(game)
        flushLayer!(game,:layer1)
        flushLayer!(game,:layer2)
        flushLayer!(game,:layer3)
        flushLayer!(game,:layer4)
        
        game.im.sprites[:main].active = false

        game.im.postprocess.active = true
        game.im.postprocess.func = shutterHorizontal!
        game.im.postprocess.args = (24+80,0)

        game.im.layers.layer1[24+1:24+112,16+1:16+240] = getBattleBack("grass1")
        game.im.layers.layer3[24+1+112:24+160,16+1:16+240] = getDialogue("battle")

        createSprite!(game,:pkmn1,:layer2,getBattlerBack(game.battle.state.pkmn1.pkmn),
            Position(90,40),1; active=true)
        createSprite!(game,:pkmn2,:layer2,getBattlerFront(game.battle.state.pkmn2.pkmn),
            Position(32,160),1; active=true)
        
        createSprite!(game,:cursor1,:layer4,getCursor(),
            Position(146,136),1)
        createSprite!(game,:cursor2,:layer4,getCursor(),
            Position(146,32),1)
        
        createSprite!(game,:tagown,:layer3,getBattleTagOwn(),
            Position(72+24,126+16),1; active=true)
        createSprite!(game,:tagopp,:layer3,getBattleTagOpp(),
            Position(14+24,12+16),1; active=true)

        drawText!(game,game.im.sprites[:tagown].im,pkmnName(game,game.battle.state.pkmn1.pkmn),
            UInt(1),Position(4,17),0x424242,0xded6b5)
        
        drawText!(game,game.im.sprites[:tagopp].im,pkmnName(game,game.battle.state.pkmn2.pkmn),
            UInt(1),Position(4,10),0x424242,0xded6b5)

        createCC!(game,:wiggle,animWiggleBattle!,(); active = true)
    elseif game.n.c[:battleintro].c <= 32
        game.im.postprocess.args = (24+80,game.n.c[:battleintro].c)
    elseif game.n.c[:battleintro].c <= 56
        game.im.postprocess.args = (24+80,2*game.n.c[:battleintro].c-32)
    elseif game.n.c[:battleintro].c == 81
        killCounter!(game,:battleintro)

        game.im.postprocess.active = false

        game.draw.battleintro = false
        game.draw.battle = true

        game.dialogue.str = ["Ein wildes $(pkmnName(game,game.battle.state.pkmn2.pkmn)) erscheint!",
            "Los, $(pkmnName(game,game.battle.state.pkmn1.pkmn))!"]
        game.dialogue.n = 1
        game.dialogue.callback.func = stateBattleIntroDialogue!

        game.draw.battled = true

        game.input.inputlock = false
        game.input.battle = true
        game.input.battled = true

        return
    end

    game.n.c[:battleintro].c += 1
end

function drawBattleExit!(game::GameState; s=Settings())
    if game.n.c[:battleoutro].c == 0
        killSprite!(game,:pkmn1)
        killSprite!(game,:pkmn2)
        killSprite!(game,:cursor)

        game.im.postprocess.active = true
        game.im.postprocess.func = fadeLinear!
        game.im.postprocess.args = (60,0)
    elseif game.n.c[:battleoutro].c <= 60
        game.im.postprocess.args = (game.n.c[:battleoutro].c)
    elseif game.n.c[:battleoutro] == 61
        killCounter!(game,:battleoutro)

        game.im.postprocess.active = false

        game.battle.active = false
        game.battle.outro = false

        initDrawMap!(game)
        game.input.map = true
        
        game.im.sprites[:main].active = true
    
        return
    end

    game.n.c[:battleoutro].c += 1
end

function drawBattleDialogue!(game::GameState)
    drawText!(game,:layer3,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32),0xffffff,0x6b5a73)
end

function drawBattleMenu1!(game::GameState)
    drawText!(game,:layer4,"Was soll\\$(pkmnName(game,game.battle.state.pkmn1.pkmn)) tun?",UInt(2),
        Position(144,32),0xffffff,0x6b5a73)

    drawFrame!(game,:layer4,UInt(6),UInt(16),Position(24+112,16+112))

    drawText!(game,:layer4,"KAMPF",UInt(3),Position(145,144),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer4,"BEUTEL",UInt(3),Position(145,202),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer4,"POKEMON",UInt(3),Position(161,144),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer4,"FLUCHT",UInt(3),Position(161,202),0x4a4a4a,0xd6d6ce)
end

function drawBattleMenu2!(game::GameState)
    drawFrame!(game,:layer5,UInt(6),UInt(20),Position(24+112,16+1))
    drawFrame!(game,:layer5,UInt(6),UInt(10),Position(24+112,176+1))

    drawText!(game,:layer5,"AP\\Typ:",UInt(3),Position(145,200),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer5,"/",UInt(3),Position(145,224),0x4a4a4a,0xd6d6ce)


end






function drawBattle!(game::GameState; s=Settings())
    if game.draw.battled
        drawBattleDialogue!(game)
        return
    end

    if game.draw.battle1
        drawBattleMenu1!(game)
    elseif game.draw.battle2
        return
    end

    #initDrawMap!(game)
    return
end





function initDrawMap!(game::GameState)
    for i in eachindex(fieldnames(DrawState))
        setfield!(game.draw,i,false)
    end

    game.draw.map = true
    game.draw.sprites = true
end

function initDrawBattle!(game::GameState)
    for i in eachindex(fieldnames(DrawState))
        setfield!(game.draw,i,false)
    end

    game.draw.battleintro = true
    game.draw.sprites = true
end

function drawGame!(game::GameState; s=Settings())
    if game.draw.map
        drawMap!(game; s=s)
        
        sortHorizontal!(game.im.sprites)
    end

    if game.draw.dialogue && !game.draw.battle
        drawDialogue!(game)
    end

    if game.draw.menu1
        drawMenu!(game)
    end

    if game.draw.pdex
        0
    elseif game.draw.pkmn
        drawMenuPkmn!(game)
    elseif game.draw.bags
        drawInventory!(game)
    elseif game.draw.pnav
        0
    elseif game.draw.self
        0
    elseif game.draw.save
        0
    elseif game.draw.optn
        0
    end

    if game.draw.battleintro
        drawBattleIntro!(game; s=s)
    end

    if game.draw.battle
        drawBattle!(game; s=s)
    end

    if game.draw.sprites
        drawSprites!(game; s=s)
    end
    
    #combineLayers!(game,[:menu1,:menu2,:menu3]; s=s)
    
    combineLayers!(game,[:layer1,:layer2,:layer3,:layer4,:layer5,:layer6,:menu]; s=s)

    if game.im.weather.active
        game.im.weather.func(game.im.layer,game.im.weather.args...)
    end

    if game.im.postprocess.active
        game.im.postprocess.func(game.im.layer,game.im.postprocess.args...)
    end
end





function startWindow(settings::Settings)
    window = mfb_open_ex("Pokemon Test",settings.width,settings.height,
                MiniFB.WF_RESIZABLE)
    mfb_set_target_fps(settings.fps)
    
    
    buffer = zeros(UInt32,settings.width,settings.height)

    return window, buffer
end

function resizer(window,w,h)
    s = round(minimum([w/240,h/160]); sigdigits=2)
    mfb_set_viewport(window,0,0,round(Int,240*s),round(Int,160*s))

    return nothing
end

function writeToBuffer!(buffer::Matrix{UInt32},game::GameState; s=Settings())
    @inbounds for i in eachindex(buffer)
        buffer[i] = game.im.layer[
            24+1+div(i-1,s.width)+game.screenoffset.h,
            16+1+(i-1)%s.width+game.screenoffset.w
        ]
    end
end
;
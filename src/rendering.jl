#240x160


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

function getGridImage(dir::String,rows::Int,columns::Int; attachsize::Bool=true)
    im = mfb_rgb.(load(dir))
    height, width = size(im)

    dh = div(height,rows); dw = div(width,columns)

    if attachsize
        return [(im[1+(h-1)*dh:h*dh,1+(w-1)*dw:w*dw],P(dh,dw)) 
            for w in 1:columns, h in 1:rows]
    else
        return [im[1+(h-1)*dh:h*dh,1+(w-1)*dw:w*dw] 
            for w in 1:columns, h in 1:rows]
    end
end

function getGridImage(dir::String,tilesize::Int; attachsize::Bool=true)
    im = mfb_rgb.(load(dir))
    height, width = size(im)

    nh = div(height,tilesize); nw = div(width,tilesize)

    if attachsize
        return [(im[1+(h-1)*tilesize:h*tilesize,1+(w-1)*tilesize:w*tilesize],
            P(tilesize,tilesize)) for w in 1:nw, h in 1:nh]
    else
        return [im[1+(h-1)*tilesize:h*tilesize,1+(w-1)*tilesize:w*tilesize] 
            for w in 1:nw, h in 1:nh]
    end
end




function shiftLayerUp!(l::Matrix{UInt32})
    @inbounds for j in 1:272, i in 1:208-16
        l[i,j] = l[i+16,j]
    end
end

function shiftLayerDown!(l::Matrix{UInt32})
    @inbounds for j in 1:272, i in 208:-1:17
        l[i,j] = l[i-16,j]
    end
end

function shiftLayerLeft!(l::Matrix{UInt32})
    @inbounds for j in 1:256, i in 1:208
        l[i,j] = l[i,j+16]
    end
end

function shiftLayerRight!(l::Matrix{UInt32})
    @inbounds for j in 272:-1:17, i in 1:208
        l[i,j] = l[i,j-16]
    end
end

function shiftLayerUp!(l::Matrix{UInt32},n::Int)
    @inbounds for j in 1:272, i in 1:208-n
        l[i,j] = l[i+n,j]
    end
end

function shiftLayerDown!(l::Matrix{UInt32},n::Int)
    @inbounds for j in 1:272, i in 208:-1:1+n
        l[i,j] = l[i-n,j]
    end
end

function shiftLayerLeft!(l::Matrix{UInt32},n::Int)
    @inbounds for j in 1:272-n, i in 1:208
        l[i,j] = l[i,j+n]
    end
end

function shiftLayerRight!(l::Matrix{UInt32},n::Int)
    @inbounds for j in 272:-1:1+n, i in 1:208
        l[i,j] = l[i,j-n]
    end
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

function drawMapUpdate!(game::GameState,dir::Int; s=Settings())
    # dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)
    dh,dw = div(0x0c,0x02),div(0x10,0x02)

    if dir == 1
        @inbounds for k in game.map.environment
            shiftLayerDown!(getfield(game.im.layers,k))

            @inbounds for j in 0x0001:0x0011
                tile = game.map.tiles[
                    getfield(game.map.tilemap,k)[game.pos.h-dh,
                    game.pos.w+j-dw-0x0001]]
    
                v = view(getfield(game.im.layers,k),
                    0x0001:0x0010,
                    0x0001+(j-0x0001)*0x0010:j*0x0010)
                
                @inbounds for t in eachindex(v)
                    v[t] = tile[t]
                end
            end
        end

        for i in 1:game.im.sprites.idx
            if game.im.sprites[i].id == :main
                continue
            end

            posAdd!(game.im.sprites[i].pos,+16,0)
        end
    elseif dir == 2
        @inbounds for k in game.map.environment
            shiftLayerUp!(getfield(game.im.layers,k))

            @inbounds for j in 0x0001:0x0011
                tile = game.map.tiles[
                    getfield(game.map.tilemap,k)[game.pos.h+0x000c-dh,
                    game.pos.w+j-dw-0x0001]]
    
                v = view(getfield(game.im.layers,k),
                    0x00c1:0x00d0,
                    0x0001+(j-0x0001)*0x0010:j*0x0010)
                
                @inbounds for t in eachindex(v)
                    v[t] = tile[t]
                end
            end
        end

        for i in 1:game.im.sprites.idx
            if game.im.sprites[i].id == :main
                continue
            end

            posAdd!(game.im.sprites[i].pos,-16,0)
        end
    elseif dir == 3
        @inbounds for k in game.map.environment
            shiftLayerRight!(getfield(game.im.layers,k))

            @inbounds for i in 0x01:0x0d
                tile = game.map.tiles[
                    getfield(game.map.tilemap,k)[game.pos.h+i-dh-0x01,
                    game.pos.w-dw]]
    
                v = view(getfield(game.im.layers,k),
                    0x01+(i-0x01)*0x10:i*0x10,
                    0x01:0x10)
                
                @inbounds for t in eachindex(v)
                    v[t] = tile[t]
                end
            end
        end

        for i in 1:game.im.sprites.idx
            if game.im.sprites[i].id == :main
                continue
            end
            
            posAdd!(game.im.sprites[i].pos,0,+16)
        end
    else
        @inbounds for k in game.map.environment
            shiftLayerLeft!(getfield(game.im.layers,k))

            @inbounds for i in 0x01:0x0d
                tile = game.map.tiles[
                    getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
                    game.pos.w+0x11-dw-1]]
    
                v = view(getfield(game.im.layers,k),
                    0x01+(i-0x01)*0x10:i*0x10,
                    0x01+0x0100:0x0110)
                
                @inbounds for t in eachindex(v)
                    v[t] = tile[t]
                end
            end
        end

        for i in 1:game.im.sprites.idx
            if game.im.sprites[i].id == :main
                continue
            end
            
            posAdd!(game.im.sprites[i].pos,0,-16)
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

        @inbounds for j in 1:game.im.sprites.idx
            if game.im.sprites[j].layer != k || !game.im.sprites[j].active
                continue
            end

            s = game.im.sprites[j]
            v = view(
                l,
                s.pos.h+1:s.pos.h+s.size.h,
                s.pos.w+1:s.pos.w+s.size.w
            )

            @inbounds for i in eachindex(v)
                if s.im[i] != 0x000000
                    v[i] = s.im[i]
                end
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

function updateSprite!(sprite::Sprite,frame::Int)
    sprite.frame = frame

    if sprite.size.h == sprite.dict[frame][2].h &&
            sprite.size.w == sprite.dict[frame][2].w

        sprite.im[:] = sprite.dict[frame][1]
    else
        sprite.im = copy(sprite.dict[frame][1])
        sprite.size = sprite.dict[frame][2]
    end
end

function updateSprite!(sprite::Sprite)
    if sprite.size.h == sprite.dict[sprite.frame][2].h &&
            sprite.size.w == sprite.dict[sprite.frame][2].w

        sprite.im[:] = sprite.dict[sprite.frame][1]
    else
        sprite.im = copy(sprite.dict[sprite.frame][1])
        sprite.size = sprite.dict[sprite.frame][2]
    end
end

# function drawSprites!(game::GameState; s=Settings())
#     @inbounds for i in 1:game.im.sprites.idx
#         if !game.im.sprites[i].active
#             continue
#         end
        
#         sprite = game.im.sprites.data[i]
#         l = getfield(game.im.layers,sprite.layer)

#         v = view(l, sprite.pos.h+1:sprite.pos.h+sprite.size.h,
#             sprite.pos.w+1:sprite.pos.w+sprite.size.w)

#         @inbounds for i in eachindex(v)
#             if sprite.im[i] != 0x000000
#                 v[i] = sprite.im[i]
#             end
#         end
#     end
# end

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

    d = Dict{Int,Tuple{Matrix{UInt32},Position}}()

    for k in key
        if k[5] > 1
            for i in 1:k[5]
                s = k[6]+i

                d[s] = (spriteset[k[1]+(i-1)*k[3]:k[1]+i*k[3]-1,
                    k[2]:k[2]+k[4]-1],P(k[3],k[4]))
            end
        else
            d[k[6]] = (spriteset[k[1]:k[1]+k[3]-1,k[2]:k[2]+k[4]-1],P(k[3],k[4]))
        end
    end

    d[31] = (reverse(d[21][1]; dims=2),d[21][2])
    d[32] = (reverse(d[22][1]; dims=2),d[22][2])
    d[33] = (reverse(d[23][1]; dims=2),d[23][2])
    
    d[71] = (reverse(d[61][1]; dims=2),d[61][2])
    d[72] = (reverse(d[62][1]; dims=2),d[62][2])
    d[73] = (reverse(d[63][1]; dims=2),d[63][2])
    
    return d
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
    game.im.layers.textbox[end-48-24+1:end-24,16+1:end-16] = 
        game.im.diabox[game.options.diabox]
    drawText!(game,:textbox,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32))
end

function drawDialogueUpdate!(game::GameState)
    flushLayer!(game,:textbox,P(144,32),P(32,160),0xffffff)
    drawText!(game,:textbox,game.dialogue.str[game.dialogue.n],UInt(2),
        Position(144,32))
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
    drawFrame!(game,:layer5,UInt(20),UInt(10),Position(24,176))

    drawText!(game,:layer5,"Pokedex\\Pokemon\\Beutel\\Pokenav\
        \\$(game.trainer.name)\\Speichern\\Optionen\\Beenden",
        UInt(2),Position(38,194); lineoffset=2)

    createSprite!(game,:cursor,:layer5,getCursor(),
        P(40+(game.input.menu.select)*17,185),1; active=true)
end





function getMenuStuff(str::String,partitions::Int)
    img = mfb_rgb.(load("im/"*str*".png"))

    dh = Int(size(img)[1]/partitions)
    dw = size(img)[2]

    return Dict(zip(1:partitions,[(img[1+dh*(i-1):dh*i,:],P(dh,dw)) for i in 1:partitions]))
end

function drawMenuPkmn!(game::GameState)
    game.im.layers.layer1[24+1:24+160,16+1:16+240] = 
        mfb_rgb.(load("im/menupokemon/background.png"))

    b = getMenuStuff("menupokemon/pokeballs",2)

    drawSlotMain!(game,b)

    # m = getMenuStuff("slotside",6)

    for i in 2:game.trainer.pokemon.idx
        drawSlotSide!(game,i,b)
    end

    for i in game.trainer.pokemon.idx+1:6
        game.im.layers.layer1[24+10+1+(i-2)*24:24+10+22+(i-2)*24,
            16+96+1:16+96+142] = mfb_rgb.(load("im/menupokemon/slotempty.png"))
    end

    createSprite!(game,:exit,:layer1,
        getMenuStuff("menupokemon/exit",2),
        P(24+136,16+186),1; active=true)
    
    createSprite!(game,:ballexit,:layer1,copy(b),
        P(24+132,16+184),1; active=true)

    drawText!(game,game.im.sprites[:exit].dict[1][1],"ZURUCK",UInt(1),Position(2,18),
        0xffffff,0x737373)
    drawText!(game,game.im.sprites[:exit].dict[2][1],"ZURUCK",UInt(1),Position(2,18),
        0xffffff,0x737373)

    updateSprite!(game.im.sprites[:exit])
    
    drawFrame!(game,:layer2,UInt(4),UInt(23),Position(24+128,16))
    drawText!(game,:layer2,"Wähle ein Pokémon.",UInt(2),Position(24+138,24))
end

function drawSlotMain!(game::GameState,b::Dict)
    createSprite!(game,:slot1,:layer1,getMenuStuff("menupokemon/slotmain",6),
        P(24+24,16+8),2; active=true)

    for i in 1:4
        drawHealthBar!(game.im.sprites[:slot1].dict[i][1],
            getHealthBar(game.trainer.pokemon[1]),Position(34,24))
        
        drawText!(game,game.im.sprites[:slot1].dict[i][1],
            pkmnName(game,game.trainer.pokemon[1])*"\\  Lv."*
            string(game.trainer.pokemon[1].stats.level),UInt(1),
            P(10,24),0xffffff,0x737373; lineoffset = -3)
        
        drawText!(game,game.im.sprites[1].dict[i][1],
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

    for i in 1:4
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
        updateSprite!(game.im.sprites[Symbol(:slot,from)],1)
        updateSprite!(game.im.sprites[Symbol(:ball,from)],1)
    end

    if to == game.trainer.pokemon.idx+1
        updateSprite!(game.im.sprites[:exit],2)
        updateSprite!(game.im.sprites[:ballexit],2)
    else
        updateSprite!(game.im.sprites[Symbol(:slot,to)],2)
        updateSprite!(game.im.sprites[Symbol(:ball,to)],2)
    end
    
    game.input.menu.menupkmn.select = to
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







function drawInventory!(game::GameState)
    game.im.layers.layer1[24+1:24+160,16+1:16+240] =
        mfb_rgb.(load("im/menubag/background1.png"))

    m = game.input.menu.menubags

    createSprite!(game,:slotmarker,:layer1,getMenuStuff("menubag/slotmarker1",1),
        P(24+27,16+34+m.bag*8),1; active=true)

    createSprite!(game,:slot,:layer1,getMenuStuff("menubag/slots",5),
        P(24+8,16+24),m.bag; active=true)

    createSprite!(game,:bag,:layer1,getMenuStuff("menubag/bags1",6),
        P(24+34,16+40),m.bag; active=true)

    createSprite!(game,:arrowleft,:layer1,getMenuStuff("menubag/arrowleft",1),
        P(24+8,16+22),1; active=true)
    
    createSprite!(game,:arrowright,:layer1,getMenuStuff("menubag/arrowright",1),
        P(24+8,16+90),1; active=true)

    createSprite!(game,:arrowup,:layer1,getMenuStuff("menubag/arrowup",1),
        P(24+26,16+40),1; active=false)
    
    createSprite!(game,:arrowdown,:layer1,getMenuStuff("menubag/arrowdown",1),
        P(24+26,16+40),1; active=false)
    
    createSprite!(game,:cursor,:layer1,getMenuStuff("menubag/cursor",2),
        P(24+21,16+114),1; active=true)

    println(m.bag); println(m.select);
    println(Int(getInvSlotID(game)))

    createSprite!(game,:item,:layer1,getItemIcons(m.bag),
        P(96,16+8),Int(getInvSlotID(game));
        active=true)

    createSprite!(game,:back,:layer1,
        Dict(zip([1],getGridImage("im/menubag/arrowback.png",1,1))),
        P(96,16+8),1;
        active = false)

    setVisibleItems!(game)
    drawInventoryText!(game)
end

function setVisibleItems!(game::GameState)
    m = game.input.menu.menubags
    nitems = game.trainer.inventory[-m.bag]

    m.vis .= 0
    s = m.select[m.bag]

    i0 = max(1,(s-min(2,s)+(min(5,nitems-s+1)-5)))

    for i in 0:7
        if i0+i == s
            m.slot = i+1
        elseif i0+i > nitems
            m.vis[i+1,1] = -1

            break
        end

        m.vis[i+1,:] = getInvSlot(game,m.bag,i0+i)
    end

    display(m.vis); display(s)
end

function drawInventoryText!(game::GameState)
    vis = game.input.menu.menubags.vis

    for i in 1:8
        if vis[i,1] == -1
            drawText!(game,:layer2,game.str[1][6],UInt(2),
                P(24+18+15*(i-1),16+121),0x010101,0xd6d6ce)

            break
        end

        drawText!(game,:layer2,game.str[2][vis[i,1]],UInt(2),
            P(24+18+15*(i-1),16+121),0x010101,0xd6d6ce)

        drawText!(game,:layer2,"×",UInt(1),
            P(24+21+15*(i-1),16+210),0x010101,0xd6d6ce)

        drawText!(game,:layer2,string(vis[i,2]),UInt(2),
            P(24+18+15*(i-1),16+217),0x010101,0xd6d6ce)

    end
end

function drawSlotSwitchDown!(game::GameState)
    flushLayer!(game,:layer2,P(24+10,16+120),P(10,140))
    shiftLayerUp!(game.im.layers.layer2,15)

    drawText!(game,:layer2,game.str[2][vis[8,1]],UInt(2),
        P(24+18+15*8,16+121),0x010101,0xd6d6ce)

    drawText!(game,:layer2,"×",UInt(1),
        P(24+21+15*8,16+210),0x010101,0xd6d6ce)

    drawText!(game,:layer2,string(vis[8,2]),UInt(2),
        P(24+18+15*8,16+217),0x010101,0xd6d6ce)
end

function drawBagSwitch!(game::GameState)
    
end



function getBattlers()
    img = mfb_rgb.(load("im/battlers gen1.png"))

    d1 = Dict{UInt,Matrix{UInt32}}(
        zip(Vector{UInt}(1:151),[(img[
            1+64*div(i,10):64+64*div(i,10),1+64*i%10:64+64*i%10
        ],P(64,64)) for i in 0:150])
    )

    return merge(d1,)
end

function getBattlerFront(id::Int)
    img = mfb_rgb.(load("im/battlers/front/normal/$id.png"))

    return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img[:,1:64],P(64,64)),2=>(img[:,65:128],P(64,64)))
end

function getBattlerFront(pkmn::Pkmn)
    if !pkmn.shiny
        img = mfb_rgb.(load("im/battlers/front/normal/$(pkmn.id).png"))

        return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img[:,1:64],P(64,64)),2=>(img[:,65:128],P(64,64)))
    else
        img = mfb_rgb.(load("im/battlers/front/shiny/$(pkmn.id).png"))

        return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img[:,1:64],P(64,64)),2=>(img[:,65:128],P(64,64)))
    end
end

function getBattlerBack(id::Int)
    img = mfb_rgb.(load("im/battlers/back/normal/$id.png"))

    return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img[:,1:64],P(64,64)))
end

function getBattlerBack(pkmn::Pkmn)
    if !pkmn.shiny
        img = mfb_rgb.(load("im/battlers/back/normal/$(pkmn.id).png"))

        return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img,P(64,64)))
    else
        img = mfb_rgb.(load("im/battlers/back/shiny/$(pkmn.id).png"))

        return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img,P(64,64)))
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

    return Dict(1=>(tagown,P(size(tagown)...))), Dict(1=>(tagopp,P(size(tagopp)...)))
end

function getBattleTagOwn()
    img = mfb_rgb.(load("im/battlestuff.png"))

    tagown = img[33:72,1:106]

    return Dict(1=>(tagown,P(size(tagown)...)))
end

function getBattleTagOpp()
    img = mfb_rgb.(load("im/battlestuff.png"))

    tagopp = img[1:32,1:102]

    return Dict(1=>(tagopp,P(size(tagopp)...)))
end

function getCursor()
    img = mfb_rgb.(load("im/battlestuff.png"))

    cursor = img[17:30,113:120]

    return Dict(1=>(cursor,P(size(cursor)...)))
end




function drawBattleTagOwn!(game::GameState,pkmn::Pkmn,im::Matrix{UInt32})
    drawHealthBar!(im,getHealthBar(pkmn),P(20,49))
    drawXpBar!(game,im,getXpBar(pkmn,0),P(36,33))

    drawText!(game,im,pkmnName(game,pkmn),UInt(1),Position(4,17),0x424242,0xded6b5)
    drawText!(game,im,string(pkmn.stats.level),UInt(1),Position(4,86),0x424242,0xded6b5)
    drawText!(game,im,"/",UInt(1),Position(22,76),0x424242,0xded6b5)
    drawText!(game,im,string(pkmn.stats.rv[1]),UInt(1),Position(22,81),0x424242,0xded6b5)
    drawText!(game,im,string(pkmn.stats.hp),UInt(1),Position(22,66),0x424242,0xded6b5)
end

function drawBattleTagOpp!(game::GameState,pkmn::Pkmn,im::Matrix{UInt32})
    drawHealthBar!(im,getHealthBar(pkmn),P(20,40))
        
    drawText!(game,im,pkmnName(game,pkmn),UInt(1),Position(4,10),0x424242,0xded6b5)
    drawText!(game,im,string(pkmn.stats.level),UInt(1),Position(4,76),0x424242,0xded6b5)
end

function drawBattleIntro!(game::GameState; s=Settings())
    if game.n.c[:battleintro].c == 0
        stateSetupBattle!(game)
        
        flushLayer!(game)
        flushLayer!(game,:layer1)
        flushLayer!(game,:layer2)
        flushLayer!(game,:layer3)
        flushLayer!(game,:layer4)

        game.im.layers.layer1[24+1:24+112,16+1:16+240] = getBattleBack("grass1")
        game.im.layers.layer3[24+1+112:24+160,16+1:16+240] = getDialogue("battle")

        createSprite!(game,:pkmn1,:layer2,getBattlerBack(game.battle.state.pkmn1.pkmn),
            Position(90,40),1; active=true)
        createSprite!(game,:pkmn2,:layer2,getBattlerFront(game.battle.state.pkmn2.pkmn),
            Position(32,160),1; active=true)
        
        createSprite!(game,:cursor1,:layer4,getCursor(),
            Position(146,136),1)
        createSprite!(game,:cursor2,:layer5,getCursor(),
            Position(146,24),1)
        
        createSprite!(game,:tag1,:layer3,getBattleTagOwn(),
            Position(72+24,126+16),1; active=true)
        createSprite!(game,:tag2,:layer3,getBattleTagOpp(),
            Position(14+24,12+16),1; active=true)

        drawBattleTagOwn!(game,game.battle.state.pkmn1.pkmn,game.im.sprites[:tag1].im)
        drawBattleTagOpp!(game,game.battle.state.pkmn2.pkmn,game.im.sprites[:tag2].im)

        # drawHealthBarBattle!(game.im.sprites[:tag1].im,
        #     getHealthBar(game.battle.state.pkmn1.pkmn),P(20,49))
        # drawXpBar!(game,game.im.sprites[:tag1].im,
        #     getXpBar(game.battle.state.pkmn1.pkmn,0),P(36,33))

        # drawText!(game,game.im.sprites[:tag1].im,pkmnName(game,game.battle.state.pkmn1.pkmn),
        #     UInt(1),Position(4,17),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag1].im,string(game.battle.state.pkmn1.pkmn.stats.level),
        #     UInt(1),Position(4,86),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag1].im,"/",
        #     UInt(1),Position(22,76),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag1].im,string(game.battle.state.pkmn1.pkmn.stats.rv[1]),
        #     UInt(1),Position(22,81),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag1].im,string(game.battle.state.pkmn1.pkmn.stats.hp),
        #     UInt(1),Position(22,66),0x424242,0xded6b5)
        
        # drawText!(game,game.im.sprites[:tag2].im,pkmnName(game,game.battle.state.pkmn2.pkmn),
        #     UInt(1),Position(4,10),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag2].im,string(game.battle.state.pkmn2.pkmn.stats.level),
        #     UInt(1),Position(4,76),0x424242,0xded6b5)
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

# function drawBattleExit!(game::GameState; s=Settings())
#     println(game.n.c)
#     if game.n.c[:battleoutro].c == 0
#         game.im.postprocess.active = true
#         game.im.postprocess.func = fadeLinear!
#         game.im.postprocess.args = (0x3c,0x01,0x00)
#     elseif game.n.c[:battleoutro].c <= 60
#         game.im.postprocess.args = (0x3c,0x01,UInt8(game.n.c[:battleoutro].c))
#     elseif game.n.c[:battleoutro].c == 61
#         killCounter!(game,:battleoutro)

#         stateEndBattle!(game)
    
#         return
#     end

#     game.n.c[:battleoutro].c += 1
# end

function drawBattleDialogue!(game::GameState)
    drawText!(game,:layer3,game.dialogue.str[game.dialogue.n],UInt(2),
        P(144,32),0xffffff,0x6b5a73)
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
    drawFrame!(game,:layer5,UInt(6),UInt(20),Position(24+112,16))
    drawFrame!(game,:layer5,UInt(6),UInt(10),Position(24+112,176))

    drawText!(game,:layer5,"/",UInt(3),Position(145,230),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer5,
        string(game.battle.state.pkmn1.pkmn.attacks[game.input.battle2menu.select+1].ap),
        UInt(3),Position(145,218),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer5,
        string(game.battle.state.pkmn1.pkmn.attacks[game.input.battle2menu.select+1].apmax),
        UInt(3),Position(145,236),0x4a4a4a,0xd6d6ce)

    drawText!(game,:layer5,"AP\\Typ:",UInt(3),Position(145,186),0x4a4a4a,0xd6d6ce;
        lineoffset=2)
    drawText!(game,:layer5,
        TypeNames[game.battle.state.pkmn1.pkmn.attacks[game.input.battle2menu.select+1].type],
        UInt(3),Position(161,208),0x4a4a4a,0xd6d6ce)

    for i in 1:length(game.battle.state.pkmn1.pkmn.attacks)
        drawText!(game,:layer5,game.battle.state.pkmn1.pkmn.attacks[i].name,
            UInt(3),Position(145+div(i-1,2)*16,32+((i-1)%2)*64))
    end

    for i in length(game.battle.state.pkmn1.pkmn.attacks)+1:4
        drawText!(game,:layer5,"--",
            UInt(3),Position(145+div(i-1,2)*16,32+((i-1)%2)*64))
    end
end






function drawBattle!(game::GameState; s=Settings())
    if game.draw.battled
        drawBattleDialogue!(game)
        return
    end

    if game.draw.battle1
        drawBattleMenu1!(game)
    elseif game.draw.battle2
        drawBattleMenu2!(game)
    end

    #initDrawMap!(game)
    return
end







function drawGame!(game::GameState; s=Settings())
    if game.draw.battleintro
        drawBattleIntro!(game; s=s)
    end

    if game.draw.battle
        drawBattle!(game; s=s)
    end

    # if game.draw.battleoutro
    #     drawBattleExit!(game; s=s)
    # end
    
    combineLayers!(game,game.im.L; s=s)

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
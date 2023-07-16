

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

function updateSprite!(game::GameState,spriteid::Symbol,frame::Int)
    sprite = game.im.sprites[spriteid]

    sprite.frame = frame

    if sprite.size.h == sprite.dict[frame][2].h &&
            sprite.size.w == sprite.dict[frame][2].w

        sprite.im[:] = sprite.dict[frame][1]
    else
        sprite.im = copy(sprite.dict[frame][1])
        sprite.size = sprite.dict[frame][2]
    end
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




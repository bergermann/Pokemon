

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
            if sprite.im[i] != 0x00
                v[i] = sprite.palette[sprite.im[i]]
            end
        end
    end
end

function getSprite(dir::String,len::Int)
    dict = Dict{Int,Image}()

    for i in 1:len
        dict[i] = deserialize(joinpath(dir,"$i.im"))
    end

    palette = deserialize(joinpath(dir,"palette.p"))

    return dict, palette
end




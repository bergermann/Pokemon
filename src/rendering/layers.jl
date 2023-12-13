




function flushLayer!(game::GameState,layer::Integer)
    game.im.layers[layer] .= 0x000000
end

function flushLayer!(game::GameState,layer::Integer,pos::Position,size::Position)
    v = view(game.im.layers[layer],
        pos.h+1:pos.h+size.h,pos.w+1:pos.w+size.w)
    
    v .= 0x000000
end

function flushLayer!(game::GameState,layer::Integer,pos::Position,size::Position,
        color::UInt32)
    
    v = view(game.im.layers[layer],
        pos.h+1:pos.h+size.h,pos.w+1:pos.w+size.w)
    
    v .= color
end

function flushLayer!(game::GameState)
    game.im.layer .= 0x000000
end

function flushLayers!(game::GameState)
    for k in 1:6
        flushLayer!(game,k)
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





# function combineLayers!(game::GameState,layers::Vector{<:Integer})
function combineLayers!(game::GameState)
    l = game.im.layer

    @views @inbounds for k in 1:6
        ls = game.im.layers[k]

        for i in eachindex(l)
            if ls[i] != 0x000000
                l[i] = ls[i]
            end
        end

        for j in 1:game.im.sprites[k].idx
            if !game.im.sprites[k][j].active
                continue
            end

            if game.im.sprites[k][j].colortransform.active
                p = game.im.sprites[k][j].colortransform.func(
                    game.im.sprites[k][j].palette,
                    game.im.sprites[k][j].colortransform.args)
            else
                p = game.im.sprites[k][j].palette
            end

            if !game.im.sprites[k][j].hreverse
                drawSprite!(l,game.im.sprites[k][j],p)
            else
                drawSpriteReverse!(l,game.im.sprites[k][j],p)
            end
        end
    end

    return
end

function drawSprite!(layer::Matrix{UInt32},sprite::Sprite,palette::Palette)
    lh, lw = size(layer)

    mw1 = max(1,-(sprite.pos.w-1))
    mw2 = min(sprite.size.w,lw-(sprite.pos.w+1))
    
    mh1 = max(1,-(sprite.pos.h-1))
    mh2 = min(sprite.size.h,lh-(sprite.pos.h+1))

    for j in mw1:mw2, i in mh1:mh2
        if sprite.im[i,j] != 0x00
            layer[i+sprite.pos.h,j+sprite.pos.w] = palette[sprite.im[i,j]]
        end
    end

    return
end

function drawSpriteReverse!(layer::Matrix{UInt32},sprite::Sprite,palette::Palette)
    lh, lw = size(layer)

    mw1 = max(1,-(sprite.pos.w-1))
    mw2 = min(sprite.size.w,lw-(sprite.pos.w+1))
    
    mh1 = max(1,-(sprite.pos.h-1))
    mh2 = min(sprite.size.h,lh-(sprite.pos.h+1))

    w = sprite.size.w
    ph = sprite.pos.h; pw = sprite.pos.w

    for j in mw1:mw2, i in mh1:mh2
        if sprite.im[i,1+w-j] != 0x00
            layer[i+ph,j+pw] = palette[sprite.im[i,1+w-j]]
        end
    end

    return
end





function drawView!(imbase::SubArray,im::SubArray,palette::Palette)
    for i in eachindex(im)
        if im[i] == 0x00
            continue
        end

        imbase[i] = palette[im[i]]
    end
end
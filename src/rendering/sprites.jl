

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

    if sprite.size.h == size(sprite.dict[frame],1) &&
            sprite.size.w == size(sprite.dict[frame],2)

        sprite.im[:] = sprite.dict[frame]
    else
        sprite.im = copy(sprite.dict[frame])
        sprite.size = Position(size(sprite.im)...)
    end
end

function updateSprite!(sprite::Sprite)
    if sprite.size.h == size(sprite.dict[sprite.frame],1) &&
            sprite.size.w == size(sprite.dict[sprite.frame],2)

        sprite.im[:] = sprite.dict[sprite.frame]
    else
        sprite.im = copy(sprite.dict[sprite.frame])
        sprite.size = Position(size(sprite.dict[sprite.frame])...)
    end
end

function updateSprite!(game::GameState,spriteid::Symbol,frame::Int)
    sprite = game.im.sprites[spriteid]

    sprite.frame = frame

    if sprite.size.h == size(sprite.dict[frame],1) &&
            sprite.size.w == size(sprite.dict[frame],2)

        sprite.im[:] = sprite.dict[frame]
    else
        sprite.im = copy(sprite.dict[frame])
        sprite.size = Position(size(sprite.im)...)
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

function getSprite(dir::String,len::Int,palette::String)
    dict = Dict{Int,Image}()

    for i in 1:len
        dict[i] = deserialize(joinpath(dir,"$i.im"))
    end

    palette = deserialize(joinpath(dir,"$palette.p"))

    return dict, palette
end

function getSprite(dir::String)
    dict = Dict{Int,Image}()

    imp = deserialize(dir)

    dict[1] = imp.im

    return dict, imp.palette
end





function expandPalette!(sprite::Sprite,colors::UInt32...)
    idxs = Vector{UInt8}(undef,length(colors))

    for i in eachindex(colors)
        idx = findfirst(isequal(colors[i]),sprite.palette)
    
        if isnothing(idx)
            push!(sprite.palette,colors[i])
            idx = length(sprite.palette)
        end

        idxs[i] = idx
    end

    return idxs
end





function createSprite!(game::GameState,id::Symbol,layer::Integer,
        pos::Position,frame::Int,dict::Dict{Int,Image},palette::Palette;
        active=false,hreverse=false,vreverse=false)

    push!(game.im.sprites[layer],Sprite(
        id,
        active,
        hreverse,
        vreverse,
        pos,
        Position(size(dict[frame])...),
        frame,
        dict,
        palette,
        copy(dict[frame]),
        CallbackFunction(),
        CallbackFunction())
    )
end

function createSprite!(game::GameState,id::Symbol,layer::Integer,
        pos::Position,frame::Int,(dict,palette)::Tuple{Dict,Palette};
        kwargs...)
    createSprite!(game,id,layer,pos,frame,dict,palette; kwargs...)
end

function killSprite!(game::GameState,id::Symbol)
    for k in 1:6
        popat!(game.im.sprites[k],id)
    end
end

function killSpriteAll!(game::GameState)
    for k in 1:6
        popall!(game.im.sprites[k])
    end
end



## delete if works:
# function drawSprites!(game::GameState,layer::Integer)
#     @inbounds for i in 1:game.im.sprites.idx
#         if !game.im.sprites[i].active
#             continue
#         end
        
#         sprite = game.im.sprites.data[i]
#         l = game.im.layers[sprite.layer]

#         sh,sw = size(sprite.im)

#         v = view(
#             l,
#             sprite.hreverse ? 
#                 (min(1,sprite.pos.h+1):max(s.height,sprite.pos.h+sh)) :
#                 (max(s.height,sprite.pos.h+sh):-1:min(1,sprite.pos.h+1)),
#             sprite.vreverse ?
#                 (min(1,sprite.pos.w+1):max(s.width,sprite.pos.w+sw)) :
#                 (max(s.width,sprite.pos.w+sw):-1:min(1,sprite.pos.w+1))
#         )

#         @inbounds for i in eachindex(v)
#             if sprite.im[i] != 0x00
#                 v[i] = sprite.palette[sprite.im[i]]
#             end
#         end
#     end
# end
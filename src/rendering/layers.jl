
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







# function combineLayers!(game::GameState,layers::Vector{Symbol};
#         s::Settings=Settings())

#     l = game.im.layer

#     @inbounds for k in layers
#         ls = getproperty(game.im.layers,k)

#         @inbounds for i in eachindex(l)
#             @views if ls[i] != 0x000000
#                 l[i] = ls[i]
#             end
#         end

#         @inbounds for j in 1:game.im.sprites.idx
#             if game.im.sprites[j].layer != k || !game.im.sprites[j].active
#                 continue
#             end

#             s = game.im.sprites[j]
#             v = view(
#                 l,
#                 s.pos.h+1:s.pos.h+s.size.h,
#                 s.pos.w+1:s.pos.w+s.size.w
#             )

#             @inbounds for i in eachindex(v)
#                 if s.im[i] != 0x000000
#                     v[i] = s.im[i]
#                 end
#             end
#         end
#     end

#     return
# end

function combineLayers!(game::GameState,layers::Vector{Symbol};
        s::Settings=Settings())

    l = game.im.layer

    @inbounds for k in layers
        ls = getproperty(game.im.layers,k)

        @inbounds for i in eachindex(l)
            if ls[i] != 0x000000
                l[i] = ls[i]
            end
        end

        @inbounds for j in 1:game.im.sprites.idx
            if game.im.sprites[j].layer != k || !game.im.sprites[j].active
                continue
            end

            sprite = game.im.sprites[j]

            v = view(
                l,
                sprite.hreverse ? 
                (min(s.height,sprite.pos.h+sprite.size.h):-1:max(1,sprite.pos.h+1)) :
                    (max(1,sprite.pos.h+1):min(s.height,sprite.pos.h+sprite.size.h)),
                sprite.vreverse ?
                (min(s.width,sprite.pos.w+sprite.size.w):-1:max(1,sprite.pos.w+1)) :
                    (max(1,sprite.pos.w+1):min(s.width,sprite.pos.w+sprite.size.w))
            )

            vs = view(
                sprite.im,
                max(1,-sprite.pos.h):min(sprite.size.h,s.height-sprite.pos.h),
                max(1,-sprite.pos.w):min(sprite.size.w,s.width-sprite.pos.w)
            )

            @inbounds for i in eachindex(v)
                if vs[i] != 0x00
                    v[i] = sprite.palette[vs[i]]
                end
            end
        end
    end

    return
end



# remove if works

# function combineLayers!(game::GameState; s::Settings=Settings())
#     l = game.im.layer

#     @inbounds for k in fieldnames(Layers)
#         ls = getproperty(game.im.layers,k)

#         if !ls.active
#             continue
#         end

#         @inbounds for i in eachindex(l)
#             @views if ls.layer[i] != 0x000000
#                 l[i] = ls.layer[i]
#             end
#         end
#     end

#     return
# end

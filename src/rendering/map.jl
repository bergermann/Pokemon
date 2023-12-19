


function checkMapBounds(game::GameState,map::Map,i::Integer,j::Integer,k::Integer)
    sh,sw = size(map.tilemap.map[k])

    return (1 <= game.pos.h+i-6-1 <= sh) && (1 <= game.pos.w+j-8-1 <= sw)
end

function checkMapBounds(game::GameState,map::Map,i::Integer,j::Integer,
        k::Integer,offset::Position)

    sh,sw = size(map.tilemap.map[k])
    
    return (1 <= game.pos.h+i-6-1+offset.h <= sh) &&
        (1 <= game.pos.w+j-8-1+offset.w <= sw)
end

function getTile(game::GameState,i::Integer,j::Integer,k::Integer)
    if checkMapBounds(game,game.maps.map,i,j,k)
        return game.maps.map.tilemap.map[k][game.pos.h+i-6-1,
            game.pos.w+j-8-1]
    end

    for n in game.maps.neighbours
        if checkMapBounds(game,n.map,i,j,k,n.offset)
            return n.map.tilemap.map[k][game.pos.h+i-6-1+n.offset.h,
                game.pos.w+j-8-1+n.offset.w]
        end
    end

    return 0x0001
end




function drawTile!(game::GameState,layer)
    
end

function drawMap!(game::GameState)
    @inbounds for k in 1:5
        @inbounds for i in 1:13, j in 1:17
            tile = game.im.tiles[getTile(game,i,j,k)]

            v = view(game.im.layers[k],1+(i-1)*16:i*16,1+(j-1)*16:j*16)
            
            @inbounds for t in eachindex(v)
                v[t] = tile[t]
            end
        end
    end

    @inbounds for k in 1:5
        @inbounds for i in 1:13, j in 1:17
            tile = game.im.tiles[getTile(game,i,j,k)]

            id = findfirst(isequal(tile),game.im.animids)

            if !isnothing(id)
                g = view(game.im.animdata,1:4,id)
                push!(game.im.animated,AnimTile(1+(i-1)*16,1+(j-1)*16,tile,
                    g[1],g[2],g[3],g[4]))
            end
        end
    end
end

function drawMapUpdate!(game::GameState,dir::Int)
    if dir == 1
        @inbounds for k in 1:5
            shiftLayerDown!(game.im.layers[k])

            @inbounds for j in 0x0001:0x0011
                tile = game.im.tiles[getTile(game,0x0001,j,k)]
    
                v = view(game.im.layers[k],
                    0x0001:0x0010,
                    0x0001+(j-0x0001)*0x0010:j*0x0010)
                
                @inbounds for t in eachindex(v)
                    v[t] = tile[t]
                end
            end

            for sprite in game.im.sprites[k]
                if sprite.id == :main
                    continue
                end
    
                posAdd!(sprite.pos,16,0)
            end
        end
    elseif dir == 2
        @inbounds for k in 1:5
            shiftLayerUp!(game.im.layers[k])

            @inbounds for j in 0x0001:0x0011
                tile = game.im.tiles[getTile(game,0x000d,j,k)]
    
                v = view(game.im.layers[k],
                    0x00c1:0x00d0,
                    0x0001+(j-0x0001)*0x0010:j*0x0010)
                
                @inbounds for t in eachindex(v)
                    v[t] = tile[t]
                end
            end

            for sprite in game.im.sprites[k]
                if sprite.id == :main
                    continue
                end
    
                posAdd!(sprite.pos,-16,0)
            end
        end
    elseif dir == 3
        @inbounds for k in 1:5
            shiftLayerRight!(game.im.layers[k])

            @inbounds for i in 0x01:0x0d
                tile = game.im.tiles[getTile(game,i,0x0001,k)]
    
                v = view(game.im.layers[k],
                    0x01+(i-0x01)*0x10:i*0x10,
                    0x01:0x10)
                
                @inbounds for t in eachindex(v)
                    v[t] = tile[t]
                end
            end

            for sprite in game.im.sprites[k]
                if sprite.id == :main
                    continue
                end
                
                posAdd!(sprite.pos,0,+16)
            end
        end
    else
        @inbounds for k in 1:5
            shiftLayerLeft!(game.im.layers[k])

            @inbounds for i in 0x01:0x0d
                tile = game.im.tiles[getTile(game,i,0x0011,k)]
    
                v = view(game.im.layers[k],
                    0x01+(i-0x01)*0x10:i*0x10,
                    0x01+0x0100:0x0110)
                
                @inbounds for t in eachindex(v)
                    v[t] = tile[t]
                end
            end

            for sprite in game.im.sprites[k]
                if sprite.id == :main
                    continue
                end
                
                posAdd!(sprite.pos,0,-16)
            end
        end
    end
end




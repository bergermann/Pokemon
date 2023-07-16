


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









mutable struct Tileset
    id::UInt8
    idxs::UnitRange{UInt16}
end


const tilesetranges = [
    0x0000:0x0000+0x10-0x01,
    0x0010:0x0010+0x20-0x01,
    0x0030:0x0030+0x30-0x01,
    0x0060:0x0060+0x60-0x01,
    0x00c0:0x00c0+0x60-0x01,
    0x0120:0x0120+0x30-0x01,
    0x0150:0x0150+0x50-0x01,
    0x01a0:0x01a0+0x20-0x01,
    0x01c0:0x01c0+0x20-0x01,
    0x01e0:0x01e0+0x40-0x01,
    0x0220:0x0220+0x40-0x01,
    0x0260:0x0260+0x40-0x01,
    0x02a0:0x02a0+0x40-0x01,
    0x02e0:0x02e0+0x50-0x01,
    0x0330:0x0330+0x60-0x01,
    0x0390:0x0390+0xc0-0x01,
    0x0450:0x0450+0x10-0x01,
    0x0460:0x0460+0x40-0x01,
    0x04a0:0x04a0+0x40-0x01,
    0x0600:0x0600+0x0140-0x01,
]

const tilesetnames = [
    "base",
    "ledges",
    "edges",
    "vegetation1",
    "decorations1",
    "grass1",
    "grass2",
    "borders1"  ,
    "patchesgrasslight",
    "patchesberry",
    "pokecenter",
    "gym1",
    "lab1",
    "house1",
    "house2",
    "water1",
    "flowers1",
    "flowers2",
    "flowers3",
    "interior1",
]

function getTileMap(id::UInt8)
    return deserialize("maps/$id/tilemap.map")
end

function cullTiles!(game::GameState,cull::BitVector)
    for i in eachindex(cull)
        if cull[i]
            for tileid in tileids[i]
                pop!(game.im.tiles,tileid)
            end
        end
    end
end

function getTiles!(game::GameState,load::BitVector)
    for i in eachindex(load)
        if load[i]
            tileset = mfb_rgb.(load(string("maps/",tilesetnames[i],".png")))

            height::UInt16,width::UInt16  = size(tileset)

            if height%0x0010 != 0x0000 || width%0x0010 != 0x0000
                return error("Wrong tileset format.")
            end
            
            h_tiles = div(height,s.tilesize)
            w_tiles = div(width,s.tilesize)

            for i in 1:h_tiles*w_tiles
                h = div(i,h_tiles)+1
                w = i%wtiles
                game.im.tiles[i] = tileset[1+(h-1)*16:h*16,1+(w-1)*16:w*16]
            end
        end
    end
end

function loadTiles!(game::GameState)
    ts = falses(64)

    # println(ts)
    println(game.maps.map.tilemap.tilesets)
    
    error("a")

    for i in eachindex(game.maps.map.tilemap.tilesets)
        if game.maps.map.tilemap.tilesets[i]
            ts[i] = true
        end
    end

    # error("b")

    ts[game.maps.map.tilemap.tilesets] .= true

    for n in game.maps.neighbours
        ts[n.map.tilemap.tilesets] .= true
    end

    cull = ts .& .~game.im.tilesets
    
    @time cullTiles!(game,cull)

    load = .~ts .& game.im.tilesets

    @time getTiles!(game,load)

    copy!(game.im.tilesets,ts)

    return
end



## check type of deserialization of tilemap files
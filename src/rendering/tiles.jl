




mutable struct Tileset
    id::UInt8
    idxs::UnitRange{UInt16}
end


const tilesetranges = [
    0x0000:0x0000+0x10-0x01,
    0x0010:0x0010+0x10-0x01-0x02, # fix ledges to be 2x8 someday
    0x0030:0x0030+0x18-0x01,
    0x0060:0x0060+0x30-0x01,
    0x00c0:0x00c0+0x30-0x01,
    0x0120:0x0120+0x18-0x01,
    0x0150:0x0150+0x28-0x01,
    0x01a0:0x01a0+0x10-0x01,
    0x01c0:0x01c0+0x10-0x01,
    0x01e0:0x01e0+0x20-0x01,
    0x0220:0x0220+0x20-0x01,
    0x0260:0x0260+0x20-0x01,
    0x02a0:0x02a0+0x20-0x01,
    0x02e0:0x02e0+0x28-0x01,
    0x0330:0x0330+0x30-0x01,
    0x0390:0x0390+0x60-0x01,
    0x0450:0x0450+0x08-0x01,
    0x0460:0x0460+0x10-0x01,
    0x04a0:0x04a0+0x20-0x01,
    0x0600:0x0600+0xa0-0x01,
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
    # println("cull:  ",cull)
    # println("state: ",game.im.tilesets)
    # for i in eachindex(tilesetranges)
    #     println(i,": ",tilesetranges[i].start,": ",tilesetranges[i].start ∈ Base.keys(game.im.tiles))
    # end
    for i in eachindex(cull)
        if cull[i]
            for tileid in tilesetranges[i]
                pop!(game.im.tiles,tileid)
            end
        end
    end
end

function getTiles!(game::GameState,get::BitVector)
    for g in eachindex(get)
        if get[g]
            tileset = mfb_rgb.(load(string("im/tilesets/",tilesetnames[g],".png")))

            height::UInt16,width::UInt16  = size(tileset)

            if height%0x0010 != 0x0000 || width%0x0010 != 0x0000
                return error("Wrong tileset format.")
            end
            
            h_tiles = div(height,0x0010)
            w_tiles = div(width,0x0010)

            # println(g,": ",tilesetnames[g])
            # println(height,", ",width)
            # println("h: ",h_tiles)
            # println("w: ",w_tiles)

            offset = tilesetranges[g].start

            for i in 0x0001:h_tiles*w_tiles
                h = div(i-0x01,w_tiles)+0x01
                w = (i-0x01)%w_tiles+0x01

                # println("i:  ",i)
                # println("id: ",i+offset-0x001)
                game.im.tiles[i+offset-0x001] =
                    tileset[0x1+(h-0x01)*0x0010:h*0x0010,0x01+(w-0x01)*0x0010:w*0x0010]
            end

            println()
        end
    end
end

function loadTiles!(game::GameState)
    ts = fill(false,64)

    ts .|= game.maps.map.tilemap.tilesets

    for n in game.maps.neighbours
        ts .|= n.map.tilemap.tilesets
    end

    cull = .~ts .& game.im.tilesets
    
    cullTiles!(game,cull)

    get = ts .& .~game.im.tilesets

    getTiles!(game,get)

    copy!(game.im.tilesets,ts)

    return
end



## check type of deserialization of tilemap files
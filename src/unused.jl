function test()
    if n%0x0078 == 0x0000
        game.pos.h += 0x01
        updateSurroundings!(g,game,(h=Int8(1),w=Int8(0)); s=settings)
        s = drawSurroundings(g,game)
    elseif n%0x0078 == 0x003c
        game.pos.h -= 0x01
        updateSurroundings!(g,game,(h=Int8(-1),w=Int8(0)); s=settings)
        s = drawSurroundings(g,game)
    end
end



function getTileMap(dir::String)
    files = readdir(string("maps/",dir))

    return cat([readdlm(string("maps/",dir,"/",files[i]),',',UInt16,'\n')
            for i in eachindex(files)]...; dims=3)
end

function renderLoop(fps::Float16,window,buffer::Matrix{UInt32})
    n = 0
    buffer .= 0xffffff
    buffer[10,10] = typemin(UInt32)
    buffer[10,end-10] = typemin(UInt32)
    buffer[end-10,end-10] = typemin(UInt32)

    timer = mfb_timer_create()

    while true
        str = string(" Test 1\n Test ",n,"\n Grüss anDreas\n FPS ",
                    round(n/mfb_timer_now(timer)))
        tb = textBuffer(str,(0x00a0,0x00f0),d2)
        addBuffer!(buffer,tb)
        state = mfb_update(window, buffer)
        if state != MiniFB.STATE_OK
            break
        end
        n += 1
    end
end

function addBuffer!(bufferbase::Matrix{UInt32},bufferadd::Matrix{UInt32})
    ind = bufferadd .!= 0x000000
    bufferbase[ind] = bufferadd[ind]
end

function addBuffer!(buffers::Vector{Matrix{UInt32}})
    for i in 2:length(buffers)
        addBuffer!(buffers[1],buffers[i])
    end
end



function drawMap(tiles::Dict,tilemap::Vector; s=Settings())
    #map.layers
    l = [0x01,0x02]

    width::UInt16, height::UInt16 = size(tilemap[l[0x01]])
    
    layers = zeros(UInt32,width*s.tilesize,height*s.tilesize,length(l))

    
    for k in eachindex(l)
        for i in 0x0001:width, j in 0x0001:height
            layers[0x0001+(i-0x0001)*s.tilesize:i*s.tilesize,
                0x0001+(j-0x0001)*s.tilesize:j*s.tilesize,k] = tiles[tilemap[k][i,j]]
        end
    end

    return layers
end

function getSurroundings(game::GameState; s=Settings())

    if s.Nw%0x02 == 0x00 || s.Nh%0x02 == 0x00
        return error("Grid length needs to be uneven.")
    end

    l = UInt8(size(game.map.tilemap)[3])

    grid = zeros(UInt16,s.Nh,s.Nw,l)

    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    for k in 0x01:l
        grid[:,:,k] = game.map.tilemap[
            game.pos.h-dh:game.pos.h+dh,
            game.pos.w-dw:game.pos.w+dw,k]
    end

    return grid
end

function drawSurroundings(grid::Array{UInt16,3},game::GameState; s=Settings())

    l = [0x01,0x02]

    #grid = getSurroundings(game; tilesize=tilesize)

    layers = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
                        UInt16(s.Nw)*UInt16(s.tilesize),UInt16(length(l)))
    
    for k in eachindex(l)
        for i in 0x0001:UInt16(s.Nh), j in 0x0001:UInt16(s.Nw)
            layers[0x0001+(i-0x0001)*s.tilesize:i*s.tilesize,
                0x0001+(j-0x0001)*s.tilesize:j*s.tilesize,
                k] = game.map.tiles[grid[i,j,k]]
        end
    end

    return layers
end

function updateSurroundings!(g::Array{UInt16,3},game::GameState,
        direction::NamedTuple{(:h,:w),Tuple{Int8,Int8}}; s=Settings())

    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    if direction.h == 1
        g[1:end-1,:,:] = g[2:end,:,:]
        g[end,:,:] = game.map.tilemap[game.pos.h+dh,game.pos.w-dw:game.pos.w+dw,:]
    elseif direction.h == -1
        g[2:end,:,:] = g[1:end-1,:,:]
        g[1,:,:] = game.map.tilemap[game.pos.h-dh,game.pos.w-dw:game.pos.w+dw,:]
    end

    if direction.w == 1
        g[:,1:end-1,:] = g[:,2:end,:]
        g[:,end,:] = game.map.tilemap[game.pos.h-dh:game.pos.h+dh,game.pos.h+dw,:]
    elseif direction.w == -1
        g[:,2:end,:] = g[:,1:end-1,:]
        g[:,1,:] = game.map.tilemap[game.pos.h-dh:game.pos.h+dh,game.pos.h-dw,:]
    end
end

function updateDrawSurroundings!(b,g,grid::Array{UInt16,3},game::GameState; s=Settings())

    l = [0x01,0x02]

    #grid = getSurroundings(game; tilesize=tilesize)

    layers = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
                        UInt16(s.Nw)*UInt16(s.tilesize),UInt16(length(l)))
    
    for k in eachindex(l)
        for i in 0x0001:UInt16(s.Nh), j in 0x0001:UInt16(s.Nw)
            layers[0x0001+(i-0x0001)*s.tilesize:i*s.tilesize,
                0x0001+(j-0x0001)*s.tilesize:j*s.tilesize,
                k] = game.map.tiles[grid[i,j,k]]
        end
    end

    return layers
end

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

    
        #=
        if n_frames%0x0078 == 0x0000
            game.pos.h += 0x01
            updateLayers!(layers,[:background,:foreground],game,
                (h=Int8(1),w=Int8(0)); s=Settings())
        elseif n_frames%0x0078 == 0x003c
            game.pos.h -= 0x01
            updateLayers!(layers,[:background,:foreground],game,
                (h=Int8(-1),w=Int8(0)); s=Settings())
        end
        =#
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





function inputManager!(game::GameState,input::Input,n_frame::UInt)
    if input.up && !input.B
        game.n_anim = n_frame

        if game.direction != :up
            game.movelock = true
            game.direction = :up
            game.anim = :walkturnup
        elseif game.map.tilemap.collision[game.pos.h-Int32(1),game.pos.w] == 0x0000
            game.movelock = true
            game.anim = :walkup
        end
    elseif input.down && !input.B
        game.n_anim = n_frame

        if game.direction != :down
            game.movelock = true
            game.direction = :down
            game.anim = :walkturndown
        elseif game.map.tilemap.collision[game.pos.h+Int32(1),game.pos.w] == 0x0000
            game.movelock = true
            game.anim = :walkdown
        end
    elseif input.left && !input.B
        game.n_anim = n_frame

        if game.direction != :left
            game.movelock = true
            game.direction = :left
            game.anim = :walkturnleft
        elseif game.map.tilemap.collision[game.pos.h,game.pos.w-Int32(1)] == 0x0000
            game.movelock = true
            game.anim = :walkleft
        end
    elseif input.right && !input.B
        game.n_anim = n_frame
        
        if game.direction != :right
            game.movelock = true
            game.direction = :right
            game.anim = :walkturnright
        elseif game.map.tilemap.collision[game.pos.h,game.pos.w+Int32(1)] == 0x0000
            game.movelock = true
            game.anim = :walkright
        end
    end

    if input.up && input.B
        game.n_anim = n_frame

        if game.direction != :up
            game.movelock = true
            game.direction = :up
            game.anim = :runturnup
        elseif game.map.tilemap.collision[game.pos.h-Int32(1),game.pos.w] == 0x0000
            game.movelock = true
            game.anim = :runup
        end
    elseif false
        0
    end
end


function moveManager!(game::GameState,n_frame::UInt)
    if game.anim == :walkturnup
        if n_frame-game.n_anim < 0x04
            game.spritecycle = 0x02
        elseif n_frame-game.n_anim < 0x08
            game.spritecycle = 0x01
        elseif n_frame-game.n_anim >= 0x08
            game.anim = :null
            game.movelock = false
        end
    end

    if game.anim == :walkup
        n = n_frame-game.n_anim

        game.screenoffset.h = -Int32(n)
        game.spriteoffset.h = -Int32(n)

        if n < 0x08
            if game.pos.h%2 == 0
                game.spritecycle = 0x02
            else
                game.spritecycle = 0x03
            end
        elseif n < 0x10
            game.spritecycle = 0x01
        elseif n >= 0x10
            game.anim = :null
            game.movelock = false
            game.screenoffset.h = 0x00
            game.spriteoffset.h = 0x00
            game.pos.h -= Int32(1)
        end
    end


    
    if game.anim == :walkturndown
        if n_frame-game.n_anim < 0x04
            game.spritecycle = 0x02
        elseif n_frame-game.n_anim < 0x08
            game.spritecycle = 0x01
        elseif n_frame-game.n_anim >= 0x8
            game.anim = :null
            game.movelock = false
        end
    end

    if game.anim == :walkdown
        n = n_frame-game.n_anim

        game.screenoffset.h = +Int32(n)
        game.spriteoffset.h = +Int32(n)

        if n < 0x08
            if game.pos.h%2 == 0
                game.spritecycle = 0x02
            else
                game.spritecycle = 0x03
            end
        elseif n < 0x10
            game.spritecycle = 0x01
        elseif n >= 0x10
            game.anim = :null
            game.movelock = false
            game.screenoffset.h = 0x00
            game.spriteoffset.h = 0x00
            game.pos.h += Int32(1)
        end
    end


    
    if game.anim == :walkturnleft
        if n_frame-game.n_anim < 0x04
            game.spritecycle = 0x02
        elseif n_frame-game.n_anim < 0x08
            game.spritecycle = 0x01
        elseif n_frame-game.n_anim >= 0x08
            game.anim = :null
            game.movelock = false
        end
    end

    if game.anim == :walkleft
        n = n_frame-game.n_anim

        game.screenoffset.w = -Int32(n)
        game.spriteoffset.w = -Int32(n)

        if n < 0x08
            if game.pos.w%2 == 0
                game.spritecycle = 0x02
            else
                game.spritecycle = 0x03
            end
        elseif n < 0x10
            game.spritecycle = 0x01
        elseif n >= 0x10
            game.anim = :null
            game.movelock = false
            game.screenoffset.w = 0x00
            game.spriteoffset.w = 0x00
            game.pos.w -= Int32(1)
        end
    end

    

    if game.anim == :walkturnright
        if n_frame-game.n_anim < 0x04
            game.spritecycle = 0x02
        elseif n_frame-game.n_anim < 0x08
            game.spritecycle = 0x01
        elseif n_frame-game.n_anim >= 0x08
            game.anim = :null
            game.movelock = false
        end
    end

    if game.anim == :walkright
        n = n_frame-game.n_anim

        game.screenoffset.w = +Int32(n)
        game.spriteoffset.w = +Int32(n)

        if n < 0x08
            if game.pos.w%2 == 0
                game.spritecycle = 0x02
            else
                game.spritecycle = 0x03
            end
        elseif n < 0x10
            game.spritecycle = 0x01
        elseif n >= 0x10
            game.anim = :null
            game.movelock = false
            game.screenoffset.w = 0x00
            game.spriteoffset.w = 0x00
            game.pos.w += Int32(1)
        end
    end



    if game.anim == :runturnup
        if n_frame-game.n_anim < 0x04
            game.spritecycle = 0x02
        elseif n_frame-game.n_anim < 0x08
            game.spritecycle = 0x01
        elseif n_frame-game.n_anim >= 0x08
            game.anim = :null
            game.movelock = false
        end
    end

    if game.anim == :runup
        n = n_frame-game.n_anim
        game.transport = :run

        game.screenoffset.h = -Int32(2*n)
        game.spriteoffset.h = -Int32(2*n)

        if n < 0x04
            if game.pos.h%2 == 0
                game.spritecycle = 0x02
            else
                game.spritecycle = 0x03
            end
        elseif n < 0x08
            game.spritecycle = 0x01
        elseif n >= 0x08
            game.anim = :null
            game.movelock = false
            game.screenoffset.h = 0x00
            game.spriteoffset.h = 0x00
            game.transport = :walk
            game.pos.h -= Int32(1)
        end
    end
end



function combineLayers(layers::Layers,key::Vector{Symbol};
    s::Settings=Settings())
    L = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
        UInt16(s.Nw)*UInt16(s.tilesize))

    for k in key
        ind = getfield(layers,k) .!= 0x000000
        L[ind] = getfield(layers,k)[ind]
    end

    return L
    end

    function combineLayers(game::GameState; s::Settings=Settings())
    L = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
        UInt16(s.Nw)*UInt16(s.tilesize))

    for k in game.im.draw
        ind = getfield(game.im.layers,k) .!= 0x000000
        L[ind] = getfield(game.im.layers,k)[ind]
    end

    return L
end



function drawLayers!(layers::Layers,key::Vector{Symbol},game::GameState;
    s=Settings())

    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    for k in key
        for i in 1:s.Nh, j in 1:s.Nw
            getfield(layers,k)[1+(i-1)*s.tilesize:i*s.tilesize,
                1+(j-1)*s.tilesize:j*s.tilesize] = game.map.tiles[
                    getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
                    game.pos.w+j-dw-1]]
        end
    end
end

function updateLayers!(layers::Layers,key::Vector{Symbol},game::GameState,
    direction::NamedTuple{(:h,:w),Tuple{Int8,Int8}}; s=Settings())

    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    for k in key
        if direction.h == 1
            getfield(layers,k)[1:end-s.tilesize,:] = getfield(layers,k)[1+s.tilesize:end,:]

            for i in 1:s.Nw
                getfield(layers,k)[end-s.tilesize+1:end,1+(i-1)*s.tilesize:i*s.tilesize] = 
                    game.map.tiles[getfield(game.map.tilemap,k)[game.pos.h+dh,
                    game.pos.w+i-dw-1]]
            end
        elseif direction.h == -1
            getfield(layers,k)[1+s.tilesize:end,:] = getfield(layers,k)[1:end-s.tilesize,:]
            
            for i in 1:s.Nw
                getfield(layers,k)[1:s.tilesize,1+(i-1)*s.tilesize:i*s.tilesize] = 
                    game.map.tiles[getfield(game.map.tilemap,k)[game.pos.h-dh,
                    game.pos.w+i-dw-1]]
            end
        end

        if direction.w == 1
            return
        elseif direction.w == -1
            return
        end
    end
end




function textBuffer(str::String,area::Tuple{UInt16,UInt16},dict::Dict)
    height = size(dict[str[1]])[2]

    S = split(str,"\n")

    tb = permutedims(zeros(UInt32,area),(2,1))
    for i in eachindex(S)
        vert::UInt16 = 0x0001
        for c in collect(S[i])
            char = dict[c]
            width = UInt16(size(char)[1])
            
            tb[vert:vert+width-0x01,
                        UInt16(1+height*(i-1)):UInt16(height*i)] = char
            vert += width - 0x01
        end
    end
    
    return tb
end
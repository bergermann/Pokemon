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



function onpresstest(args...)
    for a in args
        print(a,", ")
    end

    println()

    return nothing
end

mutable struct Input
    input::Bool

    A::Bool
    A_::Bool
    B::Bool
    B_::Bool

    L::Bool
    L_::Bool
    R::Bool
    R_::Bool

    up::Bool
    up_::Bool
    down::Bool
    down_::Bool
    left::Bool
    left_::Bool
    right::Bool
    right_::Bool

    start::Bool
    start_::Bool
    select::Bool
    select_::Bool

    function Input()
        new(falses(length(fieldnames(Input)))...)
    end
end

ctrls_ = Base.ImmutableDict(
    MiniFB.KB_KEY_SPACE => :A_,
    MiniFB.KB_KEY_ENTER => :A_,

    MiniFB.KB_KEY_LEFT_CONTROL => :B_,
    MiniFB.KB_KEY_LEFT_SHIFT => :B_,
    MiniFB.KB_KEY_BACKSPACE => :B_,

    MiniFB.KB_KEY_Q => :L_,

    MiniFB.KB_KEY_E => :R_,

    MiniFB.KB_KEY_W => :up_,
    MiniFB.KB_KEY_UP => :up_,

    MiniFB.KB_KEY_S => :down_,
    MiniFB.KB_KEY_DOWN => :down_,

    MiniFB.KB_KEY_A => :left_,
    MiniFB.KB_KEY_LEFT => :left_,

    MiniFB.KB_KEY_D => :right_,
    MiniFB.KB_KEY_RIGHT => :right_,

    MiniFB.KB_KEY_X => :start_,

    MiniFB.KB_KEY_Y => :select_,
)

function onpress(window, button, mod, isPressed)::Cvoid
    global input

    if Bool(isPressed)
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,c,true)
            #setfield!(input,get(ctrls_,button,:null),false)
        end
    else
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,c,false)
            #setfield!(input,get(ctrls_,button,:null),true)
        end
    end

    return nothing
end

mutable struct Inp
    p::Bool
    _p::Bool
    p_::Bool

    function Inp()
        new(false,false,false)
    end

    function Inp(p::Bool,_p::Bool,p_::Bool)
        new(p,_p,p_)
    end

    function Inp(_p::Bool,p_::Bool)
        new(true,_p,p_)
    end
end

mutable struct Input
    input::Bool
    _input::Bool
    input_::Bool

    A::Bool
    _A::Bool
    A_::Bool
    B::Bool
    _B::Bool
    B_::Bool

    L::Bool
    _L::Bool
    L_::Bool
    R::Bool
    _R::Bool
    R_::Bool

    up::Bool
    _up::Bool
    up_::Bool
    down::Bool
    _down::Bool
    down_::Bool
    left::Bool
    _left::Bool
    left_::Bool
    right::Bool
    _right::Bool
    right_::Bool

    start::Bool
    _start::Bool
    start_::Bool
    select::Bool
    _select::Bool
    select_::Bool

    function Input()
        new([Inp() for _ in fieldnames(Input)]...)
    end

    function Input(p::Bool,_p::Bool,p_::Bool)
        new([Inp(p,_p,p_) for _ in fieldnames(Input)]...)
    end
end


function inputManager!(game::GameState,input::Input,n_frame::UInt)
    if game.inputlock
        return nothing
    end

    if !game.battle.active && !game.menu.menu && !game.movelock &&
            (input.up || input.down || input.left || input.right)
        
        inputdir = [:up,:down,:left,:right][[input.up,input.down,input.left,input.right]][1]
        movepos = posAdd(game.pos,dirs[inputdir])
        
        game.movelock = true
        game.n_anim = n_frame

        if !input.B && (game.transport == :walk || game.transport == :run)
            game.transport = :walk
            
            if game.direction != inputdir
                game.direction = inputdir
                game.moveFunc = moveTurn!
            elseif game.map.tilemap.collision[movepos.h,movepos.w] != 0x0001
                game.moveFunc = moveWalk!
            else
                game.moveFunc = moveWalkWall!
            end
        elseif input.B && (game.transport == :walk || game.transport == :run)
            game.transport = :run
            game.direction = inputdir

            if game.map.tilemap.collision[movepos.h,movepos.w] != 0x0001
                game.moveFunc = moveRun!
            else
                game.moveFunc = moveTurn!
            end
        end
    elseif !game.battle.active && !game.menu.menu && !game.movelock 
        game.transport = :walk
    end

    if !game.battle.active && !game.menu.menu && !game.menu.menu_ && input.start
        game.movelock = true
        game.menu.menu = true

        drawFrame!(game,UInt(20),UInt(10),Position(24,176))
        drawText!(game,"POKEDEX\nPOKEMON\nBEUTEL\nPOKENAV\n$(game.trainer.name)\
            \nSICHERN\nOPTION\nBEENDEN",UInt(2),Position(38,194); lineoffset=1)
        push!(game.im.draw,:menu)
        push!(game.im.draw,:text)
    elseif !game.battle.active && game.menu.menu && !game.menu.menu_ && !input.start
        game.menu.menu_ = true
    elseif !game.battle.active && game.menu.menu && game.menu.menu_ && (input.start || input.B)
        game.movelock = false
        game.menu.menu = false

        filter!(x->x!=:menu,game.im.draw)
        filter!(x->x!=:text,game.im.draw)
    elseif !game.battle.active && !game.menu.menu && game.menu.menu_ && !input.start
        game.menu.menu_ = false
    end
end


function drawText!(game::GameState,str::String,style::UInt,pos::Position;
    lineoffset=0)
height = [13,16,17][style]

S = split(str,"\n")

for i in eachindex(S)
    vert = 0
    for c in collect(S[i])
        char = game.im.font[style][c]
        
        game.im.layers.text[
            1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
            vert+1+pos.w:vert+size(char)[2]+pos.w
        ] = char
        
        vert += size(char)[2]-1
    end
end
end

function getFont()
    fontimg = load("im/font.png")

    symbols1 = ""
    symbols2 = "0123456789!?.-⋅~“”‘’♂♀€,×/®\
            ABCDEFGHIJKLMNOPQRSTUVWXYZ\
            abcdefghijklmnopqrstuvwxyz\
            ▷:ÄÖÜäöü↑↓←→+ⓁⒶⒾⓃ_ "#=\
            ①②③④⑤⑥⑦⑧⑨()⊚△⨉\
            ÀÁÂÇÈÉËÌÍÏÒÓÔŒÙÚÛÑß\
            àáâçèéêëìíîïòóôœùúûñ\
            ᵒᵃᵉʳ&+🄻=;|¿¡%[]<>\
            ⓟ⒫Ⓑ"=#
    symbols3 = ""

    key1 = Vector{Matrix{UInt16}}([])
    key2 = Vector{Matrix{UInt16}}([
        Matrix{UInt16}([
            180 5;  #0
            187 4;  #1
            192 5;  #2
            198 5;  #3
            204 5;  #4
            210 5;  #5
            216 5;  #6
            222 5;  #7
            228 5;  #8
            234 5;  #9
            241 2;  #!
            245 4;  #?
            251 3;  #.
            255 5;  #-
            261 3;  #*
            265 5;  #..
            271 5;  #"l
            277 5;  #"r
            283 3;  #'l
            287 3;  #'r
            291 5;  #male
            297 5;  #female
            303 6;  #poke
            310 3;  #,
            314 6;  #x
            321 5;  #/
            327 8]),#re
        Matrix{UInt16}([
            180 5;  #A
            186 5;  #B
            192 5;  #C
            198 5;  #D
            204 5;  #E
            210 5;  #F
            216 5;  #G
            222 5;  #H
            228 4;  #I
            233 5;  #J
            239 5;  #K
            245 5;  #L
            251 5;  #M
            257 5;  #N
            263 5;  #O
            269 5;  #P
            275 5;  #Q
            281 5;  #R
            287 5;  #S
            293 5;  #T
            299 5;  #U
            305 5;  #V
            311 5;  #W
            317 5;  #X
            323 4;  #Y
            328 5]),#Z
        Matrix{UInt16}([
            180 5;  #a
            186 5;  #b
            192 5;  #c
            198 5;  #d
            204 5;  #e
            210 5;  #f
            216 5;  #g
            222 5;  #h
            229 2;  #i
            233 5;  #j
            239 5;  #k
            246 2;  #l
            250 5;  #m
            256 5;  #n
            262 5;  #o
            268 5;  #p
            274 5;  #q
            280 5;  #r
            286 5;  #s
            292 5;  #t
            298 5;  #u
            304 5;  #v
            310 5;  #w
            316 5;  #x
            322 5;  #y
            328 5]),#z
        Matrix{UInt16}([
            181 6;  #triangle right
            189 3;  #:
            193 5;  #Ä
            199 5;  #Ö
            205 5;  #Ü
            211 5;  #ä
            217 5;  #ö
            223 5;  #ü
            229 10; #arrow up
            240 10; #arrow down
            251 9;  #arrow left
            263 9;  #arrow right
            274 6;  #+
            282 8;  #lv
            291 10; #ap
            302 8;  #id
            311 10; #no
            323 9;  #_
            333 3]),
    ])
    key3 = Vector{Matrix{UInt16}}([])

    f1 = Vector{Matrix{UInt32}}([])
    f2 = Vector{Matrix{UInt32}}([])
    f3 = Vector{Matrix{UInt32}}([])

    for i in eachindex(key1)
        k = key1[i]

        for j in Array{UInt16}(1:size(k)[1])
            push!(f1,
                    mfb_rgb.(fontimg[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
                    k[j,1]+0x01:k[j,1]+k[j,2]+0x01]))
        end
    end

    for i in eachindex(key2)
        k = key2[i]

        for j in Array{UInt16}(1:size(k)[1])
            push!(f2,mfb_rgb.(fontimg[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
                    k[j,1]+0x01:k[j,1]+k[j,2]+0x01]))
        end
    end

    for i in eachindex(key3)
        k = key3[i]

        for j in Array{UInt16}(1:size(k)[1])
            push!(f3,mfb_rgb.(fontimg[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
                    k[j,1]+0x01:k[j,1]+k[j,2]+0x01]))
        end
    end
    
    return Dict(zip(symbols1,f1)),Dict(zip(symbols2,f2)),Dict(zip(symbols3,f3))
end

function drawText!(game::GameState,layer::Symbol,str::String,style::UInt,pos::Position;
        lineoffset=0)
    height = [12,15,14][style]

    S = split(str,"\n")

    for i in eachindex(S)
        vert = 0

        for c in collect(S[i])
            char = game.im.font[style][c]
            ind = char .!= 0x000000
            #println(ind)
            
            getproperty(game.im.layers,layer)[
                1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
                vert+1+pos.w:vert+size(char)[2]+pos.w
            #] = char
            ][ind] = char[ind]
            
            vert += size(char)[2]
        end
    end
end

function combineLayers!(game::GameState; s::Settings=Settings())
    for k in game.im.draw
        ind = getfield(game.im.layers,k) .!= 0x000000

        game.im.layer[ind] = getfield(game.im.layers,k)[ind]
    end
end

#=
function drawText!(game::GameState,layer::Symbol,str::String,style::UInt,pos::Position;
        lineoffset=0)
    height = [12,15,14][style]

    S = split(str,"\n")

    for i in eachindex(S)
        vert = 0

        for c in collect(S[i])
            char = game.im.font[style][c]
            ind = char .== 0x000000
            char[ind] = getproperty(game.im.layers,layer)[
                1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
                vert+1+pos.w:vert+size(char)[2]+pos.w
            ][ind]
            
            getproperty(game.im.layers,layer)[
                1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
                vert+1+pos.w:vert+size(char)[2]+pos.w
            ] = char
            
            vert += size(char)[2]
        end
    end
end
=#

function constructFrame(game::GameState,height::UInt,width::UInt)
    frame = ones(UInt32,height*8,width*8)*game.im.frames[1][5][1]

    if height == 1 || width == 1
        return error("Frame is too small.")
    end

    for i in 1:height, j in 1:width
        if i != 1 && i != height && j != 1 && j != width
            f = 5
        elseif i == 1 && j == 1
            f = 1
        elseif i == 1 && j != 1 && j != width
            f = 2
        elseif i == 1 && j == width
            f = 3
        elseif i != 1 && i != height && j == 1
            f = 4
        elseif i != 1 && i != height && j == width
            f = 6
        elseif i == height && j == 1
            f = 7
        elseif i == height && j != 1 && j != width
            f = 8
        else
            f = 9
        end

        frame[1+(i-1)*8:i*8,1+(j-1)*8:j*8] = game.im.frames[game.options.frame][f]
    end

    return frame
end

function drawFrame!(game::GameState,layer::Symbol,height::UInt,width::UInt,
        offset::Position)
    getfield(game.im.layers,layer)[1+offset.h:height*8+offset.h,
        1+offset.w:width*8+offset.w] = constructFrame(game,height,width)
end
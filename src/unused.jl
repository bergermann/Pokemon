# function test()
#     if n%0x0078 == 0x0000
#         game.pos.h += 0x01
#         updateSurroundings!(g,game,(h=Int8(1),w=Int8(0)); s=settings)
#         s = drawSurroundings(g,game)
#     elseif n%0x0078 == 0x003c
#         game.pos.h -= 0x01
#         updateSurroundings!(g,game,(h=Int8(-1),w=Int8(0)); s=settings)
#         s = drawSurroundings(g,game)
#     end

    
#         #=
#         if n_frames%0x0078 == 0x0000
#             game.pos.h += 0x01
#             updateLayers!(layers,[:background,:foreground],game,
#                 (h=Int8(1),w=Int8(0)); s=Settings())
#         elseif n_frames%0x0078 == 0x003c
#             game.pos.h -= 0x01
#             updateLayers!(layers,[:background,:foreground],game,
#                 (h=Int8(-1),w=Int8(0)); s=Settings())
#         end
#         =#
# end



# function getTileMap(dir::String)
#     files = readdir(string("maps/",dir))

#     return cat([readdlm(string("maps/",dir,"/",files[i]),',',UInt16,'\n')
#             for i in eachindex(files)]...; dims=3)
# end

# function renderLoop(fps::Float16,window,buffer::Matrix{UInt32})
#     n = 0
#     buffer .= 0xffffff
#     buffer[10,10] = typemin(UInt32)
#     buffer[10,end-10] = typemin(UInt32)
#     buffer[end-10,end-10] = typemin(UInt32)

#     timer = mfb_timer_create()

#     while true
#         str = string(" Test 1\n Test ",n,"\n Grüss anDreas\n FPS ",
#                     round(n/mfb_timer_now(timer)))
#         tb = textBuffer(str,(0x00a0,0x00f0),d2)
#         addBuffer!(buffer,tb)
#         state = mfb_update(window, buffer)
#         if state != MiniFB.STATE_OK
#             break
#         end
#         n += 1
#     end
# end

# function addBuffer!(bufferbase::Matrix{UInt32},bufferadd::Matrix{UInt32})
#     ind = bufferadd .!= 0x000000
#     bufferbase[ind] = bufferadd[ind]
# end

# function addBuffer!(buffers::Vector{Matrix{UInt32}})
#     for i in 2:length(buffers)
#         addBuffer!(buffers[1],buffers[i])
#     end
# end



# function drawMap(tiles::Dict,tilemap::Vector; s=Settings())
#     #map.layers
#     l = [0x01,0x02]

#     width::UInt16, height::UInt16 = size(tilemap[l[0x01]])
    
#     layers = zeros(UInt32,width*s.tilesize,height*s.tilesize,length(l))

    
#     for k in eachindex(l)
#         for i in 0x0001:width, j in 0x0001:height
#             layers[0x0001+(i-0x0001)*s.tilesize:i*s.tilesize,
#                 0x0001+(j-0x0001)*s.tilesize:j*s.tilesize,k] = tiles[tilemap[k][i,j]]
#         end
#     end

#     return layers
# end

# function getSurroundings(game::GameState; s=Settings())

#     if s.Nw%0x02 == 0x00 || s.Nh%0x02 == 0x00
#         return error("Grid length needs to be uneven.")
#     end

#     l = UInt8(size(game.map.tilemap)[3])

#     grid = zeros(UInt16,s.Nh,s.Nw,l)

#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     for k in 0x01:l
#         grid[:,:,k] = game.map.tilemap[
#             game.pos.h-dh:game.pos.h+dh,
#             game.pos.w-dw:game.pos.w+dw,k]
#     end

#     return grid
# end

# function drawSurroundings(grid::Array{UInt16,3},game::GameState; s=Settings())

#     l = [0x01,0x02]

#     #grid = getSurroundings(game; tilesize=tilesize)

#     layers = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
#                         UInt16(s.Nw)*UInt16(s.tilesize),UInt16(length(l)))
    
#     for k in eachindex(l)
#         for i in 0x0001:UInt16(s.Nh), j in 0x0001:UInt16(s.Nw)
#             layers[0x0001+(i-0x0001)*s.tilesize:i*s.tilesize,
#                 0x0001+(j-0x0001)*s.tilesize:j*s.tilesize,
#                 k] = game.map.tiles[grid[i,j,k]]
#         end
#     end

#     return layers
# end

# function updateSurroundings!(g::Array{UInt16,3},game::GameState,
#         direction::NamedTuple{(:h,:w),Tuple{Int8,Int8}}; s=Settings())

#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     if direction.h == 1
#         g[1:end-1,:,:] = g[2:end,:,:]
#         g[end,:,:] = game.map.tilemap[game.pos.h+dh,game.pos.w-dw:game.pos.w+dw,:]
#     elseif direction.h == -1
#         g[2:end,:,:] = g[1:end-1,:,:]
#         g[1,:,:] = game.map.tilemap[game.pos.h-dh,game.pos.w-dw:game.pos.w+dw,:]
#     end

#     if direction.w == 1
#         g[:,1:end-1,:] = g[:,2:end,:]
#         g[:,end,:] = game.map.tilemap[game.pos.h-dh:game.pos.h+dh,game.pos.h+dw,:]
#     elseif direction.w == -1
#         g[:,2:end,:] = g[:,1:end-1,:]
#         g[:,1,:] = game.map.tilemap[game.pos.h-dh:game.pos.h+dh,game.pos.h-dw,:]
#     end
# end

# function updateDrawSurroundings!(b,g,grid::Array{UInt16,3},game::GameState; s=Settings())

#     l = [0x01,0x02]

#     #grid = getSurroundings(game; tilesize=tilesize)

#     layers = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
#                         UInt16(s.Nw)*UInt16(s.tilesize),UInt16(length(l)))
    
#     for k in eachindex(l)
#         for i in 0x0001:UInt16(s.Nh), j in 0x0001:UInt16(s.Nw)
#             layers[0x0001+(i-0x0001)*s.tilesize:i*s.tilesize,
#                 0x0001+(j-0x0001)*s.tilesize:j*s.tilesize,
#                 k] = game.map.tiles[grid[i,j,k]]
#         end
#     end

#     return layers
# end





# function inputManager!(game::GameState,input::Input,n_frame::UInt)
#     if input.up && !input.B
#         game.n_anim = n_frame

#         if game.direction != :up
#             game.movelock = true
#             game.direction = :up
#             game.anim = :walkturnup
#         elseif game.map.tilemap.collision[game.pos.h-Int32(1),game.pos.w] == 0x0000
#             game.movelock = true
#             game.anim = :walkup
#         end
#     elseif input.down && !input.B
#         game.n_anim = n_frame

#         if game.direction != :down
#             game.movelock = true
#             game.direction = :down
#             game.anim = :walkturndown
#         elseif game.map.tilemap.collision[game.pos.h+Int32(1),game.pos.w] == 0x0000
#             game.movelock = true
#             game.anim = :walkdown
#         end
#     elseif input.left && !input.B
#         game.n_anim = n_frame

#         if game.direction != :left
#             game.movelock = true
#             game.direction = :left
#             game.anim = :walkturnleft
#         elseif game.map.tilemap.collision[game.pos.h,game.pos.w-Int32(1)] == 0x0000
#             game.movelock = true
#             game.anim = :walkleft
#         end
#     elseif input.right && !input.B
#         game.n_anim = n_frame
        
#         if game.direction != :right
#             game.movelock = true
#             game.direction = :right
#             game.anim = :walkturnright
#         elseif game.map.tilemap.collision[game.pos.h,game.pos.w+Int32(1)] == 0x0000
#             game.movelock = true
#             game.anim = :walkright
#         end
#     end

#     if input.up && input.B
#         game.n_anim = n_frame

#         if game.direction != :up
#             game.movelock = true
#             game.direction = :up
#             game.anim = :runturnup
#         elseif game.map.tilemap.collision[game.pos.h-Int32(1),game.pos.w] == 0x0000
#             game.movelock = true
#             game.anim = :runup
#         end
#     elseif false
#         0
#     end
# end


# function moveManager!(game::GameState,n_frame::UInt)
#     if game.anim == :walkturnup
#         if n_frame-game.n_anim < 0x04
#             game.spritecycle = 0x02
#         elseif n_frame-game.n_anim < 0x08
#             game.spritecycle = 0x01
#         elseif n_frame-game.n_anim >= 0x08
#             game.anim = :null
#             game.movelock = false
#         end
#     end

#     if game.anim == :walkup
#         n = n_frame-game.n_anim

#         game.screenoffset.h = -Int32(n)
#         game.spriteoffset.h = -Int32(n)

#         if n < 0x08
#             if game.pos.h%2 == 0
#                 game.spritecycle = 0x02
#             else
#                 game.spritecycle = 0x03
#             end
#         elseif n < 0x10
#             game.spritecycle = 0x01
#         elseif n >= 0x10
#             game.anim = :null
#             game.movelock = false
#             game.screenoffset.h = 0x00
#             game.spriteoffset.h = 0x00
#             game.pos.h -= Int32(1)
#         end
#     end


    
#     if game.anim == :walkturndown
#         if n_frame-game.n_anim < 0x04
#             game.spritecycle = 0x02
#         elseif n_frame-game.n_anim < 0x08
#             game.spritecycle = 0x01
#         elseif n_frame-game.n_anim >= 0x8
#             game.anim = :null
#             game.movelock = false
#         end
#     end

#     if game.anim == :walkdown
#         n = n_frame-game.n_anim

#         game.screenoffset.h = +Int32(n)
#         game.spriteoffset.h = +Int32(n)

#         if n < 0x08
#             if game.pos.h%2 == 0
#                 game.spritecycle = 0x02
#             else
#                 game.spritecycle = 0x03
#             end
#         elseif n < 0x10
#             game.spritecycle = 0x01
#         elseif n >= 0x10
#             game.anim = :null
#             game.movelock = false
#             game.screenoffset.h = 0x00
#             game.spriteoffset.h = 0x00
#             game.pos.h += Int32(1)
#         end
#     end


    
#     if game.anim == :walkturnleft
#         if n_frame-game.n_anim < 0x04
#             game.spritecycle = 0x02
#         elseif n_frame-game.n_anim < 0x08
#             game.spritecycle = 0x01
#         elseif n_frame-game.n_anim >= 0x08
#             game.anim = :null
#             game.movelock = false
#         end
#     end

#     if game.anim == :walkleft
#         n = n_frame-game.n_anim

#         game.screenoffset.w = -Int32(n)
#         game.spriteoffset.w = -Int32(n)

#         if n < 0x08
#             if game.pos.w%2 == 0
#                 game.spritecycle = 0x02
#             else
#                 game.spritecycle = 0x03
#             end
#         elseif n < 0x10
#             game.spritecycle = 0x01
#         elseif n >= 0x10
#             game.anim = :null
#             game.movelock = false
#             game.screenoffset.w = 0x00
#             game.spriteoffset.w = 0x00
#             game.pos.w -= Int32(1)
#         end
#     end

    

#     if game.anim == :walkturnright
#         if n_frame-game.n_anim < 0x04
#             game.spritecycle = 0x02
#         elseif n_frame-game.n_anim < 0x08
#             game.spritecycle = 0x01
#         elseif n_frame-game.n_anim >= 0x08
#             game.anim = :null
#             game.movelock = false
#         end
#     end

#     if game.anim == :walkright
#         n = n_frame-game.n_anim

#         game.screenoffset.w = +Int32(n)
#         game.spriteoffset.w = +Int32(n)

#         if n < 0x08
#             if game.pos.w%2 == 0
#                 game.spritecycle = 0x02
#             else
#                 game.spritecycle = 0x03
#             end
#         elseif n < 0x10
#             game.spritecycle = 0x01
#         elseif n >= 0x10
#             game.anim = :null
#             game.movelock = false
#             game.screenoffset.w = 0x00
#             game.spriteoffset.w = 0x00
#             game.pos.w += Int32(1)
#         end
#     end



#     if game.anim == :runturnup
#         if n_frame-game.n_anim < 0x04
#             game.spritecycle = 0x02
#         elseif n_frame-game.n_anim < 0x08
#             game.spritecycle = 0x01
#         elseif n_frame-game.n_anim >= 0x08
#             game.anim = :null
#             game.movelock = false
#         end
#     end

#     if game.anim == :runup
#         n = n_frame-game.n_anim
#         game.transport = :run

#         game.screenoffset.h = -Int32(2*n)
#         game.spriteoffset.h = -Int32(2*n)

#         if n < 0x04
#             if game.pos.h%2 == 0
#                 game.spritecycle = 0x02
#             else
#                 game.spritecycle = 0x03
#             end
#         elseif n < 0x08
#             game.spritecycle = 0x01
#         elseif n >= 0x08
#             game.anim = :null
#             game.movelock = false
#             game.screenoffset.h = 0x00
#             game.spriteoffset.h = 0x00
#             game.transport = :walk
#             game.pos.h -= Int32(1)
#         end
#     end
# end



# function combineLayers(layers::Layers,key::Vector{Symbol};
#     s::Settings=Settings())
#     L = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
#         UInt16(s.Nw)*UInt16(s.tilesize))

#     for k in key
#         ind = getfield(layers,k) .!= 0x000000
#         L[ind] = getfield(layers,k)[ind]
#     end

#     return L
#     end

#     function combineLayers(game::GameState; s::Settings=Settings())
#     L = zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
#         UInt16(s.Nw)*UInt16(s.tilesize))

#     for k in game.im.draw
#         ind = getfield(game.im.layers,k) .!= 0x000000
#         L[ind] = getfield(game.im.layers,k)[ind]
#     end

#     return L
# end



# function drawLayers!(layers::Layers,key::Vector{Symbol},game::GameState;
#     s=Settings())

#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     for k in key
#         for i in 1:s.Nh, j in 1:s.Nw
#             getfield(layers,k)[1+(i-1)*s.tilesize:i*s.tilesize,
#                 1+(j-1)*s.tilesize:j*s.tilesize] = game.map.tiles[
#                     getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
#                     game.pos.w+j-dw-1]]
#         end
#     end
# end

# function updateLayers!(layers::Layers,key::Vector{Symbol},game::GameState,
#     direction::NamedTuple{(:h,:w),Tuple{Int8,Int8}}; s=Settings())

#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     for k in key
#         if direction.h == 1
#             getfield(layers,k)[1:end-s.tilesize,:] = getfield(layers,k)[1+s.tilesize:end,:]

#             for i in 1:s.Nw
#                 getfield(layers,k)[end-s.tilesize+1:end,1+(i-1)*s.tilesize:i*s.tilesize] = 
#                     game.map.tiles[getfield(game.map.tilemap,k)[game.pos.h+dh,
#                     game.pos.w+i-dw-1]]
#             end
#         elseif direction.h == -1
#             getfield(layers,k)[1+s.tilesize:end,:] = getfield(layers,k)[1:end-s.tilesize,:]
            
#             for i in 1:s.Nw
#                 getfield(layers,k)[1:s.tilesize,1+(i-1)*s.tilesize:i*s.tilesize] = 
#                     game.map.tiles[getfield(game.map.tilemap,k)[game.pos.h-dh,
#                     game.pos.w+i-dw-1]]
#             end
#         end

#         if direction.w == 1
#             return
#         elseif direction.w == -1
#             return
#         end
#     end
# end




# function textBuffer(str::String,area::Tuple{UInt16,UInt16},dict::Dict)
#     height = size(dict[str[1]])[2]

#     S = split(str,"\n")

#     tb = permutedims(zeros(UInt32,area),(2,1))
#     for i in eachindex(S)
#         vert::UInt16 = 0x0001
#         for c in collect(S[i])
#             char = dict[c]
#             width = UInt16(size(char)[1])
            
#             tb[vert:vert+width-0x01,
#                         UInt16(1+height*(i-1)):UInt16(height*i)] = char
#             vert += width - 0x01
#         end
#     end
    
#     return tb
# end



# function onpresstest(args...)
#     for a in args
#         print(a,", ")
#     end

#     println()

#     return nothing
# end

# mutable struct Input
#     input::Bool

#     A::Bool
#     A_::Bool
#     B::Bool
#     B_::Bool

#     L::Bool
#     L_::Bool
#     R::Bool
#     R_::Bool

#     up::Bool
#     up_::Bool
#     down::Bool
#     down_::Bool
#     left::Bool
#     left_::Bool
#     right::Bool
#     right_::Bool

#     start::Bool
#     start_::Bool
#     select::Bool
#     select_::Bool

#     function Input()
#         new(falses(length(fieldnames(Input)))...)
#     end
# end

# ctrls_ = Base.ImmutableDict(
#     MiniFB.KB_KEY_SPACE => :A_,
#     MiniFB.KB_KEY_ENTER => :A_,

#     MiniFB.KB_KEY_LEFT_CONTROL => :B_,
#     MiniFB.KB_KEY_LEFT_SHIFT => :B_,
#     MiniFB.KB_KEY_BACKSPACE => :B_,

#     MiniFB.KB_KEY_Q => :L_,

#     MiniFB.KB_KEY_E => :R_,

#     MiniFB.KB_KEY_W => :up_,
#     MiniFB.KB_KEY_UP => :up_,

#     MiniFB.KB_KEY_S => :down_,
#     MiniFB.KB_KEY_DOWN => :down_,

#     MiniFB.KB_KEY_A => :left_,
#     MiniFB.KB_KEY_LEFT => :left_,

#     MiniFB.KB_KEY_D => :right_,
#     MiniFB.KB_KEY_RIGHT => :right_,

#     MiniFB.KB_KEY_X => :start_,

#     MiniFB.KB_KEY_Y => :select_,
# )

# function onpress(window, button, mod, isPressed)::Cvoid
#     global input

#     if Bool(isPressed)
#         c = get(ctrls,button,:null)

#         if c != :null
#             setfield!(input,c,true)
#             #setfield!(input,get(ctrls_,button,:null),false)
#         end
#     else
#         c = get(ctrls,button,:null)

#         if c != :null
#             setfield!(input,c,false)
#             #setfield!(input,get(ctrls_,button,:null),true)
#         end
#     end

#     return nothing
# end

# mutable struct Inp
#     p::Bool
#     _p::Bool
#     p_::Bool

#     function Inp()
#         new(false,false,false)
#     end

#     function Inp(p::Bool,_p::Bool,p_::Bool)
#         new(p,_p,p_)
#     end

#     function Inp(_p::Bool,p_::Bool)
#         new(true,_p,p_)
#     end
# end

# mutable struct Input
#     input::Bool
#     _input::Bool
#     input_::Bool

#     A::Bool
#     _A::Bool
#     A_::Bool
#     B::Bool
#     _B::Bool
#     B_::Bool

#     L::Bool
#     _L::Bool
#     L_::Bool
#     R::Bool
#     _R::Bool
#     R_::Bool

#     up::Bool
#     _up::Bool
#     up_::Bool
#     down::Bool
#     _down::Bool
#     down_::Bool
#     left::Bool
#     _left::Bool
#     left_::Bool
#     right::Bool
#     _right::Bool
#     right_::Bool

#     start::Bool
#     _start::Bool
#     start_::Bool
#     select::Bool
#     _select::Bool
#     select_::Bool

#     function Input()
#         new([Inp() for _ in fieldnames(Input)]...)
#     end

#     function Input(p::Bool,_p::Bool,p_::Bool)
#         new([Inp(p,_p,p_) for _ in fieldnames(Input)]...)
#     end
# end


# function inputManager!(game::GameState,input::Input,n_frame::UInt)
#     if game.inputlock
#         return nothing
#     end

#     if !game.battle.active && !game.menu.menu && !game.movelock &&
#             (input.up || input.down || input.left || input.right)
        
#         inputdir = [:up,:down,:left,:right][[input.up,input.down,input.left,input.right]][1]
#         movepos = posAdd(game.pos,dirs[inputdir])
        
#         game.movelock = true
#         game.n_anim = n_frame

#         if !input.B && (game.transport == :walk || game.transport == :run)
#             game.transport = :walk
            
#             if game.direction != inputdir
#                 game.direction = inputdir
#                 game.moveFunc = moveTurn!
#             elseif game.map.tilemap.collision[movepos.h,movepos.w] != 0x0001
#                 game.moveFunc = moveWalk!
#             else
#                 game.moveFunc = moveWalkWall!
#             end
#         elseif input.B && (game.transport == :walk || game.transport == :run)
#             game.transport = :run
#             game.direction = inputdir

#             if game.map.tilemap.collision[movepos.h,movepos.w] != 0x0001
#                 game.moveFunc = moveRun!
#             else
#                 game.moveFunc = moveTurn!
#             end
#         end
#     elseif !game.battle.active && !game.menu.menu && !game.movelock 
#         game.transport = :walk
#     end

#     if !game.battle.active && !game.menu.menu && !game.menu.menu_ && input.start
#         game.movelock = true
#         game.menu.menu = true

#         drawFrame!(game,UInt(20),UInt(10),Position(24,176))
#         drawText!(game,"POKEDEX\nPOKEMON\nBEUTEL\nPOKENAV\n$(game.trainer.name)\
#             \nSICHERN\nOPTION\nBEENDEN",UInt(2),Position(38,194); lineoffset=1)
#         push!(game.im.draw,:menu)
#         push!(game.im.draw,:text)
#     elseif !game.battle.active && game.menu.menu && !game.menu.menu_ && !input.start
#         game.menu.menu_ = true
#     elseif !game.battle.active && game.menu.menu && game.menu.menu_ && (input.start || input.B)
#         game.movelock = false
#         game.menu.menu = false

#         filter!(x->x!=:menu,game.im.draw)
#         filter!(x->x!=:text,game.im.draw)
#     elseif !game.battle.active && !game.menu.menu && game.menu.menu_ && !input.start
#         game.menu.menu_ = false
#     end
# end


# function drawText!(game::GameState,str::String,style::UInt,pos::Position;
#     lineoffset=0)
# height = [13,16,17][style]

# S = split(str,"\n")

# for i in eachindex(S)
#     vert = 0
#     for c in collect(S[i])
#         char = game.im.font[style][c]
        
#         game.im.layers.text[
#             1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
#             vert+1+pos.w:vert+size(char)[2]+pos.w
#         ] = char
        
#         vert += size(char)[2]-1
#     end
# end
# end

# function getFont()
#     fontimg = load("im/font.png")

#     symbols1 = ""
#     symbols2 = "0123456789!?.-⋅~“”‘’♂♀€,×/®\
#             ABCDEFGHIJKLMNOPQRSTUVWXYZ\
#             abcdefghijklmnopqrstuvwxyz\
#             ▷:ÄÖÜäöü↑↓←→+ⓁⒶⒾⓃ_ "#=\
#             ①②③④⑤⑥⑦⑧⑨()⊚△⨉\
#             ÀÁÂÇÈÉËÌÍÏÒÓÔŒÙÚÛÑß\
#             àáâçèéêëìíîïòóôœùúûñ\
#             ᵒᵃᵉʳ&+🄻=;|¿¡%[]<>\
#             ⓟ⒫Ⓑ"=#
#     symbols3 = ""

#     key1 = Vector{Matrix{UInt16}}([])
#     key2 = Vector{Matrix{UInt16}}([
#         Matrix{UInt16}([
#             180 5;  #0
#             187 4;  #1
#             192 5;  #2
#             198 5;  #3
#             204 5;  #4
#             210 5;  #5
#             216 5;  #6
#             222 5;  #7
#             228 5;  #8
#             234 5;  #9
#             241 2;  #!
#             245 4;  #?
#             251 3;  #.
#             255 5;  #-
#             261 3;  #*
#             265 5;  #..
#             271 5;  #"l
#             277 5;  #"r
#             283 3;  #'l
#             287 3;  #'r
#             291 5;  #male
#             297 5;  #female
#             303 6;  #poke
#             310 3;  #,
#             314 6;  #x
#             321 5;  #/
#             327 8]),#re
#         Matrix{UInt16}([
#             180 5;  #A
#             186 5;  #B
#             192 5;  #C
#             198 5;  #D
#             204 5;  #E
#             210 5;  #F
#             216 5;  #G
#             222 5;  #H
#             228 4;  #I
#             233 5;  #J
#             239 5;  #K
#             245 5;  #L
#             251 5;  #M
#             257 5;  #N
#             263 5;  #O
#             269 5;  #P
#             275 5;  #Q
#             281 5;  #R
#             287 5;  #S
#             293 5;  #T
#             299 5;  #U
#             305 5;  #V
#             311 5;  #W
#             317 5;  #X
#             323 4;  #Y
#             328 5]),#Z
#         Matrix{UInt16}([
#             180 5;  #a
#             186 5;  #b
#             192 5;  #c
#             198 5;  #d
#             204 5;  #e
#             210 5;  #f
#             216 5;  #g
#             222 5;  #h
#             229 2;  #i
#             233 5;  #j
#             239 5;  #k
#             246 2;  #l
#             250 5;  #m
#             256 5;  #n
#             262 5;  #o
#             268 5;  #p
#             274 5;  #q
#             280 5;  #r
#             286 5;  #s
#             292 5;  #t
#             298 5;  #u
#             304 5;  #v
#             310 5;  #w
#             316 5;  #x
#             322 5;  #y
#             328 5]),#z
#         Matrix{UInt16}([
#             181 6;  #triangle right
#             189 3;  #:
#             193 5;  #Ä
#             199 5;  #Ö
#             205 5;  #Ü
#             211 5;  #ä
#             217 5;  #ö
#             223 5;  #ü
#             229 10; #arrow up
#             240 10; #arrow down
#             251 9;  #arrow left
#             263 9;  #arrow right
#             274 6;  #+
#             282 8;  #lv
#             291 10; #ap
#             302 8;  #id
#             311 10; #no
#             323 9;  #_
#             333 3]),
#     ])
#     key3 = Vector{Matrix{UInt16}}([])

#     f1 = Vector{Matrix{UInt32}}([])
#     f2 = Vector{Matrix{UInt32}}([])
#     f3 = Vector{Matrix{UInt32}}([])

#     for i in eachindex(key1)
#         k = key1[i]

#         for j in Array{UInt16}(1:size(k)[1])
#             push!(f1,
#                     mfb_rgb.(fontimg[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
#                     k[j,1]+0x01:k[j,1]+k[j,2]+0x01]))
#         end
#     end

#     for i in eachindex(key2)
#         k = key2[i]

#         for j in Array{UInt16}(1:size(k)[1])
#             push!(f2,mfb_rgb.(fontimg[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
#                     k[j,1]+0x01:k[j,1]+k[j,2]+0x01]))
#         end
#     end

#     for i in eachindex(key3)
#         k = key3[i]

#         for j in Array{UInt16}(1:size(k)[1])
#             push!(f3,mfb_rgb.(fontimg[0x01+0x10*(UInt16(i)-0x01):0x10*UInt16(i),
#                     k[j,1]+0x01:k[j,1]+k[j,2]+0x01]))
#         end
#     end
    
#     return Dict(zip(symbols1,f1)),Dict(zip(symbols2,f2)),Dict(zip(symbols3,f3))
# end

# function drawText!(game::GameState,layer::Symbol,str::String,style::UInt,pos::Position;
#         lineoffset=0)
#     height = [12,15,14][style]

#     S = split(str,"\n")

#     for i in eachindex(S)
#         vert = 0

#         for c in collect(S[i])
#             char = game.im.font[style][c]
#             ind = char .!= 0x000000
#             #println(ind)
            
#             getproperty(game.im.layers,layer)[
#                 1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
#                 vert+1+pos.w:vert+size(char)[2]+pos.w
#             #] = char
#             ][ind] = char[ind]
            
#             vert += size(char)[2]
#         end
#     end
# end

# function combineLayers!(game::GameState; s::Settings=Settings())
#     for k in game.im.draw
#         ind = getfield(game.im.layers,k) .!= 0x000000

#         game.im.layer[ind] = getfield(game.im.layers,k)[ind]
#     end
# end

# #=
# function drawText!(game::GameState,layer::Symbol,str::String,style::UInt,pos::Position;
#         lineoffset=0)
#     height = [12,15,14][style]

#     S = split(str,"\n")

#     for i in eachindex(S)
#         vert = 0

#         for c in collect(S[i])
#             char = game.im.font[style][c]
#             ind = char .== 0x000000
#             char[ind] = getproperty(game.im.layers,layer)[
#                 1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
#                 vert+1+pos.w:vert+size(char)[2]+pos.w
#             ][ind]
            
#             getproperty(game.im.layers,layer)[
#                 1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
#                 vert+1+pos.w:vert+size(char)[2]+pos.w
#             ] = char
            
#             vert += size(char)[2]
#         end
#     end
# end
# =#

# function constructFrame(game::GameState,height::UInt,width::UInt)
#     frame = ones(UInt32,height*8,width*8)*game.im.frames[1][5][1]

#     if height == 1 || width == 1
#         return error("Frame is too small.")
#     end

#     for i in 1:height, j in 1:width
#         if i != 1 && i != height && j != 1 && j != width
#             f = 5
#         elseif i == 1 && j == 1
#             f = 1
#         elseif i == 1 && j != 1 && j != width
#             f = 2
#         elseif i == 1 && j == width
#             f = 3
#         elseif i != 1 && i != height && j == 1
#             f = 4
#         elseif i != 1 && i != height && j == width
#             f = 6
#         elseif i == height && j == 1
#             f = 7
#         elseif i == height && j != 1 && j != width
#             f = 8
#         else
#             f = 9
#         end

#         frame[1+(i-1)*8:i*8,1+(j-1)*8:j*8] = game.im.frames[game.options.frame][f]
#     end

#     return frame
# end

# function drawFrame!(game::GameState,layer::Symbol,height::UInt,width::UInt,
#         offset::Position)
#     getfield(game.im.layers,layer)[1+offset.h:height*8+offset.h,
#         1+offset.w:width*8+offset.w] = constructFrame(game,height,width)
# end


# function drawText!(game::GameState,layer::Symbol,str::String,style::UInt,pos::Position;
#     lineoffset=0)

#     height = [12,15,14][style]

#     S = split(str,"\n")

#     for i in eachindex(S)
#         vert = 0

#         for c in collect(S[i])
#             char = game.im.font[style][c]
#             ind = char .!= 0x000000
            
#             getproperty(game.im.layers,layer)[CartesianIndices(
#                 (1+(height+lineoffset)*(i-1)+pos.h:i*(height)+pos.h+lineoffset*(i-1),
#                 vert+1+pos.w:vert+size(char)[2]+pos.w)
#             )[ind]] = char[ind]
            
#             vert += size(char)[2]
#         end
#     end
# end


# function drawMap!(game::GameState,n_frame::UInt; s=Settings())
#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     for k in game.map.environment  #:water,
#         for i in 1:s.Nh, j in 1:s.Nw
#             getfield(game.im.layers,k)[1+(i-1)*s.tilesize:i*s.tilesize,
#                 1+(j-1)*s.tilesize:j*s.tilesize] = game.map.tiles[
#                     getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
#                     game.pos.w+j-dw-1]]
#         end
#     end
# end

# function drawMap2!(game::GameState; s=Settings())
#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     for k in game.map.environment
#         for n in 1:(s.Nh*s.Nw)
#             game.im.tile = game.map.tiles[getfield(game.map.tilemap,k)[
#                 game.pos.h+(n-1)%s.Nh-dh,game.pos.w+div(n-1,s.Nw)-dw
#             ]]
#             for i in 1:(s.tilesize*s.tilesize)
#                 getfield(game.im.layers,k)[
#                     (h-1)*s.tilesize+(i-1)%s.tilesize+1,
#                     (w-1)*s.tilesize+div(j-1,s.tilesize)+1
#                 ] = game.im.tile[i,j]
#             end
#         end
#     end
# end


# function drawMap1!(game::GameState; s=Settings())
#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     @inbounds for k in game.map.environment
#         @inbounds for n in 1:(s.Nh*s.Nw)
#             game.im.tile = game.map.tiles[getfield(game.map.tilemap,k)[
#                 game.pos.h+(n-1)%s.Nh-dh,game.pos.w+div(n-1,s.Nw)-dw
#             ]]
#             @inbounds for i in eachindex(game.im.tile)
#                 getfield(game.im.layers,k)[
#                     ((n-1)%s.Nh-1)*s.tilesize+(i-1)%s.tilesize+1,
#                     (div(n-1,s.Nw)-1)*s.tilesize+div(i-1,s.tilesize)+1
#                 ] = game.im.tile[i]
#             end
#         end
#     end

#     return nothing
# end

# function combineLayers1!(game::GameState,layers::Vector{Symbol}; s::Settings=Settings())
#     for k in layers
#         ind = getfield(game.im.layers,k) .!= 0x000000

#         game.im.layer[ind] = getfield(game.im.layers,k)[ind]
#     end
# end



# function combineLayers2!(game::GameState,layers::Vector{Symbol};
#     s::Settings=Settings())

#     ls = game.im.l
#     l = game.im.layer

#     @inbounds for k in 1:size(l,3)
#         @inbounds for i in eachindex(l)
#             @views if ls[:,:,k][i] != 0x000000
#                 l[i] = ls[:,:,k][i]
#             end
#         end
#     end

#     return
# end

# function getFrames(set::String)
#     frames = mfb_rgb.(load("im/$set.png"))

#     return Dict{Int64,Array{UInt32,3}}(zip(collect(1:30),[
#         cat([frames[1+(i-1)*8+(rows-1)*8:i*8+(rows-1)*8,
#         1+(j-1)*8+(cols-1)*8:j*8+(cols-1)*8] for j in 1:3, i in 1:3][:]...; dims=3)
#             for cols in 1:10, rows in 1:3
#         ])
#     )
# end


# #=
# function getSpriteMain(set::String; s=Settings())
#     spriteset = mfb_rgb.(load("sprites/$set.png"))

#     key::Vector{Tuple{Int,Int,Int,Int,Int,Symbol}} = [
#         (1,1,32,16,3,:walkdown),
#         (1,17,32,16,3,:walkup),
#         (1,33,32,16,3,:walkleft),

#         (97,1,32,16,3,:rundown),
#         (97,17,32,16,3,:runup),
#         (97,33,32,16,3,:runleft),

#         (1,49,32,32,9,:bikedown),
#         (1,81,32,32,9,:bikeup),
#         (1,113,32,32,9,:bikeleft),

#         (1,145,32,32,2,:sitdown),
#         (1,177,32,32,2,:situp),
#         (1,209,32,32,2,:sitleft),

#         (97,145,32,32,2,:waterdown),
#         (97,177,32,32,2,:waterup),
#         (97,209,32,32,2,:waterleft),

#         (1,241,32,32,5,:pokeball),
    
#         (1,273,32,32,4,:fishdown),
#         (1,305,32,32,4,:fishup),
#         (1,337,32,32,4,:fishleft),

#         (1,369,32,32,1,:surfdown),
#         (1,401,32,32,1,:surfup),
#         (1,433,32,32,1,:surfleft),

#         (33,369,32,32,1,:divedown),
#         (33,401,32,32,1,:diveup),
#         (33,433,32,32,1,:diveleft),

#         (1,465,32,32,1,:flypkmn),
#         (1,497,64,64,4,:battlesprites),
#         (97,401,64,64,1,:battler)
#     ]

#     d =  Dict{Symbol,Vector{Matrix{UInt32}}}(zip([key[i][6] for i in eachindex(key)],
#         [[spriteset[key[i][1]+(j-1)*key[i][3]:key[i][1]+j*key[i][3]-1,
#             key[i][2]:key[i][2]+key[i][4]-1] for j in 1:key[i][5]] for i in eachindex(key)]))
    
#     d[:walkright] = reverse.(d[:walkleft]; dims=2)
#     d[:runright] = reverse.(d[:runleft]; dims=2)
#     d[:bikeright] = reverse.(d[:bikeleft]; dims=2)
#     d[:sitright] = reverse.(d[:sitleft]; dims=2)
#     d[:waterright] = reverse.(d[:waterleft]; dims=2)
#     d[:fishright] = reverse.(d[:fishleft]; dims=2)
#     d[:surfright] = reverse.(d[:surfleft]; dims=2)
#     d[:diveright] = reverse.(d[:diveleft]; dims=2)

#     return d
# end
# =#


    
# function drawSpriteMain!(layers::Layers,game::GameState; s=Settings())
#     #fix typestability
#     S = game.trainer.sprite[string(game.transport,game.direction)][game.spritecycle]

#     height,width = size(S)./s.tilesize
#     dh,dw = Int((s.Nh-1)/2),Int((s.Nw-1)/2)

#     layers.spriteshigh .= 0x000000
#     layers.spriteslow .= 0x000000

#     layers.spriteshigh[(dh-1)*s.tilesize+1+game.spriteoffset.h:dh*s.tilesize+game.spriteoffset.h,
#         Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
#         S[1:Int(s.tilesize*height/2),:]

#     layers.spriteshigh[dh*s.tilesize+1+game.spriteoffset.h:(dh+1)*s.tilesize+game.spriteoffset.h,
#         Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
#         S[Int(s.tilesize*height/2+1):end,:]
# end

# function drawSpriteMain!(game::GameState; s=Settings())
#     #fix typestability
#     S = game.trainer.sprite[string(game.transport,game.direction)][game.spritecycle]

#     height,width = size(S)./s.tilesize
#     dh,dw = Int((s.Nh-1)/2),Int((s.Nw-1)/2)

#     game.im.layers.spriteshigh .= 0x000000
#     game.im.layers.spriteslow .= 0x000000

#     game.im.layers.spriteshigh[(dh-1)*s.tilesize+1+game.spriteoffset.h:dh*s.tilesize+game.spriteoffset.h,
#         Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
#         S[1:Int(s.tilesize*height/2),:]

#     game.im.layers.spriteshigh[dh*s.tilesize+1+game.spriteoffset.h:(dh+1)*s.tilesize+game.spriteoffset.h,
#         Int(dw-0.5+width/2)*s.tilesize+1+game.spriteoffset.w:Int(dw-0.5+width/2+1)*s.tilesize+game.spriteoffset.w] =
#         S[Int(s.tilesize*height/2+1):end,:]
# end



# function inputManager_!(game::GameState,input::Input)
#     if game.inputlock
#         return
#     end

#     if !game.battle.active
#         if !game.menu.menu && !game.movelock &&
#                 (input.up || input.down || input.left || input.right)   #movement
            
#             inputdir = [:up,:down,:left,:right][[input.up,input.down,input.left,input.right]][1]
#             movepos = posAdd(game.pos,dirs[inputdir])
            
#             game.movelock = true
#             game.n.anim = 0

#             if !input.B && (game.transport == :walk || game.transport == :run)
#                 game.transport = :walk
                
#                 if game.direction != inputdir
#                     game.direction = inputdir
#                     game.moveFunc = moveTurn!
#                 elseif game.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable ||
#                         (game.map.tilemap.collision[movepos.h,movepos.w] >= 0x14 &&
#                         game.map.tilemap.collision[movepos.h,movepos.w] <= 0x3b)
#                     game.moveFunc = moveWalk!
#                 else
#                     game.moveFunc = moveWalkWall!
#                 end
#             elseif input.B && (game.transport == :walk || game.transport == :run)
#                 game.transport = :run
#                 game.direction = inputdir

#                 if game.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable ||
#                         (game.map.tilemap.collision[movepos.h,movepos.w] >= 0x14 &&
#                         game.map.tilemap.collision[movepos.h,movepos.w] <= 0x3b)
#                     game.moveFunc = moveRun!
#                 else
#                     game.moveFunc = moveTurn!
#                 end
#             end
#         elseif !game.menu.menu && !game.movelock 
#             game.transport = :walk
#         end

#         if !game.menu.menu && !game.dialogue.d && input._start  #menu opener
#             game.movelock = true
#             game.menu.menu = true
#         elseif game.menu.menu   #menu navigator
#             if game.menu.ow
#                 if input._down
#                     game.menu.select = (game.menu.select+0x01)%0x08
#                 elseif input._up
#                     game.menu.select = (game.menu.select-0x01)%0x08
#                 elseif input._A
#                     if game.menu.select == 0x00
#                         0
#                     elseif game.menu.select == 0x01
#                         game.menu.pkmn.open = true
#                         game.menu.ow = false
#                         game.im.layers.menu2 .= 0x000000
#                     elseif game.menu.select == 0x02
#                         game.menu.bags.open = true
#                         game.menu.ow = false
#                         game.im.layers.menu2 .= 0x000000
#                     elseif game.menu.select == 0x03
#                         0
#                     elseif game.menu.select == 0x04
#                         0
#                     elseif game.menu.select == 0x05
#                         0
#                     elseif game.menu.select == 0x06
#                         0
#                     else
#                         game.movelock = false
#                         game.menu.menu = false
#                         game.menu.select = 0x01
#                     end
#                 elseif (input._start || input._B) && !game.menu.pkmn.open &&
#                         !game.menu.bags.open
#                     game.movelock = false
#                     game.menu.menu = false
#                     game.menu.select = 0x01
#                 end
#             end

#             if game.menu.pdex.open  #pdex menu manager
#                 0
#             elseif game.menu.pkmn.open  #pkmn menu manager
#                 if input._A
#                     if game.menu.pkmn.select == length(game.trainer.pokemon)
#                         game.menu.pkmn.open = false
#                         game.menu.pkmn.select = 0x00
#                         game.menu.ow = true
#                     end
#                 elseif input._B
#                     game.menu.pkmn.open = false
#                     game.menu.pkmn.select = 0x00
#                     game.menu.ow = true
#                 elseif input._down
#                     if game.menu.pkmn.select == length(game.trainer.pokemon)
#                         game.menu.pkmn.select = 0x00
#                     else
#                         game.menu.pkmn.select += 0x01
#                     end
#                 elseif input._up
#                     if game.menu.pkmn.select == 0x00
#                         game.menu.pkmn.select = length(game.trainer.pokemon)
#                     else
#                         game.menu.pkmn.select -= 0x01
#                     end
#                 elseif input._left || input._right
#                     if game.menu.pkmn.select == 0x00
#                         game.menu.pkmn.select = 0x01
#                     else
#                         game.menu.pkmn.select = 0x00
#                     end
#                 end
#             elseif game.menu.bags.open
#                 if input._A
#                     0
#                 elseif input._B
#                     game.menu.bags.open = false
#                     game.menu.bags.select = 0x00
#                     game.menu.ow = true
#                 elseif input._down
#                     if game.menu.bags.select == 0x06
#                         game.menu.bags.select = 0x00
#                     else
#                         game.menu.bags.select += 0x01
#                     end
#                 elseif input._up
#                     if game.menu.bags.select == 0x00
#                         game.menu.bags.select = 0x06
#                     else
#                         game.menu.bags.select -= 0x01
#                     end
#                 elseif input._left
#                     if game.menu.bags.slot == 0x00
#                         game.menu.bags.slot = 0x04
#                     else
#                         game.menu.bags.slot -= 0x01
#                     end
#                 elseif input._right
#                     if game.menu.bags.slot == 0x04
#                         game.menu.bags.slot = 0x00
#                     else
#                         game.menu.bags.slot += 0x01
#                     end
#                 end
#             end
#         end

#         if !game.menu.menu && !game.movelock && input._A    #dialogue
#             mapAction!(game)
#         elseif game.dialogue.d && (input._A || input._B || input._down)
#             if game.dialogue.n < length(game.dialogue.str)
#                 game.dialogue.n += 0x01
#             else
#                 game.dialogue.d = false
#                 game.movelock = false
#                 game.dialogue.n = 0x01
#             end
#         end
#     else
#         0
#     end
# end


# function resetInput!()
#     global input

#     input._input = false
#     input.input_ = false

#     input._A = false
#     input.A_ = false
#     input._B = false
#     input.B_ = false

#     input._L = false
#     input.L_ = false
#     input._R = false
#     input.R_ = false

#     input._up = false
#     input.up_ = false
#     input._down = false
#     input.down_ = false
#     input._left = false
#     input.left_ = false
#     input._right = false
#     input.right_ = false

#     input._start = false
#     input.start_ = false
#     input._select = false
#     input.select_ = false
# end


# function drawMap!(game::GameState; s=Settings())
#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     for k in game.map.environment
#         @inbounds for i in 1:s.Nh, j in 1:s.Nw
#             getfield(game.im.layers,k)[1+(i-1)*s.tilesize:i*s.tilesize,
#                 1+(j-1)*s.tilesize:j*s.tilesize] = game.map.tiles[
#                     getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
#                     game.pos.w+j-dw-1]]
#         end
#     end
# end



# function drawMap_!(game::GameState; s=Settings())
#     dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

#     @inbounds for k in game.map.environment
#         vtm = getfield(game.map.tilemap,k)[
#             game.pos.h-dh:game.pos.h-dh+s.Nh-1,
#             game.pos.w-dw:game.pos.w-dw+s.Nw-1
#         ]

#         @inbounds for i in eachindex(vtm)
#             v = view(getfield(game.im.layers,k),
#                 1+(i-1)*s.tilesize:i*s.tilesize,
#                 1+(j-1)*s.tilesize:j*s.tilesize)
            
#             @inbounds for t in eachindex(v)
#                 v[i] = tile[i]
#             end
#         end
#     end
# end



# function damage(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
#     return floorProd(UInt16,
#         floorProd(UInt16,
#             (floor(UInt16,attacker.pkmn.level*2/5)+2),
#             basedamage(state,attacker,defender),
#             1/(50*defender.pkmn.stats.rv[state.attack.class == 1 ? 3 : 5])*
#                 getBuffMultiplier(defender.buffs[state.attack.class == 1 ? 2 : 4]),
#             dmgFactor1(state,attacker,defender),
#         )+2,
#         1+1*state.crit,
#         dmgFactor(3),
#         100-rand(0:15),
#         1+0.5*(attacker.pkmn.type==state.attack.type),
#         getEff(state,state.target),
#         F3
#     )
# end

# function dmgFactor1(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
#     return *(
#         1-0.5*(attacker.pkmn.status==0x01)*(state.attack.class==0x01),
#         1-0.5*(state.target == 1 ? state.env.reflect1 : state.env.reflect2)*
#             (state.attack.class==0x01),
#         1-0.5*(state.target == 1 ? state.env.screen1 : state.env.screen2)*
#             (state.attack.class==0x02),
#         1,  #2v2 factor (0.75 if atk hits mult targets)
#         1-0.5*((attack.type==0x03&&state.env.weather==0x02) ||
#             (attack.type==0x04&&state.env.weather==0x01)),
#         1+0.5*((attack.type==0x03&&state.env.weather==0x01) ||
#             (attack.type==0x04&&state.env.weather==0x02))
#     )
# end

# function dmgFactor2(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
#     return 1
# end

# function dmgFactor3(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
#     return *(
#         1-0.5*state.crit*false,  #felskern, filter + krit -> 0.5
#         1+0.2*state.crit.attacker.pkmn.item == 0xff, #expertengurt CHECK THIS
#         1+1*!state.crit*attacker.pkmn.ability == 0xffff, #aufwertung CHECK THIS
#         1-0.5*false #dmg reduct berry CHECK THIS
#     )
# end

# function basedamage(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
#     return floor(UInt16,
#         *(
#             attack.strength,
#             itemfactor(attacker,defender),
#             1+0.5*attacker.secstatus.righthand,
#             1+1*attacker.secstatus.charge,
#             1-0.5*state.env.mud*(state.attack.type==0x0c),
#             1-0.5*state.env.wet*(state.attack.type==0x03),
#             abilityfactor(attacker,defender)
#         )
#     )
# end


# function queueAttack!(game::GameState,state::BattleStateWild,attack::Attack,
#         target::Int,pkmn::Pkmn)
#     miss = getMiss(state,target)
#     crit = getCrit(state,target)
#     eff = getEff(state,target)

#     println(eff)

#     if target == 1
#         state.pkmn1.attack = attack
#         state.pkmn1.crit = crit
#         state.pkmn1.eff = eff
#         setDmgFactors!(state,state.pkmn1,state.pkmn2)
#         state.pkmn1.dmg = calcDamage(state.pkmn1.factors)
#         println(state.pkmn1.dmg)
#     else
#         state.pkmn2.attack = attack
#         state.pkmn2.crit = crit
#         state.pkmn2.eff = eff
#         setDmgFactors!(state,state.pkmn2,state.pkmn1)
#         state.pkmn2.dmg = calcDamage(state.pkmn2.factors)
#         println(state.pkmn2.dmg)
#     end

#     push!(state.queue,BattleAction(
#         :p1,120,getPkmnName(game,pkmn)*" setzt\\$(attack.name) ein.",banimEmpty!,0
#     ))

#     if miss
#         push!(state.queue,BattleAction(
#             :p1,120,"Die Attacke hat\\ihr Ziel verfehlt...",banimEmpty!,0
#         ))
#     elseif eff == 0
#         push!(state.queue,BattleAction(
#             :p1,120,"Es hat keine Wirkung...",banimEmpty!,0
#         ))
#     else
#         push!(state.queue,BattleAction(
#             :p1,60,"",bnoAnim!,target
#         ))

#         if crit
#             push!(state.queue,BattleAction(
#                 :p1,120,"Ein Volltreffer!",banimEmpty!,0
#             ))
#         end

        
#         if eff < 1
#             push!(state.queue,BattleAction(
#                 :p1,120,"Das ist nicht sehr effektiv...",banimEmpty!,0
#             ))
#         elseif eff > 1
#             push!(state.queue,BattleAction(
#                 :p1,120,"Das ist sehr effektiv!",banimEmpty!,0
#             ))
#         end
#     end
# end



# function getCrit(state::BattleState,target::Int)
#     cr = target == 1 ? state.pkmn2.pkmn.attacks[state.pkmn2.command.n].critrate : 
#         state.pkmn1.pkmn.attacks[state.pkmn1.command.n].critrate

#     br = target == 1 ? state.pkmn2.buffs[8] : state.pkmn1.buffs[8]

#     return rand() < (1/16,1/8,1/4,1/3,1/2)[clamp(cr+br,1,5)]
# end

# function getEff(state::BattleState,target::Int)
#     def = target == 1 ? state.pkmn1.pkmn : state.pkmn2.pkmn
#     att = target == 1 ? state.pkmn2.pkmn.attacks[state.pkmn2.command.n] : 
#         state.pkmn1.pkmn.attacks[state.pkmn1.command.n]
    
#     return typetable[att.type,def.type[1]]*
#         (def.type[2] != 0 ? typetable[att.type,def.type[2]] : 0x01//0x01)
# end


# function getMiss(state::BattleState,target::Int)::Bool
#     acc = target == 1 ? state.pkmn2.pkmn.attacks[state.pkmn2.command.n].accuracy : 
#         state.pkmn1.pkmn.attacks[state.pkmn1.command.n].accuracy

#     r = acc*getAccuracyMultiplier(state,target)*getAccuracyFactor(state,target)

#     return rand(1:100) > r
# end



# # function Base.pop!(a::ArrayList{Sprite})
# #     if a.idx == 0
# #         error("ArrayList is empty, can't pop element.")
# #     end

# #     a.data[a.idx] = Sprite()
# #     a.idx -= 1
# # end

# # function Base.pop!(a::ArrayList{Counter})
# #     if a.idx == 0
# #         error("ArrayList is empty, can't pop element.")
# #     end

# #     a.data[a.idx] = Counter()
# #     a.idx -= 1
# # end

# # function Base.pop!(a::ArrayList{CallbackFunction})
# #     if a.idx == 0
# #         error("ArrayList is empty, can't pop element.")
# #     end

# #     a.data[a.idx] = CallbackFunction()
# #     a.idx -= 1
# # end

# # function Base.pop!(a::ArrayList{BattleAction})
# #     if a.idx == 0
# #         error("ArrayList is empty, can't pop element.")
# #     end

# #     a.data[a.idx] = BattleAction()
# #     a.idx -= 1
# # end
# # function Base.popat!(a::ArrayList{Sprite},i::Int)
# #     if a.idx == 0
# #         error("ArrayList is empty, can't pop element.")
# #     elseif i < 1 || i > a.idx
# #         error("Invalid index, can't pop element.")
# #     end

# #     if i != a.idx
# #         a.data[i], a.data[a.idx] = a.data[a.idx], a.data[i]
# #     end

# #     a.data[a.idx] = Sprite()
# #     a.idx -= 1
# # end

# # function Base.popat!(a::ArrayList{Counter},i::Int)
# #     if a.idx == 0
# #         error("ArrayList is empty, can't pop element.")
# #     elseif i < 1 || i > a.idx
# #         error("Invalid index, can't pop element.")
# #     end

# #     if i != a.idx
# #         a.data[i], a.data[a.idx] = a.data[a.idx], a.data[i]
# #     end

# #     a.data[a.idx] = Counter()
# #     a.idx -= 1
# # end


# function queueSetup!(game::GameState,state::BattleStateWild)
#     p = getPriority(state)

#     state.pkmn1.attack = state.pkmn1.pkmn.attacks[state.pkmn1.command.n]
#     state.pkmn2.attack = state.pkmn2.pkmn.attacks[state.pkmn2.command.n]

#     if p[1] == 1
#         queueAttack!(game,state,state.pkmn1,state.pkmn2,2,:p1)
#         queueAttack!(game,state,state.pkmn2,state.pkmn1,1,:p2)
#     else
#         queueAttack!(game,state,state.pkmn2,state.pkmn1,1,:p2)
#         queueAttack!(game,state,state.pkmn1,state.pkmn2,2,:p1)
#     end

#     queueStatusCond!(state)
#     queueWeather!(state)
# end

# function queueAttack!(game::GameState,state::BattleState,
#         attacker::PkmnBattle,defender::PkmnBattle,target::Int,id::Symbol)
#     attacker.hit = getHit(state,attacker,defender)
#     attacker.crit = getCrit(attacker,defender)
#     attacker.eff = getEff(attacker,defender)

#     setDmgFactors!(state,attacker,defender)
#     attacker.dmg = calcDamage(attacker.factors)

#     println("$id D: ",attacker.dmg)
    
#     push!(state.queue,BattleAnimation(
#         id,120,getPkmnName(game,attacker.pkmn)*" setzt\\$(attacker.attack.name) ein.",
#         banimEmpty!,0
#     ))

#     if !attacker.hit
#         push!(state.queue,BattleAnimation(
#             id,120,"Die Attacke hat\\ihr Ziel verfehlt...",banimEmpty!,0
#         ))

#         return
#     elseif attacker.eff == 0
#         push!(state.queue,BattleAnimation(
#             id,120,"Es hat keine Wirkung...",banimEmpty!,0
#         ))

#         return
#     end

#     push!(state.queue,BattleAnimation(
#         id,60,"",bnoAnim!,target
#     ))

#     push!(state.queue,BattleAnimation(
#         id,48,"",bhpAnim!,target
#     ))

#     if attacker.crit
#         push!(state.queue,BattleAnimation(
#             id,120,"Ein Volltreffer!",banimEmpty!,0
#         ))
#     end

#     if attacker.eff < 1
#         push!(state.queue,BattleAnimation(
#             id,120,"Das ist nicht sehr effektiv...",banimEmpty!,0
#         ))
#     elseif attacker.eff > 1
#         push!(state.queue,BattleAnimation(
#             id,120,"Das ist sehr effektiv!",banimEmpty!,0
#         ))
#     end
# end


# # function Base.popat!(a::ArrayList,id::Symbol)
#     # if a.idx == 0
#     #     error("ArrayList is empty, can't pop element.")
#     # end

# #     a[id], a[a.idx] = a[a.idx], a[id]

# #     a[a.idx] = eltype(a.data).name.wrapper()
# #     a.idx -= 1
# # end

# # function Base.popat!(a::ArrayList,i::Int)   #DOES NOT RETAIN ORDERING
# #     if a.idx == 0
# #         error("ArrayList is empty, can't pop element.")
# #     elseif i < 1 || i > a.idx
# #         error("Invalid index, can't pop element.")
# #     end

# #     if i != a.idx
# #         a.data[i], a.data[a.idx] = a.data[a.idx], a.data[i]
# #     end

# #     a.data[a.idx] = eltype(a.data).name.wrapper()
# #     a.idx -= 1
# # end



# # function bxpAnim!(game::GameState,levelups::Int)
# #     createCC!(game,:xp,bxpAnim!,
# #         (
# #             Int(calcXpDrop1(game.battle.state,game.battle.state[1],game.battle.state[2])),
# #             xpFormulas(game.battle.state[1].pkmn.stats.level+1,game.battle.state[1].pkmn.xptype) - 
# #             game.battle.state[1].pkmn.stats.xp,
# #             levelups
# #         ); active=true)
# # end

# # function bxpAnim!(game::GameState,xpgain::Int,xpnext::Int,levelups::Int)
# #     p = game.battle.state.pkmn1.pkmn

# #     d = 0

# #     if levelups > 0
# #         d = xpFormulas(
# #             game.battle.state[1].pkmn.stats.level+levelups,
# #             game.battle.state[1].pkmn.xptype
# #         ) - xpFormulas(
# #             game.battle.state[1].pkmn.stats.level,game.battle.state[1].pkmn.xptype
# #         )
# #     end

# #     drawXpBar!(game,game.im.sprites[:tag1].im,
# #         getXpBar(p,trunc(Int,min(xpgain-d,xpnext)*game.n.c[:xp].c/64)),P(36,33))

# #     if game.n.c[:xp].c == 59
# #         if xpgain < xpnext
# #             p.stats.xp += UInt32(xpgain)
# #         elseif xpgain >= xpnext
# #             drawXpBar!(game,game.im.sprites[:tag1].im,0,P(36,33))
# #         elseif levelups > 0
# #             p.stats.xp += UInt32(xpgain)
# #             p.stats.level += UInt8(levelups)
# #         end

# #         killCC!(game,:xp)

# #         return
# #     end

# #     game.n.c[:xp].c += 1
# # end

# function drawMenuPkmn!(game::GameState)
    #     game.im.layers.menu1[24+1:24+160,16+1:16+240] = game.im.menupkmn["bg"]
        
    
    #     for i in eachindex(game.trainer.pokemon)
    #         if i == 1
    #             if game.menu.pkmn.select == 0x00
    #                 game.im.layers.menu1[24+24+1:24+24+49,
    #                     16+8+1:16+8+78] = game.im.menupkmn["slotmain1"]
                    
    #                 game.im.layers.menu2[24+16+1:24+16+24,
    #                     16+2+1:16+2+20] = game.im.menupkmn["ball1"]
    #             else
    #                 game.im.layers.menu1[24+24+1:24+24+49,
    #                     16+8+1:16+8+78] = game.im.menupkmn["slotmain0"]
                    
    #                 game.im.layers.menu2[24+16+1:24+16+24,
    #                     16+2+1:16+2+20] = game.im.menupkmn["ball0"]
    #             end
                
    #             drawText!(game,:menu1,pkmnName(game,game.trainer.pokemon[1])*"\\  Lv."*
    #                 string(game.trainer.pokemon[1].stats.level),UInt(1),
    #                 Position(24+34,16+34); lineoffset = -3)
                
    #             drawText!(game,:menu1,string(game.trainer.pokemon[1].stats.hp)*"/"*
    #                 string(game.trainer.pokemon[1].stats.rv[1]),UInt(1),
    #                 Position(24+60,16+58))
                
    #             drawHealthBar!(xxx,getHealthBar(game.trainer.pokemon[1]),
    #                 Position(24+58,16+33))
    #         else
    #             if game.menu.pkmn.select == UInt8(i-1)
    #                 game.im.layers.menu1[24+10+1+(i-2)*24:24+10+22+(i-2)*24,
    #                     16+96+1:16+96+142] = game.im.menupkmn["slotside1"]
                    
    #                 game.im.layers.menu2[24+9+1+(i-2)*24:24+9+24+(i-2)*24,
    #                     16+88+1:16+88+20] = game.im.menupkmn["ball1"]
    #             else
    #                 game.im.layers.menu1[24+10+1+(i-2)*24:24+10+22+(i-2)*24,
    #                     16+96+1:16+96+142] = game.im.menupkmn["slotside0"]
                    
    #                 game.im.layers.menu2[24+9+1+(i-2)*24:24+9+24+(i-2)*24,
    #                     16+88+1:16+88+20] = game.im.menupkmn["ball0"]
    #             end
                
    #             drawText!(game,:menu1,pkmnName(game,game.trainer.pokemon[i])*"\\  Lv."*
    #                 string(game.trainer.pokemon[i].stats.level),UInt(1),
    #                 Position(24+11+(i-2)*24,16+121); lineoffset = -3)
                
    #             drawText!(game,:menu1,string(game.trainer.pokemon[i].stats.hp)*"/"*
    #                 string(game.trainer.pokemon[i].stats.rv[1]),UInt(1),
    #                 Position(24+21+(i-2)*24,16+211))
    
    #             drawHealthBar!(xxx,getHealthBar(game.trainer.pokemon[i]),
    #                 Position(24+19+(i-2)*24,16+185))
    #         end
    #     end
    
    #     for i in length(game.trainer.pokemon)+1:6
    #         game.im.layers.menu1[24+10+1+(i-2)*24:24+10+22+(i-2)*24,
    #             16+96+1:16+96+142] = game.im.menupkmn["slotempty"]
    #     end
    
    #     if game.menu.pkmn.select == length(game.trainer.pokemon)
    #         game.im.layers.menu1[24+136+1:24+136+16,
    #             16+186+1:16+186+52] = game.im.menupkmn["exit1"]
            
    #         game.im.layers.menu2[24+132+1:24+132+24,
    #             16+184+1:16+184+20] = game.im.menupkmn["ball1"]
    #     else
    #         game.im.layers.menu1[24+136+1:24+136+16,
    #             16+186+1:16+186+52] = game.im.menupkmn["exit0"]
            
    #         game.im.layers.menu2[24+132+1:24+132+24,
    #             16+184+1:16+184+20] = game.im.menupkmn["ball0"]
    #     end
    
    #     drawFrame!(game,:menu2,UInt(4),UInt(23),Position(24+128,16))
    
    #     drawText!(game,:menu2,"Wähle ein Pokémon.",UInt(2),Position(24+136,24))
    #     drawText!(game,:menu2,"ZURUCK",UInt(1),Position(24+137,16+204))
    # end
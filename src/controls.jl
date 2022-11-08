using MiniFB

include("maps.jl")



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
        new([false for _ in fieldnames(Input)]...)
    end
end

ctrls = Base.ImmutableDict(
    MiniFB.KB_KEY_SPACE => :A,
    MiniFB.KB_KEY_ENTER => :A,

    MiniFB.KB_KEY_LEFT_CONTROL => :B,
    MiniFB.KB_KEY_LEFT_SHIFT => :B,
    MiniFB.KB_KEY_BACKSPACE => :B,

    MiniFB.KB_KEY_Q => :L,

    MiniFB.KB_KEY_E => :R,

    MiniFB.KB_KEY_W => :up,
    MiniFB.KB_KEY_UP => :up,

    MiniFB.KB_KEY_S => :down,
    MiniFB.KB_KEY_DOWN => :down,

    MiniFB.KB_KEY_A => :left,
    MiniFB.KB_KEY_LEFT => :left,

    MiniFB.KB_KEY_D => :right,
    MiniFB.KB_KEY_RIGHT => :right,

    MiniFB.KB_KEY_X => :start,

    MiniFB.KB_KEY_Y => :select,
)

_ctrls = Base.ImmutableDict(
    MiniFB.KB_KEY_SPACE => :_A,
    MiniFB.KB_KEY_ENTER => :_A,

    MiniFB.KB_KEY_LEFT_CONTROL => :_B,
    MiniFB.KB_KEY_LEFT_SHIFT => :_B,
    MiniFB.KB_KEY_BACKSPACE => :_B,

    MiniFB.KB_KEY_Q => :_L,

    MiniFB.KB_KEY_E => :_R,

    MiniFB.KB_KEY_W => :_up,
    MiniFB.KB_KEY_UP => :_up,

    MiniFB.KB_KEY_S => :_down,
    MiniFB.KB_KEY_DOWN => :_down,

    MiniFB.KB_KEY_A => :_left,
    MiniFB.KB_KEY_LEFT => :_left,

    MiniFB.KB_KEY_D => :_right,
    MiniFB.KB_KEY_RIGHT => :_right,

    MiniFB.KB_KEY_X => :_start,

    MiniFB.KB_KEY_Y => :_select,
)

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

dirs = Base.ImmutableDict(
    :up => Position(-1,0),
    :down => Position(1,0),
    :left => Position(0,-1),
    :right => Position(0,1),
    :null => Position(0,0)
)

mapid = Base.ImmutableDict(
    0x00 => map0,
    0x01 => map1
)



function onpress(window, button, mod, isPressed)::Cvoid
    global input

    if Bool(isPressed)
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,:input,true)
            setfield!(input,:_input,true)
            setfield!(input,c,true)
            setfield!(input,get(_ctrls,button,:null),true)
        end
    else
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,:input,false)
            setfield!(input,:input_,true)
            setfield!(input,c,false)
            setfield!(input,get(ctrls_,button,:null),true)
        end
    end

    return nothing
end

function resetInput!()
    global input

    input._input = false
    input.input_ = false

    input._A = false
    input.A_ = false
    input._B = false
    input.B_ = false

    input._L = false
    input.L_ = false
    input._R = false
    input.R_ = false

    input._up = false
    input.up_ = false
    input._down = false
    input.down_ = false
    input._left = false
    input.left_ = false
    input._right = false
    input.right_ = false

    input._start = false
    input.start_ = false
    input._select = false
    input.select_ = false
end



walkable::Vector{UInt16} = [0x0000,0x0005,0x00006,0x00007]
bikeable::Vector{UInt16} = [0x0000,0x0005,0x00006]
swimmable::Vector{UInt16} = [0x0002,0x0003]



function moveDont!(game::GameState,n_frame::UInt)
    return
end

function moveTurn!(game::GameState,n_frame::UInt)
    n = n_frame-game.n_anim

    if n < 0x04
        game.spritecycle = 0x02
    elseif n < 0x08
        game.spritecycle = 0x01
    elseif n == 0x08
        game.movelock = false
    elseif n > 0x08
        game.moveFunc = moveDont!
    end
end

function moveWalk!(game::GameState,n_frame::UInt)
    n = n_frame-game.n_anim

    game.screenoffset = posMult(Int32(n),dirs[game.direction])
    game.spriteoffset = posMult(Int32(n),dirs[game.direction])

    if n < 0x08
        if (game.pos.h%2 == 0 && game.pos.w%2 == 0) || (game.pos.h%2 == 1 && game.pos.w%2 == 1)
            game.spritecycle = 0x02
        else
            game.spritecycle = 0x03
        end
    elseif n < 0x10
        game.spritecycle = 0x01
    elseif n == 0x10
        game.movelock = false
        game.screenoffset = dirs[:null]
        game.spriteoffset = dirs[:null]
        game.pos = posAdd(game.pos,dirs[game.direction])
        game.moveFunc = moveDont!
    elseif n > 0x10
        0
    end
end

function moveWalkWall!(game::GameState,n_frame::UInt)
    n = n_frame-game.n_anim

    if n < 0x10
        if (game.pos.h%2 == 0 && game.pos.w%2 == 0) || (game.pos.h%2 == 1 && game.pos.w%2 == 1)
            game.spritecycle = 0x02
        else
            game.spritecycle = 0x03
        end
    elseif n < 0x20
        game.movelock = false
        game.spritecycle = 0x01
    elseif n == 0x20
        game.moveFunc = moveDont!
    end
end

function moveRun!(game::GameState,n_frame::UInt)
    n = n_frame-game.n_anim

    game.screenoffset = posMult(Int32(2*n),dirs[game.direction])
    game.spriteoffset = posMult(Int32(2*n),dirs[game.direction])

    if n < 0x04
        if game.pos.h%2 == 0
            game.spritecycle = 0x02
        else
            game.spritecycle = 0x03
        end
    elseif n < 0x08
        game.spritecycle = 0x01
    elseif n == 0x08
        game.movelock = false
        game.screenoffset = dirs[:null]
        game.spriteoffset = dirs[:null]
        game.pos = posAdd(game.pos,dirs[game.direction])
        game.moveFunc = moveDont!
    end
end

function inputManager!(game::GameState,input::Input,n_frame::UInt)
    if game.inputlock
        return nothing
    end

    if !game.battle.active  #movement
        if !game.menu.menu && !game.movelock &&
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
                elseif game.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable
                    game.moveFunc = moveWalk!
                else
                    game.moveFunc = moveWalkWall!
                end
            elseif input.B && (game.transport == :walk || game.transport == :run)
                game.transport = :run
                game.direction = inputdir

                if game.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable
                    game.moveFunc = moveRun!
                else
                    game.moveFunc = moveTurn!
                end
            end
        elseif !game.menu.menu && !game.movelock 
            game.transport = :walk
        end

        if !game.menu.menu && !game.dialogue.d && input.start_  #menu opener
            game.movelock = true
            game.menu.menu = true

            push!(game.im.draw,:menu)
        elseif game.menu.menu && (input.start_ || input.B_)
            game.movelock = false
            game.menu.menu = false

            filter!(x->x!=:menu,game.im.draw)
        end
    
        if game.menu.menu   #menu navigator
            if input._down
                #game.im.layers.textbox[38+(game.menu.select)*17:38+(game.menu.select+1)*17,
                #    186:192] .*= UInt32(0)
                game.menu.select = (game.menu.select+0x01)%0x08
            elseif input._up
                #game.im.layers.textbox[38+(game.menu.select)*17:38+(game.menu.select+1)*17,
                #    186:192] .*= UInt32(0)
                game.menu.select = (game.menu.select-0x01)%0x08
            end

            drawMenu!(game)

            if input._A
                if game.menu.select == 0x00
                    0
                elseif game.menu.select == 0x01
                    game.menu.pkmn.open = true

                    game.im.draw = [:menu1,:menu2,:menu3]
                elseif game.menu.select == 0x02
                    0
                elseif game.menu.select == 0x03
                    0
                elseif game.menu.select == 0x04
                    0
                elseif game.menu.select == 0x05
                    0
                elseif game.menu.select == 0x06
                    0
                else
                    game.movelock = false
                    game.menu.menu = false
        
                    filter!(x->x!=:menu,game.im.draw)
                end
            end
        end

        if game.menu.pdex.open  #pkmn menu manager
            0
        end

        if game.menu.pkmn.open  #pkmn menu manager
            0
        end

        if !game.menu.menu && !game.movelock && input._A    #dialogue
            mapAction!(game)
        elseif game.dialogue.d && (input._A || input._B || input._down)
            game.dialogue.d = false
            game.movelock = false

            filter!(x->x!=:textbox,game.im.draw)
        end
    else
        0
    end
end



function changeMap!(game::GameState,exit::Tuple{UInt8,Position})
    game.map = mapid[exit[1]]
    game.pos = posAdd(game.pos,exit[2])
end

function mapAction!(game::GameState)
    t = posAdd(game.pos,dirs[game.direction])
    tile = game.map.tilemap.collision[t.h,t.w]

    if tile ∈ [0x0000,0x0001,0x0005,0x0006,0x0007]
        return
    elseif tile >= 0x003c && tile <= 0x004f
        game.movelock = true
        game.dialogue.d = true
        drawDialogue!(game,game.map.signs[tile-0x003b][1])

        push!(game.im.draw,:textbox)
    end
end




function updateGame!(game::GameState,input::Input,n_frame::UInt; s=Settings())
    inputManager!(game,input,n_frame)

    if game.moveFunc != moveDont!
        game.moveFunc(game,n_frame)
    end

    if game.map.tilemap.collision[game.pos.h,game.pos.w] != 0x0000
        changeMap!(game,game.map.exits[game.map.tilemap.collision[game.pos.h,game.pos.w]-19])
    end
end

function drawGame!(game::GameState,n_frame::UInt; s=Settings())
    if game.menu.ow
        drawLayers!(game,n_frame; s=s)
        drawSpriteMain!(game; s=s)
    end

    combineLayers!(game; s=s)
end
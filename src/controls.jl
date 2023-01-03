#using MiniFB

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
    1 => Position(-1,0),    #up
    2 => Position(1,0),     #down
    3 => Position(0,-1),    #left
    4 => Position(0,1),     #right
    0 => Position(0,0)      #null
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

function checkWalkable(game::GameState,movepos::Position)
    return game.map.tilemap.collision[movepos.h,movepos.w] ∈ walkable ||
        (game.map.tilemap.collision[movepos.h,movepos.w] >= 0x14 &&
        game.map.tilemap.collision[movepos.h,movepos.w] <= 0x3b)
end

function checkEncounter!(game::GameState)
    if !(game.map.tilemap.collision[game.pos.h,game.pos.w] ∈ 0xc8:0xdb)
        return
    elseif rand(0x00:0xff) > 0x20e
        return
    end

    initBattleWild(game)

    game.animFunc = animBattleEntry(game)
end





function moveDont!(game::GameState)
    return
end

function moveTurn!(game::GameState,dir::Int)
    if game.n.c[:spritemain].c == 0x00
        updateSprite!(game.im.sprites[:main],(dir-1)*10+1)
    elseif game.n.c[:spritemain].c == 0x04
        updateSprite!(game.im.sprites[:main],(dir-1)*10+2)
    elseif game.n.c[:spritemain].c == 0x08
        updateSprite!(game.im.sprites[:main],(dir-1)*10+1)
        game.movelock = false

        killCallback!(game,:move)

        game.n.c[:spritemain].c = 0
        
        checkEncounter!(game)

        return
    end

    game.n.c[:spritemain].c += 0x01
end

function moveWalk!(game::GameState,dir::Int)
    game.screenoffset = posMult(Int32(game.n.c[:spritemain].c+1),dirs[dir])

    posAdd!(game.im.sprites[:main].pos,dirs[dir])

    if game.n.c[:spritemain].c == 0
        if (game.pos.h%2 == 0 && game.pos.w%2 == 0) || (game.pos.h%2 == 1 && game.pos.w%2 == 1)
            updateSprite!(game.im.sprites[:main],(dir-1)*10+2)
        else
            updateSprite!(game.im.sprites[:main],(dir-1)*10+3)
        end
    elseif game.n.c[:spritemain].c == 8
        updateSprite!(game.im.sprites[:main],(dir-1)*10+1)
    elseif game.n.c[:spritemain].c == 15
        game.screenoffset = dirs[0]
        posAdd!(game.im.sprites[:main].pos,posMult(-16,dirs[dir]))

        posAdd!(game.pos,dirs[dir])

        game.movelock = false

        killCallback!(game,:move)

        game.n.c[:spritemain].c = 0

        checkEncounter!(game)

        return
    end

    game.n.c[:spritemain].c += 1
end

function moveWall!(game::GameState,dir::Int,input::Input)
    if !(input.up || input.down || input.left || input.right)
        updateSprite!(game.im.sprites[:main],(dir-1)*10+1)

        killCallback!(game,:move)
        
        game.n.c[:spritemain].c = 0

        return
    end    

    if game.n.c[:spritemain].c%32 == 0
        if div(game.n.c[:spritemain].c,32)%2 == 0
            updateSprite!(game.im.sprites[:main],(dir-1)*10+2)
        else
            updateSprite!(game.im.sprites[:main],(dir-1)*10+3)
        end
    elseif game.n.c[:spritemain].c%32 == 15
        updateSprite!(game.im.sprites[:main],(dir-1)*10+1)
    end

    game.n.c[:spritemain].c += 1
end

function moveRun!(game::GameState,dir::Int,input::Input)
    game.screenoffset = posMult(Int32(2*(game.n.c[:spritemain].c+1)),dirs[dir])

    posAdd!(game.im.sprites[:main].pos,posMult(2,dirs[dir]))

    if game.n.c[:spritemain].c == 0
        if (game.pos.h%2 == 0 && game.pos.w%2 == 0) || (game.pos.h%2 == 1 && game.pos.w%2 == 1)
            updateSprite!(game.im.sprites[:main],(dir+3)*10+2)
        else
            updateSprite!(game.im.sprites[:main],(dir+3)*10+3)
        end
    elseif game.n.c[:spritemain].c == 4
        updateSprite!(game.im.sprites[:main],(dir+3)*10+1)
    elseif game.n.c[:spritemain].c == 7

        game.screenoffset = dirs[0]
        posAdd!(game.im.sprites[:main].pos,posMult(-16,dirs[dir]))

        posAdd!(game.pos,dirs[dir])

        game.movelock = false

        killCallback!(game,:move)

        game.n.c[:spritemain].c = 0

        checkEncounter!(game)

        return
    end

    game.n.c[:spritemain].c += 1
end





function inputManager!(game::GameState,input::Input)
    if game.inputlock
        return
    end

    if !game.battle.active
        inputMap!(game,input)
    else
        return
    end
end

function inputMap!(game::GameState,input::Input)
    if !game.movelock && !game.menu.menu
        inputMove!(game::GameState,input::Input)
    end
end

function inputMove!(game::GameState,input::Input)
    if !(input.up || input.down || input.left || input.right)
        return
    end

    dir = findfirst([input.up,input.down,input.left,input.right])
    movepos = posAdd(game.pos,dirs[dir])

    if !checkWalkable(game,movepos)
        if game.n.c[:spritemain].c == 0
            createCallback!(game,:move,moveWall!,(dir,input))
        end

        return
    end

    if game.n.c[:spritemain].c != 0
        killCallback!(game,:move)
        game.n.c[:spritemain].c = 0
    end

    game.movelock = true

    if !input.B
        if game.direction == dir
            createCallback!(game,:move,moveWalk!,(dir,))
        else
            game.direction = dir
            createCallback!(game,:move,moveTurn!,(dir,))
        end
    else
        game.direction = dir
        createCallback!(game,:move,moveRun!,(dir,input))
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
        game.dialogue.str = game.map.signs[tile-0x003b]
    end
end





function updateGame!(game::GameState,input::Input; s=Settings())
    inputManager!(game,input)

    for i in 1:game.callbacks.idx
        game.callbacks[i].func(game,game.callbacks[i].args...)
    end

    if game.map.tilemap.collision[game.pos.h,game.pos.w] != 0x0000
        changeMap!(game,game.map.exits[game.map.tilemap.collision[game.pos.h,game.pos.w]-19])
    end
end

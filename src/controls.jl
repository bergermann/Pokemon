using MiniFB



mutable struct Input
    input::Bool

    A::Bool
    B::Bool

    L::Bool
    R::Bool

    up::Bool
    down::Bool
    left::Bool
    right::Bool

    start::Bool
    select::Bool

    function Input()
        new(falses(length(fieldnames(Input)))...)
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

dirs = Base.ImmutableDict(
    :up => Position(-1,0),
    :down => Position(1,0),
    :left => Position(0,-1),
    :right => Position(0,1),
    :null => Position(0,0)
)



function onpress(window, button, mod, isPressed)::Cvoid
    global input

    if Bool(isPressed)
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,c,true)
        end
    else
        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,c,false)
        end
    end

    return nothing
end

function onpresstest(args...)
    for a in args
        print(a,", ")
    end

    println()

    return nothing
end



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

    if !game.battle.active && !game.menu.menu && !game.movelock &&
            (input.up || input.down || input.left || input.right)
        
        inputdir = [:up,:down,:left,:right][[input.up,input.down,input.left,input.right]][1]
        movepos = posAdd(game.pos,dirs[inputdir])
        
        game.movelock = true
        game.n_anim = n_frame

        if game.direction != inputdir
            game.direction = inputdir
            game.moveFunc = moveTurn!
        elseif !input.B && (game.transport == :walk || game.transport == :run)
            game.transport = :walk
            if game.map.tilemap.collision[movepos.h,movepos.w] == 0x0000
                game.moveFunc = moveWalk!
            else
                game.moveFunc = moveWalkWall!
            end
        elseif input.B && (game.transport == :walk || game.transport == :run)
            game.transport = :run
            if game.map.tilemap.collision[movepos.h,movepos.w] == 0x0000
                game.moveFunc = moveRun!
            else
                game.moveFunc = moveTurn!
            end
        end
    elseif !game.battle.active && !game.menu.menu && !game.movelock 
        game.transport = :walk
    end

end



function updateGame!(game::GameState,input::Input,n_frame::UInt; s=settings())
    inputManager!(game,input,n_frame)

    if game.moveFunc != moveDont!
        game.moveFunc(game,n_frame)
    end
end
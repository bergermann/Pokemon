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

function onpress(window, button, mod, isPressed)::Cvoid
    global input

    if Bool(isPressed)

        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,c,true)
        end
    end

    return nothing
end

function updateGame!(game::GameState,input::Input,n_frame::UInt; s=settings())
    if game.inputlock
        return
    end

    if !game.movelock

        if input.up
            game.n_anim = n_frame

            if game.direction != :up
                game.movelock = true
                game.direction = :up
                game.anim = :walkturnup
            elseif game.map.tilemap.collision[game.pos.h-Int32(1),game.pos.w] == 0x0000
                game.movelock = true
                game.anim = :walkup
            end
        elseif input.down
            if game.map.tilemap.collision[game.pos.h+Int32(1),game.pos.w] == 0x0000
                game.pos.h += Int32(1)
            end
            game.direction = :down
        elseif input.left
            if game.map.tilemap.collision[game.pos.h,game.pos.w-Int32(1)] == 0x0000
                game.pos.w -= Int32(1)
            end
            game.direction = :left
        elseif input.right
            if game.map.tilemap.collision[game.pos.h,game.pos.w+Int32(1)] == 0x0000
                game.pos.w += Int32(1)
            end
            game.direction = :right
        end
    end

    if game.anim == :walkturnup
        if n_frame-game.n_anim < 0x0a
            game.spritecycle = 0x02
        elseif n_frame-game.n_anim < 0x14
            game.spritecycle = 0x01
        elseif n_frame-game.n_anim > 0x1e
            game.anim = :null
            game.movelock = false
        end
    end

    if game.anim == :walkup
        n = n_frame-game.n_anim
        game.screenoffset.h = -Int32(div(n,0x02))
        if n < 0x0a
            game.spritecycle = 0x02
        elseif n < 0x14
            game.spritecycle = 0x01
        elseif n > 0x20
            game.anim = :null
            game.movelock = false
            game.screenoffset.h = 0x00
            game.pos.h -= Int32(1)
        end
    end
end

function moveManager!()
    return
end
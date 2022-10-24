using MiniFB

mutable struct Input
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
    println(mod)
    if Bool(isPressed)
        println(button)

        c = get(ctrls,button,:null)

        if c != :null
            setfield!(input,c,true)
        end
    end

    return nothing
end
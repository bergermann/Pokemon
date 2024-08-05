

mutable struct Input
    press::Bool
    hold::Bool
end

mutable struct Inputs
    A::Input
    B::Input

    L::Input
    R::Input

    up::Input
    right::Input
    down::Input
    left::Input

    start::Input
    select::Input

    function Inputs()
        new([Input(false,false) for _ in fieldnames(Inputs)]...)
    end
end

const km = Base.ImmutableDict(
    GLFW.KEY_SPACE => :A,
    GLFW.KEY_ENTER => :A,

    GLFW.KEY_LEFT_CONTROL => :B,
    GLFW.KEY_LEFT_SHIFT => :B,
    GLFW.KEY_BACKSPACE => :B,

    GLFW.KEY_Q => :L,

    GLFW.KEY_E => :R,

    GLFW.KEY_W => :up,
    GLFW.KEY_UP => :up,

    GLFW.KEY_S => :down,
    GLFW.KEY_DOWN => :down,

    GLFW.KEY_A => :left,
    GLFW.KEY_LEFT => :left,

    GLFW.KEY_D => :right,
    GLFW.KEY_RIGHT => :right,

    GLFW.KEY_X => :start,

    GLFW.KEY_Y => :select 
)

function setupInputs(km)
    inputs = Inputs()

    d = Base.ImmutableDict(
        [key => getfield(inputs,input) for (key,input) in km]...
    )

    return inputs, d
end



mutable struct Dialogue
    d::Bool
    str::Vector{String}
    n::UInt8
    callback::Callback

    function Dialogue()
        new(false,[""],0x01,Callback())
    end
end



mutable struct MenuDex
    select::Int

    function MenuDex()
        new(1)
    end
end

mutable struct MenuPkmn
    select::Int

    swapping::Bool
    swap::Int
    # choice::Int

    sub::Bool
    # subslot::Int
    # submode::Int

    function MenuPkmn()
        new(1,false,0,false)
    end
end

mutable struct MenuNav
    select::Int

    function MenuNav()
        new(1)
    end
end

mutable struct MenuBags
    bag::Int
    select::Vector{Int}
    cursor::Vector{Int}

    function MenuBags()
        new(1,ones(5),ones(5))
    end
end

mutable struct MenuSelf
    select::Int

    function MenuSelf()
        new(1)
    end
end

mutable struct MenuSave
    select::Int

    function MenuSave()
        new(1)
    end
end

mutable struct MenuOpt
    select::Int

    function MenuOpt()
        new(1)
    end
end

mutable struct MenuBattle
    d::Bool
    m1::Bool
    s1::Integer
    m2::Bool
    s2::Integer
    bag::Bool
    bags::MenuBags

    function MenuBattle()
        new(false,false,0,false,0,false,MenuBags())
    end
end

mutable struct Menu
    main::Bool
    select::Int

    pdex::Bool
    menupdex::MenuDex
    pkmn::Bool
    menupkmn::MenuPkmn
    bags::Bool
    menubags::MenuBags
    pnav::Bool
    menupnav::MenuNav
    self::Bool
    menuself::MenuSelf
    save::Bool
    menusave::MenuSave
    optn::Bool
    menuoptn::MenuOpt

    function Menu()
        new(
            false,
            1,

            false,
            MenuDex(),
            false,
            MenuPkmn(),
            false,
            MenuBags(),
            false,
            MenuNav(),
            false,
            MenuSelf(),
            false,
            MenuSave(),
            false,
            MenuOpt()
        )
    end
end

mutable struct Choice
    active::Bool
    exit::Bool
    sel::Int
    max::Int

    layer::Integer

    func::Callback

    function Choice()
        new(false,false,0,0,6,Callback())
    end
end

mutable struct InputState
    inputlock::Bool
    textlock::Bool
    npclock::Bool

    map::Bool
    move::Bool

    menu::Menu

    choice::Choice

    dialogue::Bool

    battle::MenuBattle

    worldmap::Bool

    function InputState()
        new(
            false,
            false,
            false,

            false,
            false,

            Menu(),

            Choice(),

            false,

            MenuBattle(),

            false
        )
    end
end


const dirs = Base.ImmutableDict(
    0 => P( 0, 0),
    1 => P( 0,-1),
    2 => P( 1, 0),
    3 => P( 0, 1),
    4 => P(-1, 0),
)

function invdir(dir::Int)
    return (dir!=0)*((dir+1)%4+1)
end

function getdir(input::Input)::Int
    if input.up
        return 1
    elseif input.right
        return 2
    elseif input.down
        return 3
    else
        return 4
    end
end

mutable struct Controls
    pos1::Position
    pos2::Position
    mpos::Position
    height::Int
    chunk::Position
    dir::Int            # 1,2,3,4 = N,E,S,W

    input::InputState
    
    dialogue::Dialogue

    function Controls(x::Int,y::Int,h::Int,cx::Int,cy::Int,dir::Int)
        new(P(x,y),P(x,y),P(x,y),h,P(cx,cy),dir,InputState(),Dialogue())
    end
end
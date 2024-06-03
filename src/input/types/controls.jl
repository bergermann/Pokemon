



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

# ctrls = Base.ImmutableDict(
#     MiniFB.KB_KEY_SPACE => :A,
#     MiniFB.KB_KEY_ENTER => :A,

#     MiniFB.KB_KEY_LEFT_CONTROL => :B,
#     MiniFB.KB_KEY_LEFT_SHIFT => :B,
#     MiniFB.KB_KEY_BACKSPACE => :B,

#     MiniFB.KB_KEY_Q => :L,

#     MiniFB.KB_KEY_E => :R,

#     MiniFB.KB_KEY_W => :up,
#     MiniFB.KB_KEY_UP => :up,

#     MiniFB.KB_KEY_S => :down,
#     MiniFB.KB_KEY_DOWN => :down,

#     MiniFB.KB_KEY_A => :left,
#     MiniFB.KB_KEY_LEFT => :left,

#     MiniFB.KB_KEY_D => :right,
#     MiniFB.KB_KEY_RIGHT => :right,

#     MiniFB.KB_KEY_X => :start,

#     MiniFB.KB_KEY_Y => :select,
# )

# _ctrls = Base.ImmutableDict(
#     MiniFB.KB_KEY_SPACE => :_A,
#     MiniFB.KB_KEY_ENTER => :_A,

#     MiniFB.KB_KEY_LEFT_CONTROL => :_B,
#     MiniFB.KB_KEY_LEFT_SHIFT => :_B,
#     MiniFB.KB_KEY_BACKSPACE => :_B,

#     MiniFB.KB_KEY_Q => :_L,

#     MiniFB.KB_KEY_E => :_R,

#     MiniFB.KB_KEY_W => :_up,
#     MiniFB.KB_KEY_UP => :_up,

#     MiniFB.KB_KEY_S => :_down,
#     MiniFB.KB_KEY_DOWN => :_down,

#     MiniFB.KB_KEY_A => :_left,
#     MiniFB.KB_KEY_LEFT => :_left,

#     MiniFB.KB_KEY_D => :_right,
#     MiniFB.KB_KEY_RIGHT => :_right,

#     MiniFB.KB_KEY_X => :_start,

#     MiniFB.KB_KEY_Y => :_select,
# )

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
















mutable struct Dialogue
    d::Bool
    str::Vector{String}
    n::UInt8
    callback::CallbackFunction

    function Dialogue()
        new(false,[""],0x01,CallbackFunction())
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
    vis::Matrix{Int}
    slot::Int

    sub::Bool
    subslot::Int
    submode::Int

    function MenuBags()
        new(1,ones(5),zeros(8,2),0,false,0,0)
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
    select::Int

    function MenuBattle()
        new(0)
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

    func::Function
    args::Tuple

    function Choice()
        new(false,false,0,0,6,(() -> nothing),())
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

    battle::Bool
    battled::Bool
    battle1::Bool
    battle1menu::MenuBattle
    battle2::Bool
    battle2menu::MenuBattle
    battlebag::Bool
    battlebags::MenuBags

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

            false,
            false,
            false,
            MenuBattle(),
            false,
            MenuBattle(),
            false,
            MenuBags(),

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
    pos::Position
    mpos::Position
    chunk::Position
    dir::Int            # 1,2,3,4 = N,E,S,W

    input::InputState
    
    dialogue::Dialogue

    function Controls(h::Int,w::Int,ch::Int,cw::Int,dir::Int=2)
        new(P(h,w),P(h,w)+dirs[dir],P(ch,cw),dir,InputState(),Dialogue())
    end
end
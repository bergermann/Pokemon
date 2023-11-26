# core types for base functionality



mutable struct BattleAnimation
    id::Symbol

    l::Int
    str::String

    anim::Function
    target::Int

    function BattleAnimation()
        new(Symbol(),0,"",banimEmpty!,0)
    end

    function BattleAnimation(id,l,str,anim,target)
        new(id,l,str,anim,target)
    end
end

mutable struct BattleAction
    id::Symbol

    priority::Int
    init::Int

    user::Int
    target::Int

    function BattleAction()
        new(Symbol(),0,0,0,0)
    end

    function BattleAction(id,priority,init,user,target)
        new(id,priority,init,user,target)
    end
end




mutable struct PkmnData
    base::Matrix{UInt16}
    name::Vector{String}
    dex::Vector{String}

    function PkmnData()
        new(getStatsBase(),getNames("ger"),[])
    end
end

mutable struct Trainer
    name::String
    id::UInt16
    gender::UInt8

    pokemon::ArrayList{Pkmn}
    inventory::Inventory

    boxes::Array{ArrayList{Pkmn}}

    badges::Vector{UInt8}
    pokedex::Vector{Bool}
end

mutable struct MItem
    name::String
    description::String
    type::UInt8
end

mutable struct TItem
    name::String
    description::String
    type::UInt8
end

mutable struct KItem
    name::String
    description::String
    type::UInt8
end





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

    layer::Symbol

    func::Function
    args::Tuple

    function Choice()
        new(false,false,0,0,:layer6,(() -> nothing),())
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





abstract type BattleState end

mutable struct Battle
    active::Bool
    
    dialogue::Dialogue

    state::BattleState

    menu::MenuBattle

    teamperm::Vector{Int}

    function Battle()
        new(false,Dialogue(),BattleStateNone(),MenuBattle(),[])
    end
end

# battlestages:
# 1 - selection
# 10 - attack
# x - send first pokemon
# x - swap pokemon
# x - opponent send pokemon
# x - faint own
# x - faint opp
# x - weather
# x - damage own
# x - damage opp
# x - throw ball
# x - catch pending
# x - caught
# x - naming
# x - item own
# x - item opp
# 250 - flee

# 100 - intro dialogue
# 101 - victory dialogue
# 102 - defeat dialogue
# 103 - flee dialogue
# 104 - flee trainer dialogue
# 105 - flee fail dialogue 
# 110 - mid dialogue
# x - caught dialogue
# x - catch trainer dialogue






struct Settings
    width::UInt16
    height::UInt16
    fps::Float16

    Nh::UInt8
    Nw::UInt8
    tilesize::UInt8

    offseth::UInt16
    offsetw::UInt16

    function Settings()
        new(240,160,60,0x0d,0x11,0x10,0x0000,0x0000)
    end

    function Settings(width::UInt16,height::UInt16,fps::Float16,
            Nh::UInt8,Nw::UInt8,tilesize::UInt8,offseth::UInt16,offsetw::UInt16)
        new(width,height,fps,Nh,Nw,tilesize,offseth,offsetw)
    end
end

struct Options
    frame::UInt8
    diabox::UInt8
    battleanim::Bool

    lang::UInt8

    function Options()
        new(0x01,0x01,false,0x01)
    end
end




mutable struct Locks
    move::Bool
    input::Bool
    dialogue::Bool
    movenpc::Bool

    function Locks()
        new(false,false,false,false)
    end
end




abstract type NPC end

abstract type NPCNormal <: NPC end

abstract type NPCTrainer <:NPC end





mutable struct Flags
    general::BitVector
    progress::BitVector
    items::BitVector
    trainers::BitVector

    function Flags()
        new(falses(256),falses(256),falses(256),falses(256),)
    end
end






mutable struct GameState
    im::Im
    str::Vector{Vector{String}}
    pkmndata::PkmnData

    trainer::Trainer

    maps::Maps
    pos::Position
    movepos::Position
    direction::Int

    spriteoffset::Position
    screenoffset::Position

    n::Counters
    callbacks::ArrayList{CallbackFunction}

    dialogue::Dialogue

    overworld::Bool
    battle::Battle
    
    input::InputState
    draw::DrawState

    npcstatic::ArrayList{<:NPCNormal}
    npcmove::ArrayList{<:NPCNormal}
    # trainers::ArrayList{NPCTrainer}

    flags::Flags

    options::Options
end




# control related stuff


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



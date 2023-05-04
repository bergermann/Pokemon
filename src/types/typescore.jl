# core types for base functionality

mutable struct Position
    h::Int32
    w::Int32

    function Position()
        new(0,0)
    end

    function Position(h,w)
        new(h,w)
    end
end

Base.println(p::Position) = println("P($(p.h),$(p.w))")

const P = Position

function posAdd(a::Position,b::Position)
    return Position(a.h+b.h,a.w+b.w)
end

function posAdd!(a::Position,b::Position)
    a.h += b.h; a.w += b.w

    return
end

function posAdd!(p::Position,h::Int,w::Int)
    p.h += h; p.w += w

    return
end

function posSub(a::Position,b::Position)
    return Position(a.h-b.h,a.w-b.w)
end

function posSub!(a::Position,b::Position)
    a.h -= b.h; a.w -= b.w

    return
end

function posMult(p::Position,n::Signed)
    return Position(n*p.h,n*p.w)
end

function posMult!(p::Position,n::Signed)
    p.h *= n; p.w *= n

    return
end

function posAddMult!(a::Position,b::Position,n::Signed)
    a.h += b.h*n; a.w += b.w*n

    return
end

function setPos!(pos::Position,h::Int,w::Int)
    pos.h = h
    pos.w = w
end





mutable struct CallbackFunction
    id::Symbol

    active::Bool

    func::Function
    args::Tuple

    function CallbackFunction()
        new(Symbol(),false,emptyCallback,())
    end

    function CallbackFunction(id,func,args)
        new(id,true,func,args)
    end

    function CallbackFunction(id,active,func,args)
        new(id,active,func,args)
    end
end

mutable struct Counter
    id::Symbol
    c::Int

    function Counter(id::Symbol)
        new(id,0)
    end

    function Counter(id::Symbol,n::Int)
        new(id,n)
    end

    function Counter()
        new(Symbol(),0)
    end
end

mutable struct Sprite
    id::Symbol

    active::Bool

    hreverse::Bool
    vreverse::Bool

    layer::Symbol
    pos::Position
    size::Position

    frame::Int
    dict::Dict{Int,Tuple{Matrix{UInt32},Position}}

    im::Matrix{UInt32}

    function Sprite()
        new(
            Symbol(),

            false,

            false,
            false,

            Symbol(),
            Position(0,0),
            Position(0,0),

            0,
            Dict{Int,Tuple{Matrix{UInt32},Position}}(),

            zeros(UInt32,0,0)
        )
    end

    function Sprite(id,active,hreverse,vreverse,layer,pos,size,frame,dict,im)
        new(id,active,hreverse,vreverse,layer,pos,size,frame,dict,im)
    end

    function Sprite(id,layer,pos,dict)
        new(id,true,false,false,layer,pos,Position(0,0),0,dict,zeros(UInt32,0,0))
    end
end

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

mutable struct ArrayList{T}
    data::Vector{T}
    idx::Int

    function ArrayList(T::Type,n::Int)
        new{T}(Vector{T}(undef,n),0)
    end
end

function Base.getindex(a::ArrayList, inds...)
    return getindex(a.data, inds...)
end

function Base.setindex!(a::ArrayList, x, inds...)
    setindex!(a.data,x,inds...)
end

function Base.getindex(a::ArrayList,id::Symbol)
    return getindex(a.data, findfirst(x -> x.id==id, a.data))
end

function Base.setindex!(a::ArrayList, x, id::Symbol)
    return setindex!(a.data,x,findfirst(x -> x.id==id, a.data))
end

function Base.eachindex(a::ArrayList)
    return eachindex(a.data[1:a.idx])
end

function Base.push!(a::ArrayList, x)
    if a.idx >= length(a.data)           
        error("ArrayList is full, can't push new element.")
    end

    a.idx += 1
    a.data[a.idx] = x
end

function Base.pushfirst!(a::ArrayList,x)
    if a.idx >= length(a.data)
        error("ArrayList is full, can't push new element.")
    end

    a.idx += 1
    a.data[2:a.idx] = a.data[1:a.idx-1]
    a.data[1] = x
end

function pushat!(a::ArrayList,x,idx::Int)
    if a.idx >= length(a.data)
        error("ArrayList is full, can't push new element.")
    end

    a.idx += 1
    a.data[idx+1:a.idx] = a.data[idx:a.idx-1]
    a.data[idx] = x
end

function Base.pop!(a::ArrayList)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    a.data[a.idx] = eltype(a.data).name.wrapper()
    a.idx -= 1
end

function Base.popat!(a::ArrayList,id::Symbol)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    i = findfirst(x -> x.id==id, a.data[1:a.idx])
    a.data[i:a.idx-1] = a.data[i+1:a.idx]

    a[a.idx] = eltype(a.data).name.wrapper()

    a.idx -= 1
end

function Base.popat!(a::ArrayList,ids::Symbol...)
    for id in ids
        popat!(a,id)
    end
end

function Base.popat!(a::ArrayList,i::Int)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    elseif i < 1 || i > a.idx
        error("Invalid index, can't pop element.")
    end

    a[i] = eltype(a.data).name.wrapper()

    a.data[i:a.idx-1] = a.data[i+1:a.idx-1]
    a.idx -= 1
end

function popall!(a::ArrayList)
    for i in 1:a.idx
        a.data[i] = eltype(a.data).name.wrapper()
    end

    a.idx = 0
end

function Base.popfirst!(a::ArrayList)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    if a.idx == 1
        a.data[1] = eltype(a.data).name.wrapper()
        a.idx -= 1

        return
    end

    a.data[1:a.idx-1] = a.data[2:a.idx]
    a.data[a.idx] = eltype(a.data).name.wrapper()
    a.idx -= 1
end




function Base.print(a::ArrayList)
    println("")
    println("Type: ",eltype(a.data))
    println("Leng: ",a.idx)
    for i in 1:a.idx
        println(a.data[i])
    end
end

Base.println(a::ArrayList) = begin print(a); println("") end




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
    inventory::Vector   #placeholder

    badges::Vector{UInt8}
    pokedex::Vector{Bool}

    sprite::Dict{Int,Tuple{Matrix{UInt32},Position}}
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

mutable struct Inventory
    items::Array{Tuple{Item,UInt16}}
    medicine::Array{Tuple{MItem,UInt16}}
    balls::Array{Tuple{Pokeball,UInt16}}
    training::Array{Tuple{TItem,UInt16}}
    keys::Array{Tuple{KItem}}

    cash::UInt32
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
    swap::Int
    choice::Int

    function MenuPkmn()
        new(1,1,1)
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
    select::Int

    function MenuBags()
        new(1,1)
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

mutable struct InputState
    inputlock::Bool
    textlock::Bool
    npclock::Bool

    map::Bool
    move::Bool

    menu::Menu

    choice::Bool
    choicesel::Int

    dialogue::Bool

    battle::Bool
    battled::Bool
    battle1::Bool
    battle1menu::MenuBattle
    battle2::Bool
    battle2menu::MenuBattle

    worldmap::Bool

    function InputState()
        new(
            false,
            false,
            false,

            false,
            false,

            Menu(),

            false,
            1,

            false,

            false,
            false,
            false,
            MenuBattle(),
            false,
            MenuBattle(),

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

    function Battle()
        new(false,Dialogue(),BattleStateNone(),MenuBattle())
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

    function Options()
        new(0x01,0x01,false)
    end
end





mutable struct TileMap
    water::Matrix{UInt16}
    layer1::Matrix{UInt16}
    layer2::Matrix{UInt16}
    layer3::Matrix{UInt16}
    layer4::Matrix{UInt16}
    
    collision::Matrix{UInt16}

    function TileMap(; s::Settings=Settings())
        new([zeros(UInt32,s.Nh,s.Nw) for _ in eachindex(fieldnames(TileMap))]...)
    end
end

mutable struct Map
    id::UInt8
    environment::Vector{Symbol}
    path::String

    areas::Vector
    exits::Vector{Tuple{UInt8,Position}}  #(id,transform)
    tiles::Dict{UInt16,Matrix{UInt32}}
    tilemap::TileMap

    str::Vector{String}

    function Map(id::UInt8)
        new(
            id,                                                             # id
            [:layer1,:layer2,:layer3,:layer4],      # env
            "$id",                                                          # path

            [],                                                             # area
            [],                                                             # exits
            getTiles("tiles_exterior"),                                     # tiles
            getTileMap("$id",[:layer1,:layer2,:layer3,:layer4,:collision]), # tilemap
            
            loadMapStrings(id)                                              # str
        )
    end

    function Map(id,environment,path,areas,exits,tiles,tilemap,str)
        new(id,environment,path,areas,exits,tiles,tilemap,str)
    end
end



mutable struct DrawState
    map::Bool

    menu1::Bool

    pdex::Bool
    dexinfo::Bool

    pkmn::Bool
    pkmninfo::Bool

    bags::Bool

    pnav::Bool
    pnavinfo::Bool

    self::Bool

    save::Bool

    optn::Bool

    dialogue::Bool

    battleintro::Bool
    battleoutro::Bool
    battle::Bool
    battle1::Bool
    battle2::Bool
    battled::Bool

    worldmap::Bool

    sprites::Bool

    function DrawState()
        new([false for _ in eachindex(fieldnames(DrawState))]...)
    end
end

mutable struct Layer
    layer::Matrix{UInt32}
    active::Bool
    offset::Position

    function Layer(layer)
        new(layer,true,Position(0,0))
    end

    function Layer(layer,active,offset)
        new(layer,active,offset)
    end
end

mutable struct Layers
    water::Matrix{UInt32}
    layer1::Matrix{UInt32}
    layer2::Matrix{UInt32}
    layer3::Matrix{UInt32}
    layer4::Matrix{UInt32}
    layer5::Matrix{UInt32} #text?
    layer6::Matrix{UInt32}

    textbox::Matrix{UInt32}
    

    function Layers(; s::Settings=Settings())
        new([zeros(UInt32,UInt16(s.Nh)*UInt16(s.tilesize),
            UInt16(s.Nw)*UInt16(s.tilesize)) for _ in eachindex(fieldnames(Layers))]...)
    end
end

mutable struct Font
    fonts::Tuple{Dict,Dict,Dict}
    heights::Tuple{UInt,UInt,UInt}
    h_::UInt
    w_::UInt
    h::UInt
    w::UInt
    char::Matrix{UInt32}

    function Font()
        new(getFont(),(12,15,14),12,5,0,0,zeros(UInt32,15,5))
    end
end

mutable struct Frame
    frame::Dict{Int,Dict{Int,Matrix{UInt32}}}
end

mutable struct Im
    font::Font
    frames::Dict
    diabox::Dict

    tilesext::Dict
    tilesint::Dict
    tile::Matrix{UInt32}

    sprites::ArrayList{Sprite}

    L::Vector{Symbol}

    layers::Layers
    layer::Matrix{UInt32}

    weather::CallbackFunction
    postprocess::CallbackFunction

    function Im()
        new(
            Font(),
            getFrames("frames"),
            getDialogueBox("dialogue"),
            
            getTiles("tiles_exterior"),
            Dict(),
            zeros(UInt32,16,16),

            ArrayList(Sprite,128),

            [:layer1,:layer2,:layer3,:layer4,:layer5,:layer6,:textbox],

            Layers(),
            copy(Layers().layer1),

            CallbackFunction(:weather,false,empty,()),
            CallbackFunction(:pp,false,empty,())
        )
    end
end

mutable struct Counters
    frame::UInt
    c::ArrayList{Counter}

    function Counters(n::Int)
        new(0,ArrayList(Counter,n))
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









mutable struct GameState
    im::Im
    pkmndata::PkmnData

    trainer::Trainer

    map::Map
    pos::Position
    movepos::Position
    direction::Int

    spriteoffset::Position
    screenoffset::Position

    n::Counters
    callbacks::ArrayList{CallbackFunction}

    dialogue::Dialogue

    battle::Battle
    
    input::InputState
    draw::DrawState

    npcstatic::ArrayList{NPCStatic}
    npcmove::ArrayList{NPCMove}
    # trainers::ArrayList{NPCTrainer}

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



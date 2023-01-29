
include("pokemons.jl")



mutable struct Position
    h::Int32
    w::Int32
end

function posAdd(a::Position,b::Position)
    return Position(a.h+b.h,a.w+b.w)
end

function posAdd!(a::Position,b::Position)
    a.h += b.h; a.w += b.w

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
    dict::Dict{Int,Matrix{UInt32}}

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
            Dict{Int,Matrix{UInt32}}(),

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

mutable struct ArrayList{T}
    data::Vector{T}
    idx::Int

    function ArrayList(T::Type,n::Int)
        new{T}(Vector{T}(undef,n),0)
    end
end

function Base.getindex(A::ArrayList, inds...)
    return getindex(A.data, inds...)
end

function Base.setindex!(A::ArrayList, X, inds...)
    setindex!(A.data,X,inds...)
end

function Base.getindex(A::ArrayList,id::Symbol)
    return getindex(A.data, findfirst(x -> x.id==id, A.data[1:A.idx]))
end

function Base.setindex!(A::ArrayList, X, id::Symbol)
    return setindex!(A.data,X,findfirst(x -> x.id==id, A.data))
end

function Base.push!(a::ArrayList, x)
    if a.idx >= length(a.data)           
        error("ArrayList is full, can't push new element.")
    end

    a.idx += 1
    a.data[a.idx] = x
end

function Base.pop!(a::ArrayList{Sprite})
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    a.data[a.idx] = Sprite()
    a.idx -= 1
end

function Base.pop!(a::ArrayList{Counter})
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    a.data[a.idx] = Counter()
    a.idx -= 1
end

function Base.pop!(A::ArrayList{CallbackFunction})
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    a.data[a.idx] = CallbackFunction()
    a.idx -= 1
end





function Base.popat!(a::ArrayList{Sprite},i::Int)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    elseif i < 1 || i > a.idx
        error("Invalid index, can't pop element.")
    end

    if i != a.idx
        a.data[i], a.data[a.idx] = a.data[a.idx], a.data[i]
    end

    a.data[a.idx] = Sprite()
    a.idx -= 1
end

function Base.popat!(a::ArrayList{Counter},i::Int)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    elseif i < 1 || i > a.idx
        error("Invalid index, can't pop element.")
    end

    if i != a.idx
        a.data[i], a.data[a.idx] = a.data[a.idx], a.data[i]
    end

    a.data[a.idx] = Counter()
    a.idx -= 1
end

function Base.popat!(A::ArrayList{Counter},id::Symbol)
    A[id], A[A.idx] = A[A.idx], A[id]

    A[A.idx] = Counter()
    A.idx -= 1
end

function Base.popat!(A::ArrayList{CallbackFunction},id::Symbol)
    A[id], A[A.idx] = A[A.idx], A[id]

    A[A.idx] = CallbackFunction()
    A.idx -= 1
end





function quicksort!(A::Vector,lo::Int,hi::Int)
    if lo >= hi || lo < 0
        return
    end

    p = partition!(A,lo,hi)

    quicksort!(A,lo,p-1)
    quicksort!(A,p+1,hi)
end

function quicksort!(A::Vector,lo::Int,hi::Int,mask::Function)
    if lo >= hi || lo < 0
        return
    end

    p = partition!(A,lo,hi,mask)

    quicksort!(A,lo,p-1,mask)
    quicksort!(A,p+1,hi,mask)
end

function partition!(A::Vector,lo::Int,hi::Int)
    pivot = A[hi]

    i = lo-1

    @inbounds for j in lo:hi-1
        if A[j] <= pivot
            i += 1
            
            A[i], A[j] = A[j], A[i]
        end
    end

    i += 1

    A[i], A[hi] = A[hi], A[i]

    return i
end

function partition!(A::Vector,lo::Int,hi::Int,mask::Function)
    pivot = mask(A[hi])

    i = lo-1

    @inbounds for j in lo:hi-1
        if mask(A[j]) <= pivot
            i += 1
            
            A[i], A[j] = A[j], A[i]
        end
    end

    i += 1

    A[i], A[hi] = A[hi], A[i]

    return i
end

function sortHorizontal!(A::ArrayList{Sprite})
    quicksort!(A.data,1,A.idx,a->a.pos.h)
end

function sortVertical!(A::ArrayList{Sprite})
    quicksort!(A.data,1,A.idx,a->a.pos.w)
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

    pokemon::Vector{Pkmn}
    inventory::Vector   #placeholder

    badges::Vector{UInt8}
    pokedex::Vector{Bool}

    sprite::Dict{Int,Matrix{UInt32}}
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

    function Dialogue()
        new(false,[""],0x01)
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
    choice::Int

    function MenuPkmn()
        new(0,0)
    end
end

mutable struct MenuNav
    select::Int

    function MenuNav()
        new(0)
    end
end

mutable struct MenuBags
    bag::Int
    select::Int

    function MenuBags()
        new(0,0)
    end
end

mutable struct MenuSelf
    select::Int

    function MenuSelf()
        new(0)
    end
end

mutable struct MenuSave
    select::Int

    function MenuSave()
        new(0)
    end
end

mutable struct MenuOpt
    select::Int

    function MenuOpt()
        new(0)
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

            Menu(),

            false,
            1,

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

    function Options()
        new(0x01,0x01)
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

    signs::Vector{Vector{String}}

    npcs::Vector
    trainers::Vector

    function Map(id::UInt8)
        new(id,0,"$id",[],getTiles("tiles_exterior"),
            getTileMap("$id",[:layer1,:layer2,:layer3,:layer4,:collision]),
            [],[],[])
    end

    function Map(id::UInt8,environment::Vector{Symbol},path::String,areas::Vector,
            exits::Vector{Tuple{UInt8,Position}},tiles::Dict{UInt16,Matrix{UInt32}},
            tilemap::TileMap,signs::Vector{Vector{String}},npcs::Vector,
            trainers::Vector)

        new(id,environment,path,areas,exits,tiles,tilemap,signs,npcs,trainers)
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
    battle::Bool
    battle1::Bool
    battle2::Bool

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

    textbox::Matrix{UInt32}
    menu::Matrix{UInt32}
    menu1::Matrix{UInt32}
    menu2::Matrix{UInt32}
    menu3::Matrix{UInt32}
    
    #text::Matrix{UInt32}
    

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
    menupkmn::Dict
    inv::Dict

    tilesext::Dict
    tilesint::Dict
    tile::Matrix{UInt32}

    sprites::ArrayList{Sprite}

    layers::Layers
    layer::Matrix{UInt32}

    weather::CallbackFunction
    postprocess::CallbackFunction

    function Im()
        new(
            Font(),
            getFrames("frames"),
            getDialogueBox("dialogue"),
            getMenuPkmn(),
            getInventory(),
            
            getTiles("tiles_exterior"),
            Dict(),
            zeros(UInt32,16,16),

            ArrayList(Sprite,128),

            Layers(),
            copy(Layers().layer1),

            CallbackFunction(:pp,empty,()),
            CallbackFunction(:pp,empty,())
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
    dialoge::Bool
    movenpc::Bool

    function Locks()
        new(false,false,false,false)
    end
end

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

    options::Options
end





function emptyCallback(game::GameState)
    return
end

function createCounter!(game::GameState,id::Symbol)
    push!(game.n.c,Counter(id))
end

function createCounter!(game::GameState,id::Symbol,n::Int)
    push!(game.n.c,Counter(id,n))
end

function killCounter!(game::GameState,id::Symbol)
    popat!(game.n.c,id)
end

function createCallback!(game::GameState,id::Symbol,func::Function,args::Tuple)
    push!(game.callbacks,CallbackFunction(id,false,func,args))
end

function createCallback!(game::GameState,id::Symbol,active::Bool,func::Function,args::Tuple)
    push!(game.callbacks,CallbackFunction(id,active,func,args))
end

function killCallback!(game::GameState,id::Symbol)
    popat!(game.callbacks,id)
end

function createCC!(game::GameState,id::Symbol,func::Function,args::Tuple)
    createCounter!(game,id::Symbol)
    createCallback!(game,id,func,args)
end

function createCC!(game::GameState,idc::Symbol,idcb::Symbol,func::Function,args::Tuple)
    createCounter!(game,idc::Symbol)
    createCallback!(game,idcb,func,args)
end

function killCC!(game::GameState,id::Symbol)
    killCounter!(game,id)
    killCallback!(game,id)
end

function killCC!(game::GameState,idc::Symbol,idcb::Symbol)
    killCounter!(game,idc)
    killCallback!(game,idcb)
end
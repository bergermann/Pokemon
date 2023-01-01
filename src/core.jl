
include("pokemons.jl")



mutable struct Position
    h::Int32
    w::Int32
end

function posAdd(a::Position,b::Position)
    return Position(a.h+b.h,a.w+b.w)
end

function posSub(a::Position,b::Position)
    return Position(a.h-b.h,a.w-b.w)
end

function posMult(n::Int32,a::Position)
    return Position(n*a.h,n*a.w)
end




mutable struct Sprite
    id::Symbol

    layer::Symbol
    pos::Position
    size::Position

    frame::Symbol

    im::Dict{Symbol,Matrix{UInt32}}

    function Sprite()
        new(
            Symbol(),

            Symbol(),
            Position(0,0),
            Position(0,0),

            Symbol(),

            Dict{Symbol,Matrix{UInt32}}()
        )
    end

    function Sprite(id,pos,size,im)
        new(id,pos,size,im)
    end

    function Sprite(id,pos,im)
        new(id,pos,Position(size(im)...),im)
    end
end

mutable struct ArrayList{T}
    data::Vector{T}
    idx::Int

    function ArrayList(T,n::Int)
        new{T}(Vector{T}(undef,n),0)
    end
end

function Base.push!(a::ArrayList, x)
    if a.idx >= length(a.data)           
        error("ArrayList is full, can't push new element.")
    else
         a.idx += 1
         a.data[a.idx] = x
    end
end

function Base.pop!(a::ArrayList{Sprite})
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
        return
    end

    a.data[a.idx] = Sprite()
    a.idx -= 1
end

function Base.popat!(a::ArrayList{Sprite},i::Int)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
        return
    elseif i < 1 || i > a.idx
        error("Invalid index, can't pop element.")
    end

    if i != a.idx
        a.data[i], a.data[a.idx] = a.data[a.idx], a.data[i]
    end

    a.data[a.idx] = Sprite()
    a.idx -= 1
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

    sprite::Dict{String,Vector{Matrix{UInt32}}}
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
    open::Bool

    function MenuDex()
        new(false)
    end
end

mutable struct MenuPkmn
    open::Bool
    optn::Bool
    select::UInt8
    choice::UInt8

    function MenuPkmn()
        new(false,false,0x00,0x00)
    end
end

mutable struct MenuNav
    open::Bool

    function MenuNav()
        new(false)
    end
end

mutable struct MenuInv
    open::Bool
    optn::Bool
    slot::UInt8
    select::UInt8
    choice::UInt8

    function MenuInv()
        new(false,false,0x00,0x00,0x00)
    end
end

mutable struct MenuSelf
    open::Bool

    function MenuSelf()
        new(false)
    end
end

mutable struct MenuSave
    open::Bool

    function MenuSave()
        new(false)
    end
end

mutable struct MenuOpt
    open::Bool

    function MenuOpt()
        new(false)
    end
end

mutable struct MenuBattle
    row::UInt8
    col::UInt8
end

mutable struct Menu
    ow::Bool
    menu::Bool
    select::UInt8

    pdex::MenuDex
    pkmn::MenuPkmn
    pnav::MenuNav
    bags::MenuInv
    self::MenuSelf
    save::MenuSave
    optn::MenuOpt

    function Menu()
        new(true,false,0x01,MenuDex(),MenuPkmn(),MenuNav(),MenuInv(),MenuSelf(),
            MenuSave(),MenuOpt())
    end
end



mutable struct Battle
    active::Bool

    turn::UInt8
    menu::MenuBattle
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
    background1::Matrix{UInt16}
    background2::Matrix{UInt16}
    spriteslow::Matrix{UInt16}
    spriteshigh::Matrix{UInt16}
    foreground1::Matrix{UInt16}
    foreground2::Matrix{UInt16}
    
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
            getTileMap("$id",[:background1,:background2,:foreground1,:foreground2,:collision]),
            [],[],[])
    end

    function Map(id::UInt8,environment::Vector{Symbol},path::String,areas::Vector,
            exits::Vector{Tuple{UInt8,Position}},tiles::Dict{UInt16,Matrix{UInt32}},
            tilemap::TileMap,signs::Vector{Vector{String}},npcs::Vector,
            trainers::Vector)

        new(id,environment,path,areas,exits,tiles,tilemap,signs,npcs,trainers)
    end
end


mutable struct Layers
    water::Matrix{UInt32}
    background1::Matrix{UInt32}
    background2::Matrix{UInt32}
    spriteslow::Matrix{UInt32}
    spriteshigh::Matrix{UInt32}
    foreground1::Matrix{UInt32}
    foreground2::Matrix{UInt32}
    weather::Matrix{UInt32}

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

    spritesmain::Vector{Dict}
    spriteart::Dict
    tilesext::Dict
    tilesint::Dict
    tile::Matrix{UInt32}

    sprites::ArrayList{Sprite}

    layers::Layers
    layer::Matrix{UInt32}
    bitmap::BitMatrix

    function Im()
        new(
            Font(),
            getFrames("frames"),
            getDialogueBox("dialogue"),
            getMenuPkmn(),
            getInventory(),
            
            [getSpriteMain("sprite"),],
            Dict(),
            getTiles("tiles_exterior"),
            Dict(),
            zeros(UInt32,16,16),

            ArrayList(Sprite,128),

            Layers(),
            copy(Layers().background1),
            BitMatrix(undef,size(Layers().background1))
        )
    end
end

mutable struct Counters
    frame::UInt
    anim::UInt
    idle::UInt

    function Counters()
        new(0,0,0)
    end
end

mutable struct GameState
    im::Im
    pkmndata::PkmnData

    trainer::Trainer

    pos::Position
    transport::Symbol
    direction::Symbol
    spritecycle::UInt8
    spriteoffset::Position
    map::Map

    movelock::Bool
    textlock::Bool
    inputlock::Bool

    battle::Battle

    dialogue::Dialogue

    menu::Menu

    n::Counters
    moveFunc::Function
    animFunc::Function

    screenoffset::Position

    options::Options
end


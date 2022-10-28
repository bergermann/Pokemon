#

mutable struct Stats
    bv::Vector{UInt8}
    dv::Vector{UInt8}   #HP, At, Def, SpAt, SpDef, Init
    ev::Vector{UInt8}
    level::UInt8
    xp::UInt32

    nature::UInt8
end

mutable struct Attack
    name::String
    description::String

    power::UInt8
    accuracy::UInt8
end

mutable struct Item
    name::String
    description::String
    type::UInt8
end

struct Pokeball
    name::String
    description::String
    catchrate::Float64
    sprite
end

mutable struct Pkmn
    id::UInt16
    name::String
    gender::UInt8
    genderweight::Vector{UInt8} #sample(x,aweigths(w))
    shiny::Bool

    otrainer::String
    otrainerid::UInt16
    location::String
    ball::Pokeball
    markers::Vector{Bool}

    stats::Stats
    status::UInt8
    item::Item

    attacks::Vector{Attack}
    learnableup::Vector{Tuple{Attack,UInt8}}
    learnabletm::Vector{UInt8}
    learnableun::Vector{Attack}
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



mutable struct Menu
    menu::Bool
    pkdx::Bool
    pkmn::Bool
    pnav::Bool
    bags::Bool
    self::Bool
    save::Bool
    optn::Bool

    function Menu()
        new(falses(8)...)
    end
end

mutable struct MenuInv
    bag::UInt8
    slot::UInt8
end

mutable struct MenuPkmn
    slot::UInt8
    optn::UInt8
end

mutable struct MenuBattle
    row::UInt8
    col::UInt8
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
    environment::UInt8
    path::String

    size::Tuple{UInt16,UInt16}
    areas::Vector
    tiles::Dict{UInt16,Matrix{UInt32}}
    tilemap::TileMap

    npcs::Vector
    trainers::Vector

    function Map(id::UInt8,size::Tuple{UInt16,UInt16})
        new(id,0,"$id",size,[],getTiles("tiles_exterior"),
            getTileMap("$id",[:background1,:background2,:foreground1,:foreground2,:collision]),
            [],[])
    end
end

mutable struct GameState
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

    menu::Menu
    menuinv::MenuInv
    menupkmn::MenuPkmn

    n_anim::UInt64
    moveFunc::Function

    screenoffset::Position
end


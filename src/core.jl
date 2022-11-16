#include("rendering.jl")

mutable struct Stats
    bv::Vector{UInt8}
    dv::Vector{UInt8}   #HP, At, Def, SpAt, SpDef, Init
    ev::Vector{UInt8}
    level::UInt8
    xp::UInt32

    nature::UInt8
    
    maxhp::UInt16
    hp::UInt16
end

mutable struct Attack
    name::String
    description::String

    power::UInt8
    accuracy::UInt8

    effect::Function
end

mutable struct Item
    name::String
    description::String
    type::UInt8

    function Item()
        new("","",0x00)
    end
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

function getHealthBar(pokemon::Pkmn)
    return ceil(Int,48*pokemon.stats.hp/pokemon.stats.maxhp)
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
    bag::UInt8
    slot::UInt8
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
    environment::UInt8
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

    function Map(id::UInt8,environment::UInt8,path::String,areas::Vector,
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

mutable struct Im
    font::Vector{Dict}
    frames::Dict
    diabox::Dict
    menupkmn::Dict
    inv::Dict

    spritesmain::Vector{Dict}
    sprites::Dict
    tilesext::Dict
    tilesint::Dict

    layers::Layers
    layer::Matrix{UInt32}

    function Im()
        new([getFont()...],getFrames("frames"),getDialogueBox("dialogue"),
            getMenuPkmn(),getInventory(),[getSpriteMain("sprite"),],Dict(),
            getTiles("tiles_exterior"),Dict(),Layers(),copy(Layers().background1)
        )
    end
end

mutable struct GameState
    im::Im

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

    n_anim::UInt64
    moveFunc::Function

    screenoffset::Position

    options::Options
end


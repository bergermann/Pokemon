#list of pokemons

include("core.jl")
include("pokeballs.jl")

#=
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

mutable struct Stats
    bv::Vector{UInt8}
    dv::Vector{UInt8}   #HP, At, Def, SpAt, SpDef, Init
    ev::Vector{UInt8}
    level::UInt8
    xp::UInt32

    nature::UInt8
end
=#

p001 = Pkmn(
    UInt16(001),
    "Bisasam",
    UInt8(0),
    Vector{UInt8}([7,1,0]),
    false,

    "",
    UInt16(00000),
    "",
    pokeball,
    [false,false,false,false,false],

    Stats(Vector{UInt8}([45,49,49,65,65,45]),   #bv
            Vector{UInt8}([0,0,0,0,0,0]),       #dv
            Vector{UInt8}([0,0,0,0,0,0]),       #ev
            UInt8(0),                           #level
            UInt32(0),                          #xp
            UInt8(0)),                          #nature
    UInt8(0),
    Item(),
    
    Vector{Attack}([]),
    Vector{Tuple{Attack,UInt8}}([]),
    Vector{UInt8}([]),
    Vector{Attack}([])
)

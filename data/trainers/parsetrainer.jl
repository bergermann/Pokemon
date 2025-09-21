using JSON, Serialization

mutable struct Pkmn
    id::UInt16
    name::String
    gender::UInt8
    shiny::Bool
    form::UInt8
    xptype::UInt8

    otrainer::String
    otrainerid::UInt16
    location::String
    ball::UInt8
    markers::Vector{Bool}

    type::Tuple{UInt8,UInt8}
    stats::Stats
    status::UInt8
    item::Int

    attacks::Vector{Atk}
    ability::UInt16

    evolve::UInt16
end


mutable struct Trainer
    sprite::Int
    name::String
    ai::Int

    money::Int
    # prize::Array{Int}

    intro::String
    outro::String
    inter::String
    extro::String

    pokemon::Array{Pkmn}
end

for i in 1:1
    d = JSON.parsefile("data/trainers/jsons/1.json")

    serialize("data/trainers/$i.t",parseTrainer(d))
end

function parseTrainer(d::Dict)
    pkmn = Pkmn[]

    for p in d["pokemon"]
        push!(pkmn,parsePkmn(p))
    end

    return Trainer(
        getkey(d,"sprite",1),
        getkey(d,"name","Gorg"),
        getkey(d,"ai level",0),

        getkey(d,"prize money",100),

        getkey(d,"introtext","Hi."),
        getkey(d,"outrotext","Bye."),
        getkey(d,"intertext",""),
        getkey(d,"extrotext","Yikers."),

        pkmn
    )
end

function parsePkmn(p::Dict)
    return Pkmn(
        p["id"],
        "",
        getkey(p,"gender",1), # FIX
        rand(UInt16) <= 1,
        0,
        0,

        "",
        0x0000,
        "",
        getkey(p,"ball",1),
        [],

        type,
        stats,
        status,
        item,

        attacks,
        ability,

        evolve,
    )
end

  "pokemon": [{
    "id": "Bisasam",
    "ball": "Pokéball",
    "level": 5,
    "gender": "male",
    "ability": 1,
    "attacks": ["Tackle","Rankenhieb"],
    "DV": [0,0,0,0,0,0],
    "EV": [0,0,0,0,0,0]
  },{
    "id": "Rattfratz",
    "ball": "Superball",
    "level": 10,
    "gender": "male",
    "ability": 1,
    "attacks": ["Tackle","Rankenhieb"],
    "DV": [0,0,0,0,0,0],
    "EV": [0,0,0,0,0,0]
  }]
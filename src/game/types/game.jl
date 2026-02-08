# core types for base functionality

mutable struct PkmnData
    base::Matrix{UInt16}
    name::Vector{String}

    attacks::Matrix{UInt8}
    attacknames::Vector{String}

    function PkmnData()
        new(getStatsBase(),getNames("ger"),
            deserialize("data/attacks.data"),readlines("str/ger/attack_names.txt"))
    end
end



mutable struct Battle
    active::Bool
    state::BattleState
    teamperm::Vector{Int}

    function Battle()
        new(false,BattleState(),collect(1:6))
    end
end



struct Options
    frame::UInt8
    diabox::UInt8
    battleanim::Bool

    lang::Language

    function Options()
        new(0x01,0x01,false,LANG_GER)
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



mutable struct Flags
    general::BitVector
    progress::BitVector
    items::BitVector
    trainers::BitVector
    counters::Vector{UInt32}

    function Flags()
        new(falses(256),falses(256),falses(256),falses(256),zeros(UInt32,256))
    end
end



mutable struct PlayerData
    name::String
    id::UInt16
    gender::UInt8

    pokemon::ArrayList{Pkmn}
    inventory::Inventory

    boxes::Array{ArrayList{Pkmn}}

    badges::Vector{Bool}
    dex::Matrix{Bool}

    function PlayerData()
        new("Test",rand(UInt16),2,ArrayList(Pkmn,6),Inventory(),
            [ArrayList(Pkmn,30) for _ in 1:8],falses(8),falses(649,2))
    end

    function PlayerData(name,gender)
        new(name,rand(UInt16),gender,ArrayList(Pkmn,6),Inventory(),
            [ArrayList(Pkmn,30) for _ in 1:8],falses(8),falses(649,2))
    end

    function PlayerData(name,id,gender,pokemon,inventory,boxes,badges,dex)
        new(name,id,gender,pokemon,inventory,boxes,badges,dex)
    end
end

mutable struct GameState
    frame::UInt32

    p::PlayerData
    im::Im
    ctrl::Controls
    m::MapData
    str::Vector{Vector{String}}
    data::PkmnData

    n::ArrayList{Counter}
    callbacks::ArrayList{Callback}

    overworld::Bool
    battle::Battle
    evolving::Bool

    flags::Flags
    events::Events

    options::Options
end




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

    badges::Vector{UInt8}
    pokedex::Vector{Bool}
end

mutable struct GameState
    frame::UInt32

    p::PlayerData
    im::Im
    ctrl::Controls
    m::MapData
    str::Vector{Vector{String}}
    pkmndata::PkmnData

    n::ArrayList{Counter}
    callbacks::ArrayList{CallbackFunction}

    overworld::Bool
    battle::Battle

    npcstatic::ArrayList{<:NPCNormal}
    npcmove::ArrayList{<:NPCNormal}
    # trainers::ArrayList{NPCTrainer}

    flags::Flags

    options::Options
end




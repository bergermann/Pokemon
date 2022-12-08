#battle manager stuff
include("core.jl")





mutable struct SecStatus
    confused::Bool
    flinch::Bool
    charmed::Bool
    seeded::Bool
    attackblock::Vector{Bool}
    trapped::Bool
    trappedc::UInt8
    trappeddmg::UInt8
    cursed::Bool
    nightmare::Bool
    perish::Bool
    perishc::UInt8
    spotted::UInt8
    escapeblock::Bool
    encore::Bool
    torment::Bool
    taunt::Bool
    healblock::Bool
    itemblock::Bool
    telekinesis::Bool

    function SecStatus()
        new(
            false,      #confused
            false,      #flinch
            false,
            false,
            falses(4),  #attackblock
            false,
            0,
            0,
            false,      #cursed
            false,
            false,
            0,
            0,          #spotted
            false,
            false,
            false,
            false,      #taunt
            false,
            false,
            false       #telekinesis
        )
    end
end

mutable struct PkmnBattle
    pkmn::Pkmn
    
    buffs::Vector{Int8}     #at,spat,def,spdef,init,acc,eva

    secstatus::SecStatus

    sight::Bool

    fly::Bool
    dive::Bool
    dig::Bool
    shadow::Bool
    bounce::Bool
    
    attackchoice::UInt8

    function PkmnBattle(pkmn::Pkmn)
        new(
            pkmn,           #pkmn
            zeros(Int8,7),  #buffs
            SecStatus(),    #secstatus
            false,          #sight
            false,          #fly
            false,          #dig
            false,          #shadow
            false,          #bounce
            0x00,           #attackchoice
        )
    end
end

mutable struct BattleCounters
    c1::Int
    c2::Int
    c3::Int

    function BattleCounters()
        new(0,0,0)
    end
end

mutable struct EntryHazards
    spikes::UInt8
    toxspikes::UInt8
    rocks::Bool
    sticky::Bool

    function EntryHazards()
        new(0,0,false,false)
    end
end

mutable struct BattleRoom
    trick::Bool
    trickc::UInt8

    magic::Bool
    magicc::UInt8

    wonder::Bool
    wonderc::UInt8

    function BattleRoom()
        new(false,0,false,0,false,0)
    end
end

mutable struct BattleEnvironment
    weather::UInt8
    weatherc::UInt8

    enthaz1::EntryHazards
    enthaz2::EntryHazards

    room::BattleRoom

    function BattleEnvironment()
        new(
            0,
            0,
            EntryHazards(),
            EntryHazards(),
            BattleRoom()
        )
    end
end





abstract type BattleState end

mutable struct BattleStateWild <: BattleState
    counters::BattleCounters
    turn::UInt

    env::BattleEnvironment

    pkmn1::PkmnBattle
    pkmn2::PkmnBattle

    attackanim::Function

    function BattleState(counters,turn,env,pkmn1,pkmn2,nothing)
        new(counters,turn,env,pkmn1,pkmn2)
    end
end

mutable struct BattleStateTrainerSolo <: BattleState
    counters::BattleCounters
    turn::UInt

    env::BattleEnvironment

    pkmn1::PkmnBattle
    pkmn2::PkmnBattle

    attackanim::Function

    function BattleState(counters,turn,env,pkmn1,pkmn2,nothing)
        new(counters,turn,env,pkmn1,pkmn2)
    end
end

mutable struct BattleStateTrainerDouble <: BattleState
    counters::BattleCounters
    turn::UInt

    env::BattleEnvironment

    pkmn11::PkmnBattle
    pkmn12::PkmnBattle
    pkmn21::PkmnBattle
    pkmn22::PkmnBattle

    attackanim::Function

    function BattleState(counters,turn,env,pkmn1,pkmn2,nothing)
        new(counters,turn,env,pkmn1,pkmn2)
    end
end





function setupBattle(game::GameState)
    0
end

function loopBattleWild(game::GameState)
    0

end

function initBattleWild(game::GameState)
    pb1 = PkmnBattle(activePkmn(game))
    pb2 = PkmnBattle(generatePkmn(game,rand(0x0001:0x0289),rand(0x01:0x64)))

    return BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2,Nothing)
end

function initBattleWild(game::GameState,ids::Vector{UInt16},levels::Vector{UInt8})
    pb1 = PkmnBattle(activePkmn(game))
    pb2 = PkmnBattle(generatePkmn(game,rand(ids),rand(levels)))

    return BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2,Nothing)
end







mutable struct PkmnBattle
    pkmn::Pkmn
    
    buffs::Vector{Int8}
    confused::Bool
    flinch::Bool
    charmed::Bool

    sight::Bool

    fly::Bool
    dive::Bool
    dig::Bool
    shadow::Bool
    bounce::Bool
    
    attackchoice::UInt8

    function PkmnBattle(pkmn::Pkmn)
        new(pkmn,zeros(Int8,6),false,false,0x00)
    end
    
    function PkmnBattle()
        new()
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

mutable struct BattleEnvironment
    weather::UInt8
end

mutable struct BattleState
    counters::BattleCounters
    turn::UInt

    env::BattleEnvironment

    pkmn1::PkmnBattle
    pkmn2::PkmnBattle


end

function battleLoop(game::GameState)
    0
end

function initBattleWild(game::GameState)
    pb1 = PkmnBattle(activePkmn(game))
    pb2 = PkmnBattle(generatePkmn(game,rand(0x0001:0x0289),rand(0x01:0x64)))

    return BattleState(BattleCounters,0,pb1,pb2)
end




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
            0x00            #attackchoice
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


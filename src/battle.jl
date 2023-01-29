#battle manager stuff
#include("core.jl")



abstract type BattleCommand end

mutable struct CommandAttack <: BattleCommand
    n::UInt
end

mutable struct CommandSwitch <: BattleCommand
    n::UInt
end

mutable struct CommandItem <: BattleCommand
    target::UInt
    #item::Item
end

mutable struct CommandFlee <: BattleCommand end

mutable struct CommandChoose <: BattleCommand end




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

    righthand::Bool
    charge::Bool

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

mutable struct DoubleMoves
    sight::Bool
    sightc::UInt

    fly::Bool
    dive::Bool
    dig::Bool
    shadow::Bool
    bounce::Bool

    function DoubleMoves()
        new(false,0x00,false,false,false,false,false)
    end
end
    

mutable struct PkmnBattle
    pkmn::Pkmn
    
    buffs::Vector{Int8}     #at,spat,def,spdef,init,acc,eva

    secstatus::SecStatus

    dmoves::DoubleMoves
    
    command::BattleCommand

    function PkmnBattle(pkmn::Pkmn)
        new(
            pkmn,           #pkmn
            zeros(Int8,7),  #buffs
            SecStatus(),    #secstatus
            DoubleMoves(),  #dmoves
            CommandChoose()           #attackchoice
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

    mud::Bool
    wet::Bool

    enthaz1::EntryHazards
    enthaz2::EntryHazards

    room::BattleRoom

    function BattleEnvironment()
        new(
            0,
            0,
            false,
            false,
            EntryHazards(),
            EntryHazards(),
            BattleRoom()
        )
    end
end





#abstract type BattleState end

mutable struct BattleStateNone <: BattleState end

mutable struct BattleStateWild <: BattleState
    counters::BattleCounters
    turn::UInt

    env::BattleEnvironment

    pkmn1::PkmnBattle
    pkmn2::PkmnBattle

    function BattleStateWild(counters,turn,env,pkmn1,pkmn2)
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





function setupBattle!(game::GameState)
    game.input.inputlock = true
    game.input.map = false
    game.input.move = false

    createCounter!(game,:battleanim)
    createCounter!(game,:battledelay)
    createCounter!(game,:battleintro)
    createCallback!(game,:battleintro,true,animBattleEntry1!,())
end

function closeBattle!(game::GameState)
    game.input.inputlock = false
    game.input.move = true
    game.input.map = true
    
    initDrawMap!(game)
end

function loopBattleWild(game::GameState)
    0
end

function initBattleWild!(game::GameState)
    setupBattle!(game)

    pb1 = PkmnBattle(activePkmn(game))
    pb2 = PkmnBattle(generatePkmn(game,rand(0x0001:0x0097),rand(0x01:0x64)))

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
end

function initBattleWild(game::GameState,ids::Vector{UInt16},levels::Vector{UInt8})
    game.battle.active = true

    pb1 = PkmnBattle(activePkmn(game))
    pb2 = PkmnBattle(generatePkmn(game,rand(ids),rand(levels)))

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
end

function damage(game::GameState)
    0
end

function itemfactor(attacker::PkmnBattle,defender::PkmnBattle)
    return 1
end

function abilityfactor(attacker::PkmnBattle,defender::PkmnBattle)
    return 1
end

function basedamage(game::GameState,attacker::PkmnBattle,defender::PkmnBattle)
    return ceil(UInt16,
        *(1+0.5*attacker.secstatus.righthand,
        attack.strength,
        itemfactor(attacker,defender),
        1+1*attacker.secstatus.charge,
        1-0.5*game.battle.env.mud,
        1-0.5*game.battle.env.wet,
        abilityfactor(attacker,defender))
    )
end

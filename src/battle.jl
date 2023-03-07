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
    
    buffs::Vector{Int8}     #at,spat,def,spdef,init,acc,eva,crit

    secstatus::SecStatus

    dmoves::DoubleMoves
    
    command::BattleCommand

    function PkmnBattle(pkmn::Pkmn)
        new(
            pkmn,           #pkmn
            zeros(Int8,8),  #buffs
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

    queue::ArrayList{BattleAction}

    function BattleStateWild(counters,turn,env,pkmn1,pkmn2)
        new(counters,turn,env,pkmn1,pkmn2,ArrayList(BattleAction,32))
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

    killCounter!(game,:battleanim)
    killCounter!(game,:battledelay)
    
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
    
    createCC!(game,:battlecounter,animBattlePhaseWild!,(); active=false)
end

function initBattleWild!(game::GameState,ids::Vector{UInt16},levels::Vector{UInt8})
    game.battle.active = true

    pb1 = PkmnBattle(activePkmn(game))
    pb2 = PkmnBattle(generatePkmn(game,rand(ids),rand(levels)))

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
end

function damage(game::GameState,state::BattleState)
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

function flee!(game::GameState)
    flee!(game.battle.state)
end

function flee!(state::BattleStateWild)
    if state.pkmn1.secstatus.escapeblock
        return
    end

    if (state.pkmn1.rv[6]*128/max(state.pkmn2.rv[6],1)+30)%256 > rand(UInt8)
        #flucht gescheitert

        return
    end

    stateEndBattleFlee!(game)
end

function flee!(state::BattleStateTrainerSolo)

end

function flee!(state::BattleStateTrainerDouble)

end

function checkAttack!(game::GameState)
    if game.battle.state.pkmn1.pkmn.attacks[game.input.battle2menu.select+1].ap == 0
        return false
    end

    return true
end

function getPriority(state::BattleStateWild)
    p1 = state.pkmn1.pkmn.attacks[state.pkmn1.command.n].priority
    p2 = state.pkmn2.pkmn.attacks[state.pkmn2.command.n].priority

    if p1 != p2
        if !state.env.room.wonder
            return (p1 > p2 ? (1,2) : (2,1))
        else
            return (p1 < p2 ? (1,2) : (2,1))
        end
    end

    p1 = state.pkmn1.pkmn.stats.rv[6]
    p1 *= getBuffMultiplier(state.pkmn1.buffs[6])

    p2 = state.pkmn2.pkmn.stats.rv[6]
    p2 *= getBuffMultiplier(state.pkmn2.buffs[6])

    if !state.env.room.wonder
        return (p1 > p2 ? (1,2) : (2,1))
    else
        return (p1 < p2 ? (1,2) : (2,1))
    end
end

function getBuffMultiplier(level::Int8)::Rational{Int8}
    if level >= 0
        return (2+level)/2
    else 
        return 2/(2-level)
    end
end

function getAccuracyMultiplier(state::BattleState,target::Int)::Rational{Int8}
    level = target == 1 ? state.pkmn2.buffs[7]-state.pkmn1.buffs[8] : state.pkmn1.buffs[7]-state.pkmn2.buffs[8]

    if level >= 0
        return (3+level)/3
    else 
        return 3/(3-level)
    end
end

function getAccuracyFactor(state::BattleState,target::Int)::Rational{UInt8}
    return 0x01//0x01
end

function getMiss(state::BattleState,target::Int)::Bool
    acc = target == 1 ? state.pkmn2.pkmn.attacks[state.pkmn2.command.n].accuracy : 
        state.pkmn1.pkmn.attacks[state.pkmn1.command.n].accuracy

    r = acc*getAccuracyMultiplier(state,target)*getAccuracyFactor(state,target)

    return rand(1:100) > r
end

function getEff(state::BattleState,target::Int)
    def = target == 1 ? state.pkmn1.pkmn : state.pkmn2.pkmn
    att = target == 1 ? state.pkmn2.pkmn.attacks[state.pkmn2.command.n] : 
        state.pkmn1.pkmn.attacks[state.pkmn1.command.n]
    
    return typetable[att.type,def.type[1]]*
        (def.type[2] != 0 ? typetable[att.type,def.type[2]] : 0x01//0x01)
end

function getCrit(state::BattleState,target::Int)
    cr = target == 1 ? state.pkmn2.pkmn.attacks[state.pkmn2.command.n].critrate : 
        state.pkmn1.pkmn.attacks[state.pkmn1.command.n].critrate

    br = target == 1 ? state.pkmn2.buffs[8] : state.pkmn1.buffs[8]

    return rand() < (1/16,1/8,1/4,1/3,1/2)[clamp(cr+br,1,5)]
end

function queueSetup!(game::GameState,state::BattleStateWild)
    p = getPriority(state)

    p1 = state.pkmn1.pkmn
    p2 = state.pkmn2.pkmn
    a1 = state.pkmn1.pkmn.attacks[state.pkmn1.command.n]
    a2 = state.pkmn2.pkmn.attacks[state.pkmn2.command.n]

    if p[1] == 1
        queueAttack!(game,state,a1,2,p1)
        queueAttack!(game,state,a2,1,p2)
    else
        queueAttack!(game,state,a2,1,p2)
        queueAttack!(game,state,a1,2,p1)
    end
end

function queueAttack!(game::GameState,state::BattleState,attack::Attack,
        target::Int,pkmn::Pkmn)
    miss = getMiss(state,target)
    crit = getCrit(state,target)
    eff = getEff(state,target)

    println(eff)

    push!(state.queue,BattleAction(
        :p1,120,getPkmnName(game,pkmn)*" setzt\\$(attack.name) ein.",banimEmpty!,0
    ))

    if miss
        push!(state.queue,BattleAction(
            :p1,120,"Die Attacke hat\\ihr Ziel verfehlt...",banimEmpty!,0
        ))
    elseif eff == 0
        push!(state.queue,BattleAction(
            :p1,120,"Es hat keine Wirkung...",banimEmpty!,0
        ))
    else
        push!(state.queue,BattleAction(
            :p1,60,"",bnoAnim!,target
        ))

        if crit
            push!(state.queue,BattleAction(
                :p1,120,"Ein Volltreffer!",banimEmpty!,0
            ))
        end

        
        if eff < 1
            push!(state.queue,BattleAction(
                :p1,120,"Das ist nicht sehr effektiv...",banimEmpty!,0
            ))
        elseif eff > 1
            push!(state.queue,BattleAction(
                :p1,120,"Das ist sehr effektiv!",banimEmpty!,0
            ))
        end
    end
end

function queueWeather!(state::BattleState)
    return
end

function queueStatusCond!(state::BattleState)
    return
end

function queueCheckStatus!(state::BattleState)
    return true
end
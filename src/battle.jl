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
            false,       #telekinesis
        )
    end
end

mutable struct DmgFactors
    LVL::UInt

    BP::UInt         #base power
    RH::Float64     #right hand
    CH::Float64     #charge
    IF::Float64     #item factor attacker
    MW::Float64     #muddy, wet
    AA::Float64     #ability attacker
    AD::Float64     #ability defender
    BD::UInt16      #base dmg

    ATK::UInt16
    DEF::UInt16
    CRIT::Float64
    EFF::Float64
    STAB::Float64

    RAND::UInt16

    BRT::Float64
    RFSC::Float64
    MULT::Float64
    WEATHER::Float64
    FC::Float64     #firecatcher
    F1::Float64

    LO::Float64     #Lifeorb
    ME::Float64     #metronom factor
    MC::UInt8       #metronom count
    ET::Float64     #egotrip
    F2::Float64

    FF::Float64
    EB::Float64
    UP::Float64
    BF::Float64
    F3::Float64

    function DmgFactors()
        new(
            0,#::UInt        #level

            0,#::Int         #base power
            1,#::Float64     #right hand
            1,#::Float64     #charge
            1,#::Float64     #item factor attacker
            1,#::Float64     #muddy, wet
            1,#::Float64     #ability attacker
            1,#::Float64     #ability defender
            0,#::UInt16      #base dmg

            0,# ATK::UIn16
            0,# DEF::UInt16
            1,# CRIT::Float64
            1,# EFF::Float64
            1,# STAB::Float64

            100,# RAND::UInt16

            1,# BRT::Float
            1,# RFSC::Float
            1,# MULT::Float
            1,# WEATHER::Float
            1,# FC::Float
            1,# F1::Float

            1,# ME::Float
            1,# MC::UInt8
            1,# F2::Float

            1,# FF::Float
            1,# EB::Float
            1,# UP::Float
            1,# BF::Float
            1,# F3::Float
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
    
    buffs::Vector{Int8}     #at,def,spat,spdef,init,acc,eva,crit #CHECK THIS LATER

    secstatus::SecStatus
    factors::DmgFactors
    
    hit::Bool
    crit::Bool
    eff::Float64
    dmg::Int
    heal::Int
    stat::Int

    screen::Bool
    screenc::Int
    reflect::Bool
    reflectc::Int

    dmoves::DoubleMoves
    
    command::BattleCommand
    attack::Attack
    lastattack::Int

    function PkmnBattle(pkmn::Pkmn)
        new(
            pkmn,           #pkmn
            zeros(Int8,8),  #buffs
            SecStatus(),    #secstatus
            DmgFactors(),

            true,
            false,
            1,
            0,
            0,
            0,
            false,
            0,
            false,
            0,
            DoubleMoves(),  #dmoves
            CommandChoose(),           #attackchoice
            Attack(),
            0
        )
    end
end

mutable struct BattleCounters
    turn::Int
    flee::Int
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
    weather::UInt8          #CHECK THIS
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
    pb2 = PkmnBattle(generatePkmn(game,rand(0x0001:0x0097),rand(0x01:0x0a)))

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
    
    createCC!(game,:battlecounter,animBattlePhaseWild!,(); active=false)
end

function initBattleWild!(game::GameState,ids::Vector{UInt16},levels::Vector{UInt8})
    game.battle.active = true

    pb1 = PkmnBattle(activePkmn(game))
    pb2 = PkmnBattle(generatePkmn(game,rand(ids),rand(levels)))

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
end





function floorProd(t::Type,args...)
    x = t(1)

    for arg in args
        x = floor(t,x*arg)
    end

    return x
end

function setDmgFactors!(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    attacker.factors.LVL = attacker.pkmn.stats.level

    attacker.factors.BP = attacker.attack.power
    attacker.factors.RH = 1+0.5*attacker.secstatus.righthand
    attacker.factors.CH = 1+1*attacker.secstatus.charge
    attacker.factors.IF = itemFactorAttacker(attacker)
    attacker.factors.MW = 1
        -0.5*state.env.wet*(attacker.attack.type==0x03)
        -0.5*state.env.mud*(attacker.attack.type==0x0c)
    attacker.factors.AA = abilityFactorAttacker(attacker)
    attacker.factors.AD = abilityFactorDefender(defender)
    attacker.factors.BD = calcBaseDamage(attacker.factors)

    attacker.factors.ATK = attackFactor(attacker)
    attacker.factors.DEF = defenseFactor(attacker,defender)*
        (1+0.5*(state.env.weather==0x03)*(attacker.attack.class==2))
    attacker.factors.CRIT = 1+0.5*attacker.crit
    attacker.factors.EFF = attacker.eff
    attacker.factors.STAB = 1+0.5*(attacker.attack.type in attacker.pkmn.type)

    attacker.factors.RAND = 100-rand(0:15)

    attacker.factors.BRT = 1-0.5*(attacker.pkmn.status==0x01)*
        (attacker.attack.class==0x01)
    attacker.factors.RFSC = screenFactor(state,attacker,defender)
    attacker.factors.MULT = 1
    attacker.factors.WEATHER = factorWeather(state,attacker)
    attacker.factors.F1 = factorF1(attacker.factors)

    attacker.factors.LO = 1+0.3*(attacker.pkmn.item==0xff)
    attacker.factors.ME = 1+0.1*min(attacker.factors.MC,10)
    attacker.factors.ET = 1
    attacker.factors.F2 = factorF2(attacker.factors)

    attacker.factors.FF = 1-0.5*attacker.crit*
        (defender.pkmn.ability==0xff || defender.pkmn.ability==0xff)
    attacker.factors.EB = 1+0.2*(attacker.eff>1)*(attacker.pkmn.item==0xff)
    attacker.factors.UP = 1+1*(attacker.eff<1)*(attacker.pkmn.ability==0xff)
    attacker.factors.BF = 1
    attacker.factors.F3 = factorF3(attacker.factors)
end

function itemFactorAttacker(attacker::PkmnBattle)
    return 1
end

function abilityFactorAttacker(attacker::PkmnBattle)
    return 1
end

function abilityFactorDefender(defender::PkmnBattle)
    return 1
end

function calcBaseDamage(f::DmgFactors)
    return floorProd(UInt16,
        f.RH,
        f.BP,
        f.IF,
        f.CH,
        f.MW,
        f.AA,
        f.AD
    )
end

function attackFactor(attacker::PkmnBattle)
    if attacker.attack.class == 1
        return attacker.pkmn.stats.rv[2]*
            max(getBuffMultiplier(attacker.buffs[1]),attacker.crit)*
            abilityFactorAttack(attacker)*
            itemFactorAttack(attacker)
    else
        return attacker.pkmn.stats.rv[4]*
            getBuffMultiplier(attacker.buffs[3])*
            abilityFactorAttack(attacker)*
            itemFactorAttack(attacker)
    end
end

function abilityFactorAttack(attacker::PkmnBattle)
    return 1
end

function itemFactorAttack(attacker::PkmnBattle)
    return 1
end

function defenseFactor(attacker::PkmnBattle,defender::PkmnBattle)
    if attacker.attack.class == 1
        return defender.pkmn.stats.rv[2]*
            getBuffMultiplier(defender.buffs[1])*
            abilityFactorDefense(defender)*
            itemFactorDefense(defender)
    else
        return defender.pkmn.stats.rv[4]*
            getBuffMultiplier(defender.buffs[3])*
            abilityFactorDefense(defender)*
            itemFactorDefense(defender)
    end
end

function abilityFactorDefense(defender::PkmnBattle)
    return 1
end

function itemFactorDefense(defender::PkmnBattle)
    return 1
end

function screenFactor(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    if typeof(state) == BattleStateWild
        return 1-0.5*!attacker.crit*
            (attacker.attack.class==1 ? defender.reflect : defender.screen)
    elseif typeof(state) == BattleStateTrainerDouble
        return 1-1/3*!attacker.crit*
            (attacker.attack.class==1 ? defender.reflect : defender.screen)
    end
end

function factorWeather(state::BattleState,attacker::PkmnBattle)
    return 1 - 
        0.5*(attacker.attack.type==0x03 && state.env.weather==0x02) -
        0.5*(attacker.attack.type==0x04 && state.env.weather==0x01) +
        0.5*(attacker.attack.type==0x03 && state.env.weather==0x01) +
        0.5*(attacker.attack.type==0x04 && state.env.weather==0x02)
end

function factorF1(f::DmgFactors)
    return *(
        f.BRT,
        f.RFSC,
        f.MULT,
        f.WEATHER,
        f.FC
    )
end

function factorF2(f::DmgFactors)
    return *(
        f.LO,
        f.ME,
        f.ET
    )
end

function factorF3(f::DmgFactors)
    return *(
        f.FF,
        f.EB,
        f.UP,
        f.BF
    )
end

function calcDamage(f::DmgFactors)
    return floorProd(UInt16,
        floorProd(UInt16,
            floor(UInt16,f.LVL*2/5+2),
            f.BD,
            f.ATK,
            1/(50*f.DEF),
            f.F1
        )+2,
        f.CRIT,
        f.F2,
        f.RAND/100,
        f.STAB,
        f.EFF,
        f.F3
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

function getAccuracyMultiplier(attacker::PkmnBattle,defender::PkmnBattle)::Rational{Int8}
    level = attacker.buffs[7]-defender.buffs[8]

    if level >= 0
        return (3+level)/3
    else 
        return 3/(3-level)
    end
end

function getAccuracyFactor(state::BattleState,attacker::PkmnBattle,
        defender::PkmnBattle)::Rational{UInt8}
    return 0x01//0x01
end

function getHit(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    return rand(1:100) < attacker.attack.accuracy*
        getAccuracyFactor(state,attacker,defender)*
        getAccuracyMultiplier(attacker,defender)
end

function getEff(attacker::PkmnBattle,defender::PkmnBattle)
    return typetable[attacker.attack.type,defender.pkmn.type[1]]*
        (defender.pkmn.type[2]!=0x00 ?
            typetable[attacker.attack.type,defender.pkmn.type[2]] : 0x01//0x01)
end

function getCrit(attacker::PkmnBattle,defender::PkmnBattle)
    return rand() < (1/16,1/8,1/4,1/3,1/2)[clamp(
        attacker.attack.critrate+attacker.buffs[8],1,5)]
end

function queueSetup!(game::GameState,state::BattleStateWild)
    p = getPriority(state)

    state.pkmn1.attack = state.pkmn1.pkmn.attacks[state.pkmn1.command.n]
    state.pkmn2.attack = state.pkmn2.pkmn.attacks[state.pkmn2.command.n]

    if p[1] == 1
        queueAttack!(game,state,state.pkmn1,state.pkmn2,2,:p1)
        queueAttack!(game,state,state.pkmn2,state.pkmn1,1,:p2)
    else
        queueAttack!(game,state,state.pkmn2,state.pkmn1,1,:p2)
        queueAttack!(game,state,state.pkmn1,state.pkmn2,2,:p1)
    end

    queueStatusCond!(state)
    queueWeather!(state)
end

function queueAttack!(game::GameState,state::BattleState,
        attacker::PkmnBattle,defender::PkmnBattle,target::Int,id::Symbol)
    attacker.hit = getHit(state,attacker,defender)
    attacker.crit = getCrit(attacker,defender)
    attacker.eff = getEff(attacker,defender)

    setDmgFactors!(state,attacker,defender)
    attacker.dmg = calcDamage(attacker.factors)

    println("$id D: ",attacker.dmg)
    
    push!(state.queue,BattleAction(
        id,120,getPkmnName(game,attacker.pkmn)*" setzt\\$(attacker.attack.name) ein.",
        banimEmpty!,0
    ))

    if !attacker.hit
        push!(state.queue,BattleAction(
            id,120,"Die Attacke hat\\ihr Ziel verfehlt...",banimEmpty!,0
        ))

        return
    elseif attacker.eff == 0
        push!(state.queue,BattleAction(
            id,120,"Es hat keine Wirkung...",banimEmpty!,0
        ))

        return
    end

    push!(state.queue,BattleAction(
        id,60,"",bnoAnim!,target
    ))

    push!(state.queue,BattleAction(
        id,48,"",bhpAnim!,target
    ))

    if attacker.crit
        push!(state.queue,BattleAction(
            id,120,"Ein Volltreffer!",banimEmpty!,0
        ))
    end

    if attacker.eff < 1
        push!(state.queue,BattleAction(
            id,120,"Das ist nicht sehr effektiv...",banimEmpty!,0
        ))
    elseif attacker.eff > 1
        push!(state.queue,BattleAction(
            id,120,"Das ist sehr effektiv!",banimEmpty!,0
        ))
    end
end

function queueWeather!(state::BattleState)
    if state.env.weather == 0x00
        return
    end

    push!(state.queue,BattleAction(
        :p1,120,"Wetter",banimEmpty!,0
    ))
end

function queueStatusCond!(state::BattleState)
    if state.pkmn1.pkmn.status != 0x00
        0
    end

    if state.pkmn2.pkmn.status != 0x00
        0
    end
end

function queueCheckStatus!(state::BattleState)
    return true
end
#types commonly used in battle proceedings


const blabels = Base.ImmutableDict(
    [i => (
            pkmn   = Symbol(:pkmn,i),
            tag    = Symbol(:tag,i),
            name   = Symbol(:name,i),
            health = Symbol(:health,i),
            level  = Symbol(:lvl,i),
            attack = Symbol(:attack,i),
        )
    for i in 1:4]...
)


abstract type BattleCommand end

mutable struct CommandAttack <: BattleCommand
    n::UInt
end

mutable struct CommandSwitch <: BattleCommand
    n::Int
end

mutable struct CommandItem <: BattleCommand
    target::Int
    item::ItemType
end

mutable struct CommandFlee <: BattleCommand
    success::Bool
end

mutable struct CommandChoose <: BattleCommand end
const CC0 = CommandChoose()

mutable struct CommandNone <: BattleCommand end
const CN0 = CommandNone()



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
    name::String
    xpdrop::UInt32
    
    buffs::Vector{Int8}     #at,def,spat,spdef,init,acc,eva,crit # FIX CHECK THIS LATER

    secstatus::SecStatus
    factors::DmgFactors
    
    hit::Bool
    crit::Bool
    eff::Float64
    dmgd::Int
    dmgt::Int
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
            "",
            0,
            zeros(Int8,8),  #buffs
            SecStatus(),    #secstatus
            DmgFactors(),

            true,
            false,
            1,
            0,
            0,
            0,
            0,
            false,
            0,
            false,
            0,
            DoubleMoves(),  #dmoves
            CC0,           #attackchoice
            Attack(),
            0,
        )
    end

    function PkmnBattle(pkmn::Pkmn,name::String)
        new(
            pkmn,           #pkmn
            name,
            0,
            zeros(Int8,8),  #buffs
            SecStatus(),    #secstatus
            DmgFactors(),

            true,
            false,
            1,
            0,
            0,
            0,
            0,
            false,
            0,
            false,
            0,
            DoubleMoves(),  #dmoves
            CC0,           #attackchoice
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

    animqueue::ArrayList{BattleAnimation}
    actionqueue::ArrayList{BattleAction}

    caught1::Bool
    caught2::Bool

    forceswitch1::Bool
    forceswitch2::Bool

    function BattleStateWild(counters,turn,env,pkmn1,pkmn2)
        new(counters,turn,env,pkmn1,pkmn2,
            ArrayList(BattleAnimation,32),ArrayList(BattleAction,8),false,false)
    end
end

function Base.getindex(state::BattleStateWild,ind)
    # return ind == 1 ? state.pkmn1 : state.pkmn2
    return getfield(state,ind+3)
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

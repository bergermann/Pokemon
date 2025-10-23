#types commonly used in battle proceedings

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

const T0 = Trainer(0,"",0,0,"","","","",Pkmn[])

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
    rooted::Bool
    trapped::Bool
    cursed::Bool
    nightmare::Bool
    perish::Bool
    escapeblock::Bool
    encore::Bool
    torment::Bool
    taunt::Bool
    healblock::Bool
    itemblock::Bool
    telekinesis::Bool
    shielded::Bool

    righthand::Bool
    charge::Bool

    attackblock::Vector{Bool}

    trappedc::UInt8
    trappeddmg::UInt8
    
    perishc::UInt8
    spotted::UInt8

    function SecStatus()
        new(
            false,      # confused
            false,      # flinch
            false,      # charmed
            false,      # seeded
            false,      # rooted
            false,      # trapped
            false,      # cursed
            false,      # nightmare
            false,      # perish
            false,      # escapeblock
            false,      # encore
            false,      # torment
            false,      # taunt
            false,      # healblock
            false,      # itemblock
            false,      # telekinesis
            false,      # shielded

            false,      # righthand
            false,      # charge

            falses(4),  # attackblock

            0,          # trappedc
            0,          # trappeddmg

            0,          # perishc
            0,          # spotted
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
    reflect::Bool
    screenc::Int
    reflectc::Int

    dmoves::DoubleMoves
    
    command::BattleCommand
    attacks::Vector{Attack}
    attack::Int
    lastattack::Int

    function PkmnBattle(game,pkmn)
        new(
            pkmn,                       # pkmn
            pkmnName(game,pkmn),        # name
            100, # game.data.base[pkmn.id,x],  # xpdrop FIX

            zeros(Int8,8),  # buffs

            SecStatus(),    # secstatus
            DmgFactors(),   # dmgfactors

            true,           # hit
            false,          # crit
            1,              # eff
            0,              # dmgd
            0,              # dmgt
            0,              # heal
            0,              # stat

            false,          # screen
            false,          # reflect
            0,              # screenc
            0,              # reflectc
            
            DoubleMoves(),  # dmoves
            CC0,            # command
            loadBattleAttacks(game,pkmn),
            0,
            0,
        )
    end

    function PkmnBattle(pkmn)
        new(
            pkmn,           # pkmn
            "",             # name
            0,              # xpdrop

            zeros(Int8,8),  # buffs

            SecStatus(),    # secstatus
            DmgFactors(),   # dmgfactors

            true,           # hit
            false,          # crit
            1,              # eff
            0,              # dmgd
            0,              # dmgt
            0,              # heal
            0,              # stat

            false,          # screen
            false,          # reflect
            0,              # screenc
            0,              # reflectc
            
            DoubleMoves(),  # dmoves
            CC0,            # command
            Atk[],
            0,
            0,
        )
    end
end

mutable struct BattleCounters
    turn::UInt8
    flee::UInt8
    # c3::Int

    function BattleCounters()
        new(0,0)
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
    trick::UInt8
    magic::UInt8
    wonder::UInt8

    function BattleRoom()
        new(0,0,0)
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



mutable struct BattleState
    counters::BattleCounters

    env::BattleEnvironment

    pkmn1::PkmnBattle
    pkmn2::PkmnBattle
    pkmn3::PkmnBattle
    pkmn4::PkmnBattle

    animqueue::ArrayList{BattleAnimation}
    actionqueue::ArrayList{BattleAction}

    forceswitch::BitVector

    iswild::Bool
    isdouble::Bool
    caught1::Bool
    caught2::Bool

    trainer1::Trainer
    trainer2::Trainer

    function BattleState()
        new(
            BattleCounters(),BattleEnvironment(),
            PB0,PB0,PB0,PB0,
            ArrayList(BattleAnimation,32),ArrayList(BattleAction,8),
            falses(4),
            false,false,false,false,
            T0,T0
        )
    end
end

function Base.getindex(state::BattleState,ind::Integer)::PkmnBattle
    return getfield(state,2+(1+!state.isdouble)*(ind-1)+1)
end

function Base.setindex!(state::BattleState,pkmn::PkmnBattle,ind::Integer)
    return setfield!(state,2+(1+!state.isdouble)*(ind-1)+1,pkmn)
end

# function Base.getindex(state::BattleState,team::Integer,ind::Integer)::PkmnBattle
#     return getfield(state,2*team+ind)
# end

function forceswitch(state::BattleState,ind::Integer)::Bool
    return state.forceswitch[(1+!state.isdouble)*(ind-1)+1]
end

const fs = forceswitch

function forceswitch!(state::BattleState,ind::Integer,val::Bool)
    state.forceswitch[(1+!state.isdouble)*(ind-1)+1] = val

    return
end

const fs! = forceswitch!
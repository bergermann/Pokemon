# types used to characterize and manage pokemons


const typetable = Matrix{Rational{UInt8}}(
    [#  no  pf  fe  wa  ka  fl  gi  bo  st  kä  ge  el  ps  eis dr  un  st  fee
        1   1   1   1   1   1   1   1   0.5 1   0   1   1   1   1   1   0.5 1   #normal
        1   0.5 0.5 2   1   0.5 0.5 2   2   0.5 1   1   1   1   0.5 1   0.5 1   #pflanze
        1   2   0.5 0.5 1   1   1   1   0.5 2   1   1   1   2   0.5 1   2   1   #feuer
        1   0.5 2   0.5 1   1   1   2   2   1   1   1   1   1   0.5 1   1   1   #wasser
        2   1   1   1   1   0.5 0.5 1   2   0.5 0   1   0.5 2   1   2   2   0.5 #kampf
        1   2   1   1   2   1   1   1   0.5 2   1   0.5 1   1   1   1   0.5 1   #flug
        1   2   1   1   1   1   0.5 0.5 0.5 1   0.5 1   1   1   1   1   0   2   #gift
        1   0.5 2   1   1   0   2   1   2   0.5 1   2   1   1   1   1   2   1   #boden
        1   1   2   1   0.5 2   1   0.5 1   2   1   1   1   2   1   1   0.5 1   #stein
        1   2   0.5 1   0.5 0.5 0.5 1   1   1   0.5 1   2   1   1   2   0.5 0.5 #käfer
        0   1   1   1   1   1   1   1   1   1   2   1   2   1   1   0.5 1   1   #geist
        1   0.5 1   2   1   2   1   0   1   1   1   0.5 1   1   0.5 1   1   1   #elektro
        1   1   1   1   2   1   2   1   1   1   1   1   0.5 1   1   0   0.5 1   #psycho
        1   2   0.5 0.5 1   2   1   2   1   1   1   1   1   0.5 2   1   0.5 1   #eis
        1   1   1   1   1   1   1   1   1   1   1   1   1   1   2   1   0.5 0   #drache
        1   1   1   1   0.5 1   1   1   1   1   2   1   2   1   1   0.5 1   0.5 #unlicht
        1   1   0.5 0.5 1   1   1   1   2   1   1   0.5 1   2   1   1   0.5 2   #stahl
        1   1   0.5 1   2   1   0.5 1   1   1   1   1   1   1   2   2   0.5 1   #fee
    ]
)

function printTypes(attacker)
    println("Angreifer:     $(TypeNames[UInt8(attacker)])")
    println("Stark gegen:   ",get.(Ref(TypeNames),findall(x->x==0x02//0x01,typetable[attacker,:]),0).*", "...)
    println("Schwach gegen: ",get.(Ref(TypeNames),findall(x->x==0x01//0x02,typetable[attacker,:]),0).*", "...)
    println("Kein Effekt:   ",get.(Ref(TypeNames),findall(x->x==0x00//0x01,typetable[attacker,:]),0).*", "...)
end

const TypeNames = Base.ImmutableDict(
    0x00 => "Null",
    0x01 => "Normal",
    0x02 => "Pflanze",
    0x03 => "Feuer",
    0x04 => "Wasser",
    0x05 => "Kampf",
    0x06 => "Flug",
    0x07 => "Gift",
    0x08 => "Boden",
    0x09 => "Gestein",
    0x0a => "Käfer",
    0x0b => "Geist",
    0x0c => "Elektro",
    0x0d => "Psycho",
    0x0e => "Eis",
    0x0f => "Drache",
    0x10 => "Unlicht",
    0x11 => "Stahl",
    0x12 => "Fee",
)

mutable struct Stats
    bv::Vector{UInt8}
    dv::Vector{UInt8}   #HP, At, Def, SpAt, SpDef, Init
    ev::Vector{UInt8}
    rv::Vector{UInt16}

    hp::Int

    level::UInt8
    xp::Int

    nature::UInt8
    affection::UInt8

    function Stats(bv,level)
        new(bv,rand(0:31,6),zeros(UInt8,6),zeros(UInt16,6),0,level,0,rand(1:25),0)
    end

    function Stats(bv,dv,level)
        new(bv,dv,zeros(UInt8),level,1,0,rand(1:25),0)
    end

    function Stats(bv,dv,level,nature,affection)
        new(bv,dv,zeros(UInt8),level,1,0,nature,affection)
    end
end
    
# abstract type AttackEffect end

mutable struct AttackEffect
    id::Int
    func::Function
    args::Tuple
end

mutable struct Attack
    id::UInt
    apmax::UInt8
    ap::UInt8

    type::UInt8
    class::UInt8
    power::UInt8
    accuracy::UInt8
    priority::Int8
    critrate::Int8

    effect::Vector{AttackEffect}

    function Attack()
        new(0,0,0,0,0,0,0,0,0,[])
    end

    function Attack(id,ap,apmax,class,type,power,accuracy,priority,critrate,effect)
        new(id,ap,apmax,class,type,power,accuracy,priority,critrate,effect)
    end
end

function loadBattleAttacks(pkmn)
    ad = deserialize("data/attacks.data")

    at = pkmn.attacks
    attacks = Attack[]

    for i in 1:min(size(pkmn.attacks,2),4)
        id = at[1,i]

        push!(attacks,Attack(
            id,
            at[2,i],
            at[3,i],

            ad[id,2],
            ad[id,3],
            ad[id,4],
            ad[id,5],
            1,
            1,

            AttackEffect[]
        ))
    end

    return attacks
end
#= status
0x00
0x01 -> gift
0x02 -> verbrannt
0x03 -> paralyse
0x04 -> schlaf
0x05 -> gefroren
0x06 -> kampfunfähig
=#

mutable struct Pkmn
    id::UInt16
    name::String
    gender::UInt8
    shiny::Bool
    form::UInt8
    xptype::UInt8

    otrainer::String
    otrainerid::UInt16
    location::String
    ball::UInt8
    markers::Vector{Bool}

    type::Tuple{UInt8,UInt8}
    stats::Stats
    status::UInt8
    item::Int

    attacks::Matrix{UInt16}
    ability::UInt16

    evolve::UInt16
end


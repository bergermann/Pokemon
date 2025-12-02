# types used to characterize and manage pokemons


const typetable = Rational{UInt8}[
 #  no  pf  fe  wa  ka  fl  gi  bo  st  kä  ge  el  ps  eis dr  un  st  fee
    1   1   1   1   1   1   1   1   .5  1   0   1   1   1   1   1   .5  1   # normal
    1   .5  .5  2   1   .5  .5  2   2   .5  1   1   1   1   .5  1   .5  1   # pflanze
    1   2   .5  .5  1   1   1   1   .5  2   1   1   1   2   .5  1   2   1   # feuer
    1   .5  2   .5  1   1   1   2   2   1   1   1   1   1   .5  1   1   1   # wasser
    2   1   1   1   1   .5  .5  1   2   .5  0   1   .5  2   1   2   2   .5  # kampf
    1   2   1   1   2   1   1   1   .5  2   1   .5  1   1   1   1   .5  1   # flug
    1   2   1   1   1   1   .5  .5  .5  1   .5  1   1   1   1   1   0   2   # gift
    1   .5  2   1   1   0   2   1   2   .5  1   2   1   1   1   1   2   1   # boden
    1   1   2   1   .5  2   1   .5  1   2   1   1   1   2   1   1   .5  1   # stein
    1   2   .5  1   .5  .5  .5  1   1   1   .5  1   2   1   1   2   .5  .5  # käfer
    0   1   1   1   1   1   1   1   1   1   2   1   2   1   1   .5  1   1   # geist
    1   .5  1   2   1   2   1   0   1   1   1   .5  1   1   .5  1   1   1   # elektro
    1   1   1   1   2   1   2   1   1   1   1   1   .5  1   1   0   .5  1   # psycho
    1   2   .5  .5  1   2   1   2   1   1   1   1   1   .5  2   1   .5  1   # eis
    1   1   1   1   1   1   1   1   1   1   1   1   1   1   2   1   .5  0   # drache
    1   1   1   1   .5  1   1   1   1   1   2   1   2   1   1   .5  1   .5  # unlicht
    1   1   .5  .5  1   1   1   1   2   1   1   .5  1   2   1   1   .5  2   # stahl
    1   1   .5  1   2   1   .5  1   1   1   1   1   1   1   2   2   .5  1   # fee
]

const TypeNames = Base.ImmutableDict(
    Tnone     => "Null",
    Tnormal   => "Normal",
    Tgrass    => "Pflanze",
    Tfire     => "Feuer",
    Twater    => "Wasser",
    Tfight    => "Kampf",
    Tflying   => "Flug",
    Tpoison   => "Gift",
    Tground   => "Boden",
    Trock     => "Gestein",
    Tbug      => "Käfer",
    Tghost    => "Geist",
    Telectric => "Elektro",
    Tpsycho   => "Psycho",
    Tice      => "Eis",
    Tdragon   => "Drache",
    Tdark     => "Unlicht",
    Tsteel    => "Stahl",
    Tfairy    => "Fee",
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
        new(bv,dv,          zeros(UInt8,6),zeros(UInt16,6),0,level,0,rand(1:25),0)
    end

    function Stats(bv,dv,level,nature,affection)
        new(bv,dv,          zeros(UInt8,6),zeros(UInt16,6),0,level,0,nature,affection)
    end
end
    
# abstract type AttackEffect end

mutable struct Atk
    id::UInt16
    ap::UInt8
    apmax::UInt8
end

mutable struct AttackEffect
    id::Int
    func::Function
    args::Tuple
end

mutable struct Attack
    atk::Atk

    type::PType
    class::AttackClass
    power::UInt8
    accuracy::UInt8
    priority::Int8
    critrate::Int8

    effect::Vector{AttackEffect}

    function Attack()
        new(Atk(0,0,0),Tnone,ACnone,0,0,0,0,[])
    end

    function Attack(atk,class,type,power,accuracy,priority,critrate,effect)
        new(atk,class,type,power,accuracy,priority,critrate,effect)
    end
end


mutable struct Pkmn
    id::UInt16
    name::String
    gender::Gender
    shiny::Bool
    form::UInt8
    xptype::UInt8

    otrainer::String
    otrainerid::UInt16
    location::String
    ball::BallID

    type::Tuple{PType,PType}
    stats::Stats
    status::HealthStatus
    item::Items

    attacks::Vector{Atk}
    ability::Ability

    evolve::UInt16
end

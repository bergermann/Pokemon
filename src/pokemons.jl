#pokemon stuff

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

    hp::UInt16

    level::UInt8
    xp::UInt32

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

function effectNo()
    return
end

mutable struct Attack
    id::UInt
    name::String
    description::String
    ap::UInt8
    apmax::UInt8

    class::UInt8
    type::UInt8
    power::UInt8
    accuracy::UInt8
    priority::Int8
    critrate::Int8

    effect::Function

    function Attack()
        new(0,"","",0,0,0,0,0,0,0,0,effectNo)
    end

    function Attack(id,name,description,ap,apmax,class,type,power,accuracy,priority,critrate,effect)
        new(id,name,description,ap,apmax,class,type,power,accuracy,priority,critrate,effect)
    end
end

mutable struct Item
    name::String
    description::String
    type::UInt8

    function Item()
        new("","",0x00)
    end
end

struct Pokeball
    name::String
    description::String
    catchrate::Float64
    sprite
end

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
    item::Item

    attacks::Vector{Attack}
    ability::UInt16
end





function getStatsBase()
    return readdlm("pkmn_data.csv",',',UInt16,'\n'; skipstart=1)
end

function getNames(lang::String)
    return readlines("str/names_"*lang*".txt")
end

function getGender(genderweight::Vector{UInt16})
    s = sum(genderweight)
    r = rand()

    if r < genderweight[1]/s
        return 0x00
    elseif r < (genderweight[1]+genderweight[2])/s
        return 0x01
    else
        return 0x02
    end
end





function updateStats!(pkmn::Pkmn)
    N = natureMod(pkmn.stats.nature)

    pkmn.stats.rv[1] = UInt16(floor(UInt16,
        (2*pkmn.stats.bv[1]+pkmn.stats.dv[1]+floor(pkmn.stats.ev[1]/4))*pkmn.stats.level/100)
        +pkmn.stats.level+10)
    
    for i in 2:6
        pkmn.stats.rv[i] = floor(UInt16,floor(UInt16,
            (2*pkmn.stats.bv[i]+pkmn.stats.dv[i]+floor(pkmn.stats.ev[i]/4))*pkmn.stats.level/100+5)
            *(1+0.1*N[i-1]))
    end

    return
end

function natureMod(nature::UInt8)
    a = zeros(Int8,5)

    a[div(nature-0x01,0x05)+0x01] += 1
    a[(nature-0x01)%0x05+0x01] -= 1

    return a
end

function generatePkmn(game,id::UInt16,level::UInt8)
    data = game.pkmndata.base[id,:]
    
    p =  Pkmn(
        id,                             #id
        "",                             #name
        getGender(data[14:end]),        #gender from weight
        rand(UInt16) < 0x0010,          #shiny
        0x00,                           #form
        data[13],                       #xptype
        game.trainer.name,              #OTrainer
        game.trainer.id,                #OTrainer id
        "",                             #location
        0x00,                           #ball id
        falses(5),                      #markers
        Tuple{UInt8,UInt8}(data[2:3]),  #types
        Stats(data[4:9],level),         #stats
        0x00,                           #status
        Item(),                         #item
        [
            Attack(
                0x01,
                "Tackle",
                "Trifft den Gegner mit vollem Körpereinsatz.",
                35,
                35,
                0,
                1,
                40,
                100,
                0,
                1,
                effectNo
            ),
            Attack(
                0x02,
                "Rankenhieb",
                "Peitschenartiger Schlag mit Ranken.",
                25,
                25,
                0,
                2,
                45,
                100,
                0,
                1,
                effectNo
            )
        ],                              #attacks
        0x00
    )

    updateStats!(p)

    p.stats.hp = p.stats.rv[1]
    p.stats.xp = xpFormulas(level,p.xptype)

    return p
end

function getHealthBar(pokemon::Pkmn)
    return ceil(Int,48*pokemon.stats.hp/pokemon.stats.rv[1])
end

function getHealthBar(pokemon::Pkmn,hp::Int)
    return ceil(Int,48*hp/pokemon.stats.rv[1])
end

function xpFormulas(level::UInt8,xptype::UInt8)
    n = UInt(level)

    if n == 1
        return 0
    elseif xptype == 1
        if n <= 50
            return floor(UInt32,n^3*(100-n)/50)
        elseif n <= 68
            return floor(UInt32,n^3*(150-n)/100)
        elseif n <= 98
            return floor(UInt32,n^3*floor(UInt,(1911-10*n)/3)/500)
        else
            return floor(UInt32,n^3*(160-n)/100)
        end
    elseif xptype == 0x02
        return floor(UInt32,4n^3/5)
    elseif xptype == 0x03
        return UInt32(n^3)
    elseif xptype == 0x04
        return floor(UInt32,6n^3/5-15n^2+100n-140)
    elseif xptype == 0x05
        return floor(UInt32,5n^3/4)
    else
        if n <= 15
            return floor(UInt32,n^3*(24+floor(UInt32,(n+1/3)))/50)
        elseif n <= 36
            return floor(UInt32,n^3*(14+n)/50)
        else
            return floor(UInt32,n^3*(32+floor(UInt,n/2))/50)
        end
    end
end

function pkmnName(game,pkmn::Pkmn)
    if pkmn.name == ""
        return game.pkmndata.name[pkmn.id]
    end
    
    return pkmn.name
end

getPkmnName(game,pkmn::Pkmn) = pkmnName(game,pkmn)

function activePkmn(game)
    return game.trainer.pokemon[
        findfirst(x->x.stats.hp!=0x0000,game.trainer.pokemon)
    ]
end
using JSON, DelimitedFiles, Serialization

mutable struct Atk
    id::UInt16
    ap::UInt8
    apmax::UInt8
end

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
        new(bv,rand(0:31,6),zeros(UInt8,6),zeros(UInt16,6),
            0,level,0,
            rand(1:25),0)
    end

    function Stats(bv,dv,level)
        new(bv,dv,zeros(UInt8,6),zeros(UInt16,6),
            0,level,0,
            rand(1:25),0)
    end

    function Stats(bv,dv,ev,level,nature,affection)
        new(bv,dv,ev,zeros(UInt16,6),
            0,level,0,
            nature,affection)
    end
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
    item::Int

    attacks::Vector{Atk}
    ability::UInt16

    evolve::UInt16
end

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

mutable struct PkmnData
    base::Matrix{UInt16}
    name::Vector{String}

    attacks::Matrix{UInt8}
    attacknames::Vector{String}

    function PkmnData()
        new(readdlm("data/pkmn_data.csv",',',UInt16,'\n'; skipstart=1),
            readlines("str/ger/pkmn_names.txt"),
            deserialize("data/attacks.data"),
            readlines("str/ger/attack_names.txt"))
    end
end

pdata = PkmnData()

balls_ = readlines("str/ger/pokeballs.txt")
balls = Dict(balls_[i] => i for i in eachindex(balls_))

items_ = readlines("str/ger/item_names.txt")
items = Dict{Any,Int}(items_[i] => i for i in eachindex(items_))
items["none"] = 0; items[0] = 0; items[""] = 0

genders = Dict(
    "none" => 0,
    "male" => 1,
    "female" => 2,
    0 => 0,
    1 => 1,
    2 => 2,
)

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

    pkmn.stats.rv[1] = calcHP(pkmn)
    
    for i in 2:6
        pkmn.stats.rv[i] = floor(UInt16,floor(UInt16,
            (2*pkmn.stats.bv[i]+pkmn.stats.dv[i]+floor(pkmn.stats.ev[i]/4))
                *pkmn.stats.level/100+5)*(1+0.1*N[i-1]))
    end

    return
end

function natureMod(nature::UInt8)
    a = zeros(Int8,5)

    a[div(nature-0x01,0x05)+0x01] += 1
    a[(nature-0x01)%0x05+0x01] -= 1

    return a
end

function calcHP(pkmn::Pkmn)
    return UInt16(
        floor(UInt16,
            (2*pkmn.stats.bv[1]+pkmn.stats.dv[1]+floor(pkmn.stats.ev[1]/4))*
            pkmn.stats.level/100
        )+pkmn.stats.level+10
    )
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

function xpFormulas(level,xptype)
    return Int(xpFormulas(UInt8(level),UInt8(xptype)))
end

function parseTrainer(i::Int,d::Dict)
    pkmn = Pkmn[]

    ailevel = get(d,"ai level",rand(1:100))

    for p in d["pokemon"]
        push!(pkmn,parsePkmn(p,ailevel))
    end

    return Trainer(
        get(d,"sprite",1),
        d["name"],
        ailevel,

        get(d,"prize money",100),

        get(d,"introtext","Hi."),
        get(d,"outrotext","Bye."),
        get(d,"intertext",""),
        get(d,"extrotext","Yikers."),

        pkmn
    )
end

function genEV(ailevel::Int)
    ev_ = rand(6)*ailevel/100
    ev = zeros(UInt8,6)

    EV = 510
    for i in 1:6
        idx = argmax(ev_)

        dev = min(ceil(UInt8,ev_[idx]*252),EV)
        ev_[idx] = 0
        ev[idx] = dev
        EV -= dev

        if EV <= 0; break; end
    end

    return ev
end

function parsePkmn(p::Dict,ailevel::Int)
    id = findfirst(isequal(p["id"]),pdata.name)

    data = pdata.base[id,:]
    bv = data[4:9]
    dv = get(p,"DV",round.(UInt8,31*rand(6)*ailevel/100))
    ev = get(p,"EV",genEV(ailevel))

    stats = Stats(bv,dv,ev,p["level"],
        get(p,"nature",rand(1:25)),
        get(p,"affection",rand(UInt8)))

    a = get(p,"attacks",[])
    attacks = Atk[]

    for atk in a
        a_ = findfirst(isequal(atk),pdata.attacknames)
        apmax = pdata.attacks[a_,5]
        push!(attacks,Atk(a_,apmax,apmax))
    end

    if isempty(attacks)
        ad = deserialize("data/pkmn/$id/attacks.data")

        idx0 = findfirst(!isequal(0),ad[:,1]); idx1 = findlast(<=(level),ad[:,1])
        ab = ad[idx0:idx1,2]; shuffleAttacks!(ab)

        for i in 1:min(length(ab),4)
            apmax = game.data.attacks[ab[i],5]
            push!(attacks,Atk(ab[i],apmax,apmax))
        end
    end

    pkmn = Pkmn(
        id,
        "",
        genders[get(p,"gender",getGender(data[14:end]))],
        get(p,"shiny",rand(UInt16) < 0x0010),
        0,
        0,

        "",
        0x0000,
        "",
        balls[get(p,"ball","Pokéball")],
        [],

        Tuple{UInt8,UInt8}(data[2:3]),
        stats,
        0x00,
        items[get(p,"item",0)],

        attacks,
        0x0000, # UInt16(p["ability"]),

        0x0000,
    )

    updateStats!(pkmn)

    pkmn.stats.hp = pkmn.stats.rv[1]
    pkmn.stats.xp = xpFormulas(pkmn.stats.level,pkmn.xptype)

    return pkmn
end


for i in 1:1000
    p = "data/trainers/jsons/$i.json"

    if !isfile(p); break; end

    d = JSON.parse(read(p,String))

    serialize("data/trainers/$i.td",parseTrainer(i,d))
end
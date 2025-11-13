using JSON, DelimitedFiles, Serialization

module Pokemon
using DelimitedFiles, Serialization
end


function parseTrainer(i::Int,d::Dict)
    pkmn = Pokemon.Pkmn[]

    ailevel = get(d,"ai level",rand(1:100))

    for p in d["pokemon"]
        push!(pkmn,parsePkmn(p,ailevel))
    end

    return Pokemon.Trainer(
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

    stats = Pokemon.Stats(bv,dv,ev,p["level"],
        get(p,"nature",rand(1:25)),
        get(p,"affection",rand(UInt8)))

    a = get(p,"attacks",[])
    attacks = Pokemon.Atk[]

    for atk in a
        a_ = findfirst(isequal(atk),pdata.attacknames)
        apmax = pdata.attacks[a_,5]
        push!(attacks,Pokemon.Atk(a_,apmax,apmax))
    end

    if isempty(attacks)
        ad = deserialize("data/pkmn/$id/attacks.data")

        idx0 = findfirst(!isequal(0),ad[:,1]); idx1 = findlast(<=(level),ad[:,1])
        ab = ad[idx0:idx1,2]; shuffleAttacks!(ab)

        for i in 1:min(length(ab),4)
            apmax = game.data.attacks[ab[i],5]
            push!(attacks,Pokemon.Atk(ab[i],apmax,apmax))
        end
    end

    pkmn = Pokemon.Pkmn(
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
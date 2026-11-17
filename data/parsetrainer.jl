using JSON, DelimitedFiles, Serialization, Pokemon
using Pokemon: Trainer, Pkmn, Stats, PType, Atk, getGender, updateStats!, xpFormulas

pdata = Pokemon.PkmnData()

getEnum(enum) = getproperty(Pokemon,Symbol(enum))

function parseTrainer(i::Int,d::JSON.Object{String,Any})
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

function parsePkmn(p::JSON.Object{String,Any},ailevel::Int)
    id = findfirst(isequal(p["id"]),pdata.name)

    data = pdata.base[id,:]
    bv = data[4:9]
    dv = get(p,"DV",round.(UInt8,31*rand(6)*ailevel/100))

    stats = Stats(
        bv,dv,UInt8(p["level"]),Pokemon.XP_NONE,
        get(p,"nature",rand(1:25)),
        get(p,"affection",rand(UInt8)))

    stats.ev .= get(p,"EV",genEV(ailevel))

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
        "",                                                                     # name
        haskey(p,"gender") ? getEnum(p["gender"]) : getGender(data[14:end]),    # gender
        get(p,"shiny",rand(UInt16) < 0x0010),                                   # shiny
        0x00,                                                                   # form

        "",                                                                     # otrainer
        0x0000,                                                                 # otrainerid
        "",                                                                     # location
        
        haskey(p,"ball") ? getEnum(p["ball"]) : Pokemon.BALL_POKE,              # ball
        Tuple{PType,PType}(PType.(data[2:3])),                                  # type
        stats,                                                                  # stats
        Pokemon.HSnormal,                                                       # status
        haskey(p,"item") ? getEnum(p["item"]) : nothing,                        # item

        attacks,                                                                # attacks
        Pokemon.A_NONE, # FIX!                                                  # ability

        0x0000,                                                                 # evolve
    )

    updateStats!(pkmn)

    pkmn.stats.hp = pkmn.stats.rv[1]

    return pkmn
end

# t = JSON.parse(read("data/trainers/raw/1.json"))
# p = t["pokemon"][1]
# parsePkmn(p,0)

for i in 1:1000
    p = "data/trainers/raw/$i.json"

    if !isfile(p); break; end

    d = JSON.parse(read(p,String))

    trainer = parseTrainer(i,d)

    serialize("data/trainers/compiled/$i.td",trainer)
end
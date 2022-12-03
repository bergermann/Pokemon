#pokemon stuff


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

mutable struct Attack
    name::String
    description::String

    power::UInt8
    accuracy::UInt8

    effect::Function
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
end

function getStatsBase()
    return readdlm("pkmn_data.csv",',',UInt16,'\n'; skipstart=1)
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

    pkmn.stats.rv[1] = UInt16(floor(UInt8,
        (2*pkmn.stats.bv[1]+pkmn.stats.dv[1]+floor(pkmn.stats.ev[1]/4))*pkmn.stats.level/100)
        +pkmn.stats.level+10)
    
    for i in 2:6
        pkmn.stats.rv[i] = floor(UInt16,floor(UInt8,
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

function generatePkmn(game,id::UInt8,level::UInt8)
    

    function Pkmn(game,id::UInt8,level::UInt8)
        data = game.pkmndata.base[id,:]
        
        new(
            id,"",getGender(data[14:end]),rand(UInt16) < 0x0010,0x00,data[13],
            game.trainer.name,game.trainer.id,"",0x00,falses(5),
            Tuple{UInt8,UInt8}(data[2:3]),Stats(data[4:9],level),0x00,Item(),[]
        )
    end
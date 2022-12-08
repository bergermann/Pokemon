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
    ap::UInt8

    power::UInt8
    accuracy::UInt8
    priority::Int8

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
        []                              #attacks
    )

    updateStats!(p)

    p.stats.hp = p.stats.rv[1]
    p.stats.xp = xpFormulas(level,p.xptype)

    return p
end

function getHealthBar(pokemon::Pkmn)
    return ceil(Int,48*pokemon.stats.hp/pokemon.stats.rv[1])
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
    else
        return pkmn.name
    end
end

function activePkmn(game)
    return game.trainer.pokemon[
        findfirst(x->x.stats.hp!=0x0000,game.trainer.pokemon)
    ]
end
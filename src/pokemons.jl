#pokemon stuff




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

function generatePkmn(game::GameState,id::UInt16,level::UInt8)
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

# function getHealthBar(pokemon::Pkmn,hp::UInt16)
#     return ceil(Int,48*hp/pokemon.stats.rv[1])
# end

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

function calcXpDrop1(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    return floor(UInt32,
        *(
            1+0.5*!(typeof(state)==BattleStateWild),
            100, #game.pkmndata.base[defender.pkmn.id], #xp base value
            1.5,    #trainer != otrainer
            1+0.5*(attacker.pkmn.item==0x00),   #glücksei
            defender.pkmn.stats.level
        )/7
    )
end

function pkmnName(game,pkmn::Pkmn)
    if pkmn.name == ""
        return game.pkmndata.name[pkmn.id]
    end
    
    return pkmn.name
end

getPkmnName(game,pkmn::Pkmn) = pkmnName(game,pkmn)

function activePkmn(game::GameState)
    return game.trainer.pokemon[
        findfirst(x->x.stats.hp!=0x0000,game.trainer.pokemon)
    ]
end

function getStatsBase()
    return readdlm("data/pkmn_data.csv",',',UInt16,'\n'; skipstart=1)
end

function getNames(lang::String)
    return readlines("str/"*lang*"/pkmn_names.txt")
end

function getGender(genderweight::Vector{UInt16})
    s = sum(genderweight)
    r = rand()

    if r < genderweight[1]/s
        return G_NONE
    elseif r < (genderweight[1]+genderweight[2])/s
        return G_MALE
    else
        return G_FEMALE
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

function calcHP(pkmn::Pkmn,levelups::UInt8,evups::UInt8)
    return UInt16(
        floor(UInt16,
            (2*pkmn.stats.bv[1]+pkmn.stats.dv[1]+floor((pkmn.stats.ev[1]+evups)/4))*
            (pkmn.stats.level+levelups)/100
        )+(pkmn.stats.level+levelups)+10
    )
end

function getHPBar(pkmn::Pkmn)
    return clamp(ceil(Int,48*pkmn.stats.hp/pkmn.stats.rv[1]),0,48)
end

function getHPBar(pkmn::Pkmn,hp::Int)
    return clamp(ceil(Int,48*hp/pkmn.stats.rv[1]),0,48)
end

function setHPBar!(game::GameState,spriteid::Symbol,value::Int,w0::Int)
    moveSpriteW!(game,spriteid,w0+div(value,2)+isodd(value),true)
    scaleSpriteW!(game,spriteid,Float64(value),true)
    setSpriteFrame!(game,spriteid,1+(value>12)+(value>24))

    return
end


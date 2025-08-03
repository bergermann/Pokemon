
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

function getXPBar(pkmn::Pkmn,xpgain::Int)
    x0 = xpFormulas(pkmn.stats.level,pkmn.xptype)

    return floor(Int,min(64,64*(pkmn.stats.xp+xpgain-x0)/
        (xpFormulas(pkmn.stats.level+1,pkmn.xptype)-x0)))
end

function setXPBar!(game::GameState,spriteid::Symbol,value::Int,w0::Int)
    moveSpriteW!(game,spriteid,w0+div(value,2)+isodd(value),true)
    scaleSpriteW!(game,spriteid,Float64(value),true)

    return
end



function calcXpDrop1(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    return floor(UInt32,
        *(
            1+0.5*!(typeof(state)==BattleStateWild),
            defender.xpdrop, #game.pkmndata.base[defender.pkmn.id], #xp base value
            1.5,    #trainer != otrainer
            1+0.5*(attacker.pkmn.item==0x00),   #glücksei
            defender.pkmn.stats.level,
            10  # remove this
        )/7
    )
end



function addEV!(pkmn::Pkmn,from::UInt16)
    if sum(pkmn.stats.ev) >= 510; return; end

    data = deserialize()

    return
end




function checkEvolve(game::GameState)
    for i in eachindex(game.p.pokemon)
        if game.p.pokemon[i].evolve != 0x0000; return i; end
    end

    return 0
end


function checkEvolveLevelUp(pkmn::Pkmn)
    data = deserialize("data/pkmn/$(pkmn.id)/evolve.data")
    
    for i in axes(data,1)
        if data[2] == EVnone
            return 0x0000
        elseif data[4] != 0x0000 && data[4] != pkmn.gender
            continue
        elseif data[2] == EVlevelup
            if pkmn.stats.level >= data[3]; return data[1]; end
        elseif data[2] == EVitemheld
            if pkmn.item == data[3]; return data[1]; end
        elseif data[2] == EVfriendship
            if pkmn.stats.affection >= data[3]; return data[1]; end
        elseif data[2] == hasattack
            if occursin(data[3],pkmn.attacks); return data[1]; end
        end
    end

    return 0x0000
end

function checkEvolveItem(pkmn::Pkmn,item::UInt16)
    data = deserialize("data/pkmn/$(pkmn.id)/evolve.data")
    
    for i in axes(data,1)
        if data[2] == EVnone
            return 0x0000
        elseif data[4] != 0x0000 && data[4] != pkmn.gender
            continue
        elseif data[2] == EVitem || data[2] == EVitemtrade
            if data[3] == item; return data[1]; end
        end
    end

    return 0x0000
end

function evolvePokemon!(pkmn::Pkmn,to::UInt16)
    pkmn.id = to

    updateStats!(pkmn)
    learnLevelUp!(pkmn)

    return
end

function learnLevelUp!(pkmn::Pkmn)
    data = deserialize("data/pkmn/$(pkmn.id)/evolve.data")
    
    for i in axes(data,1)
        if data[i,1] == pkmn.stats.level && !hasattack(pkmn,data[i,2])
            push!(pkmn.attacks,data[i,2])
        end
    end

    return
end

function learnMachine!(pkmn::Pkmn,machine::Machine)
    if !hasattack(pkmn,machine.attack); push!(pkmn.attacks,machine.attack); end; return
end

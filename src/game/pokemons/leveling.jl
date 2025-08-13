
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
            defender.xpdrop, #game.data.base[defender.pkmn.id], #xp base value
            1.5,    #trainer != otrainer
            1+0.5*(attacker.pkmn.item==0x00),   #glücksei
            defender.pkmn.stats.level,
            10  # remove this
        )/7
    )
end



function addEV!(pkmn::Pkmn,from::UInt16)
    ev = pkmn.stats.ev; S = sum(ev); if S >= 510; return; end

    data = deserialize("data/pkmn/$(from)/ev.data")

    for i in eachindex(data)
        ev[i] += UInt8(min(0xfc-ev[i],510-S,data[i]))
    end

    return
end




function levelup!(pkmn::Pkmn,levelups::Int,game::GameState)
    learnLevelUp!(pkmn,levelups,game)

    hp = pkmn.stats.rv[1]; pkmn.stats.level += levelups
    updateStats!(pkmn); pkmn.stats.hp += pkmn.stats.rv[1]-hp
    
    pkmn.evolve = checkEvolveLevelUp(pkmn)

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
        if data[i,2] == EVnone
            return 0x0000
        elseif data[i,4] != 0x0000 && data[i,4] != pkmn.gender
            continue
        elseif data[i,2] == EVlevelup
            if pkmn.stats.level >= data[i,3]; return data[i,1]; end
        elseif data[i,2] == EVitemheld
            if pkmn.item == data[i,3]; return data[i,1]; end
        elseif data[i,2] == EVfriendship
            if pkmn.stats.affection >= data[i,3]; return data[i,1]; end
        elseif data[i,2] == hasattack
            if occursin(data[i,3],pkmn.attacks); return data[i,1]; end
        end
    end

    return 0x0000
end

function checkEvolveItem(pkmn::Pkmn,item::UInt16)
    data = deserialize("data/pkmn/$(pkmn.id)/evolve.data")
    
    for i in axes(data,1)
        if data[i,2] == EVnone
            return 0x0000
        elseif data[i,4] != 0x0000 && data[i,4] != pkmn.gender
            continue
        elseif data[i,2] == EVitem || data[i,2] == EVitemtrade
            if data[i,3] == item; return data[i,1]; end
        end
    end

    return 0x0000
end

function evolvePokemon!(pkmn::Pkmn,game::GameState)
    pkmn.id = pkmn.evolve; pkmn.evolve = 0x00

    # reload base stats here FIX

    updateStats!(pkmn)
    learnLevelUp!(pkmn,game)

    return
end

function learnLevelUp!(pkmn::Pkmn,game::GameState)
    data = deserialize("data/pkmn/$(pkmn.id)/attacks.data")
    
    for i in axes(data,1)
        if data[i,1] == pkmn.stats.level; learnAttack!(pkmn,data[i,2],game); end
    end

    return
end

function learnLevelUp!(pkmn::Pkmn,levelups::Int,game::GameState)
    data = deserialize("data/pkmn/$(pkmn.id)/attacks.data")

    l = pkmn.stats.level

    for i in axes(data,1)
        if l < data[i,1] <= l+levelups; learnAttack!(pkmn,data[i,2],game); end
    end

    return
end

function learnAttack!(pkmn::Pkmn,attack::UInt16,game::GameState)
    if !hasattack(pkmn,attack)
        apmax = game.data.attacks[attack,5]
        push!(pkmn.attacks,Atk(attack,apmax,apmax))

        println("pkmn $(pkmn.id) learned attack $attack")
    end

    return
end

learnAttack!(game::GameState,pkmn::Pkmn,machine::Machine) =
    learnAttack!(game,pkmn,machine.attack)
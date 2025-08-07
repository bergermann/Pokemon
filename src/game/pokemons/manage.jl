
function generatePkmn(game::GameState,id::UInt16,level::UInt8)
    data = game.data.base[id,:]
    ad = deserialize("data/pkmn/$id/attacks.data")
    idx0 = findfirst(!isequal(0),ad[:,1]); idx1 = findlast(<=(level),ad[:,1])
    ab = ad[idx0:idx1,2]; shuffleAttacks!(ab)

    attacks = Vector{Atk}(undef,length(ab))
    for i in eachindex(ab)
        apmax = game.data.attacks[ab[i],5]
        attacks[i] = Atk(ab[i],apmax,apmax)
    end
    
    p =  Pkmn(
        id,                             # id
        "",                             # name
        getGender(data[14:end]),        # gender from weight
        rand(UInt16) < 0x0010,          # shiny
        0x00,                           # form
        data[13],                       # xptype
        game.p.name,                    # OTrainer
        game.p.id,                      # OTrainer id
        "",                             # location
        0x01,                           # ball id
        falses(5),                      # markers
        Tuple{UInt8,UInt8}(data[2:3]),  # types
        Stats(data[4:9],level),         # stats
        0x00,                           # status
        0,                              # item
        attacks,                        # attacks
        0x00,                           # ability
        0x00,                           # evolve
    )

    updateStats!(p)

    p.stats.hp = p.stats.rv[1]
    p.stats.xp = xpFormulas(level,p.xptype)

    return p
end

function shuffleAttacks!(attacks::Vector{UInt16})
    for i in 5:length(attacks)
        if rand() <= 0.5
            idx = rand(1:4)
            attacks[idx], attacks[i] =  attacks[i], attacks[idx]
        end
    end

    quicksort!(attacks,5,length(attacks))

    return
end



function addPokemon!(game::GameState,pkmn::Pkmn)
    if game.p.pokemon.idx < 6
        push!(game.p.pokemon,pkmn)
    else
        b = findfirst(x->x.idx<30,game.p.boxes)

        push!(game.p.boxes[b],pkmn)
    end

    return
end

function removePokemon!(game::GameState,)
    

    return
end



function isfainted(pkmn::Pkmn)
    return pkmn.status == 0x06
end

function isfainted(game::GameState,i::Int)
    return game.p.pokemon[i].status == 0x06
end



function hasattack(pkmn::Pkmn,attack::UInt16)
    for atk in pkmn.attacks
        if atk.id == attack; return true; end
    end

    return false
end

function hasitem(pkmn::Pkmn)
    return pkmn.item > 0
end

function hasitem(pkmn::Pkmn,item::UInt16)
    return pkmn.item == item
end

function hasitem(game::GameState,i::Int)
    return game.p.pokemon[i].item > 0
end



function pkmnName(game::GameState,pkmn::Pkmn)
    if pkmn.name == ""
        return game.data.name[pkmn.id]
    end
    
    return pkmn.name
end

getPkmnName(game::GameState,pkmn::Pkmn) = pkmnName(game,pkmn)



function activePkmn(game::GameState)
    return game.p.pokemon[findfirst(p->p.stats.hp>0x0000,game.p.pokemon.data)]
end

function activePkmn!(game::GameState)
    idx = findfirst(x->x.stats.hp>0x0000,game.p.pokemon.data)

    if idx == 1
        return
    end

    swap!(game.p.pokemon,1,idx)
    game.battle.teamperm[1], game.battle.teamperm[idx] = 
        game.battle.teamperm[idx], game.battle.teamperm[1]

    return
end



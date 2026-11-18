
function healPkmn!(pkmn::Pkmn)
    pkmn.stats.hp = pkmn.stats.rv[1]
    pkmn.status = HS_NORMAL

    for atk in pkmn.attacks
        atk.ap = atk.apmax
    end
    
    return
end

function healAll!(game::GameState)
    for pkmn in game.p.pokemon
        healPkmn!(pkmn)
    end

    for box in game.p.boxes, pkmn in box
        healPkmn!(pkmn)
    end

    game.flags.general[SF_HEALED] = true

    return
end
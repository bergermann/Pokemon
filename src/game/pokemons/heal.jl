
function healPkmn!(pkmn::Pkmn)
    pkmn.stats.hp = pkmn.stats.rv[1]
    pkmn.status = 0x00

    pkmn.attacks[3,:] .= pkmn.attacks[2,:]
    
    return
end

function healAll!(game::GameState)
    for pkmn in game.p.pokemon
        healPkmn!(pkmn)
    end

    for box in game.p.boxes, pkmn in box
        healPkmn!(pkmn)
    end

    game.flags.general[0xc8] = true

    return
end
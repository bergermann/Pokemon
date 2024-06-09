


function checkTeleport!(game::GameState,movepos::Position)
    col = game.maps.map.tilemap.collision[movepos[1],movepos[2]]

    if col ∉ 0x14:0x3b
        return
    end

    teleport!(game,game.maps.map.exits[col-0x13])

    return
end













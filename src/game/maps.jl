


function checkTeleport!(game::GameState,movepos::Position)
    r = game.im.c.renderdistance
    col = game.m.chunkdata[game.m.idxs[r+1,r+1]].collision[movepos[1],movepos[2],1]

    if col ∉ 0x14:0x3b
        return
    end

    # teleport!(game,game.maps.map.exits[col-0x13])

    return
end













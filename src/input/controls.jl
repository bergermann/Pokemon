


function mapAction!(game::GameState)
    b, npc = checkTileNPC(game)

    if b
        if npc.dialogue == 0    # FIX
            return
        end

        stateSetDialogue!(game,1,npc.dialogue,npc.dialoguelen)

        return
    end

    tile = game.maps.map.tilemap.collision[game.movepos.h,game.movepos.w]

    if 0x003c <= tile <= 0x004f
        stateSetDialogue!(game,1,tile-59,1)

        return
    end

    tile = game.maps.map.tilemap.collision[game.pos.h,game.pos.w]

    if 0x00a0 <= tile <= 0x00b3
        event = game.maps.map.events[tile-159]

        if event.onpress
            evalEvent(game,event)
        end

        return
    end
end





function updateGame!(game::GameState,inputs::Inputs)
    inputManager!(game,inputs)

    if game.overworld
        # arrange sprites here

        if !game.input.npclock
            manageNPCs!(game)
        end
    end

    for i in 1:game.callbacks.idx
        if game.callbacks[i].active
            game.callbacks[i].func(game,game.callbacks[i].args)
        end
    end

    drawAnimatedTiles!(game)
end

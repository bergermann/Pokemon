


function mapAction!(game::GameState)
    game.ctrl.mpos = game.ctrl.pos1+dirs[game.ctrl.dir]
    game.ctrl.mchunk = modc.(game.ctrl.mpos).+(game.im.c.renderdistance+1)
    # game.ctrl.mchunk = dirs[dir].+(game.im.c.renderdistance+1)
    @. game.ctrl.mpos = (game.ctrl.mpos+15)%16+1

    # b, npc = checkTileNPC(game)

    # if b
    #     if npc.dialogue == 0    # FIX
    #         return
    #     end

    #     stateSetDialogue!(game,1,npc.dialogue,npc.dialoguelen)

    #     return
    # end

    tile = getCollision(game,game.ctrl.mpos,game.ctrl.mchunk,game.ctrl.l)

    if 0x003c <= tile <= 0x004f
        stateSetDialogue!(game,1,tile-59,1)

        return
    end

    tile = getCollision(game,game.ctrl.pos1,game.ctrl.chunk,game.ctrl.l)

    if 0x00a0 <= tile <= 0x00b3
        event = game.maps.map.events[tile-159]

        if event.onpress
            evalEvent(game,event)
        end

        return
    end

    return
end





function updateGame!(game::GameState,inputs::Inputs)
    inputManager!(game,inputs)

    if game.overworld
        # arrange sprites here

        if !game.ctrl.input.npclock
            # manageNPCs!(game)
        end
    end

    for i in 1:game.callbacks.idx
        if game.callbacks[i].active
            evalCallback(game,game.callbacks[i])
        end
    end

    return
end

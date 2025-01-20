
function findSign(game::GameState,chunk::Pos,pos::Position,fg::Bool)
    for sign in game.m.chunkdata[game.m.idxs[chunk]].signs
        if sign[].fg==fg && isequal(sign[].pos,pos)
            return sign[].str
        end
    end

    return ["No sign found."]
end

function findEvent(game::GameState,chunk::Pos,pos::Position)
    for event in game.m.chunkdata[game.m.idxs[chunk]].events
        if event.px <= pos.x <= event.px+event.dx && event.py <= pos.y <= event.py+event.dy
            @info "At event $(event.id)."

            return event
        end
    end

    return E0
end

function mapAction!(game::GameState)
    @. game.ctrl.mpos = game.ctrl.pos1+dirs[game.ctrl.dir]
    @. game.ctrl.mchunk = modc(game.ctrl.mpos)+(game.im.c.renderdistance+1)
    @. game.ctrl.mpos = (game.ctrl.mpos+15)%16+1

    # b, npc = checkTileNPC(game)

    # if b
    #     if npc.dialogue == 0    # FIX
    #         return
    #     end

    #     stateSetDialogue!(game,1,npc.dialogue,npc.dialoguelen)

    #     return
    # end

    col = getCollision(game,game.ctrl.mpos,game.ctrl.mchunk,1+game.ctrl.fg)

    if col == 0x15
        stateSetDialogue!(game,findSign(game,game.ctrl.mchunk,game.ctrl.mpos,game.ctrl.fg))

        return
    end

    evalEvent(game,findEvent(game,game.ctrl.mchunk,game.ctrl.mpos))

    return
end





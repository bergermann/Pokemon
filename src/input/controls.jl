
function findNPC(game::GameState,chunk::Pos,pos::Position,fg::Bool)
    for npc in game.m.chunkdata[game.m.idxs[chunk]].npcs
        if npc[].fg==fg && isequal(npc[].pos,pos)
            return true,npc[].str
        end
    end

    return false,[""]
end

function findSign(game::GameState,chunk::Pos,pos::Position,fg::Bool)
    for sign in game.m.chunkdata[game.m.idxs[chunk]].signs
        if sign[].fg==fg && isequal(sign[].pos,pos)
            return sign[].str
        end
    end

    return ["No sign found."]
end

function findEvent(game::GameState,chunk::Pos,pos::Position,fg::Bool)
    for ev in game.m.events
        if ev.fg==fg &&
                16*(ev.cx-chunk.x)+ev.px <= pos.x <= 16*(ev.cx-chunk.x)+ev.px+ev.dx &&
                16*(ev.cy-chunk.y)+ev.py <= pos.y <= 16*(ev.cy-chunk.y)+ev.py+ev.dy

            @info "At event $(ev.id)."

            return ev
        end
    end

    return E0
end

function mapAction!(game::GameState)
    @. game.ctrl.mpos = game.ctrl.pos1+dirs[game.ctrl.dir]
    @. game.ctrl.mchunk = modc(game.ctrl.mpos)+(game.im.c.renderdistance+1)
    @. game.ctrl.mpos = (game.ctrl.mpos+15)%16+1

    b, npcstr = findNPC(game,game.ctrl.mpos,game.ctrl.mchunk,1+game.ctrl.fg)

    if b
        stateSetDialogue!(game,npcstr)

        return
    end

    col = getCollision(game,game.ctrl.mpos,game.ctrl.mchunk,1+game.ctrl.fg)

    if col == 0x15
        stateSetDialogue!(game,findSign(game,game.ctrl.mchunk,game.ctrl.mpos,game.ctrl.fg))

        return
    end

    evalEvent(game,findEvent(game,game.ctrl.mchunk,game.ctrl.mpos,game.ctrl.fg))

    return
end





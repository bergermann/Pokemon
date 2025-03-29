
function findNPC(game::GameState,chunk::Pos,pos::Position,fg::Bool)
    for npc in game.m.chunkdata[game.m.idxs[chunk]].npcs
        if npc[].fg==fg && isequal(npc[].pos1,pos)
            return true,npc[]
        end
    end

    return false,Ref{NPC}()
end

function findSign(game::GameState,chunk::Pos,pos::Position,fg::Bool)
    for sign in game.m.chunkdata[game.m.idxs[chunk]].signs
        if sign[].fg==fg && isequal(sign[].pos,pos)
            return sign[].str
        end
    end

    return ["No sign found."]
end

function findEvent(game::GameState)
    p = game.ctrl.mpos
    c = game.ctrl.chunk
    m = game.ctrl.mchunk
    r = Int(game.im.c.renderdistance)+1

    for ev in game.m.events[1:game.m.events.idx]
        if ev.fg==game.ctrl.fg &&
                16*(ev.cx-(c.x+m.x-r))+ev.px <= p.x <= 16*(ev.cx-(c.x+m.x-r))+ev.px+ev.dx &&
                16*(ev.cy-(c.y+m.y-r))+ev.py <= p.y <= 16*(ev.cy-(c.y+m.y-r))+ev.py+ev.dy

            @info "At event $(ev.id)."

            return ev
        end
    end

    @info "No event found."

    return E0
end

function mapAction!(game::GameState)
    @. game.ctrl.mpos = game.ctrl.pos1+dirs[game.ctrl.dir]
    @. game.ctrl.mchunk = modc(game.ctrl.mpos)+(game.im.c.renderdistance+1)
    @. game.ctrl.mpos = (game.ctrl.mpos+15)%16+1

    b, npc = findNPC(game,game.ctrl.mchunk,game.ctrl.mpos,game.ctrl.fg)

    if b
        if npc[].event != Symbol() && evalFlagSet(game,events[npc[].event])
            setupEvent!(game,npc[].event)
        else
            stateSetDialogue!(game,npc[].str)
        end

        return
    end

    col = getCollision(game,game.ctrl.mpos,game.ctrl.mchunk,1+game.ctrl.fg)

    if col == 0x15
        stateSetDialogue!(game,findSign(game,game.ctrl.mchunk,game.ctrl.mpos,game.ctrl.fg))

        return
    end

    evalEvent(game,findEvent(game))

    return
end





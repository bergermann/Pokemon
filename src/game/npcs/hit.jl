
function checkHit(game::GameState)
    if game.ctrl.movec == 1 || game.ctrl.movec == -1
        for i in eachindex(game.m.npcs)
            npc = game.m.npcs[i]
        
            if npc.fg == game.ctrl.fg && npc.trainerid != 0x0000 && !game.m.npchit[i] &&
                    length(game.m.npchits) >= 2 && hitscanNPC(game,npc)

                game.m.npchit[i] = true
                push!(game.m.npchits,i)
                
                lockInput!(game)
                activateCallback!(game,:hit)
            end
        end
    end

    return
end



function hitscanNPC(game::GameState,npc::NPC)
    if dirscanNPC(game,npc)
        # println("dir hit by npc ",npc.id)
        return linescanNPC(game,npc)
    end

    return false
end

function dirscanNPC(game,npc)
    c1 = game.ctrl.chunk; c2 = npc.chunk
    p1 = game.ctrl.pos2;  p2 = npc.pos2
    r = npc.range

    if npc.dir == 1
        return c1[2] == c2[2] && p1[2] == p2[2] && r >= (16*(c2[1]-c1[1])+p2[1]-p1[1]) > 0
    elseif npc.dir == 2
        return c1[1] == c2[1] && p1[1] == p2[1] && r >= (16*(c1[2]-c2[2])+p1[2]-p2[2]) > 0
    elseif npc.dir == 3
        return c1[2] == c2[2] && p1[2] == p2[2] && r >= (16*(c1[1]-c2[1])+p1[1]-p2[1]) > 0
    else
        return c1[1] == c2[1] && p1[1] == p2[1] && r >= (16*(c2[2]-c1[2])+p2[2]-p1[2]) > 0
    end
end

function linescanNPC(game::GameState,npc::NPC)
    c1 = game.ctrl.chunk; c2 = npc.chunk
    p1 = game.ctrl.pos2;  p2 = npc.pos2

    l = 1+npc.fg

    @. npc.mpos = p2+dirs[npc.dir]
    @. npc.mchunk = modc(npc.mpos)+(game.im.c.renderdistance+1)+c1-c2
    @. npc.mpos = (npc.mpos+15)%16+1

    if npc.dir == 1
        d = (16*(c2[1]-c1[1])+p2[1]-p1[1])+1

        for i in 1:d
            if !checkWalkable(game,npc.mpos,npc.mchunk,l); return false; end
            npc.mpos[1] -= 1
            if npc.mpos[1] == 0; npc.mpos[1] += 16; npc.mchunk[1] -= 1; end
        end
    elseif npc.dir == 2
        d = (16*(c1[2]-c2[2])+p1[2]-p2[2])

        for i in 1:d
            if !checkWalkable(game,npc.mpos,npc.mchunk,l); return false; end
            npc.mpos[2] += 1
            if npc.mpos[2] == 17; npc.mpos[2] -= 16; npc.mchunk[2] += 1; end
        end
    elseif npc.dir == 3
        d = (16*(c1[1]-c2[1])+p1[1]-p2[1])+1

        for i in 1:d
            if !checkWalkable(game,npc.mpos,npc.mchunk,l); return false; end
            npc.mpos[1] += 1
            if npc.mpos[1] == 17; npc.mpos[1] -= 16; npc.mchunk[1] += 1; end
        end
    else
        d = (16*(c2[2]-c1[2])+p2[2]-p1[2])+1

        for i in 1:d
            if !checkWalkable(game,npc.mpos,npc.mchunk,l); return false; end
            npc.mpos[2] -= 1
            if npc.mpos[2] == 0; npc.mpos[2] += 16; npc.mchunk[2] -= 1; end
        end
    end

    println("line hit by npc ",npc.id)

    return true
end


function manageTrainerHit!(game::GameState,()::Tuple{})
    k = true

    for npc in game.m.npchits
        k *= npc.
    end

    if k; killCallback!(game,:hit); end

    return
end
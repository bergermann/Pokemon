
function checkHit(game::GameState)
    if game.ctrl.movec == 1 || game.ctrl.movec == -1
        for i in eachindex(game.m.npcs)
            npc = game.m.npcs[i]
        
            if npc.trainerid != 0x0000 && npc.fg == game.ctrl.fg && !game.m.npchit[i] &&
                    length(game.m.npchits) <= 1 && hitscanNPC(game,npc)

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
        println("dir hit by npc ",npc.id)
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


function manageTrainerHit1!(game::GameState,()::Tuple{})
    manageNPCs!(game)

    k = true

    for n in game.m.npchits
        npc = game.m.npcs[n]

        if npc.dynamic
            if npc.c2 == 0
                npc.dynamic = false; npc.pattern = 0
            end
        else
            npc.pattern = 0
        end
    end

    if k
        game.callbacks[:hit].func = manageTrainerHit2!; game.n[:hit].c = 60
    end

    return
end


function manageTrainerHit2!(game::GameState,()::Tuple{})
    if length(game.m.npchits) == 0
        initBattleTrainer!(game)
        unlockInput!(game)
        deactivateCallback!(game,:hit)

        return
    end

    npc = game.m.npcs[game.m.npchits[1]]

    if game.n[:hit].c > 0
        if game.n[:hit].c == 60; createEmote!(game,npc,1); end

        game.n[:hit].c -= 1; return
    end

    if npc.c2 == 0
        @. npc.mpos = npc.pos1+dirs[npc.dir]
        @. npc.mchunk = modc(npc.mpos)+(game.im.c.renderdistance+1)+game.ctrl.chunk-npc.chunk
        @. npc.mpos = (npc.mpos+15)%16+1

        if isequal(game.ctrl.mchunk,npc.mchunk) && isequal(game.ctrl.pos2,npc.mpos)
            popfirst!(game.m.npchits); game.n[:hit].c = 60
            println("npc $(npc.id) finished moving")
        else
            @. npc.pos2 = npc.pos1+dirs[npc.dir]

            # checkChunks!(game,npc) # FIX

            setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4))+1+sum(npc.pos1)%2)
            reverseSpriteW!(game,npc.sprite,npc.dir==4)

            moveSprite!(game,npc.sprite,dirs[npc.dir][2],dirs[npc.dir][1])
        end
        
        npc.c2 += 1
    else
        moveSprite!(game,npc.sprite,dirs[npc.dir][2],dirs[npc.dir][1])

        if npc.c2 == 8
            @. npc.pos1 = npc.mpos

            setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4)))
        end

        npc.c2 += 1
        npc.c2 %= 16
    end

    return
end
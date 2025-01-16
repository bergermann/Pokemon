# NPC related stuff

# pattern directions: clockwise from starting direction
# patterns              # static
# 0 dont return         # none
# 1 return              # return
# 2 line                # line
# 3 angle               # angle
# 4 T                   # T rand
# 5 T clockwise         # T cw
# 6 T cclockwise        # T ccw
# 7 circ clockwise      # cw
# 8 circ cclockwise     # ccw
# 9 rand                # rand

# patterns              # dynamic
# 0 rand                # none
# 1 linear              # linear
# 2 angle               # angle
# 3 rectangle cw        # cw
# 4 rectangle ccw       # ccw



function manageNPCs!(game::GameState)
    for npc in game.m.npcs
        if npc.dynamic
            manageDynamicNPC!(game,npc)
        else
            manageStaticNPC!(game,npc)
        end
    end

    return
end

function manageStaticNPC!(game::GameState,npc::NPC)
    if npc.pattern <= 1         # none/return
        return
    elseif npc.pattern == 2     # line
        if npc.c1 == npc.parg1
            npc.dir = invdir(npc.dir)
            npc.c1 = 0
        end
    elseif npc.pattern == 3     # angle
        if npc.c1 == npc.parg1
            npc.dir = (npc.dir)%4+1
        elseif npc.c1 == 2*npc.parg1
            npc.dir = (npc.dir+2)%4+1
            npc.c1 = 0
        end
    elseif npc.pattern == 4     # T
        if npc.c1 == npc.parg1
            npc.dir = (npc.dir)%4+1
        elseif npc.c1 == 2*npc.parg1
            npc.dir = (npc.dir)%4+1
        elseif npc.c1 == 3*npc.parg1
            npc.dir = (npc.dir+2)%4+1
        elseif npc.c1 == 4*npc.parg1
            npc.dir = (npc.dir+2)%4+1
            npc.c1 = 0
        end
    elseif npc.pattern == 5     # T cw
        if npc.c1 == npc.parg1
            npc.dir = (npc.dir)%4+1
        elseif npc.c1 == 2*npc.parg1
            npc.dir = (npc.dir)%4+1
        elseif npc.c1 == 3*npc.parg1
            npc.dir = invdir(npc.dir)
            npc.c1 = 0
        end
    elseif npc.pattern == 6     # T ccw
        if npc.c1 == npc.parg1
            npc.dir = (npc.dir+2)%4+1
        elseif npc.c1 == 2*npc.parg1
            npc.dir = (npc.dir+2)%4+1
        elseif npc.c1 == 3*npc.parg1
            npc.dir = invdir(npc.dir)
            npc.c1 = 0
        end
    elseif npc.pattern == 7    # cw
        if npc.c1 >= npc.parg1
            npc.dir = (npc.dir)%4+1
            npc.c1 = 0
        end
    elseif npc.pattern == 8    # ccw
        if npc.c1 >= npc.parg1
            npc.dir = (npc.dir+2)%4+1
            npc.c1 = 0
        end
    elseif npc.pattern == 9    # random
        if npc.c1 >= 30 && rand(UInt8) < npc.parg1
            npc.dir = rand(1:4)
            npc.c1 = 0
        end
    end
    
    setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4)))            
    reverseSpriteW!(game,npc.sprite,npc.dir==4)

    npc.c1 += 1

    return
end

function manageDynamicNPC!(game::GameState,npc::NPC)
    if npc.c2 == 0
        if npc.pattern == 0     # rand
            m = moveRandomNPC!(npc)
        elseif npc.pattern == 1 # linear
            m = moveLinearNPC!(npc)
        elseif npc.pattern == 2 # angle
            m = moveAngleNPC!(npc)
        elseif npc.pattern == 3 # cw
            m = moveRectangleNPC!(npc,false)
        elseif npc.pattern == 4 # ccw
            m = moveRectangleNPC!(npc,true)
        end

        @. npc.mpos = npc.pos1+dirs[npc.dir]
        @. npc.mchunk = modc(npc.mpos)+(game.im.c.renderdistance+1)+game.ctrl.chunk-npc.chunk
        @. npc.mpos = (npc.mpos+15)%16+1

        w = isequal(game.ctrl.mchunk,npc.mchunk) &&
            (isequal(game.ctrl.pos1,npc.mpos) || isequal(game.ctrl.pos2,npc.mpos))

        if m && !w && checkWalkable(game,npc.mpos,npc.mchunk,npc.fg+1)
            @. npc.pos2 = npc.pos1+dirs[npc.dir]

            # checkChunks!(game,npc)

            setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4))+1+sum(npc.pos1)%2)
            reverseSpriteW!(game,npc.sprite,npc.dir==4)

            moveSprite!(game,npc.sprite,dirs[npc.dir][2],dirs[npc.dir][1])
        else
            npc.c2 = -1

            setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4)))
            reverseSpriteW!(game,npc.sprite,npc.dir==4)
        end
    else
        moveSprite!(game,npc.sprite,dirs[npc.dir][2],dirs[npc.dir][1])

        if npc.c2 == 8
            @. npc.pos1 = npc.mpos; 
    
            setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir==4)))
        end
    end

    npc.c2 += 1
    npc.c2 %= 16
    # npc.c2 -= 16*(npc.c2>=16)

    return
end

function checkChunks!(game::GameState,npc::NPC)
    mchunk = game.ctrl.chunk-npc.chunk .+ (game.im.c.renderdistance+1)

    if !isequal(mchunk,npc.mchunk)
        @. npc.chunk += modc(npc.mpos)
        @. npc.pos2 = npc.mpos

        println("moving npc ",npc.id," from chunk ",mchunk," to ",npc.mchunk)

        idx = findfirst(x->x[].id==npc.id,game.m.chunkdata[game.m.idxs[mchunk]].npcs)
        push!(game.m.chunkdata[game.m.idxs[npc.mchunk]].npcs,
            popat!(game.m.chunkdata[game.m.idxs[mchunk]].npcs,idx))
    end

    return
end

function moveRandomNPC!(npc::NPC)
    if npc.c1 < 32
        npc.c1 += 1; return false
    end

    if rand(UInt8) <= npc.parg1
        npc.dir = rand(1:4)
    else
        return false
    end

    if rand(Bool); npc.c1 = 0; return false; end

    dh = abs((npc.pos1[1]-npc.hpos[1])+16*(npc.chunk[1]-npc.hchunk[1])+dirs[npc.dir][1])
    dw = abs((npc.pos1[2]-npc.hpos[2])+16*(npc.chunk[2]-npc.hchunk[2])+dirs[npc.dir][2])

    if dh <= npc.parg2 && dw <= npc.parg2
        npc.c1 = 16; return true
    else
        return false
    end
end


function moveLinearNPC!(npc::NPC)
    if npc.dir == 1 || npc.dir == 3
        dr = (npc.pos1[1]-npc.hpos[1])+16*(npc.chunk[1]-npc.hchunk[1])   
    else
        dr = (npc.pos1[2]-npc.hpos[2])+16*(npc.chunk[2]-npc.hchunk[2])
    end

    if dr >= npc.parg1 && (npc.dir == 1 || npc.dir == 2)
        npc.dir = invdir(npc.dir)
    elseif dr <= -npc.parg2 && (npc.dir == 3 || npc.dir == 4)
        npc.dir = invdir(npc.dir)
    end

    return true
end

function moveAngleNPC!(npc::NPC)
    dh = abs((npc.pos1[1]-npc.hpos[1])+16*(npc.chunk[1]-npc.hchunk[1]))
    dw = abs((npc.pos1[2]-npc.hpos[2])+16*(npc.chunk[2]-npc.hchunk[2]))

    if dh == 0 && dw == 0 && npc.c1 == 3
        npc.dir = (npc.dir)%4+1     # turn right
        npc.c1 = 0
    elseif (dh >= npc.parg1 || dw >= npc.parg2) && iseven(npc.c1)
        npc.dir = invdir(npc.dir)
        npc.c1 += 1
    elseif dh == 0 && dw == 0 && npc.c1 == 1
        npc.dir = (npc.dir+2)%4+1   # turn left
        npc.c1 += 1
    end

    return true
end

function moveRectangleNPC!(npc::NPC,ccw::Bool)
    dh = abs((npc.pos1[1]-npc.hpos[1])+16*(npc.chunk[1]-npc.hchunk[1]))
    dw = abs((npc.pos1[2]-npc.hpos[2])+16*(npc.chunk[2]-npc.hchunk[2]))

    if (dh == 0 && dw == 0 && npc.c1 == 3) ||
            (((dh==npc.parg1 && dw==0) || (dh==0 && dw==npc.parg2)) && iseven(npc.c1)) ||
            (dh == npc.parg1 && dw == npc.parg2) && npc.c1 == 1

        npc.dir = (npc.dir+2*ccw)%4+1
        npc.c1 += 1; npc.c1 %= 4 
    end
    
    return true
end

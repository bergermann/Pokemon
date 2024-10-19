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
    for npc in game.npcs
        if npc.dynamic
            manageDynamicNPC!(game,npc)
        else
            manageStaticNPC!(game,npc)
        end
    end
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
            # m = moveAngleNPC!(game,npc)
            return
        elseif npc.pattern == 3 # cw
            # m = moveRectangleNPC!(game,npc)
            return
        elseif npc.pattern == 4 # ccw
            # m = moveRectangleNPC!(game,npc)
            return
        end

        npc.mpos = npc.pos1+dirs[npc.dir]
        @. npc.mchunk = modc(npc.mpos)+(game.im.c.renderdistance+1)+game.ctrl.chunk-npc.chunk
        @. npc.mpos = (npc.mpos+15)%16+1

        w = isequal(game.ctrl.mchunk,npc.mchunk) &&
            (isequal(game.ctrl.pos1,npc.mpos) || isequal(game.ctrl.pos2,npc.mpos))

        if m && !w && checkWalkable(game,npc.mpos,npc.mchunk,npc.fg+1)
            @. npc.pos2 = npc.pos1+dirs[npc.dir]

            checkChunks!(game,npc)

            setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir == 4))+1+sum(npc.pos1)%2)
            reverseSpriteW!(game,npc.sprite,npc.dir==4)

            moveSprite!(game,npc.sprite,dirs[npc.dir][2],dirs[npc.dir][1])
        else
            npc.c2 = -1

            setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir == 4)))
            reverseSpriteW!(game,npc.sprite,npc.dir==4)
        end
    else
        moveSprite!(game,npc.sprite,dirs[npc.dir][2],dirs[npc.dir][1])

        if npc.c2 == 8
            # npc.pos1 += dirs[npc.dir]
            @. npc.pos1 = npc.mpos; 
    
            setSpriteFrame!(game,npc.sprite,1+3*(npc.dir-1-2*(npc.dir == 4)))
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
end

function moveRandomNPC!(npc::NPC)
    if npc.c1 < 32
        npc.c1 += 1
        return false
    end

    if rand(UInt8) <= npc.parg1
        npc.dir = rand(1:4)
    else
        return false
    end

    if rand(Bool); npc.c1 = 0; return false; end

    dh = (npc.pos1[1]-npc.homepos[1])+16*(npc.chunk[1]-npc.homechunk[1])+dirs[npc.dir][1]
    dw = (npc.pos1[2]-npc.homepos[2])+16*(npc.chunk[2]-npc.homechunk[2])+dirs[npc.dir][2]

    if -npc.parg2 <= dh <= npc.parg2 && -npc.parg2 <= dw <= npc.parg2
        npc.c1 = 16; return true
    else
        return false
    end
end


function moveLinearNPC!(npc::NPC)
    if npc.dir == 1 || npc.dir == 3
        dr = (npc.pos1[1]-npc.homepos[1])+16*(npc.chunk[1]-npc.homechunk[1])   
    else
        dr = (npc.pos1[2]-npc.homepos[2])+16*(npc.chunk[2]-npc.homechunk[2])
    end

    if dr >= npc.parg1 && (npc.dir == 1 || npc.dir == 2)
        npc.dir = invdir(npc.dir)
    elseif dr <= -npc.parg2 && (npc.dir == 3 || npc.dir == 4)
        npc.dir = invdir(npc.dir)
    end

    return true
end

# function moveAngleNPC!(game::GameState,npc::NPC)
#     if npc.c1 == 0
#         dh = npc.pos.h-npc.homepos.h
#         dw = npc.pos.w-npc.homepos.w

#         if dh == 0 && dw == 0 && npc.c2 == 4
#             npc.dir = dirsturnright[npc.dir]
#             npc.c2 = 1
#         elseif (abs(dh) >= npc.parg1 || abs(dw) >= npc.parg2) &&
#                 (npc.c2 == 1 || npc.c2 == 3)
            
#             npc.dir = dirsinv[npc.dir]
#             npc.c2 += 1
#         elseif dh == 0 && dw == 0 && npc.c2 == 2
#             npc.dir = dirsturnleft[npc.dir]
#             npc.c2 += 1
#         end

#         if isequal(npc.pos,game.pos,dirs[npc.dir])
#             updateSprite!(game.im.sprites[3][npc.spriteid],min(3,npc.dir))
#             game.im.sprites[3][npc.spriteid].hreverse = (npc.dir == 4)

#             return
#         else
#             posAdd!(npc.pos,dirs[npc.dir])
#         end
        
#         if npc.pos.h%2 == npc.pos.w%2
#             updateSprite!(game.im.sprites[3][npc.spriteid],min(3,npc.dir)+3)
#             game.im.sprites[3][npc.spriteid].hreverse = (npc.dir == 4)
#         else
#             updateSprite!(game.im.sprites[3][npc.spriteid],min(3,npc.dir)+6)
#             game.im.sprites[3][npc.spriteid].hreverse = (npc.dir == 4)
#         end
#     elseif npc.c1 == 8
#         updateSprite!(game.im.sprites[3][npc.spriteid],min(3,npc.dir))
#         game.im.sprites[3][npc.spriteid].hreverse = (npc.dir == 4)
#     end

#     posAdd!(game.im.sprites[3][npc.spriteid].pos,dirs[npc.dir])

#     npc.c1 += 1
#     npc.c1 %= 16

#     return
# end

# function moveRectangleNPC!(game::GameState,npc::NPC,turns::Base.ImmutableDict)
#     if npc.c1 == 0
#         dh = npc.pos.h-npc.homepos.h
#         dw = npc.pos.w-npc.homepos.w

#         if dh == 0 && dw == 0 && npc.c2 == 4
#             npc.dir = turns[npc.dir]
#             npc.c2 = 1
#         elseif ((abs(dh) == npc.parg1 && dw == 0) ||
#                 (dh == 0 && abs(dw) == npc.parg2)) && 
#                 (npc.c2 == 1 || npc.c2 == 3)

#             npc.dir = turns[npc.dir]
#             npc.c2 += 1
#         elseif ((abs(dh) == npc.parg1 && abs(dw) == npc.parg2)) && npc.c2 == 2
#             npc.dir = turns[npc.dir]
#             npc.c2 += 1
#         end

#         if isequal(npc.pos,game.pos,dirs[npc.dir])
#             updateSprite!(game.im.sprites[3][npc.spriteid],min(3,npc.dir))
#             game.im.sprites[3][npc.spriteid].hreverse = (npc.dir == 4)

#             return
#         else
#             posAdd!(npc.pos,dirs[npc.dir])
#         end
        
#         if npc.pos.h%2 == npc.pos.w%2
#             updateSprite!(game.im.sprites[3][npc.spriteid],min(3,npc.dir)+3)
#             game.im.sprites[3][npc.spriteid].hreverse = (npc.dir == 4)
#         else
#             updateSprite!(game.im.sprites[3][npc.spriteid],min(3,npc.dir)+6)
#             game.im.sprites[3][npc.spriteid].hreverse = (npc.dir == 4)
#         end
#     elseif npc.c1 == 8
#         updateSprite!(game.im.sprites[3][npc.spriteid],min(3,npc.dir))
#         game.im.sprites[3][npc.spriteid].hreverse = (npc.dir == 4)
#     end

#     posAdd!(game.im.sprites[3][npc.spriteid].pos,dirs[npc.dir])

#     npc.c1 += 1
#     npc.c1 %= 16

#     return
# end

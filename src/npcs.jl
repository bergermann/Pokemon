# NPC related stuff



function loadStaticNPCs!(game::GameState,d::Vector{Int})
    push!(game.npcstatic,NPCStatic(
            d[1],                   # id
            P(d[2],d[3]),           # pos
            d[4],                   # dir
            d[5],                   # sprite
            Symbol("npc",d[1]),     # sprite id
            d[6],                   # pattern
            d[7],                   # pattern arg
            0,                      # counter
            d[8],                   # dialogue
            d[9]                    # dialogue length
        )
    )

    # createSprite!(game,Symbol("npc",d[1]),:layer2,getSpriteNPC(d[5]),
    #     P(80+16*(d[2]-game.pos.h),128+16*(d[3]-game.pos.w)),d[4])
end

function loadMoveNPCs!(game::GameState,d::Vector{Int})
    push!(game.npcmove,NPCMove(
            d[1],               # id::UInt16

            P(d[2],d[3]),       # pos::Position
            P(d[2],d[3]),       # homepos
            d[4],               # dir::Int
            d[5],               # sprite::Int
            Symbol("npc",d[1]), # spriteid::Symbol
                
            d[6],               # pattern::Int
            d[7],               # parg1::Int
            d[8],               # parg2::Int
            0,                  # c1::Int
            1,               # c2::Int

            d[9],               # dialogue::Int
            d[10]               # dialoguelen::Int
        )
    )

    # createSprite!(game,Symbol("npc",d[1]),:layer2,getSpriteNPC(d[5]),
    #     P(80+16*(d[2]-game.pos.h),128+16*(d[3]-game.pos.w)),d[4])
end

function loadNPCs!(game::GameState,mapid)
    f1 = readdlm("maps/$mapid/npcstatic.txt",'\t',Int,'\n'; skipstart=1)
    f2 = readdlm("maps/$mapid/npcmove.txt",'\t',Int,'\n'; skipstart=1)

    for i in axes(f1,1)
        loadStaticNPCs!(game,f1[i,:])
    end

    for i in axes(f2,1)
        loadMoveNPCs!(game,f2[i,:])
    end
end

function getSpriteNPC(id::Int)
    if id == 0
        return Dict{Int,Tuple{Matrix{UInt32},Position}}(
            0 => (Array{Int}(undef,0,0),P(0,0)))
    end

    img = mfb_rgb.(load("im/npcs/$id.png"))

    d = Dict{Int,Tuple{Matrix{UInt32},Position}}(
        zip([2,1,3,6,10,5,9,7,11],
        [(img[:,1+16*i:16+16*i], P(32,16)) for i in 0:8])
    )

    d[4] = (reverse(d[3][1]; dims=2),d[3][2])
    d[8] = (reverse(d[7][1]; dims=2),d[7][2])
    d[12] = (reverse(d[11][1]; dims=2),d[11][2])

    return d
end

function loadSpritesNPCs!(game::GameState)
    for i in 1:game.npcstatic.idx
        npc = game.npcstatic[i]
        createSprite!(game,npc.spriteid,:layer2,getSpriteNPC(npc.sprite),
            P(80+16*(npc.pos.h-game.pos.h),128+16*(npc.pos.w-game.pos.w)),npc.dir)
    end

    for i in 1:game.npcmove.idx
        npc = game.npcmove[i]
        createSprite!(game,npc.spriteid,:layer2,getSpriteNPC(npc.sprite),
            posAddMult(P(80+16*(npc.pos.h-game.pos.h),128+16*(npc.pos.w-game.pos.w)),
            dirs[npc.c2],-npc.c1),npc.dir)
    end

    checkProximityNPCs!(game)
end




function checkProximityNPCs!(game::GameState)
    # for i in 1:game.npcstatic.idx
    #     if -11 < game.pos.h-game.npcstatic[i].pos < 11
    #         game.im
    #     end
    # end

    for i in 1:game.im.sprites.idx
        if (0 < game.im.sprites[i].pos.h <= 184) &&
                (0 < game.im.sprites[i].pos.w <= 248)
            game.im.sprites[i].active = true
        else
            game.im.sprites[i].active = false
        end
    end
end

function checkTileNPC(game::GameState)
    for i in 1:game.npcstatic.idx
        if game.npcstatic[i].pos.h == game.movepos.h &&
                game.npcstatic[i].pos.w == game.movepos.w
            
            return true, game.npcstatic[i]
        end
    end

    for i in 1:game.npcmove.idx
        if game.npcmove[i].pos.h == game.movepos.h &&
                game.npcmove[i].pos.w == game.movepos.w # &&
                # game.npcmove[i].c1 == 0
            
            return true, game.npcmove[i]
        end
    end

    return false, nothing
end

function manageNPCs!(game::GameState)
    manageStaticNPCs!(game)
    manageMoveNPCs!(game)
end

function manageStaticNPCs!(game::GameState)
    if game.input.npclock
        return
    end

    for i in 1:game.npcstatic.idx
        manageStaticNPC!(game,game.npcstatic[i])
    end
end

function manageStaticNPC!(game::GameState,npc::NPCStatic)
    if npc.pattern == 0
        return
    elseif 1 <= npc.pattern <= 4
        if npc.dir == npc.pattern
            return
        end
        
        npc.dir = npc.pattern
        updateSprite!(game.im.sprites[npc.spriteid],npc.pattern)

        return
    elseif npc.pattern == 5
        if npc.c >= npc.parg
            if npc.dir == 1
                npc.dir = 4
            elseif npc.dir == 2
                npc.dir = 3
            elseif npc.dir == 3
                npc.dir = 1
            else
                npc.dir = 2
            end

            updateSprite!(game.im.sprites[npc.spriteid],npc.dir)

            npc.c = 0
        end

        npc.c += 1

        return
    elseif npc.pattern == 6
        if npc.c >= npc.parg
            if npc.dir == 1
                npc.dir = 3
            elseif npc.dir == 2
                npc.dir = 4
            elseif npc.dir == 3
                npc.dir = 2
            else
                npc.dir = 1
            end

            updateSprite!(game.im.sprites[npc.spriteid],npc.dir)

            npc.c = 0
        end

        npc.c += 1

        return
    elseif npc.pattern == 7
        if rand(UInt8) < npc.parg && npc.c >= 30
            npc.dir = rand(1:4)

            updateSprite!(game.im.sprites[npc.spriteid],npc.dir)

            npc.c = 0
        else
            npc.c += 1
        end

        return
    end
end

function manageMoveNPCs!(game::GameState)
    for i in 1:game.npcmove.idx
        manageMoveNPC!(game,game.npcmove[i])
    end
end

function manageMoveNPC!(game::GameState,npc::NPCMove)
    if game.input.npclock && npc.c1 == 0
        updateSprite!(game.im.sprites[npc.spriteid],dirsinv[game.direction])
        
        return
    end
    
    if npc.pattern == 0
        return
    elseif npc.pattern == 1 # horizontal
        moveLinearNPC!(game,npc)
    elseif npc.pattern == 2
        moveAngleNPC!(game,npc)
    elseif npc.pattern == 3
        moveRectangleNPC!(game,npc,dirsturnright)
    elseif npc.pattern == 4
        moveRectangleNPC!(game,npc,dirsturnleft)
    else
        return
    end    
end

function moveLinearNPC!(game::GameState,npc::NPC)
    if npc.c1 == 0
        if npc.dir == 1 || npc.dir == 2
            dr = npc.pos.h-npc.homepos.h+dirs[npc.dir].h
        else
            dr = npc.pos.w-npc.homepos.w+dirs[npc.dir].w
        end

        if dr < -npc.parg1
            npc.c2 = 2
            npc.dir = dirsinv[npc.dir]
        elseif dr > npc.parg1
            npc.c2 = 1
            npc.dir = dirsinv[npc.dir]
        end

        if isequal(npc.pos,game.pos,dirs[npc.dir])
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir)

            return
        else
            posAdd!(npc.pos,dirs[npc.dir])
        end
        
        if npc.pos.h%2 == npc.pos.w%2
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir+4)
        else
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir+8)
        end
    elseif npc.c1 == 8
        updateSprite!(game.im.sprites[npc.spriteid],npc.dir)
    end

    posAdd!(game.im.sprites[npc.spriteid].pos,dirs[npc.dir])

    npc.c1 += 1
    npc.c1 %= 16

    return
end

function moveAngleNPC!(game::GameState,npc::NPC)
    if npc.c1 == 0
        dh = npc.pos.h-npc.homepos.h
        dw = npc.pos.w-npc.homepos.w

        if dh == 0 && dw == 0 && npc.c2 == 4
            npc.dir = dirsturnright[npc.dir]
            npc.c2 = 1
        elseif (abs(dh) >= npc.parg1 || abs(dw) >= npc.parg2) &&
                (npc.c2 == 1 || npc.c2 == 3)
            
            npc.dir = dirsinv[npc.dir]
            npc.c2 += 1
        elseif dh == 0 && dw == 0 && npc.c2 == 2
            npc.dir = dirsturnleft[npc.dir]
            npc.c2 += 1
        end

        if isequal(npc.pos,game.pos,dirs[npc.dir])
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir)

            return
        else
            posAdd!(npc.pos,dirs[npc.dir])
        end
        
        if npc.pos.h%2 == npc.pos.w%2
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir+4)
        else
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir+8)
        end
    elseif npc.c1 == 8
        updateSprite!(game.im.sprites[npc.spriteid],npc.dir)
    end

    posAdd!(game.im.sprites[npc.spriteid].pos,dirs[npc.dir])

    npc.c1 += 1
    npc.c1 %= 16

    return
end

function moveRectangleNPC!(game::GameState,npc::NPC,turns::Base.ImmutableDict)
    if npc.c1 == 0
        dh = npc.pos.h-npc.homepos.h
        dw = npc.pos.w-npc.homepos.w

        if dh == 0 && dw == 0 && npc.c2 == 4
            npc.dir = turns[npc.dir]
            npc.c2 = 1
        elseif ((abs(dh) == npc.parg1 && dw == 0) ||
                (dh == 0 && abs(dw) == npc.parg2)) && 
                (npc.c2 == 1 || npc.c2 == 3)

            npc.dir = turns[npc.dir]
            npc.c2 += 1
        elseif ((abs(dh) == npc.parg1 && abs(dw) == npc.parg2)) && npc.c2 == 2
            npc.dir = turns[npc.dir]
            npc.c2 += 1
        end

        if isequal(npc.pos,game.pos,dirs[npc.dir])
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir)

            return
        else
            posAdd!(npc.pos,dirs[npc.dir])
        end
        
        if npc.pos.h%2 == npc.pos.w%2
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir+4)
        else
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir+8)
        end
    elseif npc.c1 == 8
        updateSprite!(game.im.sprites[npc.spriteid],npc.dir)
    end

    posAdd!(game.im.sprites[npc.spriteid].pos,dirs[npc.dir])

    npc.c1 += 1
    npc.c1 %= 16

    return
end

function moveHorizontalNPC!(game::GameState,npc::NPC)
    dw = npc.pos.w-npc.homepos.w
    dir = npc.c2 == 3 ? -1 : 1

    if npc.c1 == 0
        if -npc.parg1 < dw < npc.parg2
            if !isequal(npc.pos,game.pos,0,dir)
                npc.pos.w += dir
            else
                return
            end
        else
            npc.pos.w -= dir
            npc.c2 -= dir
            npc.dir = npc.c2
        end
        
        if npc.pos.h%2 == npc.pos.w%2
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir+4)
        else
            updateSprite!(game.im.sprites[npc.spriteid],npc.dir+8)
        end
    elseif npc.c1 == 8
        updateSprite!(game.im.sprites[npc.spriteid],npc.dir)
    end

    game.im.sprites[npc.spriteid].pos.w += dir

    npc.c1 += 1
    npc.c1 %= 16

    return
end

function moveVerticalNPC!(game::GameState,npc::NPC)
    dh = npc.pos.h-npc.homepos.h
    dir = npc.c2 == 1 ? -1 : 1

    if npc.c1 == 0
        if -npc.parg1 < dh < npc.parg2
            if !isequal(npc.pos,game.pos,dir,0)
                npc.pos.h += dir
            else
                return
            end
        else
            npc.pos.h -= dir
            npc.c2 -= dir
            npc.dir = npc.c2
        end
        
        if npc.pos.h%2 == npc.pos.w%2
            updateSprite!(game.im.sprites[npc.spriteid],npc.c2+4)
        else
            updateSprite!(game.im.sprites[npc.spriteid],npc.c2+8)
        end
    elseif npc.c1 == 8
        updateSprite!(game.im.sprites[npc.spriteid],npc.c2)
    end

    game.im.sprites[npc.spriteid].pos.h += dir

    npc.c1 += 1
    npc.c1 %= 16

    return
end
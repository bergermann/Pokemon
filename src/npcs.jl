# NPC related stuff



#= 
id::UInt16

pos::Position
dir::Int
sprite::Int
spriteid::Symbol
# dialogue::Vector{String}
dialogue::Int
pattern::Int
parg::Int
c::Int

id	h	w	dir	spr	dia	pat parg
id	h	w	dir	spr	pat par	dia	dl
=#


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

    createSprite!(game,Symbol("npc",d[1]),:layer2,getSpriteNPC(d[5]),
        P(80+16*(d[2]-game.pos.h),128+16*(d[3]-game.pos.w)),d[4])
end

function loadNPCs!(game::GameState,mapid)
    f = readdlm("maps/$mapid/npcstatic.txt",'\t',Int,'\n'; skipstart=1)

    for i in 1:size(f)[1]
        loadStaticNPCs!(game,f[i,:])
    end

    checkProximityNPCs!(game)
end

function getSpriteNPC(id::Int)
    img = mfb_rgb.(load("im/npcs/$id.png"))

    d = Dict{Int,Tuple{Matrix{UInt32},Position}}(
        zip([2,1,3,6,5,7,10,9,11],
        [(img[:,1+16*i:16+16*i], P(32,16)) for i in 0:8])
    )

    d[4] = (reverse(d[3][1]; dims=2),d[3][2])
    d[8] = (reverse(d[7][1]; dims=2),d[7][2])
    d[12] = (reverse(d[11][1]; dims=2),d[11][2])

    return d
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
    end
end

function manageMoveNPCs!(game::GameState)
    return
end

function loadMapStrings(mapid::Int)
    return readlines("map/$mapid.txt")
end
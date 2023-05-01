# NPC related stuff



# npctest = NPCStatic(
#     1,
#     P(110,30),
#     2,
#     1,
#     ["Test 123","Ich bin eine hohle Nuss."],
#     0
# )

function loadStaticNPCs!(game::GameState,d::Vector{Int})
    push!(game.npcstatic,NPCStatic(d[1],P(d[2],d[3]),d[4],d[5],d[6],d[7]))
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

    return Dict{Int,Tuple{Matrix{UInt32},Position}}(
        zip(1:9,
        [(img[:,1+16*i:16+16*i], P(32,16)) for i in 0:8])
    )
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
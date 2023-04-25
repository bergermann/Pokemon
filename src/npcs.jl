# NPC related stuff



# npctest = NPCStatic(
#     1,
#     P(110,30),
#     2,
#     1,
#     ["Test 123","Ich bin eine hohle Nuss."],
#     0
# )

function loadStaticNPC!(game::GameState,d::Vector{Int})
    push!(game.npcstatic,NPCStatic(d[1],P(d[2],d[3]),d[4],d[5],d[6],d[7]))
end

function loadNPCs(game::GameState,mapid::Int)
    f = readdlm("maps/$mapid/npcstatic.txt",'\t',)

    for i in 1:size(f)[1]
        loadStaticNPC(game,f[i,:])
    end
end

function getSpriteNPC(id::Int)
    
end

function setupChunks(game::GameState)
    r = 2*game.im.c.renderdistance+1

    game.im.c.ulocp1 = glGetUniformLocation(game.im.programs[1],"projection1")
    game.im.c.ulocp2 = glGetUniformLocation(game.im.programs[1],"projection2")
    game.im.c.ulocframe = glGetUniformLocation(game.im.programs[1],"frame")
    
    glBindVertexArray(game.im.c.vao)
    glBindBuffer(GL_ARRAY_BUFFER,game.im.c.vbo)
    
    glVertexAttribIPointer(0,1,GL_UNSIGNED_SHORT,2,C_NULL)
    glEnableVertexAttribArray(0)

    glBufferData(GL_ARRAY_BUFFER,sizeof(game.m.tilemap),C_NULL,GL_DYNAMIC_DRAW)

    glBindBuffer(GL_ARRAY_BUFFER,0)
    glBindVertexArray(0)

    glBindBuffer(GL_TEXTURE_BUFFER,game.im.c.bidxs)
    glBufferData(GL_TEXTURE_BUFFER,r^2,pointer(game.m.didxs),GL_DYNAMIC_DRAW)
    glBindTexture(GL_TEXTURE_BUFFER,game.im.c.tidxs)
    glTexBuffer(GL_TEXTURE_BUFFER,GL_R8I,game.im.c.bidxs)

    ad = deserialize(joinpath("textures","tilesets","tileanim.data"))
    glBindBuffer(GL_TEXTURE_BUFFER,game.im.c.banimdata)
    glBufferData(GL_TEXTURE_BUFFER,sizeof(ad),pointer(ad),GL_DYNAMIC_DRAW)
    glBindTexture(GL_TEXTURE_BUFFER,game.im.c.tanimdata)
    glTexBuffer(GL_TEXTURE_BUFFER,GL_R32I,game.im.c.banimdata)

    glBindBuffer(GL_TEXTURE_BUFFER,0)
    glBindTexture(GL_TEXTURE_BUFFER,0)

    glUseProgram(game.im.programs[1])
    glUniform1i(glGetUniformLocation(game.im.programs[1],"r"),r)
    glUniform1i(glGetUniformLocation(game.im.programs[1],"tex"),0)
    glUniform1i(glGetUniformLocation(game.im.programs[1],"idxs"),1)
    glUniform1i(glGetUniformLocation(game.im.programs[1],"animdata"),2)

    glUniformMatrix4fv(game.im.c.ulocp1,1,true,pointer(game.im.c.projection1))
    glUniformMatrix4fv(game.im.c.ulocp2,1,true,pointer(game.im.c.projection2))

    checkError("Gen chunks")

    return
end

function updateChunkIdxs(game::GameState)
    r = 2*game.im.c.renderdistance+1

    glBindBuffer(GL_TEXTURE_BUFFER,game.im.c.bidxs)
    glBufferData(GL_TEXTURE_BUFFER,r^2,pointer(game.m.didxs),GL_DYNAMIC_DRAW)
    glBindBuffer(GL_TEXTURE_BUFFER,0)

    return
end


function loadChunk!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    println("loading chunk $cx-$cy")

    unloadNPCs!(game,target)

    if !isdir("maps/$cx-$cy/")
        game.m.tilemap[1+1280*(target-1):1280*target] .= 1
        game.m.chunkdata[target].height .= 0
        game.m.chunkdata[target].collision .= 0
    else
        game.m.tilemap[1+1280*(target-1):1280*target] =
            deserialize("maps/$cx-$cy/tiles.tm")
        game.m.chunkdata[target].height[:] = deserialize("maps/$cx-$cy/heights.hm")
        game.m.chunkdata[target].collision[:] = deserialize("maps/$cx-$cy/col.cm")

        loadNPCs!(game,target,cx,cy)
    end

    return
end

loadChunk!(game::GameState,target::Int,chunk::Position) =
    loadChunk!(game,target,chunk[1],chunk[2])

function loadChunksAll!(game::GameState; reset::Bool=true)
    rd = Int(game.im.c.renderdistance)
    r = 2*rd+1

    c = game.ctrl.chunk

    if reset
        game.m.idxs[:] .= 1:r^2
        game.m.didxs[:] .= 1:r^2
    end

    for i in -rd:rd, j in -rd:rd
        loadChunk!(game,game.m.idxs[j+rd+1,i+rd+1],i+c[1],j+c[2])
    end

    updateChunkIdxs(game)

    return
end


function loadChunks!(game::GameState,targets::AbstractVector{<:Integer},
        cx::AbstractVector{<:Integer},cy::AbstractVector{<:Integer})

    @assert length(targets) == length(cx) == length(cy) "Inputs must be of same length."

    for i in eachindex(targets)
        loadChunk!(game,targets[i],cx[i],cy[i])
    end

    updateChunkIdxs(game)

    return
end

function loadNPCs!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    npcs = deserialize("maps/$cx-$cy/npcs.nm"); i = 1

    for l in 1:2
        for npc in npcs[l]
            id = UInt16(i+64*cx+64*64*cy)

            if id in game.npcids
                continue
            else
                push!(game.npcids,id)
            end

            sid = Symbol(:npc,id)
            x = npc[1]; y = npc[2]
            spriteid = npc[8]; dir = npc[9]

            npc_ = NPC(
                id,

                P(y,x),
                P(y,x),
                P(y,x),
                P(y,x),
                game.m.chunkdata[target].height[y,x]*(l==1),
                P(cy,cx),
                P(cy,cx),
                P(cy,cx),
                l==2,
                dir,

                sid,
                
                npc[3],
                npc[6],
                npc[4],
                npc[5],
                0,
                0,

                0,
                0,

                npc[7],
            )

            push!(game.npcs,npc_)
            push!(game.m.chunkdata[target].npcs,Ref(npc_))

            createSprite!(game,sid,:npcs,spriteid,1+3*(dir-1-2*(dir==4)),
                16*(16*(cx-game.ctrl.chunk[2])+(x-game.ctrl.pos1[2])),
                16*(16*(cy-game.ctrl.chunk[1])+(y-game.ctrl.pos1[1]))-8,
                10,3;
                wreverse=dir==4,active=true)

            i += 1
        end
    end

    return
end

    
function unloadNPCs!(game::GameState,target::Integer)
    # println("unloading chunk $target")
    # println(game.m.chunkdata[target].npcs)

    for npc in game.m.chunkdata[target].npcs
        idx1 = findfirst(x->x.id==npc[].id,game.npcs.data[1:game.npcs.idx])
        idx2 = findfirst(isequal(npc[].id),game.npcids)

        popat!(game.npcs,idx1)
        popat!(game.npcids,idx2)
    end

    empty!(game.m.chunkdata[target].npcs)
end
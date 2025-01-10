
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
    glBufferData(GL_TEXTURE_BUFFER,Int(game.im.c.r2)^2,pointer(game.m.didxs),GL_DYNAMIC_DRAW)
    glBindBuffer(GL_TEXTURE_BUFFER,0)

    return
end


function loadChunk!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    @info "loading chunk $cx-$cy"

    unloadNPCs!(game,target)
    unloadObjects!(game,target)
    unloadItems!(game,target)

    if !isdir("maps/$cx-$cy/")
        game.m.tilemap[1+1280*(target-1):1280*target] .= 1
        game.m.chunkdata[target].height .= 0
        game.m.chunkdata[target].collision .= 0
    else
        game.m.tilemap[1+1280*(target-1):1280*target] =
            deserialize("maps/$cx-$cy/tiles.tm")
        game.m.chunkdata[target].height[:] = deserialize("maps/$cx-$cy/heights.hm")
        game.m.chunkdata[target].collision[:] = deserialize("maps/$cx-$cy/col.cm")

        loadNPCs!(     game,target,cx,cy)
        loadObjects!(  game,target,cx,cy)
        loadItems!(    game,target,cx,cy)
        loadTeleports!(game,cx,cy)
        loadEvents!(   game,cx,cy)
        loadAreas!(    game,cx,cy)
    end

    return
end

loadChunk!(game::GameState,target::Int,chunk::Position) =
    loadChunk!(game,target,chunk[1],chunk[2])

function loadChunksAll!(game::GameState; reset::Bool=true)
    rd = Int(game.im.c.renderdistance)

    c = game.ctrl.chunk

    if reset
        @inbounds @simd for i in eachindex(game.m.idxs)
            game.m.idxs[i] = i
            game.m.didxs[i] = i
        end
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



function loadTeleports!(game::GameState,cx::Integer,cy::Integer)
    tps = deserialize("maps/$cx-$cy/teleports.tm"); i = 1

    for l in 1:2
        for tp in tps[l]
            id = UInt16(i+64*cx+64*64*cy)

            if id in game.m.teleportids
                continue
            else
                push!(game.m.teleportids,id)
            end

            push!(game.m.teleports,Teleport(id,tp[1:10]...,l==2,tp[11]))

            i += 1
        end
    end

    return
end

function loadEvents!(game::GameState,cx::Integer,cy::Integer)
    events = deserialize("maps/$cx-$cy/events.em"); i = 1

    for l in 1:2
        for event in events[l]
            id = UInt16(i+64*cx+64*64*cy)

            if id in game.m.eventids# || game.flags.items[flag]
                continue
            else
                push!(game.m.eventids,id)
            end

            push!(game.m.events,Event(
                id,event[1:6]...,l==2,events[event[7]][1],p[8],events[event[7]][2]))

            i += 1
        end
    end

    return
end

function loadNPCs!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    npcs = deserialize("maps/$cx-$cy/npcs.nm"); i = 1

    for l in 1:2
        for npc in npcs[l]
            id = UInt16(i+64*cx+64*64*cy)

            if id in game.m.npcids
                continue
            else
                push!(game.m.npcids,id)
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
                spriteid,
                
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

            push!(game.m.npcs,npc_)
            push!(game.m.chunkdata[target].npcs,Ref(npc_))

            createSprite!(game,sid,:npcs_all,spriteid,1+3*(dir-1-2*(dir==4)),
                16*(16*(cx-game.ctrl.chunk[2])+(x-game.ctrl.pos1[2])),
                16*(16*(cy-game.ctrl.chunk[1])+(y-game.ctrl.pos1[1]))-8,
                10,3;
                wreverse=dir==4,active=true)

            i += 1
        end
    end

    return
end

function loadObjects!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    objects = deserialize("maps/$cx-$cy/objects.om"); i = 1

    for l in 1:2
        for object in objects[l]
            id = UInt16(i+64*cx+64*64*cy)

            if id in game.m.objectids
                continue
            else
                push!(game.m.objectids,id)
            end

            sid = Symbol(:object,id)
            type = object[1]
            x = object[2]; y = object[3]

            obj_ = Object(
                id,
                type,
                P(y,x),
                P(cx,cy),
                l == 2,
                0,
                sid
            )

            push!(game.m.objects,obj_)
            push!(game.m.chunkdata[target].objects,Ref(obj_))

            createSprite!(game,sid,:objects,1,9+4*(type-1),
                16*(16*(cx-game.ctrl.chunk[2])+(x-game.ctrl.pos1[2])),
                16*(16*(cy-game.ctrl.chunk[1])+(y-game.ctrl.pos1[1])),
                10,3;
                active=true)

            i += 1
        end
    end

    return
end

function loadItems!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    items = deserialize("maps/$cx-$cy/items.im"); i = 1

    for l in 1:2
        for item in items[l]
            id = UInt16(i+64*cx+64*64*cy)

            type = item[1]
            x = item[2]; y = item[3]
            vis = item[4]
            # flag = item[5]

            if id in game.m.itemids# || game.flags.items[flag]
                continue
            else
                push!(game.m.itemids,id)
            end

            sid = Symbol(:item,id)

            item_ = MapItem(
                id,
                type,
                0,#flag
                P(y,x),
                P(cx,cy),
                l == 2,
                vis,
                sid
            )

            push!(game.m.items,item_)
            push!(game.m.chunkdata[target].items,Ref(item_))

            if vis
                createSprite!(game,sid,:objects,1,1,
                    16*(16*(cx-game.ctrl.chunk[2])+(x-game.ctrl.pos1[2])),
                    16*(16*(cy-game.ctrl.chunk[1])+(y-game.ctrl.pos1[1])),
                    10,3; active=true)
            end

            i += 1
        end
    end

    return
end

function loadAreas!(game::GameState,cx::Integer,cy::Integer)
    areas = deserialize("maps/$cx-$cy/areas.am"); i = 1

    for l in 1:2
        for area in areas[l]
            id = UInt16(i+64*cx+64*64*cy)

            if id in game.m.areaids# || game.flags.items[flag]
                continue
            else
                push!(game.m.areaids,id)
            end

            push!(game.m.areas,Area(
                id,
                area[1][1],area[1][2],
                area[1][3],area[1][4],
                cx,cy,l==2,area[2]))

            i += 1
        end
    end

    return
end

function unloadNPCs!(game::GameState,target::Integer)
    for npc in game.m.chunkdata[target].npcs
        idx1 = findfirst(x->x.id==npc[].id,game.m.npcs.data[1:game.m.npcs.idx])
        idx2 = findfirst(isequal(npc[].id),game.m.npcids)
        
        killSprite!(game,npc[].sprite)
        popat!(game.m.npcs,idx1)
        popat!(game.m.npcids,idx2)
    end

    empty!(game.m.chunkdata[target].npcs)
end

function unloadObjects!(game::GameState,target::Integer)
    for object in game.m.chunkdata[target].objects
        idx1 = findfirst(x->x.id==object[].id,game.m.objects.data[1:game.m.objects.idx])
        idx2 = findfirst(isequal(object[].id),game.m.objectids)
        
        killSprite!(game,object[].sprite)
        popat!(game.m.objects,idx1)
        popat!(game.m.objectids,idx2)
    end

    empty!(game.m.chunkdata[target].objects)
end

function unloadItems!(game::GameState,target::Integer)
    for item in game.m.chunkdata[target].items
        idx1 = findfirst(x->x.id==item[].id,game.m.items.data[1:game.m.items.idx])
        idx2 = findfirst(isequal(item[].id),game.m.itemids)
        
        killSprite!(game,item[].sprite)
        popat!(game.m.items,idx1)
        popat!(game.m.itemids,idx2)
    end

    empty!(game.m.chunkdata[target].items)
end



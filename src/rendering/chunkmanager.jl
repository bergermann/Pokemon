
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

    ad = deserialize(joinpath(PATH,"textures","tilesets","tileanim.data"))
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

    if !isdir("maps/$cx-$cy/")
        game.m.tilemap[1+1280*(target-1):1280*target] .= 1
        game.m.chunkdata[target].height .= 0
        game.m.chunkdata[target].collision .= 1
    else
        game.m.tilemap[1+1280*(target-1):1280*target] =
            deserialize("maps/$cx-$cy/tiles.tm")
        game.m.chunkdata[target].height[:] = deserialize("maps/$cx-$cy/height.hm")
        game.m.chunkdata[target].collision[:] = deserialize("maps/$cx-$cy/col.cm")

        loadNPCs!(     game,target,cx,cy)
        loadObjects!(  game,target,cx,cy)
        loadItems!(    game,target,cx,cy)
        loadSigns!(    game,target,cx,cy)
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

    unloadChunksAll!(game)

    for i in -rd:rd, j in -rd:rd
        loadChunk!(game,game.m.idxs[j+rd+1,i+rd+1],i+c.y,j+c.x)
    end

    updateChunkIdxs(game)

    return
end

function loadChunks!(game::GameState,targets::AbstractVector{<:Integer},
        cx::AbstractVector{<:Integer},cy::AbstractVector{<:Integer})

    @assert length(targets) == length(cx) == length(cy) "Inputs must be of same length."

    unloadTeleports!(game)
    unloadEvents!(game)
    unloadAreas!(game)

    for target in targets
        unloadChunk!(game,target)
    end

    for i in eachindex(targets)
        loadChunk!(game,targets[i],cx[i],cy[i])

        createChunkSprites!(game,targets[i])
    end

    updateChunkIdxs(game)

    return
end

function unloadChunk!(game::GameState,target::Integer)
    unloadNPCs!(game,target)
    unloadObjects!(game,target)
    unloadItems!(game,target)
    unloadSigns!(game,target)

    return
end

function unloadChunksAll!(game::GameState)
    empty!(game.m.teleports)
    empty!(game.m.teleportids)

    empty!(game.m.events)
    empty!(game.m.eventids)

    empty!(game.m.npcs)
    empty!(game.m.npcids)

    empty!(game.m.objects)
    empty!(game.m.objectids)
        
    empty!(game.m.items)
    empty!(game.m.itemids)
        
    empty!(game.m.signs)
    empty!(game.m.signids)

    empty!(game.m.areas)
    empty!(game.m.areaids)

    for idx in game.m.idxs
        empty!(game.m.chunkdata[idx].npcs)
        empty!(game.m.chunkdata[idx].objects)
        empty!(game.m.chunkdata[idx].items)
        empty!(game.m.chunkdata[idx].signs)
    end

    if haskey(game.im.s.sheets,:npcs_all); killSprites!(game,:npcs_all); end
    if haskey(game.im.s.sheets,:objects);  killSprites!(game,:objects);  end

    return
end

function ID(x::Integer,y::Integer,i::Integer)
    x_ = UInt32(x&0x0fff)<<20
    y_ = UInt32(y&0x0fff)<<8
    
    return UInt32(x_+y_+i&0xff)
end

function ID(id::UInt32)
    return Int((id&0xfff00000)>>20), Int((id&0x000fff00)>>8), Int(id&0xff)
end



function loadNPCs!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    npcs = deserialize("maps/$cx-$cy/npcs.nm"); i = 1

    for l in 1:2
        for npc in npcs[l]
            id = ID(cx,cy,i)

            if id in game.m.npcids
                continue
            else
                push!(game.m.npcids,id)
            end

            sid = Symbol(:npc,id)
            x = npc[1]; y = npc[2]
            spriteid = npc[8]; dir = npc[9]; event = npc[10]

            npc_ = NPC(
                id,

                P(x,y),P(x,y),P(x,y),P(x,y),
                game.m.chunkdata[target].height[y,x]*(l==1),
                P(cy,cx),P(cy,cx),P(cy,cx),
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
                event
            )

            push!(game.m.npcs,npc_)
            push!(game.m.chunkdata[target].npcs,Ref(npc_))

            if event != Symbol() && !haskey(events,event); loadEvent!(game,event); end

            i += 1
        end
    end

    return
end

function loadObjects!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    objects = deserialize("maps/$cx-$cy/objects.om"); i = 1

    for l in 1:2
        for object in objects[l]
            id = ID(cx,cy,i)

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
                P(x,y),
                P(cy,cx),
                l == 2,
                0,
                sid
            )

            push!(game.m.objects,obj_)
            push!(game.m.chunkdata[target].objects,Ref(obj_))

            i += 1
        end
    end

    return
end

function loadItems!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    items = deserialize("maps/$cx-$cy/items.im"); i = 1

    for l in 1:2
        for item in items[l]
            id = ID(cx,cy,i)

            if id in game.m.itemids# || game.flags.items[flag]
                continue
            else
                push!(game.m.itemids,id)
            end
            sid = Symbol(:item,id)
            x = item[2]; y = item[3]

            item_ = MapItem(
                id,
                item[1],
                0,#flag item[5]
                P(x,y),
                P(cy,cx),
                l == 2,
                item[4],
                sid
            )

            push!(game.m.items,item_)
            push!(game.m.chunkdata[target].items,Ref(item_))

            i += 1
        end
    end

    return
end

function loadSigns!(game::GameState,target::Integer,cx::Integer,cy::Integer)
    signs = deserialize("maps/$cx-$cy/signs.sm"); i = 1

    for l in 1:2
        for sign in signs[l]
            id = ID(cx,cy,i)

            if id in game.m.signids
                continue
            else
                push!(game.m.signids,id)
            end

            sign_ = Sign(id,P(sign[1],sign[2]),P(cy,cx),l==2,sign[3])

            push!(game.m.signs,sign_)
            push!(game.m.chunkdata[target].signs,Ref(sign_))

            i += 1
        end
    end

    return
end

function loadTeleports!(game::GameState,cx::Integer,cy::Integer)
    tps = deserialize("maps/$cx-$cy/teleports.tm"); i = 1

    for l in 1:2
        for tp in tps[l]
            id = ID(cx,cy,i)

            if id in game.m.teleportids
                continue
            else
                push!(game.m.teleportids,id)
            end

            push!(game.m.teleports,
                Teleport(id,tp[1:4]...,cy,cx,tp[5:8]...,l==2,tp[9]))
            i += 1
        end
    end

    return
end

function loadEvents!(game::GameState,cx::Integer,cy::Integer)
    events_ = deserialize("maps/$cx-$cy/events.em"); i = 1

    for l in 1:2
        for event in events_[l]
            id = ID(cx,cy,i)

            if id in game.m.eventids# || game.flags.items[flag]
                continue
            else
                push!(game.m.eventids,id)
            end

            push!(game.m.events,
                Event(id,event[1:4]...,cy,cx,l==2,event[5:6]...,events[event[7]]...))

            i += 1
        end
    end

    return
end

function loadAreas!(game::GameState,cx::Integer,cy::Integer)
    areas = deserialize("maps/$cx-$cy/areas.am"); i = 1

    for l in 1:2
        for area in areas[l]
            id = ID(cx,cy,i)

            if id in game.m.areaids# || game.flags.items[flag]
                continue
            else
                push!(game.m.areaids,id)
            end

            push!(game.m.areas,Area(
                id,
                area[1][1],area[1][2],
                area[1][3],area[1][4],
                cy,cx,l==2,area[2]))

            i += 1
        end
    end

    return
end




function unloadNPCs!(game::GameState,target::Integer)
    if isempty(game.m.chunkdata[target].npcs); return; end

    c = game.m.chunkdata[target].npcs[1][].chunk
    
    for (i,npc) in Iterators.reverse(enumerate(game.m.npcs[1:game.m.npcs.idx]))
        if isequal(npc.chunk,c)
            killSprite!(game,npc.sprite)
            popat!(game.m.npcids,i)
            popat!(game.m.npcs,i)
            if npc.event != Symbol(); unloadEvent!(game,npc.event); end
        end
    end

    empty!(game.m.chunkdata[target].npcs)

    return
end

function unloadObjects!(game::GameState,target::Integer)
    if isempty(game.m.chunkdata[target].objects); return; end

    c = game.m.chunkdata[target].objects[1][].chunk
    
    for (i,object) in Iterators.reverse(enumerate(game.m.objects[1:game.m.objects.idx]))
        if isequal(object.chunk,c)
            killSprite!(game,object.sprite)
            popat!(game.m.objectids,i)
            popat!(game.m.objects,i)
        end
    end

    empty!(game.m.chunkdata[target].objects)

    return
end

function unloadItems!(game::GameState,target::Integer)
    if isempty(game.m.chunkdata[target].items); return; end

    c = game.m.chunkdata[target].items[1][].chunk
    
    for (i,item) in Iterators.reverse(enumerate(game.m.items[1:game.m.items.idx]))
        if isequal(item.chunk,c)
            if item.vis; killSprite!(game,item.sprite); end
            popat!(game.m.itemids,i)
            popat!(game.m.items,i)
        end
    end

    empty!(game.m.chunkdata[target].items)

    return
end

function unloadSigns!(game::GameState,target::Integer)
    if isempty(game.m.chunkdata[target].signs); return; end

    c = game.m.chunkdata[target].signs[1][].chunk

    for (i,sign) in Iterators.reverse(enumerate(game.m.signs[1:game.m.signs.idx]))
        if isequal(sign.chunk,c)
            popat!(game.m.signids,i)
            popat!(game.m.signs,i)
        end
    end

    empty!(game.m.chunkdata[target].signs)

    return
end

function unloadTeleports!(game::GameState)
    for (i,tp) in Iterators.reverse(enumerate(game.m.teleports[1:game.m.teleports.idx]))
        if abs(tp.cx-game.ctrl.mchunk.x) > game.im.c.renderdistance ||
                abs(tp.cy-game.ctrl.mchunk.y) > game.im.c.renderdistance

            popat!(game.m.teleports,i)
            popat!(game.m.teleportids,i)
        end
    end

    return
end

function unloadEvents!(game::GameState)
    for (i,ev) in Iterators.reverse(enumerate(game.m.events[1:game.m.events.idx]))
        if abs(ev.cx-game.ctrl.mchunk.x) > game.im.c.renderdistance ||
                abs(ev.cy-game.ctrl.mchunk.y) > game.im.c.renderdistance

            popat!(game.m.events,i)
            popat!(game.m.eventids,i)
        end
    end

    return
end

function unloadAreas!(game::GameState)
    for (i,ar) in Iterators.reverse(enumerate(game.m.areas[1:game.m.areas.idx]))
        if abs(ar.cx-game.ctrl.mchunk.x) > game.im.c.renderdistance ||
                abs(ar.cy-game.ctrl.mchunk.y) > game.im.c.renderdistance

            popat!(game.m.areas,i)
            popat!(game.m.areaids,i)
        end
    end

    return
end


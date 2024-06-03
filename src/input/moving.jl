
trans1 = trans(Float32, 0, 1/240,0)
trans2 = trans(Float32, 0,-1/240,0)
trans3 = trans(Float32, 1/240,0,0)
trans4 = trans(Float32,-1/240,0,0)

function move(game::GameState)
    game.ctrl.counter += 1

    if game.ctrl.dir == 1
        game.im.c.projection1[2,4] += Float32(1/16)
        moveSprites(game,:npcs,dirs[1])
    elseif game.ctrl.dir == 2
        game.im.c.projection1[1,4] -= Float32(1/16)
        moveSprites(game,:npcs,dirs[4])
    elseif game.ctrl.dir == 3
        game.im.c.projection1[2,4] -= Float32(1/16)
        moveSprites(game,:npcs,dirs[3])
    else
        game.im.c.projection1[1,4] += Float32(1/16)
        moveSprites(game,:npcs,dirs[2])
    end

    if game.ctrl.counter == 16
        game.ctrl.moving = false
        game.ctrl.counter = 0

        game.ctrl.pos += dirs[game.ctrl.dir]

        checkChunks(game,game.ctrl.dir)
    end

    return
end

function checkChunks(game::GameState,dir::Int)
    @assert 1 <= dir <= 4 "Direction index out of bounds."

    rd = Int(game.im.c.renderdistance)
    r = 2*rd+1
    c = game.ctrl.chunk

    if dir == 1 && game.ctrl.pos[2] < 1
        game.ctrl.pos[2] += 16
        game.ctrl.chunk[2] -= 1

        game.im.c.projection1[2,4] -= 16

        shifty!(game.m.idxs,false)
        shifty!(game.m.didxs,!false)
        loadChunks!(game,game.m.idxs[1,:],c[1]-rd:c[1]+rd,fill(c[2]-rd,r))
    elseif dir == 2 && game.ctrl.pos[1] > 16
        game.ctrl.pos[1] -= 16
        game.ctrl.chunk[1] += 1

        game.im.c.projection1[1,4] += 16

        shiftx!(game.m.idxs,false)
        shiftx!(game.m.didxs,!false)
        loadChunks!(game,game.m.idxs[:,end],fill(c[1]+rd,r),c[2]-rd:c[2]+rd)
    elseif dir == 3 && game.ctrl.pos[2] > 16
        game.ctrl.pos[2] -= 16
        game.ctrl.chunk[2] += 1

        game.im.c.projection1[2,4] += 16

        shifty!(game.m.idxs,true)
        shifty!(game.m.didxs,!true)
        loadChunks!(game,game.m.idxs[end,:],c[1]-rd:c[1]+rd,fill(c[2]+rd,r))
    elseif dir == 4 && game.ctrl.pos[1] < 1
        game.ctrl.pos[1] += 16
        game.ctrl.chunk[1] -= 1

        game.im.c.projection1[1,4] -= 16

        shiftx!(game.m.idxs,true)
        shiftx!(game.m.didxs,!true)
        loadChunks!(game,game.m.idxs[:,1],fill(c[1]-rd,r),c[2]-rd:c[2]+rd)
    end

    return
end

function shiftx!(m::AbstractMatrix,rev::Bool=false)
    if rev
        c = copy(m[:,end])
        m[:,2:end] = m[:,1:end-1]
        m[:,1] = c
    else
        c = copy(m[:,1])
        m[:,1:end-1] = m[:,2:end]
        m[:,end] = c
    end

    return
end

function shifty!(m::AbstractMatrix,rev::Bool=false)
    if rev
        c = copy(m[1,:])
        m[1:end-1,:] = m[2:end,:]
        m[end,:] = c
    else
        c = copy(m[end,:])
        m[2:end,:] = m[1:end-1,:]
        m[1,:] = c
    end

    return
end
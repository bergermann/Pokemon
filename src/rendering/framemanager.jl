
function setupFrames(game::GameState)
    vbo = Float32[
       #x, y, tx, ty
        0, 0, 0, 0,
        1, 0, 1, 0,
        2, 0, 2, 0,
        3, 0, 3, 0,
        0, 1, 0, 1,
        1, 1, 1, 1,
        2, 1, 2, 1,
        3, 1, 3, 1,
        0, 2, 0, 2,
        1, 2, 1, 2,
        2, 2, 2, 2,
        3, 2, 3, 2,
        0, 3, 0, 3,
        1, 3, 1, 3,
        2, 3, 2, 3,
        3, 3, 3, 3,
    ]

    vbo[1:4:end] *= 8; vbo[2:4:end] *= 8
    vbo[3:4:end] /= 3; vbo[4:4:end] /= 3

    ebo = UInt8[
         0,  4,  1,
         4,  5,  1,
         1,  5,  2,
         5,  6,  2,
         2,  6,  3,
         6,  7,  3,
         4,  8,  5,
         8,  9,  5,
         5,  9,  6,
         9,  6, 10,
         6, 10,  7,
        10, 11,  7,
         8, 12,  9,
        12, 13,  9,
         9, 13, 10,
        13, 14, 10,
        10, 14, 11,
        14, 15, 11,
    ]

    glBindVertexArray(game.im.f.vao)
    glBindBuffer(GL_ARRAY_BUFFER,game.im.f.vbo)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,game.im.f.ebo)

    glVertexAttribPointer(0,2,GL_FLOAT,false,16,ptr(0)); glEnableVertexAttribArray(0)
    glVertexAttribPointer(1,2,GL_FLOAT,false,16,ptr(8)); glEnableVertexAttribArray(1)
    
    glBufferData(GL_ARRAY_BUFFER,sizeof(vbo),pointer(vbo),GL_STATIC_DRAW)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,sizeof(ebo),pointer(ebo),GL_STATIC_DRAW)
    
    glBindVertexArray(0)
    glBindBuffer(GL_ARRAY_BUFFER,0)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0)

    game.im.f.ulocpos = glGetUniformLocation(game.im.programs[2],"pos")
    game.im.f.ulocsize = glGetUniformLocation(game.im.programs[2],"size")

    loadTexture!(game,"frames/$(game.im.f.frameid).png",:frame)

    return
end



function createFrame!(game::GameState,name::Symbol,width::Int,height::Int,
        px::Int,py::Int,layer::Int; active::Bool=true)

    game.im.f.frames[name] = Frame(active,MVector{5,Float32}(px,py,layer,width,height))

    return
end

function removeFrame!(game::GameState,name::Symbol)
    pop!(game.im.f.frames,name)

    return
end

function moveFrame!(game::GameState,name::Symbol,dx::Int,dy::Int,dl::Int=0)
    game.im.f.frames[name].pos[1] += dx
    game.im.f.frames[name].pos[2] += dy
    game.im.f.frames[name].pos[3] += dl

    return
end

function activateFrame!(game::GameState,name::Symbol)
    game.im.f.frames[name].active = true

    return
end

function deactivateFrame!(game::GameState,name::Symbol)
    game.im.f.frames[name].active = false

    return
end

function switchFrame!(game::GameState,name::Symbol)
    game.im.f.frames[name].active = !game.im.f.frames[name].active

    return
end
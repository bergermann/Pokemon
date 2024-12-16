

function setupBackgrounds(game::GameState)
    game.im.b.ulocpos = glGetUniformLocation(game.im.programs[5],"pos")
    game.im.b.ulocscale = glGetUniformLocation(game.im.programs[5],"scale")

    checkError("bg setup")

    return
end

function createBackground!(game::GameState,name::Symbol,path::String,x::Int,y::Int,l::Int;
        sx::Real=1.0,sy::Real=1.0,active::Bool=true)

    tex, w, h = loadImage(path); checkError("create bg 0")

    b = game.im.b.backgrounds[name] = Background(x,y,l,sx,sy; active=active)
    buffer = Float32[
        0,0,0,0,
        w,0,1,0,
        0,h,0,1,
        w,h,1,1,
    ]#; buffer[1:4:end] .-= w/2; buffer[2:4:end] .-= h/2

    glBindVertexArray(b.vao)
    glBindBuffer(GL_ARRAY_BUFFER,b.vbo)
    checkError("create bg 1")

    glVertexAttribPointer(0,2,GL_FLOAT,false,16,ptr(0))
    glVertexAttribPointer(1,2,GL_FLOAT,false,16,ptr(8))

    glEnableVertexAttribArray(0)
    glEnableVertexAttribArray(1)

    glBufferData(GL_ARRAY_BUFFER,sizeof(buffer),pointer(buffer),GL_STATIC_DRAW)
    checkError("create bg 2")

    glBindVertexArray(0)
    glBindBuffer(GL_ARRAY_BUFFER,0)

    glBindTexture(GL_TEXTURE_2D,b.tex)
    
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,w,h,0,GL_RGBA,GL_UNSIGNED_BYTE,pointer(tex))

    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)

    glBindTexture(GL_TEXTURE_2D,0)

    checkError("create bg 3")

    return 
end

function deleteBackground!(game::GameState,name::Symbol)
    glDeleteVertexArrays(1,pointer([game.im.b.backgrounds[name].vao]))
    glDeleteBuffers(1,pointer([game.im.b.backgrounds[name].vbo]))

    glDeleteTextures(1,pointer([game.im.b.backgrounds[name].tex]))

    pop!(game.im.b.backgrounds,name)

    return
end

function deleteBackgrounds!(game::GameState,names::Symbol...)
    for name in names
        deleteBackground!(game,name)
    end

    return
end

function activateBackground!(game::GameState,name::Symbol)
    game.im.b.backgrounds[name].active = true
    
    return
end

function deactivateBackground!(game::GameState,name::Symbol)
    game.im.b.backgrounds[name].active = false
    
    return
end

function switchBackground!(game::GameState,name::Symbol)
    game.im.b.backgrounds[name].active = !game.im.b.backgrounds[name].active
    
    return
end
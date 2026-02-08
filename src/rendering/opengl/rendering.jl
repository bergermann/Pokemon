

function drawBackgrounds(game::GameState)
    glUseProgram(game.im.programs[5]); checkError("B.0")
    
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,game.im.l.fbo)
    glClear(GL_COLOR_BUFFER_BIT)
    
    for (name,b) in game.im.b.backgrounds
        if !b.active
            continue
        end
        
        glFramebufferTextureLayer(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,
            game.im.l.tex,0,Int(b.pos[3])-1); checkError("B.0.1")

        glUniform2f(game.im.b.ulocpos,b.pos[1],b.pos[2]); checkError("B.1")
        glUniform2f(game.im.b.ulocscale,b.scale[1],b.scale[2]); checkError("B.2")
        glUniform4f(game.im.b.uloccolor,b.color[1],b.color[2],b.color[3],b.color[4])
        checkError("B.2.1")

        glBindTexture(GL_TEXTURE_2D,b.tex); checkError("B.3")
        glBindVertexArray(b.vao); checkError("B.4")
        glBindBuffer(GL_ARRAY_BUFFER,b.vbo); checkError("B.5")

        glDrawArrays(GL_TRIANGLE_STRIP,0,4); checkError("B.6")
    end

    glBindTexture(GL_TEXTURE_2D,0); checkError("B.8")
    glBindVertexArray(0)
    glBindBuffer(GL_ARRAY_BUFFER,0); checkError("B.9")

    return
end



function drawMap(game::GameState)
    r2 = (2*game.im.c.renderdistance+1)^2

    glUseProgram(game.im.programs[1]); checkError("C.0")

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,game.im.l.fbo)
    glFramebufferTexture(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,game.im.l.tex,0)
    
    glActiveTexture(GL_TEXTURE0); checkError("C.2")
    bindATexture(game,:tiles)
    
    glActiveTexture(GL_TEXTURE0+1)
    glBindTexture(GL_TEXTURE_BUFFER,game.im.c.tidxs); checkError("C.3")
    
    glActiveTexture(GL_TEXTURE0+2)
    glBindTexture(GL_TEXTURE_BUFFER,game.im.c.tanimdata); checkError("C.3")

    glUniformMatrix4fv(game.im.c.ulocp1,1,false,pointer(game.im.c.projection1))
    checkError("C.4")

    glUniform1ui(game.im.c.ulocframe,game.frame)
    checkError("C.5")

    glBindVertexArray(game.im.c.vao); checkError("C.6.1")
    glBindBuffer(GL_ARRAY_BUFFER,game.im.c.vbo)

    glBufferSubData(GL_ARRAY_BUFFER,0,2560*r2,pointer(game.m.tilemap))

    glDrawArrays(GL_POINTS,0,length(game.m.tilemap)); checkError("C.6.3")

    glBindTexture(GL_TEXTURE_BUFFER,0)

    glActiveTexture(GL_TEXTURE0+1)
    glBindTexture(GL_TEXTURE_BUFFER,0)

    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D,0); checkError("C.7")
    glBindVertexArray(0); checkError("C.8")

    return
end



function drawSprites(game::GameState)
    glUseProgram(game.im.programs[4]); checkError("S.0")

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,game.im.l.fbo)
    glFramebufferTexture(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,game.im.l.tex,0)

    for (name,sheet) in game.im.s.sheets
        glUniform2uiv(game.im.s.ulocsize,1,pointer(sheet.size))

        bindATexture(game,name)
        glBindVertexArray(sheet.vao)
        glBindBuffer(GL_ARRAY_BUFFER,sheet.vbo)
        
        setSpriteBufferData(sheet)

        glDrawArrays(GL_POINTS,0,sheet.maxsprites)
    end

    glBindTexture(GL_TEXTURE_2D,0); checkError("S.6")
    glBindBuffer(GL_ARRAY_BUFFER,0)
    glBindVertexArray(0); checkError("S.7")

    return
end

function setSpriteBufferData(sheet::SpriteSheet)
    m = sheet.maxsprites

    glBufferSubData(GL_ARRAY_BUFFER, 0*m, 8*m,pointer(sheet.idx))
    glBufferSubData(GL_ARRAY_BUFFER, 8*m,16*m,pointer(sheet.pos))
    glBufferSubData(GL_ARRAY_BUFFER,24*m, 8*m,pointer(sheet.scale))
    glBufferSubData(GL_ARRAY_BUFFER,32*m, 4*m,pointer(sheet.rot))
    glBufferSubData(GL_ARRAY_BUFFER,36*m, 4*m,pointer(sheet.alpha))
    glBufferSubData(GL_ARRAY_BUFFER,40*m, 2*m,pointer(sheet.rev))
    glBufferSubData(GL_ARRAY_BUFFER,42*m, 1*m,pointer(sheet.active))
    
    return
end



function drawFrames(game::GameState)
    glUseProgram(game.im.programs[2]); checkError("F.1")

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,game.im.l.fbo)

    bindTexture(game,:frame)
    glBindVertexArray(game.im.f.vao); checkError("F.2")
    glBindBuffer(GL_ARRAY_BUFFER,game.im.f.vbo); checkError("F.3")

    for (name,frame) in game.im.f.frames
        if !frame.active
            continue
        end

        glFramebufferTextureLayer(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,
            game.im.l.tex,0,Int(frame.pos[3])-1)

        glUniform2f(game.im.f.ulocpos,frame.pos[1],frame.pos[2]); checkError("F.5")
        glUniform2f(game.im.f.ulocsize,frame.pos[4],frame.pos[5]); checkError("F.6")

        glDrawElements(GL_TRIANGLES,54,GL_UNSIGNED_BYTE,C_NULL); checkError("F.7")
    end

    glBindTexture(GL_TEXTURE_2D,0)
    glBindVertexArray(0)
    glBindBuffer(GL_ARRAY_BUFFER,0); checkError("F.8")

    return
end



function drawTexts(game::GameState)
    glUseProgram(game.im.programs[3]); checkError("T.0")

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,game.im.l.fbo)

    for (name,text) in game.im.text.texts
        if !text.active
            continue
        end
        # println("Text: ",name)

        glFramebufferTextureLayer(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,
            game.im.l.tex,0,Int(text.pos[3])-1); checkError("T.01")

        glUniform2f(game.im.text.ulocpos,text.pos[1],text.pos[2]); checkError("T.0.1")
        glUniformMatrix3x4fv(game.im.text.uloccolors,1,false,pointer(text.colors)); checkError("T.1")

        glBindTexture(GL_TEXTURE_2D,game.im.text.texs[text.font]); checkError("T.2")
        glBindVertexArray(text.vao); checkError("T.3")
        glBindBuffer(GL_ARRAY_BUFFER,text.vbo); checkError("T.4")

        glDrawArrays(GL_TRIANGLES,0,text.nchar*6)
    end

    glBindTexture(GL_TEXTURE_2D,0); checkError("T.8")
    glBindVertexArray(0)
    glBindBuffer(GL_ARRAY_BUFFER,0); checkError("T.9")

    return
end



function drawPostProcess(game::GameState)
    glUseProgram(game.im.programs[15])

    glUniform4f(game.im.l.uloccolor,game.im.l.color[1],game.im.l.color[2],
        game.im.l.color[3],game.im.l.color[4]); checkError("PP.1")
    # glUniform4fv(game.im.l.uloccolor,4,pointer(game.im.l.color)); checkError("PP.1")
    glUniform2f(game.im.l.ulocslider,game.im.l.slider[1],game.im.l.slider[2]); checkError("PP.2")

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,0)
    glViewport(0,0,game.im.windowsize.width,game.im.windowsize.height)

    glClear(GL_COLOR_BUFFER_BIT)

    glBindTexture(GL_TEXTURE_2D_ARRAY,game.im.l.tex)
    glBindVertexArray(game.im.l.vao)
    glBindBuffer(GL_ARRAY_BUFFER,game.im.l.vbo)

    glDrawArrays(GL_TRIANGLE_STRIP,0,4)
    
    checkError("PP")

    return
end

# function drawMap(game::GameState)
#     r = 2*game.im.c.renderdistance+1

#     glUseProgram(game.im.programs[2]); checkError("M.0")

#     glBindFramebuffer(GL_DRAW_FRAMEBUFFER,game.im.l.layers[1]); checkError("M.1")
    
#     glActiveTexture(GL_TEXTURE0); checkError("M.2")
#     glBindTexture(GL_TEXTURE_2D,game.im.c.textures[1]); checkError("M.3")

#     glUniform2f(glGetUniformLocation(game.im.programs[2],"chunkconfig"),
#         Float32(r),Float32(r^2))
#     checkError("M.4.1")
#     layer_ = glGetUniformLocation(game.im.programs[2],"layer")
#     checkError("M.4.2")

#     glUniformMatrix4fv(glGetUniformLocation(game.im.programs[2],"projection"),1,
#         false,pointer(game.im.l.projection))
#     checkError("M.4.3")

#     glBindVertexArray(game.im.l.vao[2]); checkError("M.5")
    
#     for i in 1:5
#         glViewport(0,160*(i-1),240,160); # checkError("M.6.$i.0")
#         glUniform1f(layer_,Float32(i-1)); # checkError("M.6.$i.1")

#         glDrawArrays(GL_POINTS,0,r^2); # checkError("M.6.$i.2")
#     end

#     glBindTexture(GL_TEXTURE_2D,0); checkError("M.7")
#     glBindVertexArray(0); checkError("M.8")
#     glBindFramebuffer(GL_FRAMEBUFFER,0); checkError("M.9")

#     return
# end

# function drawLayers(game::GameState)
#     glUseProgram(game.im.programs[3]); checkError("L.0")

#     glBindFramebuffer(GL_DRAW_FRAMEBUFFER,0); checkError("L.1")
#     glViewport(0,0,game.im.windowsize.width,game.im.windowsize.height); checkError("L.2")
    
#     glActiveTexture(GL_TEXTURE0); checkError("L.3")
#     glBindTexture(GL_TEXTURE_2D,game.im.l.textures[1]); checkError("L.4")

#     glUniformMatrix4fv(glGetUniformLocation(game.im.programs[3],"projection"),1,
#         false,pointer(game.im.screenprojection))
#     checkError("L.5")

#     glBindVertexArray(game.im.l.vao[1]); checkError("L.5.1")
#     glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,game.im.l.ebo[1]); checkError("L.5")

#     glDrawElements(GL_TRIANGLES,6*6,GL_UNSIGNED_BYTE,C_NULL); checkError("L.6")

#     glBindTexture(GL_TEXTURE_2D,0); checkError("L.7")
#     glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0)
#     glBindVertexArray(0); checkError("L.8")
#     glBindFramebuffer(GL_FRAMEBUFFER,0); checkError("L.9")

#     return
# end
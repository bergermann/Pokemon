


mutable struct Layers
    fbo::UInt32
    tex::UInt32

    vao::UInt32
    vbo::UInt32

    function Layers()
        vao = UInt32[0]; glGenVertexArrays(1,pointer(vao))
        vbo = UInt32[0]; glGenBuffers(1,pointer(vbo))
        fbo = UInt32[0]; glGenFramebuffers(1,pointer(fbo))
    
        glBindFramebuffer(GL_FRAMEBUFFER, fbo[1])
    
        tex = UInt32[0]; glGenTextures(1,pointer(tex))
    
        glBindTexture(GL_TEXTURE_2D_ARRAY,tex[1])
        glTexImage3D(GL_TEXTURE_2D_ARRAY,0,GL_RGBA,240,160,6,0,GL_RGBA,
            GL_UNSIGNED_BYTE,C_NULL); checkError("L 1")
            
        glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)

        glFramebufferTexture(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,tex[1],0); checkError("L 2")

        if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE
            println("Framebuffer incomplete!")
        end
        
        glBindTexture(GL_TEXTURE_2D,0)
        glBindFramebuffer(GL_FRAMEBUFFER,0)
    
        checkError("L 10")
        
        glBindVertexArray(vao[1])
        glBindBuffer(GL_ARRAY_BUFFER,vbo[1])
        
        glVertexAttribPointer(0,2,GL_FLOAT,GL_TRUE,16,C_NULL)
        glEnableVertexAttribArray(0)
        
        glVertexAttribPointer(1,2,GL_FLOAT,GL_TRUE,16,ptr(8))
        glEnableVertexAttribArray(1)
    
        buffer = Float32[
            -1,-1,0,0,
            -1, 1,0,1,
             1,-1,1,0,
             1, 1,1,1,
        ]
    
        glBufferData(GL_ARRAY_BUFFER,sizeof(buffer),pointer(buffer),GL_STATIC_DRAW)
    
        glBindBuffer(GL_ARRAY_BUFFER,0)
        glBindVertexArray(0)
    
        checkError("L 11")    

        new(fbo[1],tex[1],vao[1],vbo[1])
    end
end
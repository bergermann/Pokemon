
const ptr = Ptr{Nothing}

function checkError(p)
    err = glGetError()

    if err != GL_NO_ERROR
        println("Error marker ",p)
    end

    while err != GL_NO_ERROR
        display(GLENUM(err).name)
        err = glGetError()
    end
end



function validateLink(program::UInt32)
    status = UInt32[0]

    glGetProgramiv(program,GL_VALIDATE_STATUS,status)

    if status[1] != GL_TRUE
        println("Program $program failed to link!")
        getProgramInfoLog(program)
    end

    return
end

function validateProgram(program::UInt32)
    glValidateProgram(program)

    status = UInt32[0]

    glGetProgramiv(program,GL_VALIDATE_STATUS,status)

    if status[1] != GL_TRUE
        println("Program $program failed to validate!")
    end

    return
end

function getProgramInfoLog(program::UInt32)
    l = UInt32[0]
    glGetProgramiv(program,GL_INFO_LOG_LENGTH,l)

    log = zeros(UInt8,l[1])

    glGetProgramInfoLog(program,l[1],C_NULL,log)

    println(String(log[1:l[1]-2]),"\n")

    return
end



function showTexture(tex::UInt32,imsize::Tuple{Int,Int})
    img = zeros(N0f8,imsize[1]*imsize[2]*4)

    glBindTexture(GL_TEXTURE_2D,tex); checkError("T.1")

    glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE,
        pointer(img)); checkError("T.2")

    img_ = [RGBA(img[i:3+i]...) for i in 1:4:length(img)]
    img_ = reshape(img_,imsize)
    img_ = img_'
    if !all(isequal(RGBA{N0f8}(0.0,0.0,0.0,0.0)),img_)
        println("image filled")
        # display(img_)
    end

    glBindTexture(GL_TEXTURE_2D,0); checkError("T.3")

    save("out/tex.png",img_)

    return img_
end

function showArrayTexture(tex::UInt32,imsize::Tuple{Int,Int,Int})
    img = zeros(N0f8,imsize[1]*imsize[2]*imsize[3]*4)

    glBindTexture(GL_TEXTURE_2D_ARRAY,tex); checkError("T.1")

    # glGetTexImage(GL_TEXTURE_2D_ARRAY,0,GL_RGBA,GL_UNSIGNED_BYTE,
    #     pointer(img)); checkError("T.2")
    glGetTextureSubImage(tex,0,0,0,0,240,160,imsize[3],GL_RGBA,GL_UNSIGNED_BYTE,
        sizeof(img),pointer(img)); checkError("T.2")

    img_ = [RGBA(img[i:3+i]...) for i in 1:4:length(img)]
    img_ = reshape(img_,(imsize[1],imsize[2]*imsize[3]))
    img_ = img_'
    reverse!(img_; dims=1)
    if !all(isequal(RGBA{N0f8}(0.0,0.0,0.0,0.0)),img_)
        println("image filled")
        # display(img_)
    end

    checkError("show array texture")

    glBindTexture(GL_TEXTURE_2D,0); checkError("T.3")

    save("out/tex.png",img_)

    return img_
end

function showTextureBuffer(buffer::UInt32,imsize::Tuple{Int,Int})
    img = zeros(N0f8,imsize[1]*imsize[2]*4)

    glBindFramebuffer(GL_READ_FRAMEBUFFER,buffer); checkError("B.1")
    
    glReadPixels(0,0,imsize[1],imsize[2],GL_RGBA,GL_UNSIGNED_BYTE,pointer(img))
    checkError("B.2")

    img_ = [RGBA(img[i:3+i]...) for i in 1:4:length(img)]
    img_ = reshape(img_,imsize)
    img_ = img_'
    if !all(isequal(RGBA{N0f8}(0.0,0.0,0.0,0.0)),img_)
        println("buffer filled")
        # display(img_)
    end

    glBindFramebuffer(GL_FRAMEBUFFER,0); checkError("B.3")

    save("out/buffer.png",img_)

    return img_
end

function showArrayTextureBuffer(buffer::UInt32,imsize::Tuple{Int,Int,Int})
    img = zeros(N0f8,imsize[1]*imsize[2]*4)

    for i in 1:imsize[3]
        glBindFramebuffer(GL_READ_FRAMEBUFFER,buffer); checkError("B.1.$i")
        
        glReadPixels(0,0,imsize[1],imsize[2],GL_RGBA,GL_UNSIGNED_BYTE,pointer(img))
        checkError("B.2.$i")
    end

    img_ = [RGBA(img[i:3+i]...) for i in 1:4:length(img)]
    img_ = reshape(img_,imsize)
    img_ = img_'
    if !all(isequal(RGBA{N0f8}(0.0,0.0,0.0,0.0)),img_)
        println("buffer filled")
        # display(img_)
    end

    glBindFramebuffer(GL_FRAMEBUFFER,0); checkError("B.3")

    save("out/buffer.png",img_)

    return img_
end




function glGenTexture()
    checkError("gen tex 0")
    t = zeros(UInt32,1)
    glGenTextures(1,pointer(t))

    checkError("gen tex 1")

    return t[1]
end

# import GLFW: glGenTextures
# function glGenTextures(n::Int)
#     t = zeros(UInt32,n)
#     GLFW.glGenTextures(n,pointer(t))

#     return t
# end
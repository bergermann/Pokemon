
using ModernGL, GLFW, Images #FixedPointNumbers, ColorTypes



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

function renderTex(program,vao,fbo)
    glBindFramebuffer(GL_FRAMEBUFFER,fbo)
    glUseProgram(program)
    glBindVertexArray(vao)
    glDrawArrays(GL_TRIANGLES,0,3)

    return
end

function renderScreen(program,vao,texture)
    glBindFramebuffer(GL_FRAMEBUFFER,0)
    glBindTexture(GL_TEXTURE_2D, texture)

    glUseProgram(program)
    glBindVertexArray(vao)
    glDrawArrays(GL_TRIANGLES,0,6)

    return
end

function showScreen(imsize::Tuple{Int,Int})
    img = zeros(N0f8,imsize[1]*imsize[2]*4)

    glBindFramebuffer(GL_READ_FRAMEBUFFER,0)
    
    glReadPixels(0,0,imsize[1],imsize[2],GL_RGBA,GL_UNSIGNED_BYTE,pointer(img))

    img_ = [RGBA(img[i:3+i]...) for i in 1:4:length(img)]
    img_ = reshape(img_,imsize)
    img_ = collect(reverse!(img_'; dims=1))
    
    if !all(isequal(RGBA{N0f8}(0.0,0.0,0.0,0.0)),img_)
        println("buffer filled")
        display(img_)
    end

    glBindFramebuffer(GL_FRAMEBUFFER,0)

    return img_
end

function showBuffer(buffer,imsize::Tuple{Int,Int})
    img = zeros(N0f8,imsize[1]*imsize[2]*4)

    glBindFramebuffer(GL_READ_FRAMEBUFFER,buffer)
    
    glReadPixels(0,0,imsize[1],imsize[2],GL_RGBA,GL_UNSIGNED_BYTE,pointer(img))

    img_ = [RGBA(img[i:3+i]...) for i in 1:4:length(img)]
    img_ = reshape(img_,imsize)
    img_ = collect(reverse!(img_'; dims=1))
    
    if !all(isequal(RGBA{N0f8}(0.0,0.0,0.0,0.0)),img_)
        println("buffer filled")
        display(img_)
    end

    glBindFramebuffer(GL_FRAMEBUFFER,0)

    return img_
end




scale = 1
GLFW.WindowHint(GLFW.DEPTH_BITS,16)
GLFW.WindowHint(GLFW.CLIENT_API,GLFW.OPENGL_API)
window = GLFW.Window(name="Pokemon",resolution=(240*scale,160*scale),
    visible=true,focus=true,major=3,minor=3)

GLFW.MakeContextCurrent(window)

println("OpenGL version:\n",unsafe_string(glGetString(GL_VERSION)),"\n")

glEnable(GL_BLEND)
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
glClearColor(0.0, 0.0, 0.0, 0.0)

GLFW.SwapInterval(0)

windowsize = GLFW.GetWindowSize(window)    
projection = Float32[1 0 0 0
                     0 1 0 0
                     0 0 1 0
                     0 0 0 1]
backbuffersize = (h=Int32(160),w=Int32(240))



program_basic = glCreateProgram()

vert = glCreateShader(GL_VERTEX_SHADER)
source = Vector{UInt8}(read(open("test/basic.vert"),String))
sourceptrs = Ptr{UInt8}[pointer(source)]
glShaderSource(vert, 1, sourceptrs, Ref{GLint}(length(source)))
glCompileShader(vert)
glAttachShader(program_basic,vert)

frag = glCreateShader(GL_FRAGMENT_SHADER)
source = Vector{UInt8}(read(open("test/basic.frag"),String))
sourceptrs = Ptr{UInt8}[pointer(source)]
glShaderSource(frag, 1, sourceptrs, Ref{GLint}(length(source)))
glCompileShader(frag)
glAttachShader(program_basic,frag)

glLinkProgram(program_basic)

validateLink(program_basic)
validateProgram(program_basic)

glDetachShader(program_basic,vert)
glDetachShader(program_basic,frag)
glDeleteShader(vert)
glDeleteShader(frag)



program_tex = glCreateProgram()

vert = glCreateShader(GL_VERTEX_SHADER)
source = Vector{UInt8}(read(open("test/tex.vert"),String))
sourceptrs = Ptr{UInt8}[pointer(source)]
glShaderSource(vert, 1, sourceptrs, Ref{GLint}(length(source)))
glCompileShader(vert)
glAttachShader(program_tex,vert)

frag = glCreateShader(GL_FRAGMENT_SHADER)
source = Vector{UInt8}(read(open("test/tex.frag"),String))
sourceptrs = Ptr{UInt8}[pointer(source)]
glShaderSource(frag, 1, sourceptrs, Ref{GLint}(length(source)))
glCompileShader(frag)
glAttachShader(program_tex,frag)

glLinkProgram(program_tex)

validateLink(program_tex)
validateProgram(program_tex)

glDetachShader(program_tex,vert)
glDetachShader(program_tex,frag)
glDeleteShader(vert)
glDeleteShader(frag)



programs = zeros(UInt32,2)
programs[1] = program_basic; programs[2] = program_tex



vertices1 = Float32[
    -1.0, -1.0,
     0.5, -1.0,
     0.0,  1.0,
]

vertices2 = Float32[
    -1.0,  1.0,
     0.5,  1.0,
     0.0, -1.0,
]

vertices3 = Float32[
    -1.0,  1.0,  0.0, 1.0,
    -1.0, -1.0,  0.0, 0.0,
     1.0, -1.0,  1.0, 0.0,

    -1.0,  1.0,  0.0, 1.0,
     1.0, -1.0,  1.0, 0.0,
     1.0,  1.0,  1.0, 1.0,
]

vbo = UInt32[0,0,0]; glGenBuffers(3,pointer(vbo))
vao = UInt32[0,0,0]; glGenVertexArrays(3,pointer(vao))
fbo = UInt32[0]; glGenFramebuffers(1,pointer(fbo))
texture = UInt32[0]; glGenTextures(1, pointer(texture));

glBindVertexArray(vao[1])
glBindBuffer(GL_ARRAY_BUFFER, vbo[1])
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices1), pointer(vertices1), GL_STATIC_DRAW)
glEnableVertexAttribArray(0)
glVertexAttribPointer(0,2,GL_FLOAT,false,8,Ptr{Nothing}(0))

glBindVertexArray(vao[2])
glBindBuffer(GL_ARRAY_BUFFER, vbo[2])
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices2), pointer(vertices2), GL_STATIC_DRAW)
glEnableVertexAttribArray(0)
glVertexAttribPointer(0,2,GL_FLOAT,false,8,Ptr{Nothing}(0))

glBindVertexArray(vao[3])
glBindBuffer(GL_ARRAY_BUFFER, vbo[3])
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices3), pointer(vertices3), GL_STATIC_DRAW)
glEnableVertexAttribArray(0)
glVertexAttribPointer(0,2,GL_FLOAT,false,16,Ptr{Nothing}(0))
glEnableVertexAttribArray(1)
glVertexAttribPointer(1,2,GL_FLOAT,false,16,Ptr{Nothing}(8))

glBindTexture(GL_TEXTURE_2D, texture[1])
glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,240,160,0,GL_RGB,GL_UNSIGNED_BYTE,Ptr{Nothing}(0))
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

glBindFramebuffer(GL_FRAMEBUFFER,fbo[1])
glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,texture[1],0)
glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE



renderTex(program_basic,vao[1],fbo[1])
tex = showBuffer(fbo[1],(240,160))

renderScreen(program_tex,vao[3],texture[1])
s = showScreen((240,160))



while !GLFW.WindowShouldClose(window)
    renderTex(program_basic,vao[1],fbo[1])

    renderScreen(program_tex,vao[3],texture[1])

    GLFW.SwapBuffers(window); GLFW.PollEvents(); sleep(1.0/60.0)
end; GLFW.DestroyWindow(window)



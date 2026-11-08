
using ModernGL, GLFW





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

programs = zeros(UInt32,2)
programs[1] = program_basic



vertices = Float32[
    -1, -1,
     1, -1,
     0,  1,
]

vbo = UInt32[0]; glGenBuffers(1,pointer(vbo))
vao = UInt32[0]; glGenVertexArrays(1,pointer(vao))

glBindVertexArray(vao[1])

glBindBuffer(GL_ARRAY_BUFFER, vbo[1])
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), pointer(vertices), GL_STATIC_DRAW)

glVertexAttribPointer(0,2,GL_FLOAT,false,8,Ptr{Nothing}(0))
glEnableVertexAttribArray(0)



while !GLFW.WindowShouldClose(window)
    glUseProgram(program_basic)
    glBindVertexArray(vao[1])
    glDrawArrays(GL_TRIANGLES,0,3)

    GLFW.SwapBuffers(window)

    GLFW.PollEvents()

    sleep(1.0/60.0)
end; GLFW.DestroyWindow(window)

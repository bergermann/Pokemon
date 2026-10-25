
using ModernGL, GLFW

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
glAttachShader(program,vert)

frag = glCreateShader(GL_FRAGMENT_SHADER)
source = Vector{UInt8}(read(open("test/basic.frag"),String))
sourceptrs = Ptr{UInt8}[pointer(source)]
glShaderSource(frag, 1, sourceptrs, Ref{GLint}(length(source)))
glCompileShader(frag)
glAttachShader(program,frag)

glLinkProgram(program)

glDetachShader(program,vert)
glDetachShader(program,frag)
glDeleteShader(vert)
glDeleteShader(frag)

programs = zeros(UInt32,2)
programs[1] = program_basic



vertices = Float32[
    -1, -1, 0,
     1, -1, 0,
     0,  1, 0,
]

vbo = UInt32[0]; glGenBuffers(1,pointer(vbo))
glBindBuffer(GL_ARRAY_BUFFER, vbo)
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), pointer(vertices), GL_STATIC_DRAW)

GLFW.SwapBuffers(game.im.window); checkError("swap")
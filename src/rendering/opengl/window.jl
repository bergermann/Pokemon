

# change to write directly to im?

function genWindow(scale=1;)
    GLFW.WindowHint(GLFW.DEPTH_BITS,16)
    GLFW.WindowHint(GLFW.CLIENT_API,GLFW.OPENGL_API)
    window = GLFW.Window(name="Pokemon",resolution=(240*scale,160*scale),
        visible=true,focus=true)

    GLFW.MakeContextCurrent(window)
    # GLA.set_context!(window)

    println("OpenGL version:\n",unsafe_string(glGetString(GL_VERSION)),"\n")

    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    # GLFW.SwapInterval(1)
    GLFW.SwapInterval(0)

    GLFW.SetKeyCallback(window,keyCallback)
    # GLFW.SetWindowSizeCallback(window,resizeCallback)

    return window
end
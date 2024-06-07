


include("opengl/opengl.jl")

include("backgroundmanager.jl")
include("texturemanager.jl")
include("chunkmanager.jl")
include("framemanager.jl")
include("textmanager.jl")
include("spritemanager.jl")


const tilesets = [
    "base",
    "ledges",
    "edges",
    "vegetation1",
    "decorations1",
    "grass1",
    "grass2",
    "borders1",
    "patchesgrasslight",
    "patchesberry",
    "pokecenter",
    "gym1",
    "lab1",
    "house1",
    "house2",
    "water1",
    "flowers1",
    "flowers2",
    "flowers3",
    "interior1",
] .* ".png"




function render(game::GameState)
    glViewport(0,0,240,160)

    glClear(GL_COLOR_BUFFER_BIT)

    drawBackgrounds(game)

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,game.im.l.fbo)
    glFramebufferTexture(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,game.im.l.tex,0)
    
    if game.overworld
        drawMap(game)
    end

    drawFrames(game)
    drawTexts(game)
    drawSprites(game)

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,0)
    glViewport(0,0,game.im.windowsize.width,game.im.windowsize.height)

    drawPostProcess(game)

    GLFW.SwapBuffers(game.im.window); checkError("swap")

    GLFW.PollEvents(); checkError("Poll")

    return
end
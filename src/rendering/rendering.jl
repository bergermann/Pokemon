


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
    
    if game.overworld
        drawMap(game)
    end

    drawFrames(game)
    drawTexts(game)
    drawSprites(game)

    drawPostProcess(game)

    GLFW.SwapBuffers(game.im.window); checkError("swap")

    GLFW.PollEvents(); checkError("Poll")

    return
end
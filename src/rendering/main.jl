
using ModernGL, GLFW, GLAbstraction
const GLA = GLAbstraction

using StaticArrays, LinearAlgebra
using Images, Serialization

include("matrices.jl")

include("types/types.jl")
include("opengl/opengl.jl")

include("backgroundmanager.jl")
include("texturemanager.jl")
include("chunkmanager.jl")
include("framemanager.jl")
include("textmanager.jl")
include("spritemanager.jl")
include("controls/moving.jl")


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


function setupGame(windowscale::Int=4,renderdistance::Int=2,maxtextures::Int=64;)
    game = GameState(
        0,
        PlayerData(),
        Im(windowscale,renderdistance,maxtextures),
        Controls(10,10,1,1),
        MapData(renderdistance)
    )

    setupBackgrounds(game)
    setupChunks(game)
    setupFrames(game)
    setupFonts(game)
    setupSprites(game)

    game.im.c.projection1[1:2,4] .= -game.ctrl.pos

    loadArrayTexture!(game,"tilesets",tilesets,:tiles,16,16)
    
    loadSpriteSheet!(game,"npcs_all.png",:npcs,16,32,9; maxsprites=2)
    loadSpriteSheet!(game,"main1.png",:mc,32,32,9; maxsprites=1)

    loadChunksAll!(game)

    return game
end



function render(game::GameState)
    glViewport(0,0,240,160)

    glClear(GL_COLOR_BUFFER_BIT)

    drawBackgrounds(game)

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,game.im.l.fbo)
    glFramebufferTexture(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,game.im.l.tex,0)
    
    drawMap(game)
    drawSprites(game)
    drawFrames(game)
    drawTexts(game)

    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,0)
    glViewport(0,0,game.im.windowsize.width,game.im.windowsize.height)

    drawPostProcess(game)

    GLFW.SwapBuffers(game.im.window); checkError("swap")

    GLFW.PollEvents(); checkError("Poll")

    return
end
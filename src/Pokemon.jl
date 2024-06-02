# __precompile__(true)

module Pokemon

export play, g

using ModernGL, GLFW#, GLAbstraction
# const GLA = GLAbstraction

using StaticArrays, LinearAlgebra
using Images, Serialization, DelimitedFiles

include("types.jl")
include("rendering/types/texts.jl")
include("game/types/types.jl")

include("core.jl")
include("rendering/rendering.jl")
# include("audio/audio.jl")
include("input/input.jl")
include("game/game.jl")

# @time foreach(names(@__MODULE__, all=true)) do s
#     @eval export $s
# end

function main()
    # Base.GC.enable(false)
    # Base.GC.@preserve game sceneTransition!

    input = 0
    
    @time game = setupGame()
    
    setInventoryTest!(game.trainer.inventory)
    
    push!(game.trainer.pokemon,generatePkmn(game,0x0001,0x14))
    push!(game.trainer.pokemon,generatePkmn(game,0x0002,0x03))
    push!(game.trainer.pokemon,generatePkmn(game,0x0003,0x60))
    
    createSprite!(game,:npctest1,:npcs,10, 7,P(-16, 8),15, 2; active=true)
    createSprite!(game,:npctest2,:npcs, 1, 4,P(-48,40), 5, 2; active=true)
    createSprite!(game,:mc,      :mc,   1, 4,P(  0, 8),10, 3; active=true)
    
    createFrame!(game,:testframe,28,5,-120,24,6)
    
    createText!(game,:test,3,-120+8,24+8,6,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"*
    " abcdefghijk/lmnopqrstuvwxyz0123456789!?.:,;%()ß",
    [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; wpad=0)
    
    render(game)
    
    GLFW.DestroyWindow(game.im.window); return game
    
    # Base.GC.gc()

    while !GLFW.WindowShouldClose(game.im.window)
        game.frame += 0x01
 
        # @time updateGame!(game,input; s=settings)
        updateGame!(game,input)

        render(game)
    end

    GLFW.DestroyWindow(game.im.window)

    return game
end

g = play();

end

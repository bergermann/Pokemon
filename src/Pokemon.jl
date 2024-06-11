# __precompile__(true)

module Pokemon

export play, g

using ModernGL, GLFW#, GLAbstraction
# const GLA = GLAbstraction

using LinearAlgebra, Images, Serialization, DelimitedFiles

include("types.jl")
include("rendering/types/types.jl")
include("input/types/controls.jl")
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

    inputs, keymap = setupInputs(km); global keymap

    include("input/callbacks.jl")
    
    @time game = setupGame()
    
    setInventoryTest!(game.p.inventory)
    
    push!(game.p.pokemon,generatePkmn(game,0x0001,0x14))
    push!(game.p.pokemon,generatePkmn(game,0x0002,0x03))
    push!(game.p.pokemon,generatePkmn(game,0x0003,0x60))
    
    render(game)
    
    # GLFW.DestroyWindow(game.im.window); return game
    
    # Base.GC.gc()

    while !GLFW.WindowShouldClose(game.im.window)
        game.frame += 0x01
 
        # @time updateGame!(game,inputs)
        updateGame!(game,inputs)

        render(game)
    end

    GLFW.DestroyWindow(game.im.window)

    return game, inputs
end

game, inputs = main();

end

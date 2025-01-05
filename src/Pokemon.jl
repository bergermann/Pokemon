# __precompile__(true)

module Pokemon

export game, inputs

using ModernGL, GLFW#, GLAbstraction
# const GLA = GLAbstraction

# using TickTock
using StatsBase, Images, Serialization, DelimitedFiles
# using LinearAlgebra

include("types.jl")
include("game/types/npcs.jl")
include("game/types/objects.jl")
include("game/types/items.jl")
include("rendering/types/types.jl")
include("input/types/controls.jl")
include("game/types/types.jl")

include("core.jl")
include("rendering/rendering.jl")
include("spritesheets.jl")
# include("audio/audio.jl")
include("input/input.jl")
include("game/game.jl")

# @time foreach(names(@__MODULE__, all=true)) do s
#     @eval export $s
# end

function main()
    fps = 60.

    inputs, keymap = setupInputs(km); global keymap; pause = false

    include("input/callbacks.jl")
    
    @time game = setupGame(4)
    
    # Base.GC.enable(false)
    Base.GC.@preserve game sceneTransition!
    
    setInventoryTest!(game.p.inventory)
    
    push!(game.p.pokemon,generatePkmn(game,0x0001,0x14))
    push!(game.p.pokemon,generatePkmn(game,0x0002,0x03))
    push!(game.p.pokemon,generatePkmn(game,0x0003,0x60))
    push!(game.p.pokemon,generatePkmn(game,0x0004,0x08))
    push!(game.p.pokemon,generatePkmn(game,0x0005,0x13))

    game.p.dex[1:5,2] .= true
    game.p.dex[1:15,1] .= true

    render(game)
    
    @time Base.GC.gc()

    # tick()
    # t0 = 0.
    t0 = time()
    t1 = 0.

    while !GLFW.WindowShouldClose(game.im.window)
        # t1 = peektimer()
        t2 = time()-t0
        
        if 60.0*t2 >= game.frame
            if inputs.pause.press
                pause ? println("unpausing") : println("pausing")
                
                pause = !pause
                inputs.pause.press = false
                resetInputs!(inputs)
            end
            
            if !pause || inputs.next.press# || inputs.next.hold
                game.frame += 0x01
        
                # @time updateGame!(game,inputs)
                updateGame!(game,inputs)
            end
        end

        if t2-t1 >= 1/fps
            # t0 = peektimer()
            t1 = t2
            render(game)
        end
    end

    GLFW.DestroyWindow(game.im.window)

    return game, inputs
end

end

game, inputs = Pokemon.main();

# __precompile__(true)

module Pokemon

export game, inputs

using ModernGL, GLFW#, GLAbstraction
# const GLA = GLAbstraction

# using TickTock
using StatsBase, Images, Serialization, DelimitedFiles
# using LinearAlgebra

include("types.jl")
include("game/types/types1.jl")
include("rendering/types/types.jl")
include("input/types/controls.jl")
include("game/types/types2.jl")

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
    
    @time game = setupGame(4); @time Base.GC.gc()

    for i in eachindex(game.m.npcs)
        game.m.npcs[i].trainerid = 1; game.m.npcs[i].range = 8
    end
    
    GC.enable(false)
    GC.@preserve game sceneTransition!
    
    setInventoryTest!(game.p.inventory)
    
    push!(game.p.pokemon,generatePkmn(game,0x0001,0x0f))
    push!(game.p.pokemon,generatePkmn(game,0x0002,0x02))
    push!(game.p.pokemon,generatePkmn(game,0x0003,0x60))
    push!(game.p.pokemon,generatePkmn(game,0x0004,0x08))
    push!(game.p.pokemon,generatePkmn(game,0x0005,0x13))

    game.p.dex[1:5,2] .= true
    game.p.dex[1:15,1] .= true
    game.p.dex[19,1] = true

    render(game)

    t0 = time(); t1 = 0.

    while !GLFW.WindowShouldClose(game.im.window)
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
                # println(game.ctrl.mpos)
            end
        end

        if t2-t1 >= 1/fps
            t1 = t2
            render(game)
        end
    end

    GLFW.DestroyWindow(game.im.window)

    return game, inputs
end

end

game, inputs = Pokemon.main();

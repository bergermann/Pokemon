# __precompile__(true)

module Pokemon

export play, g

using Serialization, Images, DelimitedFiles
# using GLFW

include("rendering/types/texts.jl")
include("game/types/types.jl")

include("rendering/rendering.jl")
include("game/game.jl")

# @time foreach(names(@__MODULE__, all=true)) do s
#     @eval export $s
# end

function play()

    global input = Input()

    # Base.GC.@preserve game sceneTransition!

    setInventoryTest!(game.trainer.inventory)

    push!(game.trainer.pokemon,generatePkmn(game,0x0001,0x14))
    push!(game.trainer.pokemon,generatePkmn(game,0x0002,0x03))
    push!(game.trainer.pokemon,generatePkmn(game,0x0003,0x60))

    game.input.map = true
    game.input.move = true

    resetMovePos!(game)
    loadNPCs!(game,game.maps.map.id)

    stateInitDrawMap!(game)

    w,b = startWindow(settings)
    
    mfb_set_resize_callback(w,resizer)
    mfb_set_keyboard_callback(w,onpress)
    mfb_set_target_fps(settings.fps)

    state = mfb_update(w, b)

    Base.GC.gc()

    try
        while true
            begin
            # @time begin
                game.n.frame += 0x01

                writeToBuffer!(b,game)
                state = mfb_update(w, b)

                if state != MiniFB.STATE_OK
                    break
                end
                
                # @time updateGame!(game,input; s=settings)
                updateGame!(game,input)

                # @time drawGame!(game; s=settings)
                drawGame!(game; s=settings)
                resetInput!(input)
            end
        end
    catch e
        println(e)
        display(stacktrace(catch_backtrace()))
        return game
    end

    return game, times
end

function main()
    Base.GC.enable(false)

    settings = Settings()

    @time game = setupGame()


    GLFW.SetWindowSizeCallback(game.im.window,resizeCallback)

    createSprite!(game,:npctest1,:npcs,10, 7,P(-16, 8),15, 2; active=true)
    createSprite!(game,:npctest2,:npcs, 1, 4,P(-48,40), 5, 2; active=true)
    createSprite!(game,:mc,      :mc,   1, 4,P(  0, 8),10, 3; active=true)

    createFrame!(game,:testframe,28,5,-120,24,6)

    createText!(game,:test,3,-120+8,24+8,6,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"*
        " abcdefghijk/lmnopqrstuvwxyz0123456789!?.:,;%()ß",
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; wpad=0)

    render(game)
    
    GLFW.DestroyWindow(game.im.window); return game

    while !GLFW.WindowShouldClose(game.im.window)
        game.frame += 0x01

        # @time begin
        begin
            if game.ctrl.moving
                move(game)
            end

            render(game)
        end
    end

    GLFW.DestroyWindow(game.im.window)

    return game
end

g = play();

end

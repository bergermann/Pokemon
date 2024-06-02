
include("src/main.jl")

using Dates


function main()
    include("src/opengl/callbacks.jl")

    @time global game = setupGame() # global im = imSetup(wscale)

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

    t1 = now()
    fps = zero(UInt)

    while !GLFW.WindowShouldClose(game.im.window)
        game.frame += 0x01
        fps += 0x01

        # @time begin
        begin
            if game.ctrl.moving
                move(game)
            end

            render(game)
        end

        t2 = now()

        if t2 - t1 > Second(5)
            println("FPS: ",round(1000*fps/(t2-t1).value,sigdigits=4))
            t1 = now()
            fps = zero(UInt)
        end
    end

    GLFW.DestroyWindow(game.im.window)

    return game
end

g = main();

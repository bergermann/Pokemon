using BenchmarkTools, Plots

include("core.jl")
include("rendering.jl")
include("controls.jl")
include("pokemons.jl")
include("animations.jl")
include("battle.jl")
#include("maps.jl")

function showIm(im)
    display(plot(reinterpret(RGB24,im)))
end

function testmain()
    settings = Settings()

    global input = Input()

    game = GameState(
        Im(),
        PkmnData(),

        Trainer("Void",0x0000,0x02,Vector{Pkmn}([]),[],[],
            falses(151),getSpriteMain("sprite"; s=settings)),

        map1,
        Position(0x00006e,0x000013),
        Position(0x00006f,0x000013),
        2,

        Position(0,0),
        Position(0,0),

        Counters(128),
        ArrayList(CallbackFunction,128),

        Dialogue(),

        Battle(),

        InputState(),
        DrawState(),

        Options()
    )
    
    p = Position(10,10)
    s = Position(100,200)

    drawMap!(game)

    showIm(game.im.layers.layer1)
    
    flushLayer!(game,:layer1,p,s)

    showIm(game.im.layers.layer1)

    return game
end

g = testmain()

;
using BenchmarkTools

include("core.jl")
include("rendering.jl")
include("controls.jl")
include("pokemons.jl")
include("animations.jl")
include("battle.jl")
#include("maps.jl")

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

    @btime initDrawBattle!($game)

    println(nfields(game.draw))
    println(nfields(DrawState))

    return game
end

g = testmain()

;
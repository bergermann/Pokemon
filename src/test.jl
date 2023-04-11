using BenchmarkTools, Plots

using MiniFB, Images, DelimitedFiles

include("types/typespkmn.jl")
include("types/typescore.jl")
include("types/typesbattle.jl")

include("parser.jl")
include("pokemons.jl")
include("core.jl")
include("battle.jl")
include("statetransitions.jl")
include("rendering.jl")
include("controls.jl")
include("npcs.jl")
include("animations.jl")
include("attackanimations.jl")
include("battlenpc.jl")
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

    push!(game.trainer.pokemon,generatePkmn(game,0x0001,0x09))
    push!(game.trainer.pokemon,generatePkmn(game,0x0002,0x03))

    createSprite!(game,:main,:layer2,getSpriteMain("sprite"),Position(80,128),
        11; active=true)

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.direction,-1))

    game.input.map = true
    game.input.move = true

    resetMovePos!(game)
    
    initDrawMap!(game)

    return game
end

g = testmain()

;
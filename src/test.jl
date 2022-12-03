using BenchmarkTools

include("core.jl")
include("rendering.jl")
include("controls.jl")
#include("maps.jl")

function test()
    settings = Settings()

    spritemain = getSpriteMain("sprite")

    game = GameState(
        Im(),
        PkmnData(),
        Trainer("Void",0x0000,0x02,Vector{Pkmn}([]),[],[],
            falses(151),getSpriteMain("sprite"; s=settings)),
        Position(0x00000e,0x000013),
        :walk,
        :down,
        0x01,
        Position(0,0),
        map0,
        false,
        false,
        false,
        Battle(false,0x00,MenuBattle(0x00,0x00)),
        Dialogue(),
        Menu(),
        UInt(0),
        Counters(),
        moveDont!,
        Position(0x000000,0x000000),
        Options()
    )

    
    push!(game.trainer.pokemon,Pkmn(game,0x01,0x01))

    updateStats!(game.trainer.pokemon[1])

    println(Int.(game.trainer.pokemon[1].stats.rv))

    return game
end

g = test()

;
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
        0,
        3,

        Position(0,0),

        map0,

        false,
        false,
        false,

        Battle(false,0x00,MenuBattle(0x00,0x00)),

        Dialogue(),

        Menu(),

        Counters(128),
        ArrayList(CallbackFunction,128),

        Position(0x000000,0x000000),
        Options()
    )
    
    push!(game.trainer.pokemon,generatePkmn(game,0x01,0x09))
    push!(game.trainer.pokemon,generatePkmn(game,0x02,0x03))

    for i in 1:100
        m = Sprite(:main,:background2,Position(104,72),Position(32,16),1,
            game.im.spritesmain[1],game.im.spritesmain[1][1])

        push!(game.im.sprites,m)
    end

    drawSprites!(game)

    createCounter!(game,:spritemain)
    @time begin
        createCounter!(game,:test)

        killCounter!(game,:test)
    end

    @time begin
        createCallback!(game,:test,emptyCallback,())

        game.callbacks[:test].func(game,game.callbacks[:test].args...)

        #println("check")

        killCallback!(game,:test)
    end

    return game
end

g = test()

;
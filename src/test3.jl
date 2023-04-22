# using BenchmarkTools, Plots

# using MiniFB, Images, DelimitedFiles

include("types/typespkmn.jl")
include("types/typescore.jl")
include("types/typesbattle.jl")

include("parser.jl")
include("pokemons.jl")
include("core.jl")
include("battle.jl")
include("statetransitions.jl")
include("rendering.jl")
include("npcs.jl")
include("maps.jl")
include("controls.jl")
include("animations.jl")
include("attackanimations.jl")
include("battlenpc.jl")

function showIm(im)
    display(plot(reinterpret(RGB24,im)))
end

function testmain()
    
    settings = Settings()

    global input = Input()

    game = GameState(
        Im(),
        PkmnData(),

        Trainer("Void",0x0000,0x02,ArrayList(Pkmn,6),[],[],
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
    
    createSprite!(game,:main,:layer2,getSpriteMain("sprite"),Position(80,128),
        11; active=true)

    createSprite!(game,:main1,:layer2,getSpriteMain("sprite"),Position(96,128+32),
        11; active=true)

    # drawMap!(game)
    # combineLayers!(game,)
    # showIm(game.im.layer)

    # l = [:layer1,:layer2,:layer3,:layer4,:layer5,:layer6]

    # @btime combineLayers!($game,$l; s=$settings)

    s = :main
    game.im.sprites[:main1]
    # @btime $game.im.sprites[$s]


    return game
end

g = testmain()

;



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



function drawMap!(game::GameState; s=Settings())
    dh,dw = div(s.Nh-0x01,0x02),div(s.Nw-0x01,0x02)

    @inbounds for k in game.map.environment
        @inbounds for i in 1:s.Nh, j in 1:s.Nw
            tile = game.map.tiles[
                getfield(game.map.tilemap,k)[game.pos.h+i-dh-1,
                game.pos.w+j-dw-1]]

            v = view(getfield(game.im.layers,k),
                1+(i-1)*s.tilesize:i*s.tilesize,
                1+(j-1)*s.tilesize:j*s.tilesize)
            
            @inbounds for t in eachindex(v)
                v[t] = tile[t]
            end
        end
    end
end

# __precompile__(true)

module Pokemon

export main

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

# @time foreach(names(@__MODULE__, all=true)) do s
#     @eval export $s
# end

function main()
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

    push!(game.trainer.pokemon,generatePkmn(game,0x0001,0x14))
    push!(game.trainer.pokemon,generatePkmn(game,0x0002,0x03))
    push!(game.trainer.pokemon,generatePkmn(game,0x0003,0x60))

    createSprite!(game,:main,:layer2,getSpriteMain("sprite"),Position(80,128),
        11; active=true)

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.direction,-1))

    game.input.map = true
    game.input.move = true

    resetMovePos!(game)
    
    initDrawMap!(game)

    w,b = startWindow(settings)
    
    mfb_set_resize_callback(w,resizer)
    mfb_set_keyboard_callback(w,onpress)
    mfb_set_target_fps(settings.fps)

    state = mfb_update(w, b)
    
    while true
        begin
        # @time begin
            game.n.frame += 0x01

            writeToBuffer!(b,game)
            state = mfb_update(w, b)

            if state != MiniFB.STATE_OK
                break
            end

            # print(game.input.battled,", ")
            # print(game.input.inputlock,", ")
            # print(game.dialogue.n)
            # println()
            #print("update:")
            # @time updateGame!(game,input; s=settings)
            updateGame!(game,input; s=settings)

            #print("draw:")
            @time drawGame!(game; s=settings)
            # drawGame!(game; s=settings)
            resetInput!()
        end
    end
end

main()

end

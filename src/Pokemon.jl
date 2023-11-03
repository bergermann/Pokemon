# __precompile__(true)

module Pokemon

export play, g

using MiniFB, Serialization, Images, DelimitedFiles

include("types/typescore.jl")
include("types/typesrendering.jl")
include("types/typesinventory.jl")
include("types/typespkmn.jl")
include("types/typesmap.jl")
include("types/typesgame.jl")
include("types/typesbattle.jl")
include("types/typesnpc.jl")

include("rendering/rendering.jl")
include("battle/battle.jl")
include("statetransitions/general.jl")
include("items/inventory.jl")
include("pokemons.jl")
include("core.jl")
include("npcs.jl")
include("maps.jl")
include("controls.jl")
include("animations.jl")
include("npcs.jl")

# @time foreach(names(@__MODULE__, all=true)) do s
#     @eval export $s
# end

function play()
    settings = Settings()

    global input = Input()

    game = GameState(
        Im(),
        [],
        PkmnData(),

        Trainer("Void",0x0000,0x02,ArrayList(Pkmn,6),Inventory(),
            [ArrayList(Pkmn,30) for _ in 1:8],[],falses(151)),

        getMaps(0x01),
        Position(0x00006e,0x000013),
        Position(0x00006f,0x000013),
        2,

        Position(0,0),
        Position(0,0),

        Counters(128),
        ArrayList(CallbackFunction,128),

        Dialogue(),

        true,
        Battle(),

        InputState(),
        DrawState(),

        ArrayList(NPCStatic,64),
        ArrayList(NPCMove,64),

        Options()
    )

    Base.GC.@preserve game sceneTransition!

    game.im.tiles[0xffff] = fill(0x010101,16,16)

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

    while true
        try
            begin
            # @time begin
                game.n.frame += 0x01

                writeToBuffer!(b,game)
                state = mfb_update(w, b)

                if state != MiniFB.STATE_OK
                    break
                end
                
                # @time updateGame!(game,input; s=settings)
                updateGame!(game,input; s=settings)

                # @time drawGame!(game; s=settings)
                drawGame!(game; s=settings)
                resetInput!(input)
            end
        catch e
            println(e)
            display(stacktrace(catch_backtrace()))
            return game
        end
    end

    return game
end

g = play();

end

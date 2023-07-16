# __precompile__(true)

module Pokemon

export main

using MiniFB, Images, DelimitedFiles

include("types/typesinventory.jl")
include("types/typespkmn.jl")
include("types/typescore.jl")
include("types/typesbattle.jl")
include("types/typesnpc.jl")
include("types/typesrendering.jl")

include("inventory.jl")
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
include("npcs.jl")

# @time foreach(names(@__MODULE__, all=true)) do s
#     @eval export $s
# end

function main()
    settings = Settings()

    global input = Input()

    game = GameState(
        Im(),
        [],
        PkmnData(),

        Trainer("Void",0x0000,0x02,ArrayList(Pkmn,6),Inventory(),[],
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

        true,
        Battle(),

        InputState(),
        DrawState(),

        ArrayList(NPCStatic,64),
        ArrayList(NPCMove,64),

        Options()
    )

    Base.GC.@preserve game sceneTransition!

    setInventoryTest!(game.trainer.inventory)

    push!(game.trainer.pokemon,generatePkmn(game,0x0001,0x14))
    push!(game.trainer.pokemon,generatePkmn(game,0x0002,0x03))
    push!(game.trainer.pokemon,generatePkmn(game,0x0003,0x60))

    game.input.map = true
    game.input.move = true

    resetMovePos!(game)
    loadNPCs!(game,game.map.id)

    stateInitDrawMap!(game)

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
            
            # @time updateGame!(game,input; s=settings)
            updateGame!(game,input; s=settings)

            # @time drawGame!(game; s=settings)
            drawGame!(game; s=settings)
            resetInput!(input)
        end
    end
end

main()

end

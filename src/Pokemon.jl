module Pokemon

include("core.jl")
include("rendering.jl")
include("controls.jl")
#include("pokemons.jl")
#include("maps.jl")


function main()
    settings = Settings()

    global input = Input()

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

    push!(game.trainer.pokemon,generatePkmn(game,0x01,0x09))
    push!(game.trainer.pokemon,generatePkmn(game,0x02,0x03))

    w,b = startWindow(settings)
    
    mfb_set_resize_callback(w, resizer)
    mfb_set_keyboard_callback(w, onpress)

    state = mfb_update(w, b)

    n_frames = UInt(0)
    
    while true
        begin
        #@time begin
            n_frames += UInt(1)
            game.n.frame += 0x01

            writeToBuffer!(b,game)
            state = mfb_update(w, b)

            if state != MiniFB.STATE_OK
                break
            end

            #print("update:")
            #@time 
            updateGame!(game,input,n_frames; s=settings)
            #print("draw:")
            #@time 
            drawGame!(game,n_frames; s=settings)
            resetInput!()
            #print("loop:")
        end
    end
end

main()

end



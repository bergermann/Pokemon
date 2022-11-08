module Pokemon

include("core.jl")
include("rendering.jl")
include("parser.jl")
include("controls.jl")
#include("maps.jl")

function main()
    settings = Settings()

    global input = Input()

    game = GameState(
        Im(),
        Trainer("Void",0x0000,0x02,Vector{Pkmn}([]),[],[],falses(151),
            getSpriteMain("sprite"; s=settings)),
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
        moveDont!,
        Position(0x000000,0x000000),
        Options()
    )

    w,b = startWindow(settings)
    mfb_set_keyboard_callback(w, onpress)

    n_frames = UInt(0)
    
    while true
        n_frames += UInt(1)

        begin
        #@time begin
            b .= permutedims(game.im.layer[
                24+1+game.screenoffset.h:end-24+game.screenoffset.h,
                16+1+game.screenoffset.w:end-16+game.screenoffset.w],(2,1))
            
            #@time state = mfb_update(w, b)
            state = mfb_update(w, b)

            if state != MiniFB.STATE_OK
                break
            end

            updateGame!(game,input,n_frames; s=settings)

            drawGame!(game,n_frames; s=settings)
            
            resetInput!()
        end
    end
end

main()

end



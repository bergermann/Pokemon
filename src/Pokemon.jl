__precompile__(true)

module Pokemon

include("core.jl")
include("rendering.jl")
include("controls.jl")
#include("pokemons.jl")
include("animations.jl")
include("battle.jl")
#include("maps.jl")


function main()
    settings = Settings()

    global input = Input()

    game = GameState(
        Im(),
        PkmnData(),

        Trainer("Void",0x0000,0x02,Vector{Pkmn}([]),[],[],
            falses(151),getSpriteMain("sprite"; s=settings)),

        map1,
        Position(0x00006e,0x000013),
        2,

        Position(0,0),

        false,
        false,
        false,

        Battle(),

        Dialogue(),

        Menu(),

        Counters(128),
        ArrayList(CallbackFunction,128),

        Position(0x000000,0x000000),
        Options()
    )

    push!(game.trainer.pokemon,generatePkmn(game,0x0001,0x09))
    push!(game.trainer.pokemon,generatePkmn(game,0x0002,0x03))

    m = Sprite(:main,true,false,false,:background2,Position(80,128),
        Position(32,16),:1,game.im.spritesmain[1],game.im.spritesmain[1][1])

    updateSprite!(m,21)
    push!(game.im.sprites,m)

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.direction,-1))



    w,b = startWindow(settings)
    
    mfb_set_resize_callback(w,resizer)
    mfb_set_keyboard_callback(w,onpress)
    mfb_set_target_fps(settings.fps)

    state = mfb_update(w, b)
    
    while true
        begin
        #@time begin
            game.n.frame += 0x01

            writeToBuffer!(b,game)
            state = mfb_update(w, b)

            if state != MiniFB.STATE_OK
                break
            end

            #print("update:")
            #@time updateGame!(game,input; s=settings)
            updateGame!(game,input; s=settings)
            #print("draw:")
            #@time 
            drawGame!(game; s=settings)
            resetInput!()
            #print("loop:")
        end
    end
end

main()

end



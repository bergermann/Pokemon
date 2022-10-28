module Pokemon

include("core.jl")
include("rendering.jl")
#include("parser.jl")
include("controls.jl")

function main()

    #d1,d2,d3 = getFont()

    settings = Settings()
    #settings = Settings(UInt16(480),UInt16(320),Float16(60))

    global input = Input()

    game = GameState(
        Trainer("Void",0x0000,0x02,Vector{Pkmn}([]),[],[],falses(151),
            getSpriteMain("sprite"; s=settings)),
        Position(0x00000e,0x000013),
        :walk,
        :down,
        0x01,
        Position(0,0),
        Map(0x00,(0x001a,0x0024)),
        false,
        false,
        false,
        Battle(false,0x00,MenuBattle(0x00,0x00)),
        Menu(),
        MenuInv(0x00,0x00),
        MenuPkmn(0x00,0x00),
        UInt(0),
        moveDont!,
        Position(0x000000,0x000000)
    )

    w,b = startWindow(settings)
    
    mfb_set_keyboard_callback(w, onpress)


    
    layers = Layers(; s=settings)

    t = getTiles("tiles_exterior")
    tm = getTileMap("0",[:background1,:background2,:foreground1,:foreground2,:collision]; s=settings)
    
    game.map.tiles = t
    game.map.tilemap = tm
    
    drawLayers!(layers,[:background1,:background2,:foreground1,:foreground2],game; s=settings)


    n_frames = UInt(0)
    
    while true
        n_frames += 0x00000001

        updateGame!(game,input,n_frames; s=settings)

        drawLayers!(layers,[:background1,:background2,:foreground1,:foreground2],game; s=settings)
        drawSpriteMain!(layers,game; s=settings)


        L = combineLayers(layers,[:background1,:background2,:spriteslow,:spriteshigh,:foreground1,:foreground2];
            s=settings)

        b .= permutedims(L[24+1+game.screenoffset.h:end-24+game.screenoffset.h,
            16+1+game.screenoffset.w:end-16+game.screenoffset.w],(2,1))

        #input = Input()

        
        #println(mfb_get_key_buffer(w))

        state = mfb_update(w, b)

        if state != MiniFB.STATE_OK
            break
        end

        #println(input.up)

    end


end

main()

end



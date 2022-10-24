module Pokemon

include("core.jl")
include("rendering.jl")
include("parser.jl")
include("controls.jl")

function main()

    d1,d2,d3 = getFont()

    settings = Settings()
    #settings = Settings(UInt16(480),UInt16(320),Float16(60))

    global input = Input()

    game = GameState(
        Trainer("Void",0x0000,0x02,Vector{Pkmn}([]),[],[],falses(151),
            getSpriteMain("sprite"; s=settings)),
        Position(0x0000a,0x00000c),
        :walk,
        :down,
        Map(0x00,(0x001a,0x0024)),
        false,
        false,
        false,
        Battle(false,0x00,MenuBattle(0x00,0x00)),
        Menu(),
        MenuInv(0x00,0x00),
        MenuPkmn(0x00,0x00),
        0x00
    )

    w,b = startWindow(settings)
    
    mfb_set_mouse_button_callback(w, onpress)
    #mfb_set_char_input_callback(w, onpress)
    mfb_set_keyboard_callback(w, onpress)


    
    layers = Layers(; s=settings)

    t = getTiles("tiles_exterior")
    tm = getTileMap("0",[:background,:foreground,:collision]; s=settings)
    
    game.map.tiles = t
    game.map.tilemap = tm
    
    drawLayers!(layers,[:background,:foreground],game; s=settings)


    n_frames = 0x0000
    
    while true
        n_frames += 0x0001

        if n_frames%0x0078 == 0x0000
            game.pos.h += 0x01
            updateLayers!(layers,[:background,:foreground],game,
                (h=Int8(1),w=Int8(0)); s=Settings())
        elseif n_frames%0x0078 == 0x003c
            game.pos.h -= 0x01
            updateLayers!(layers,[:background,:foreground],game,
                (h=Int8(-1),w=Int8(0)); s=Settings())
        end

        drawSpriteMain!(layers,game; s=settings)

        L = combineLayers(layers,[:background,:spriteslow,:spriteshigh,:foreground]; s=settings)

        b .= permutedims(L[24+1:end-24,16+1:end-16,1],(2,1))

        state = mfb_update(w, b)

        if state != MiniFB.STATE_OK
            break
        end
    end

    println(input)
end

main()

end



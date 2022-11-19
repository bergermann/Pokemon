using BenchmarkTools

include("core.jl")
include("rendering.jl")
include("controls.jl")
#include("maps.jl")

function test()
    settings = Settings()

    spritemain = getSpriteMain("sprite")

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
            Counters(),
            moveDont!,
            Position(0x000000,0x000000),
            Options()
        )


    #@btime drawText!(game,:menu,"abcd\\efgh\\ijkl",UInt(2),Position(100,50))
    #@btime drawFrame!(game,:menu,UInt(20),UInt(10),Position(24,176))
    #@btime drawFrame1!(game,:menu,UInt(20),UInt(10),Position(24,176))

    drawMap!(game)
    #@btime drawMap2!(game)
    l = [:background1,:background2,:spriteslow,:spriteshigh,
    :foreground1,:foreground2,:menu]
    
    @btime combineLayers!($game,$l)
    #@btime combineLayers2!($game,[:background1,:background2,:spriteslow,:spriteshigh,
    #    :foreground1,:foreground2,:menu])
    #@btime combineLayers3!($game,[:background1,:background2,:spriteslow,:spriteshigh,
    #    :foreground1,:foreground2,:menu])

    return
end

test()

;
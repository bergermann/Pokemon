using BenchmarkTools

include("core.jl")
include("controls.jl")
include("rendering.jl")
include("maps.jl")

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
        moveDont!,
        Position(0x000000,0x000000),
        Options()
    )
#drawLayers!(layers,[:background,:foreground],game; s=settings)


#updateLayers!(layers,[:background,:foreground],game,(h=Int8(1),w=Int8(0)); 
#        s=settings)

#L = combineLayers(layers,[:background,:foreground]; s=settings)

#drawSpriteMain!(layers,game; s=settings)

#F = getFrames("frames")
;
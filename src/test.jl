using BenchmarkTools

include("core.jl")
include("rendering.jl")

settings = Settings()

spritemain = getSpriteMain("sprite")

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

layers = Layers(; s=settings)

t = getTiles("tiles_exterior")
tm = getTileMap("0",[:background,:foreground,:collision]; s=settings)

game.map.tiles = t
game.map.tilemap = tm

drawLayers!(layers,[:background,:foreground],game; s=settings)


updateLayers!(layers,[:background,:foreground],game,(h=Int8(1),w=Int8(0)); 
        s=settings)

L = combineLayers(layers,[:background,:foreground]; s=settings)

drawSpriteMain!(layers,game; s=settings)
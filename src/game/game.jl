
include("battle/battle.jl")
include("statetransitions/general.jl")
include("items/inventory.jl")
include("dialogue/dialogue.jl")
include("pokemons.jl")
include("core.jl")
include("npcs.jl")
include("maps.jl")
# include("controls.jl")
include("animations.jl")
include("npcs.jl")
include("events.jl")




function setupGame(windowscale::Int=4,renderdistance::Int=2,maxtextures::Int=64;)
    game = GameState(
        0,
        PlayerData(),
        Im(windowscale,renderdistance,maxtextures),
        Controls(10,10,1,1),
        MapData(renderdistance)
    )

    setupBackgrounds(game)
    setupChunks(game)
    setupFrames(game)
    setupFonts(game)
    setupSprites(game)

    game.im.c.projection1[1:2,4] .= -game.ctrl.pos

    loadArrayTexture!(game,"tilesets",tilesets,:tiles,16,16)
    
    loadSpriteSheet!(game,"npcs_all.png",:npcs,16,32,9; maxsprites=2)
    loadSpriteSheet!(game,"main1.png",:mc,32,32,9; maxsprites=1)

    loadChunksAll!(game)

    return game
end


game = GameState(
    Im(),
    [],
    PkmnData(),

    Trainer("Void",0x0000,0x02,ArrayList(Pkmn,6),Inventory(),
        [ArrayList(Pkmn,30) for _ in 1:8],[],falses(151)),

    getMaps(0x01),
    Position(UInt32(28),UInt32(20)),
    Position(UInt32(29),UInt32(20)),
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

    Flags(),

    Options()
)
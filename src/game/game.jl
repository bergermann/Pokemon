
include("battle/battle.jl")
include("statetransitions/general.jl")
include("items/inventory.jl")
include("dialogue/dialogue.jl")
include("pokemons.jl")
include("npcs.jl")
include("maps.jl")
# include("controls.jl")
include("animations.jl")
include("npcs.jl")
include("events.jl")




function setupGame(windowscale::Int=4,renderdistance::Int=2,maxtextures::Int=64;)
    game = GameState(
        0,
        PlayerData("Void",0x0000,0x02,ArrayList(Pkmn,6),Inventory(),
            [ArrayList(Pkmn,30) for _ in 1:8],[],falses(151)),
        Im(windowscale,renderdistance,maxtextures),
        Controls(10,10,1,1,3),
        MapData(renderdistance),
        [],
        PkmnData(),

        ArrayList(Counter,128),
        ArrayList(CallbackFunction,128),

        true,
        Battle(),

        ArrayList(NPCStatic,64),
        ArrayList(NPCMove,64),
        # ArrayList(NPCTrainer,64)

        Flags(),

        Options()
    )

    setupBackgrounds(game)
    setupChunks(game)
    setupFrames(game)
    setupFonts(game)
    setupSprites(game)

    stateInitMap!(game)

    return game
end

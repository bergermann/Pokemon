
include("battle/battle.jl")
include("statetransitions/general.jl")
include("inventory/inventory.jl")
include("dialogue/dialogue.jl")
include("pokemons.jl")
include("npcs.jl")
include("maps.jl")
# include("controls.jl")
include("animations/animations.jl")
include("npcs.jl")
include("events.jl")




function setupGame(windowscale::Int=4,renderdistance::Int=2,maxtextures::Int=64;)
    game = GameState(
        0,
        PlayerData("Void",0x0000,0x02,ArrayList(Pkmn,6),Inventory(),
            [ArrayList(Pkmn,30) for _ in 1:8],[],falses(151)),
        Im(windowscale,renderdistance,maxtextures),
        Controls(10,10,1,1,1,4),
        MapData(renderdistance),
        [],
        PkmnData(),

        ArrayList(Counter,128),
        ArrayList(Callback,128),

        true,
        Battle(),

        UInt16[],
        ArrayList(NPC,64),

        Flags(),

        Options()
    )

    setupBackgrounds(game)
    setupChunks(game)
    setupFrames(game)
    setupFonts(game)
    setupSprites(game)

    game.im.l.uloccolor = glGetUniformLocation(game.im.programs[15],"color")
    game.im.l.ulocslider = glGetUniformLocation(game.im.programs[15],"slider")

    loadSpriteSheet!(game,"cursors.png",:cursors,6,10,3; maxsprites=8)

    stateInitMap!(game)
    stateInitMapCtrls!(game)

    return game
end


include("flags.jl")
include("battle/battle.jl")
include("statetransitions/general.jl")
include("inventory/inventory.jl")
include("dialogue/dialogue.jl")
include("pokemons/pokemons.jl")
include("npcs/npcs.jl")
include("objects.jl")
include("teleports.jl")
include("events/events.jl")
# include("maps.jl")
# include("controls.jl")
include("animations/animations.jl")




function setupGame(windowscale::Int=4,renderdistance::Int=2,maxtextures::Int=64;)
    game = GameState(
        0,
        PlayerData("Void",2),
        Im(windowscale,renderdistance,maxtextures),
        Controls(9,8,1,2,1,false,1),
        MapData(renderdistance),
        [],
        PkmnData(),

        ArrayList(Counter,128),
        ArrayList(Callback,128),

        true,
        Battle(),
        false,

        Flags(),
        Events(),

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
    stateInitMapCtrls!(game,())

    return game
end

function updateGame!(game::GameState,inputs::Inputs)
    # println(inputs.down)
    inputManager!(game,inputs)

    if game.events.active; playEventQueue!(game); end

    if game.overworld
        # arrange sprites here
        if game.ctrl.movea; moveMain!(game); end
        if !game.ctrl.input.npclock; manageNPCs!(game); end
    end

    for i in 1:game.callbacks.idx
        if game.callbacks[i].active
            evalCallback(game,game.callbacks[i])
        end
    end

    return
end
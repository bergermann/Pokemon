

function stateOpenEvolve!(game::GameState,(pkmn,)::Tuple{Pkmn,})
    game.evolving = true

    loadStringsEvolve!(game)

    createCC!(game,:evolve,animEvolve!,(); n=1)

    createBackground!(game,:b1,"backgrounds/black.png",-120,-80,6; sx=240,sy=112,active=false)
    createBackground!(game,:battle,"backgrounds/battle/grass1.png",-120,-80,1;)
    createBackground!(game,:textbox,"textboxes/battle.png",-120,32,6; active=true)

    to = pkmn.evolve
    path1 = "battle/battlers/front/$(pkmn.shiny ? "shiny" : "normal")/$(pkmn.id).png"
    path2 = "battle/battlers/front/$(pkmn.shiny ? "shiny" : "normal")/$(to).png"

    loadSpriteSheet!(game,path1,:pkmn1,64,64,2; maxsprites=1)
    loadSpriteSheet!(game,path2,:pkmn2,64,64,2; maxsprites=1)

    createSprite!(game,:pkmn1,:pkmn1,1,1,0,-8,10,3; active=true)
    createSprite!(game,:pkmn2,:pkmn2,1,1,0,-8,10,3; active=true,wscale=0.,hscale=0.)

    createText!(game,:dialogue,4,-103,41,6,"",
        [0xff,0xff,0xff,0xff],[0x6b,0x5a,0x73,0xff]; active=false,maxchar=128)

    return
end

function stateReOpenEvolve!(game::GameState,(pkmn,)::Tuple{Pkmn,})
    deactivateBackground!(game,:b1)
    activateBackground!(game,:b2)

    deleteSpriteSheets!(game,:pkmn1,:pkmn2)
    game.n[:evolve].c = 1

    to = pkmn.evolve
    path1 = "battle/battlers/back/$(pkmn.shiny ? "shiny" : "normal")/$(pkmn.id).png"
    path2 = "battle/battlers/front/$(pkmn.shiny ? "shiny" : "normal")/$(to).png"

    loadSpriteSheet!(game,path1,:pkmn1,64,64,2; maxsprites=1)
    loadSpriteSheet!(game,path2,:pkmn2,64,64,2; maxsprites=1)

    createSprite!(game,:pkmn1,:pkmn1,1,1,0,-8,10,3; active=true)
    createSprite!(game,:pkmn2,:pkmn2,1,1,0,-8,10,3; active=true,wscale=0.,hscale=0.)

    return
end

function stateStartEvolve!(game::GameState,(pkmn,)::Tuple{Pkmn})
    unlockInput!(game)

    stateSetDialogue!(game,game.str[1][1]*pkmnName(game,pkmn)*game.str[1][2],
        F(stateStartEvolveAnim!))

    return
end

function stateStartEvolveAnim!(game::GameState,args::Tuple{})
    lockInput!(game); activateCallback!(game,:evolve); return
end

function stateEndEvolve!(game::GameState,pkmn::Pkmn)
    unlockInput!(game)

    stateSetDialogue!(game,
        game.str[1][3]*pkmnName(game,pkmn)*game.str[1][4]*pkmnName(game,pkmn.evolve)*".",
        F(stateQuitEvolve!))

    evolvePokemon!(pkmn)

    return
end

function stateQuitEvolve!(game::GameState,()::Tuple{})
    lockInput!(game)

    evolve = checkEvolve(game)

    if evolve == 0
        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateCloseEvolve!),F(stateInitMapCtrls!)); active=true,n=1)
    else
        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateReopenEvolve!),F(stateStartEvolve!,)); active=true,n=1)
    end

    return
end


function stateCloseEvolve!(game::GameState)
    game.evolving = false

    deleteBackgrounds!(game,:b1,:b2)

    deleteSpriteSheets!(game,:pkmn1,:pkmn2)

    stateOpenMap!(game)

    return
end
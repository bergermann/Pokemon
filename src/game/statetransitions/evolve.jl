

function stateInitEvolve!(game::GameState,(pkmn,to)::Tuple{Pkmn,UInt16})
    createBackground!(game,:b1,"backgrounds/black.png",-120,-80,6; sx=240,sy=112)
    createBackground!(game,:b2,"backgrounds/battle/grass1.png",-120,-80,6; sx=240,sy=112)
    createBackground!(game,:textbox,"textboxes/green.png",-120,32,6; active=true)

    p1 = state.pkmn1.pkmn
    path1 = "battle/battlers/back/$(p1.shiny ? "shiny" : "normal")/$(p1.id).png"
    path2 = "battle/battlers/front/$(p1.shiny ? "shiny" : "normal")/$(to).png"

    loadSpriteSheet!(game,path1,:pkmn1,64,64,2; maxsprites=1)
    loadSpriteSheet!(game,path2,:pkmn2,64,64,2; maxsprites=1)

    createSprite!(game,:pkmn1,:pkmn1,1,1,0,-8,10,3; active=true)
    createSprite!(game,:pkmn2,:pkmn2,1,1,0,-8,10,3; active=false)

    loadStringsEvolve!(game)

    createCC!(game,:evolve,animEvolve!,(); n=1)

    return
end

function stateStartEvolve!(game::GameState,(pkmn,)::Tuple{Pkmn})
    stateSetDialogue!(game,game.str[1][1]*getPkmnName(game,pkmn)*game.str[1][2],
        F(game->(activateCallback!(game,:evolve); lockInput!(game))))

    return
end


function stateCloseEvolve!(game::GameState)
    

    return
end



function animEvolve!(game::GameState,(pkmn,)::Tuple{Pkmn,})
    c = game.n[:evolve].c 
    # set color gradually to white
    
    if c <= 60
        game.im.b.backgrounds[:b2].color[4] = Float32(c/60)
    elseif c <= 300
        s1 = trianglewave(c,120); s2 = trianglewave(c+60,120)
        scaleSprite!(game,:pkmn1,s1,s1,true)
        scaleSprite!(game,:pkmn2,s2,s2,true)
    elseif c <= 450
        s1 = trianglewave(c+30,60); s2 = trianglewave(c,60)
        scaleSprite!(game,:pkmn1,s1,s1,true)
        scaleSprite!(game,:pkmn2,s2,s2,true)
    elseif c <= 540
        s1 = trianglewave(c,30); s2 = trianglewave(c+15,30)
        scaleSprite!(game,:pkmn1,s1,s1,true)
        scaleSprite!(game,:pkmn2,s2,s2,true)
    elseif c < 600
        game.im.b.backgrounds[:b2].color[4] = Float32(1-(c-540+1)/60)
    elseif c == 600
        stateEndEvolve!(game,pkmn)

        killCC!(game,:evolve)

        return
    end

    game.n[:evolve].c += 1

    return
end

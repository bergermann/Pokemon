


function animEvolve!(gamme::GameState,)
    # set color gradually to white
    if game.n[:evolve].c == 1; println("starting evolve anim"); end

    if game.n[:evolve].c < 60

    elseif game.n[:evolve].c < 240
        s1 = trianglewave(game.n[:evolve].c,60); s2 = trianglewave(game.n[:evolve].c+30,60)
        scaleSprite!(game,:pkmn1,s1,s1,true)
        scaleSprite!(game,:pkmn2,s2,s2,true)
    elseif game.n[:evolve].c < 420
        
    elseif game.n[:evolve].c == 480
        stateEndEvolve!(game,:pkmn)

        killCC!(game,:evolve)

        return
    end

    game.n[:evolve].c += 1

    return
end

function trianglewave(x::Real,p::Real)
    return 2*abs(x/p-floor(Float64,x/p+1/2))
end
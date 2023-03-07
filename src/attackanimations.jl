
function banimEmpty!(game::GameState,target::Int)
    return
end

function bnoAnim!(game::GameState,target::Int)
    if target == 1
        createCC!(game,:dmg,btakeDamage!,(:pkmn1,:tag1,); active=true)
    else
        createCC!(game,:dmg,btakeDamage!,(:pkmn2,:tag2,); active=true)
    end
end

function bTackle!(game::GameState,target::Int)
    
end

function btakeDamage!(game::GameState,target::Symbol,tag::Symbol)    #length: 30
    if game.n.c[:dmg].c == 0
        game.im.sprites[target].active = false
        posAdd!(game.im.sprites[tag].pos,1,0)
    elseif game.n.c[:dmg].c == 22
        posAdd!(game.im.sprites[tag].pos,-1,0)
    elseif game.n.c[:dmg].c%4 == 0
       game.im.sprites[target].active = !game.im.sprites[target].active
       posAdd!(game.im.sprites[tag].pos,2,0)
    elseif game.n.c[:dmg].c%4 == 2
        posAdd!(game.im.sprites[tag].pos,-2,0)
    elseif game.n.c[:dmg].c == 23
        killCC!(game,:dmg)

        return
    end

    game.n.c[:dmg].c += 1
end

function bmoveHorizontal!(game::GameState,distance::Int,speed::Int,target::Symbol)
    if distance%speed != 0
        error("Distance needs to integer multiple of speed.")
    end

    posAdd!(game.im.sprites[target].pos,0,speed)
    
    game.n.c[:moveh].c += 1

    if game.n.c[:moveh].c == div(distance,speed)
        killCC!(game,:moveh)

        return
    end
end

function bmoveVertical!(game::GameState,distance::Int,speed::Int,target::Symbol)
    if distance%speed != 0
        error("Distance needs to integer multiple of speed.")
    end

    posAdd!(game.im.sprites[target].pos,speed,0)
    
    game.n.c[:movew].c += 1

    if game.n.c[:movew].c == div(distance,speed)
        killCC!(game,:movew)

        return
    end
end

function bmoveLinear!(game::GameState,distanceh::Int,distancew::Int,
        speedh::Int,speedw::Int,target::Symbol)
    
    if distanceh%speedh != 0 || distancew%speedw != 0
        error("Distance needs to integer multiple of speed.")
    end

    posAdd!(game.im.sprites[target].pos,speedh,speedw)
    
    game.n.c[:movel].c += 1

    if game.n.c[:movel].c == div(distanceh,speedh) ||
            game.n.c[:movel].c == div(distancew,speedw)

        killCC!(game,:movel)

        return
    end
end
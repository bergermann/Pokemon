


function animEvolve!(gamme::GameState,)
    
    if game.n[:switchin].c < 40
        moveSpriteW!(game,:ball,2)
        t = game.n[:switchin].c
        moveSpriteH!(game,:ball,round(Int,24-2.4*t+0.06*t^2),true)
        rotateSprite!(game,:ball,18.)
    elseif game.n[:switchin].c == 40
        moveSprite!(game,:ball,-48,24,true)
        rotateSprite!(game,:ball,0.,true)
        setSpriteFrame!(game,:ball,2)
    elseif game.n[:switchin].c == 48
        activateSprite!(game,:pkmn1)
        for i in 1:10; activateSprite!(game,Symbol(:spark,i)); end
    elseif 48+1 <= game.n[:switchin].c <= 48+32
        t = game.n[:switchin].c-48
        scaleSprite!(game,:pkmn1,t/32,t/32,true)
        for i in 1:10
            moveSprite!(game,Symbol(:spark,i),
                round(Int,1.5t*cospi(t/32+i/5))-48,round(Int,-1.5t*sinpi(t/32+i/5))+24,true)
        end
    elseif game.n[:switchin].c == 48+32+1
        killSprites!(game,:particles)
        moveSpriteH!(game,:ball,3)
    elseif 48+32+1 < game.n[:switchin].c <= 48+32+8
        moveSpriteH!(game,:ball,3)
    elseif 96 < game.n[:switchin].c <= 96+16
        moveSpriteW!(game,:tag1,-8)
        moveSpriteW!(game, :hp1,-8)
        moveSpriteW!(game,  :xp,-8)
        moveText!(game,:name1,-8,0)
        moveText!(game, :lvl1,-8,0)
    elseif game.n[:switchin].c == 480
        killSprite!(game,:ball)

        killCC!(game,:switchin)

        return
    end

    game.n[:evolve].c += 1

    return
end
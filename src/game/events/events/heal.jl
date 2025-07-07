
function eventHealCenter!(game::GameState,(ignore,)::Tuple{Bool})
    if game.flags.general[0xc8]*!ignore
        stateSetDialogue!(game,game.str[2][5:5])

        return
    end

    game.flags.general[0xc8] = true

    healAll!(game)

    l = length(game.p.pokemon)

    createCC!(game,:heal,animHealCenter!,(l,))
    
    for i in 0:l-1
        createSprite!(game,mplabels[i+1].b,:objects,28,1,-22+6*(i%2),-40+4*(div(i,2)),10,5)
    end

    stateSetDialogue!(game,game.str[2][2:3],
        (game,args)->(lockInput!(game); activateCallback!(game,:heal)))
        
    unlockInput!(game)

    return
end

eventHealCenter!(game::GameState,args::Tuple{}) = eventHealCenter!(game,(false,))
    


function animHealCenter!(game::GameState,(l,)::Tuple{Int})
    if game.n[:heal].c == 0
        setSpriteFrame!(game,:npc420581889,4)
        reverseSpriteW!(game,:npc420581889,true)
    elseif 60 <= game.n[:heal].c < 60+l*30
        if game.n[:heal].c%30 == 0
            activateSprite!(game,mplabels[div((game.n[:heal].c-60),30)+1].b)
        end
    elseif 90+l*30 <= game.n[:heal].c < 90+l*30+96
        if (game.n[:heal].c-(90+l*30))%8 == 0
            f = div(game.n[:heal].c-(90+l*30),8)%4
            for i in 1:l; setSpriteFrame!(game,mplabels[i].b,f+1); end
        end
    elseif game.n[:heal].c == 90+l*30+96
        for i in 1:l; setSpriteFrame!(game,mplabels[i].b,1); end
    elseif game.n[:heal].c == 90+l*30+96+30
        for i in 1:l; killSprite!(game,mplabels[i].b); end
    elseif game.n[:heal].c == 90+l*30+96+60
        setSpriteFrame!(game,:npc420581889,7)
        reverseSpriteW!(game,:npc420581889,false)
    elseif game.n[:heal].c == 90+l*30+96+90
        setSpriteFrame!(game,:npc420581889,8)
    elseif game.n[:heal].c == 90+l*30+96+135
        setSpriteFrame!(game,:npc420581889,7)
    elseif game.n[:heal].c == 90+l*30+96+160
        killCC!(game,:heal)
        unlockInput!(game)
        stateSetDialogue!(game,game.str[2][4])

        return
    end

    game.n[:heal].c += 1

    return
end


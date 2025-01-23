

function eventHealCenter!(game::GameState)
    if game.flags.general[0xc8]
        stateSetDialogue!(game,game.str[2][5])

        return
    end

    game.flags.general[0xc8] = true

    healAll!(game)

    createCC!(game,:heal,animHealCenter!,())

    stateSetDialogue!(game,1,game.str[2][4],F((game,)->(game.callbacks[:heal].active=true;
        game.ctrl.input.inputlock=true; game.ctrl.input.npclock=true)),)

    return
end

function animHealCenter!(game::GameState,ballids::Vector{Symbol})
    l = length(game.p.pokemon)

    if game.n[:heal].c == 0
        game.ctrl.input.npclock = true

        updateSprite!(game,3,:npc200,3)

        for i in 1:l
            createSprite!(game,ballids[i],3,
                P(56+4*div(i-1,2),105+6*((i-1)%2)),1,
                getSprite("im/sprites/general/healballs",5);
                active=false)
        end
    elseif 60 <= game.n[:heal].c < 60+l*30
        if game.n[:heal].c%30 == 0
            id = div((game.n[:heal].c-60),30)+1
            game.im.sprites[3][ballids[id]].active = true
        end
    elseif 90+l*30 <= game.n[:heal].c < 90+l*30+96
        if (game.n[:heal].c-(90+l*30))%8 == 0
            f = div(game.n[:heal].c-(90+l*30),8)%4

            for id in ballids
                updateSprite!(game,3,id,f+2)
            end
        end
    elseif game.n[:heal].c == 90+l*30+96
        for id in ballids
            updateSprite!(game,3,id,1)
        end
    elseif game.n[:heal].c == 90+l*30+96+30
        for id in ballids
            killSprite!(game,id)
        end
    elseif game.n[:heal].c == 90+l*30+96+60
        updateSprite!(game,3,:npc200,1)
    elseif game.n[:heal].c == 90+l*30+96+90
        updateSprite!(game,3,:npc200,4)
    elseif game.n[:heal].c == 90+l*30+96+135
        updateSprite!(game,3,:npc200,1)
    elseif game.n[:heal].c == 90+l*30+96+160
        killCC!(game,:heal)
        
        unlockInput!(game)
        
        stateSetDialogue!(game,1,4,1)

        return
    end

    game.n[:heal].c += 1

    return
end


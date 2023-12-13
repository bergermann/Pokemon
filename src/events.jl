
function evalEvent(game::GameState,event::Event)
    if event.onpress != 0 && event.dir != game.direction
        return
    end

    for i in eachindex(event.flags)
        if event.flagvals[i] !=
                getfield(game.flags,event.flagtypes[i])[event.flags[i]]
            
            return
        end
    end

    for i in eachindex(event.counters)
        if event.countervals[i] > game.flags.counters[event.counters[i]]
            return
        end
    end

    events[event.id](game)

    return
end



function eventHealCenter!(game::GameState)
    if game.flags.general[0xc8]
        stateSetDialogue!(game,1,4,1)

        return
    end

    healAll!(game)

    createCC!(game,:heal,animHealCenter!,
        ([Symbol(:ball,i) for i in 1:length(game.trainer.pokemon)],))

    stateSetDialogue!(game,1,1,2,F((game,)->(game.callbacks[:heal].active=true;
        game.input.inputlock=true; game.input.npclock=true)),)

    return
end

function animHealCenter!(game::GameState,ballids::Vector{Symbol})
    l = length(game.trainer.pokemon)

    if game.n.c[:heal].c == 0
        game.input.npclock = true

        updateSprite!(game,3,:npc200,3)

        for i in 1:l
            createSprite!(game,ballids[i],3,
                P(56+4*div(i-1,2),105+6*((i-1)%2)),1,
                getSprite("im/sprites/general/healballs",5);
                active=false)
        end
    elseif 60 <= game.n.c[:heal].c < 60+l*30
        if game.n.c[:heal].c%30 == 0
            id = div((game.n.c[:heal].c-60),30)+1
            game.im.sprites[3][ballids[id]].active = true
        end
    elseif 90+l*30 <= game.n.c[:heal].c < 90+l*30+96
        if (game.n.c[:heal].c-(90+l*30))%8 == 0
            f = div(game.n.c[:heal].c-(90+l*30),8)%4

            for id in ballids
                updateSprite!(game,3,id,f+2)
            end
        end
    elseif game.n.c[:heal].c == 90+l*30+96
        for id in ballids
            updateSprite!(game,3,id,1)
        end
    elseif game.n.c[:heal].c == 90+l*30+96+30
        for id in ballids
            killSprite!(game,id)
        end
    elseif game.n.c[:heal].c == 90+l*30+96+60
        updateSprite!(game,3,:npc200,1)
    elseif game.n.c[:heal].c == 90+l*30+96+90
        updateSprite!(game,3,:npc200,4)
    elseif game.n.c[:heal].c == 90+l*30+96+135
        updateSprite!(game,3,:npc200,1)
    elseif game.n.c[:heal].c == 90+l*30+96+160
        killCC!(game,:heal)
        
        game.input.inputlock = false
        
        stateSetDialogue!(game,1,4,1)

        return
    end

    game.n.c[:heal].c += 1

    return
end















events = Base.ImmutableDict(
    0xc8 => eventHealCenter!
)
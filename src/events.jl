
function eventHealCenter!(game::GameState)
    if game.flags.general[0xc8]
        stateSetDialogue!(game,1,4,1)

        return
    end

    game.input.inputlock = true

    createCC!(game,:heal,animHealCenter!,())

    stateSetDialogue!(game,1,1,2,F(()->(game.callbacks[:heal].active=true)),)

    return
end

function animHealCenter!(game::GameState)
    if game.n.c[:heal].c == 0
        updateSprite!(game,:npc200,3)
    elseif game.n.c[:battleintro].c == 60
        createSprite!()
    elseif game.n.c[:battleintro].c == 45
        game.im.postprocess.func = horizontalShifts!
        game.im.postprocess.args = (0,2)
    elseif 45 < game.n.c[:battleintro].c < 115
        game.im.postprocess.args = (4*(game.n.c[:battleintro].c-45),2)
    else
        game.im.postprocess.active = false
        game.im.postprocess.func = empty
        game.im.postprocess.args = ()

        game.battle.active = true
        game.draw.battleintro = true

        stateInitDrawBattle!(game)

        game.n.c[:battleintro].c = 0
        killCallback!(game,:battleintro)

        return
    end

    game.n.c[:battleintro].c += 1
end















events = Base.ImmutableDict(
    0xc8 => eventHealCenter!
)
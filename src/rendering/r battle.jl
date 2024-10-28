


function getBattlerFront(id::UInt16,shiny::Bool)
    ima = deserialize("im/pkmn/$id/front_a.im")
    imb = deserialize("im/pkmn/$id/front_b.im")

    if shiny
        palette = deserialize("im/pkmn/$id/front_shiny.p")
    else
        palette = deserialize("im/pkmn/$id/front_normal.p")
    end

    return (
        Dict{Int,Image}(1=>ima,2=>imb),
        palette
    )
end

getBattlerFront(pkmn::Pkmn) = getBattlerFront(pkmn.id,pkmn.shiny)



function getBattlerBack(id::UInt16,shiny::Bool)
    im = deserialize("im/pkmn/$id/back.im")

    if shiny
        palette = deserialize("im/pkmn/$id/back_shiny.p")
    else
        palette = deserialize("im/pkmn/$id/back_normal.p")
    end

    return (
        Dict{Int,Image}(1=>im),
        palette
    )
end

getBattlerBack(pkmn::Pkmn) = getBattlerBack(pkmn.id,pkmn.shiny)







function drawBattleTagOwn!(game::GameState,pkmn::Pkmn,sprite::Sprite)
    drawHealthBar!(sprite,getHealthBar(pkmn),P(18,48))
    drawXpBar!(sprite,getXpBar(pkmn,0),P(34,32))

    drawText!(game,sprite,pkmnName(game,pkmn),UInt(1),Position(2,16),
        0x424242,0xded6b5)
    drawText!(game,sprite,string(pkmn.stats.level),UInt(1),Position(2,85),
        0x424242,0xded6b5)
    drawText!(game,sprite,"/",UInt(1),Position(20,75),
        0x424242,0xded6b5)
    drawText!(game,sprite,string(pkmn.stats.rv[1]),UInt(1),Position(20,80),
        0x424242,0xded6b5)
    drawText!(game,sprite,string(pkmn.stats.hp),UInt(1),Position(20,65),
        0x424242,0xded6b5)
end

function drawBattleTagOpp!(game::GameState,pkmn::Pkmn,sprite::Sprite)
    drawHealthBar!(sprite,getHealthBar(pkmn),P(18,39))
        
    drawText!(game,sprite,pkmnName(game,pkmn),UInt(1),Position(2,9),
        0x424242,0xded6b5)
    drawText!(game,sprite,string(pkmn.stats.level),UInt(1),Position(2,75),
        0x424242,0xded6b5)
end


function drawBattleIntro!(game::GameState; s=Settings())
    if game.n.c[:battleintro].c == 0
        stateSetupBattle!(game)
            
        drawBattleBase!(game; s=s)
    elseif game.n.c[:battleintro].c <= 32
        game.im.postprocess.args = (24+80,game.n.c[:battleintro].c)
    elseif game.n.c[:battleintro].c <= 58
        game.im.postprocess.args = (24+80,2*game.n.c[:battleintro].c-32)
    elseif game.n.c[:battleintro].c == 80
        killCounter!(game,:battleintro)

        game.im.postprocess.active = false

        game.draw.battleintro = false
        game.draw.battle = true

        game.dialogue.str = ["Ein wildes $(pkmnName(game,game.battle.state.pkmn2.pkmn)) erscheint!",
            "Los, $(pkmnName(game,game.battle.state.pkmn1.pkmn))!"]
        game.dialogue.n = 1
        game.dialogue.callback.func = stateBattleIntroDialogue!

        game.draw.battled = true

        game.ctrl.input.inputlock = false
        game.ctrl.input.battle = true
        game.ctrl.input.battled = true

        return
    end

    game.n.c[:battleintro].c += 1

    return
end

function drawBattleDialogue!(game::GameState)
    drawText!(game,3,game.dialogue.str[game.dialogue.n],UInt(2),
        P(144,32),0xffffff,0x6b5a73)

    return
end

function drawBattleMenu1!(game::GameState)
    drawText!(game,4,
        "Was soll\\$(pkmnName(game,game.battle.state.pkmn1.pkmn)) tun?",
        UInt(2),Position(144,32),0xffffff,0x6b5a73)

    drawFrame!(game,4,6,16,Position(24+112,16+112))

    drawText!(game,4,"KAMPF",UInt(3),Position(145,144),0x4a4a4a,0xd6d6ce)
    drawText!(game,4,"BEUTEL",UInt(3),Position(145,202),0x4a4a4a,0xd6d6ce)
    drawText!(game,4,"POKEMON",UInt(3),Position(161,144),0x4a4a4a,0xd6d6ce)
    drawText!(game,4,"FLUCHT",UInt(3),Position(161,202),0x4a4a4a,0xd6d6ce)

    return
end

function drawBattleMenu2!(game::GameState)
    drawFrame!(game,5,6,20,Position(24+112,16))
    drawFrame!(game,5,6,10,Position(24+112,176))

    drawText!(game,5,"/",UInt(3),Position(145,230),0x4a4a4a,0xd6d6ce)
    drawText!(game,5,
        string(game.battle.state.pkmn1.pkmn.attacks[game.ctrl.input.battle2menu.select+1].ap),
        UInt(3),Position(145,218),0x4a4a4a,0xd6d6ce)
    drawText!(game,5,
        string(game.battle.state.pkmn1.pkmn.attacks[game.ctrl.input.battle2menu.select+1].apmax),
        UInt(3),Position(145,236),0x4a4a4a,0xd6d6ce)

    drawText!(game,5,"AP\\Typ:",UInt(3),Position(145,186),0x4a4a4a,0xd6d6ce;
        lineoffset=2)
    drawText!(game,5,
        TypeNames[game.battle.state.pkmn1.pkmn.attacks[game.ctrl.input.battle2menu.select+1].type],
        UInt(3),Position(161,208),0x4a4a4a,0xd6d6ce)

    for i in 1:length(game.battle.state.pkmn1.pkmn.attacks)
        drawText!(game,5,game.battle.state.pkmn1.pkmn.attacks[i].name,
            UInt(3),Position(145+div(i-1,2)*16,32+((i-1)%2)*64))
    end

    for i in length(game.battle.state.pkmn1.pkmn.attacks)+1:4
        drawText!(game,5,"--",
            UInt(3),Position(145+div(i-1,2)*16,32+((i-1)%2)*64))
    end

    return
end






function drawBattle!(game::GameState; s=Settings())
    if game.draw.battled
        drawBattleDialogue!(game)
        return
    end

    if game.draw.battle1
        drawBattleMenu1!(game)
        game.draw.battle1 = false
    elseif game.draw.battle2
        drawBattleMenu2!(game)
        game.draw.battle2 = false
    end

    return
end




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
        
        flushLayer!(game)
        flushLayer!(game,:layer1)
        flushLayer!(game,:layer2)
        flushLayer!(game,:layer3)
        flushLayer!(game,:layer4)

        bg = deserialize("im/battle/backgrounds/grass1.imp")
        game.im.layers.layer1[24+1:24+112,16+1:16+240] = bg.palette[bg.im]

        dia = deserialize("im/menu/dialogue/1.imp")
        game.im.layers.layer3[24+1+112:24+160,16+1:16+240] = dia.palette[dia.im]

        createSprite!(game,:pkmn1,:layer2,Position(90,40),1,
            getBattlerBack(game.battle.state.pkmn1.pkmn); active=true)
        createSprite!(game,:pkmn2,:layer2,Position(32,160),1,
            getBattlerFront(game.battle.state.pkmn2.pkmn); active=true)
        
        createSprite!(game,:cursor1,:layer4,Position(146,136),1,
            getSprite("im/battle/cursor.imp"))
        createSprite!(game,:cursor2,:layer5,Position(146,24),1,
            getSprite("im/battle/cursor.imp"))
        
        createSprite!(game,:tag1,:layer3,Position(72+24,126+16),1,
            getSprite("im/battle/tagown.imp"); active=true)
        createSprite!(game,:tag2,:layer3,Position(14+24,12+16),1,
            getSprite("im/battle/tagopp.imp"); active=true)

        drawBattleTagOwn!(game,game.battle.state.pkmn1.pkmn,game.im.sprites[:tag1])
        drawBattleTagOpp!(game,game.battle.state.pkmn2.pkmn,game.im.sprites[:tag2])
    elseif game.n.c[:battleintro].c <= 32
        game.im.postprocess.args = (24+80,game.n.c[:battleintro].c)
    elseif game.n.c[:battleintro].c <= 56
        game.im.postprocess.args = (24+80,2*game.n.c[:battleintro].c-32)
    elseif game.n.c[:battleintro].c == 81
        killCounter!(game,:battleintro)

        game.im.postprocess.active = false

        game.draw.battleintro = false
        game.draw.battle = true

        game.dialogue.str = ["Ein wildes $(pkmnName(game,game.battle.state.pkmn2.pkmn)) erscheint!",
            "Los, $(pkmnName(game,game.battle.state.pkmn1.pkmn))!"]
        game.dialogue.n = 1
        game.dialogue.callback.func = stateBattleIntroDialogue!

        game.draw.battled = true

        game.input.inputlock = false
        game.input.battle = true
        game.input.battled = true

        return
    end

    game.n.c[:battleintro].c += 1
end

function drawBattleDialogue!(game::GameState)
    drawText!(game,:layer3,game.dialogue.str[game.dialogue.n],UInt(2),
        P(144,32),0xffffff,0x6b5a73)
end

function drawBattleMenu1!(game::GameState)
    drawText!(game,:layer4,"Was soll\\$(pkmnName(game,game.battle.state.pkmn1.pkmn)) tun?",UInt(2),
        Position(144,32),0xffffff,0x6b5a73)

    drawFrame!(game,:layer4,6,16,Position(24+112,16+112))

    drawText!(game,:layer4,"KAMPF",UInt(3),Position(145,144),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer4,"BEUTEL",UInt(3),Position(145,202),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer4,"POKEMON",UInt(3),Position(161,144),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer4,"FLUCHT",UInt(3),Position(161,202),0x4a4a4a,0xd6d6ce)
end

function drawBattleMenu2!(game::GameState)
    drawFrame!(game,:layer5,6,20,Position(24+112,16))
    drawFrame!(game,:layer5,6,10,Position(24+112,176))

    drawText!(game,:layer5,"/",UInt(3),Position(145,230),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer5,
        string(game.battle.state.pkmn1.pkmn.attacks[game.input.battle2menu.select+1].ap),
        UInt(3),Position(145,218),0x4a4a4a,0xd6d6ce)
    drawText!(game,:layer5,
        string(game.battle.state.pkmn1.pkmn.attacks[game.input.battle2menu.select+1].apmax),
        UInt(3),Position(145,236),0x4a4a4a,0xd6d6ce)

    drawText!(game,:layer5,"AP\\Typ:",UInt(3),Position(145,186),0x4a4a4a,0xd6d6ce;
        lineoffset=2)
    drawText!(game,:layer5,
        TypeNames[game.battle.state.pkmn1.pkmn.attacks[game.input.battle2menu.select+1].type],
        UInt(3),Position(161,208),0x4a4a4a,0xd6d6ce)

    for i in 1:length(game.battle.state.pkmn1.pkmn.attacks)
        drawText!(game,:layer5,game.battle.state.pkmn1.pkmn.attacks[i].name,
            UInt(3),Position(145+div(i-1,2)*16,32+((i-1)%2)*64))
    end

    for i in length(game.battle.state.pkmn1.pkmn.attacks)+1:4
        drawText!(game,:layer5,"--",
            UInt(3),Position(145+div(i-1,2)*16,32+((i-1)%2)*64))
    end
end






function drawBattle!(game::GameState; s=Settings())
    if game.draw.battled
        drawBattleDialogue!(game)
        return
    end

    if game.draw.battle1
        drawBattleMenu1!(game)
    elseif game.draw.battle2
        drawBattleMenu2!(game)
    end

    return
end

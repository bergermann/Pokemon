


function getBattlers()
    img = mfb_rgb.(load("im/battlers gen1.png"))

    d1 = Dict{UInt,Matrix{UInt32}}(
        zip(Vector{UInt}(1:151),[(img[
            1+64*div(i,10):64+64*div(i,10),1+64*i%10:64+64*i%10
        ],P(64,64)) for i in 0:150])
    )

    return merge(d1,)
end

function getBattlerFront(id::Int)
    img = mfb_rgb.(load("im/battlers/front/normal/$id.png"))

    return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img[:,1:64],P(64,64)),2=>(img[:,65:128],P(64,64)))
end

function getBattlerFront(pkmn::Pkmn)
    if !pkmn.shiny
        img = mfb_rgb.(load("im/battlers/front/normal/$(pkmn.id).png"))

        return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img[:,1:64],P(64,64)),2=>(img[:,65:128],P(64,64)))
    else
        img = mfb_rgb.(load("im/battlers/front/shiny/$(pkmn.id).png"))

        return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img[:,1:64],P(64,64)),2=>(img[:,65:128],P(64,64)))
    end
end

function getBattlerBack(id::Int)
    img = mfb_rgb.(load("im/battlers/back/normal/$id.png"))

    return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img[:,1:64],P(64,64)))
end

function getBattlerBack(pkmn::Pkmn)
    if !pkmn.shiny
        img = mfb_rgb.(load("im/battlers/back/normal/$(pkmn.id).png"))

        return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img,P(64,64)))
    else
        img = mfb_rgb.(load("im/battlers/back/shiny/$(pkmn.id).png"))

        return Dict{Int,Tuple{Matrix{UInt32},Position}}(1=>(img,P(64,64)))
    end
end

function getBattleBack(str::String)
    return mfb_rgb.(load("im/battlebacks/$str.png"))
end

function getBattleIntro(str::String)
    return mfb_rgb.(load("im/battleintro/$str.png"))
end

function getBattleTags()
    img = mfb_rgb.(load("im/battlestuff.png"))

    tagopp = img[1:32,1:102]
    tagown = img[33:72,1:106]

    return Dict(1=>(tagown,P(size(tagown)...))), Dict(1=>(tagopp,P(size(tagopp)...)))
end

function getBattleTagOwn()
    img = mfb_rgb.(load("im/battlestuff.png"))

    tagown = img[33:72,1:106]

    return Dict(1=>(tagown,P(size(tagown)...)))
end

function getBattleTagOpp()
    img = mfb_rgb.(load("im/battlestuff.png"))

    tagopp = img[1:32,1:102]

    return Dict(1=>(tagopp,P(size(tagopp)...)))
end

function getCursor()
    img = mfb_rgb.(load("im/battlestuff.png"))

    cursor = img[17:30,113:120]

    return Dict(1=>(cursor,P(size(cursor)...)))
end




function drawBattleTagOwn!(game::GameState,pkmn::Pkmn,im::Matrix{UInt32})
    drawHealthBar!(im,getHealthBar(pkmn),P(20,49))
    drawXpBar!(game,im,getXpBar(pkmn,0),P(36,33))

    drawText!(game,im,pkmnName(game,pkmn),UInt(1),Position(4,17),0x424242,0xded6b5)
    drawText!(game,im,string(pkmn.stats.level),UInt(1),Position(4,86),0x424242,0xded6b5)
    drawText!(game,im,"/",UInt(1),Position(22,76),0x424242,0xded6b5)
    drawText!(game,im,string(pkmn.stats.rv[1]),UInt(1),Position(22,81),0x424242,0xded6b5)
    drawText!(game,im,string(pkmn.stats.hp),UInt(1),Position(22,66),0x424242,0xded6b5)
end

function drawBattleTagOpp!(game::GameState,pkmn::Pkmn,im::Matrix{UInt32})
    drawHealthBar!(im,getHealthBar(pkmn),P(20,40))
        
    drawText!(game,im,pkmnName(game,pkmn),UInt(1),Position(4,10),0x424242,0xded6b5)
    drawText!(game,im,string(pkmn.stats.level),UInt(1),Position(4,76),0x424242,0xded6b5)
end

function drawBattleIntro!(game::GameState; s=Settings())
    if game.n.c[:battleintro].c == 0
        stateSetupBattle!(game)
        
        flushLayer!(game)
        flushLayer!(game,:layer1)
        flushLayer!(game,:layer2)
        flushLayer!(game,:layer3)
        flushLayer!(game,:layer4)

        game.im.layers.layer1[24+1:24+112,16+1:16+240] = getBattleBack("grass1")
        game.im.layers.layer3[24+1+112:24+160,16+1:16+240] = getDialogue("battle")

        createSprite!(game,:pkmn1,:layer2,getBattlerBack(game.battle.state.pkmn1.pkmn),
            Position(90,40),1; active=true)
        createSprite!(game,:pkmn2,:layer2,getBattlerFront(game.battle.state.pkmn2.pkmn),
            Position(32,160),1; active=true)
        
        createSprite!(game,:cursor1,:layer4,getCursor(),
            Position(146,136),1)
        createSprite!(game,:cursor2,:layer5,getCursor(),
            Position(146,24),1)
        
        createSprite!(game,:tag1,:layer3,getBattleTagOwn(),
            Position(72+24,126+16),1; active=true)
        createSprite!(game,:tag2,:layer3,getBattleTagOpp(),
            Position(14+24,12+16),1; active=true)

        drawBattleTagOwn!(game,game.battle.state.pkmn1.pkmn,game.im.sprites[:tag1].im)
        drawBattleTagOpp!(game,game.battle.state.pkmn2.pkmn,game.im.sprites[:tag2].im)

        # drawHealthBarBattle!(game.im.sprites[:tag1].im,
        #     getHealthBar(game.battle.state.pkmn1.pkmn),P(20,49))
        # drawXpBar!(game,game.im.sprites[:tag1].im,
        #     getXpBar(game.battle.state.pkmn1.pkmn,0),P(36,33))

        # drawText!(game,game.im.sprites[:tag1].im,pkmnName(game,game.battle.state.pkmn1.pkmn),
        #     UInt(1),Position(4,17),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag1].im,string(game.battle.state.pkmn1.pkmn.stats.level),
        #     UInt(1),Position(4,86),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag1].im,"/",
        #     UInt(1),Position(22,76),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag1].im,string(game.battle.state.pkmn1.pkmn.stats.rv[1]),
        #     UInt(1),Position(22,81),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag1].im,string(game.battle.state.pkmn1.pkmn.stats.hp),
        #     UInt(1),Position(22,66),0x424242,0xded6b5)
        
        # drawText!(game,game.im.sprites[:tag2].im,pkmnName(game,game.battle.state.pkmn2.pkmn),
        #     UInt(1),Position(4,10),0x424242,0xded6b5)
        # drawText!(game,game.im.sprites[:tag2].im,string(game.battle.state.pkmn2.pkmn.stats.level),
        #     UInt(1),Position(4,76),0x424242,0xded6b5)
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

# function drawBattleExit!(game::GameState; s=Settings())
#     println(game.n.c)
#     if game.n.c[:battleoutro].c == 0
#         game.im.postprocess.active = true
#         game.im.postprocess.func = fadeLinear!
#         game.im.postprocess.args = (0x3c,0x01,0x00)
#     elseif game.n.c[:battleoutro].c <= 60
#         game.im.postprocess.args = (0x3c,0x01,UInt8(game.n.c[:battleoutro].c))
#     elseif game.n.c[:battleoutro].c == 61
#         killCounter!(game,:battleoutro)

#         stateEndBattle!(game)
    
#         return
#     end

#     game.n.c[:battleoutro].c += 1
# end

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

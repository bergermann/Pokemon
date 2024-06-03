


function stateInitMapCtrls!(game::GameState)
    game.input.inputlock = false

    game.input.map = true
    game.input.move = true
end

function stateInitMap!(game::GameState)
    game.overworld = true    
    game.im.c.projection1[1:2,4] .= -game.ctrl.pos

    loadChunksAll!(game)

    loadArrayTexture!(game,"tilesets",tilesets,:tiles,16,16)
    loadSpriteSheet!(game,"main1.png",:mc,32,32,9; maxsprites=1)
    loadSpriteSheet!(game,"npcs_all.png",:npcs,16,32,9; maxsprites=2)

    createSprite!(game,:mc,:mc,1,1+(game.ctrl.dir-1)*3,P(0,8),10,3; active=true)
    
    if game.ctrl.dir == 4
        reverseSprite!(game,:mc,1)
    end

    # loadNPCs!(game)
    # loadSpritesNPCs!(game)

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.ctrl.dir,-1))

    # loadMapStrings!(game; reset=true)

    return
end

function stateMapTransition!(game::GameState,exit::Exit)
    println("pos1: ",game.pos)

    if game.maps.map.id != exit.targetid
        enterMap!(game,exit)
        
        for npc in game.npcstatic.data[1:game.npcstatic.idx]
            killSprite!(game,npc.spriteid)
        end
        
        for npc in game.npcmove.data[1:game.npcmove.idx]
            killSprite!(game,npc.spriteid)
        end
        
        popall!(game.npcstatic)
        popall!(game.npcmove)
        
        loadNPCs!(game,game.maps.map.id)
        loadSpritesNPCs!(game)
    else
        enterMap!(game,exit)
    end

    moveStop!(game,game.direction)

    println("pos2: ",game.pos)

    drawMap!(game)
end
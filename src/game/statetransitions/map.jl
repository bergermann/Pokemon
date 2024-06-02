


function stateInitMapCtrls!(game::GameState)
    game.input.inputlock = false

    game.input.map = true
    game.input.move = true
end

function stateInitDrawMap!(game::GameState)
    loadTiles!(game)
    drawMap!(game)
    
    game.overworld = true
    
    createSprite!(game,:main,3,Position(80,128),min(3,game.direction),
        getSprite("im/sprites/main1",18); active=true)
    
    if game.direction == 4
        game.im.sprites[3][:main].vreverse = true
    end

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.direction,-1))

    loadSpritesNPCs!(game)

    loadMapStrings!(game; reset=true)
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
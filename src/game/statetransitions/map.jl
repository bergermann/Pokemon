


function stateInitMapCtrls!(game::GameState)
    game.ctrl.input.inputlock = false

    game.ctrl.input.map = true
    game.ctrl.input.move = true
end

function stateInitMap!(game::GameState)
    game.overworld = true    
    game.im.c.projection1[1:2,4] .= -game.ctrl.pos1

    loadMapStrings!(game; reset=true)

    loadArrayTexture!(game,"tilesets",tilesets,:tiles,16,16)
    loadSpriteSheet!(game,"main1.png",:mc,32,32,9; maxsprites=1)
    loadSpriteSheet!(game,"npcs_all.png",:npcs,16,32,9; maxsprites=128)
    loadSpriteSheet!(game,"objects.png",:objects,16,16,1; maxsprites=64)

    loadChunksAll!(game)
    
    createBackground!(game,:textbox,"textboxes/green.png",-120,32,6; active=false)
    createFrame!(game,:menu,7,18,48,-80,6; active=false)
    createText!(game,:menu,4,63,-64,6,game.str[2][1],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=3)
    createSprite!(game,:cursor,:cursors,1,3,59,-56+game.ctrl.input.menu.select*16,0,6;
        active=false)
    createSprite!(game,:mc,:mc,1,1+3*(game.ctrl.dir-1-2*(game.ctrl.dir==4)),0,-8,10,3;
        wreverse=game.ctrl.dir==4,active=true)

    createCounter!(game,:movemain,1)
    createCallback!(game,:movemain,false,moveMain!,(game.ctrl.dir,-1))

    return
end

function stateOpenMap!(game::GameState)
    game.overworld = true    
    game.im.c.projection1[1:2,4] .= -game.ctrl.pos1

    loadMapStrings!(game; reset=true)

    loadArrayTexture!(game,"tilesets",tilesets,:tiles,16,16)
    loadSpriteSheet!(game,"main1.png",:mc,32,32,9; maxsprites=1)
    loadSpriteSheet!(game,"npcs_all.png",:npcs,16,32,9; maxsprites=128)
    loadSpriteSheet!(game,"objects.png",:objects,16,16,1; maxsprites=64)
    
    createBackground!(game,:textbox,"textboxes/green.png",-120,32,6; active=false)
    createFrame!(game,:menu,7,18,48,-80,6; active=false)
    createText!(game,:menu,4,63,-64,6,game.str[2][1],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=3)
    createSprite!(game,:cursor,:cursors,1,3,59,-56+game.ctrl.input.menu.select*16,0,6;
        active=false)
    createSprite!(game,:mc,:mc,1,1+3*(game.ctrl.dir-1-2*(game.ctrl.dir==4)),0,-8,10,3;
        wreverse=game.ctrl.dir==4,active=true)

    createCounter!(game,:movemain,1)
    createCallback!(game,:movemain,false,moveMain!,(game.ctrl.dir,-1))

    for npc in game.npcs
        createNPCSprite!(game,npc)
    end

    
    for object in game.objects
        createSprite!(game,sid,:objects,1,9+4*(type-1),
            16*(16*(cx-game.ctrl.chunk[2])+(x-game.ctrl.pos1[2])),
            16*(16*(cy-game.ctrl.chunk[1])+(y-game.ctrl.pos1[1]-1)),
            10,3;
            active=true)
    end
    
    for item in game.items
        createSprite!(game,sid,:objects,1,1,
            16*(16*(cx-game.ctrl.chunk[2])+(x-game.ctrl.pos1[2])),
            16*(16*(cy-game.ctrl.chunk[1])+(y-game.ctrl.pos1[1]-1)),
            10,3;
            active=true)
    end

    return
end

function createNPCSprite!(game::GameState,npc::NPC)
    x = 16*(16*(npc.chunk[2]-game.ctrl.chunk[2])+(x-game.ctrl.pos1[2]))+
        dirs[npc.dir][1]*npc.c2
    y = 16*(16*(npc.chunk[1]-game.ctrl.chunk[1])+(y-game.ctrl.pos1[1]))-8+
        dirs[npc.dir][2]*npc.c2
    
    createSprite!(game,npc.sprite,:npcs,npc.spriteid,1+3*(npc.dir-1-2*(npc.dir==4)),
        x,y,10,3; wreverse=npc.dir==4,active=true)

    return
end


function stateCloseMap!(game::GameState)
    deleteArrayTexture!(game,:tiles)
    deleteSpriteSheet!(game,:mc)
    deleteSpriteSheet!(game,:npcs)
    deleteSpriteSheet!(game,:objects)
    # deleteSpriteSheet!(game,:cursors)
    deleteText!(game,:menu)
    deleteFrame!(game,:menu)

    killSprites!(game,:cursors)

    killCC!(game,:movemain)
    
    game.overworld = false

    return
end

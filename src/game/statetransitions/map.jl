


function stateInitMapCtrls!(game::GameState,args::Tuple)
    game.ctrl.input.inputlock = false

    game.ctrl.input.map = true
    game.ctrl.input.move = true
end

function stateInitMap!(game::GameState)
    game.overworld = true    
    game.im.c.projection1[1:2,4] .= -game.ctrl.pos1

    loadStringsMap!(game; reset=true)

    loadArrayTexture!(game,"tilesets",tilesets,:tiles,16,16)
    loadSpriteSheets!(game,:mc1,:npcs_all,:objects)

    loadChunksAll!(game)
    
    createBackground!(game,:textbox,"textboxes/green.png",-120,32,6; active=false)
    createFrame!(game,:menu,7,18,48,-80,6; active=false)
    createText!(game,:menu,4,63,-64,6,game.str[2][1],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=3)
    createSprite!(game,:cursor,:cursors,1,3,59,-56+game.ctrl.input.menu.select*16,0,6;
        active=false)
    createSprite!(game,:mc,:mc1,1,1+3*(game.ctrl.dir-1-2*(game.ctrl.dir==4)),0,-8,10,3;
        wreverse=game.ctrl.dir==4,active=true)

    createCounter!(game,:movemain,1)
    createCallback!(game,:movemain,false,moveMain!,(game.ctrl.dir,-1))

    return
end

function stateOpenMap!(game::GameState)
    game.overworld = true

    createCounter!(game,:movemain,1)
    createCallback!(game,:movemain,false,moveMain!,(game.ctrl.dir,-1))

    loadStringsMap!(game; reset=true)
    
    createBackground!(game,:text,"textboxes/green.png",-120,32,6; active=false)

    loadArrayTexture!(game,"tilesets",tilesets,:tiles,16,16)
    loadSpriteSheets!(game,:mc1,:npcs_all,:objects)

    createFrame!(game,:menu,7,18,48,-80,6; active=false)
    createText!(game,:menu,4,63,-64,6,game.str[2][1],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=3)

    createSprite!(game,:cursor,:cursors,1,3,59,-56+game.ctrl.input.menu.select*16,0,6;
        active=false)
    createSprite!(game,:mc,:mc1,1,1+3*(game.ctrl.dir-1-2*(game.ctrl.dir==4)),0,-8,10,3;
        wreverse=game.ctrl.dir==4,active=true)

    for npc in game.m.npcs
        createNPCSprite!(game,npc)
    end
    
    for object in game.m.objects
        createSprite!(game,object.sprite,:objects,1,9+4*(object.type-1),
            16*(16*(object.chunk[2]-game.ctrl.chunk[2])+(object.pos[2]-game.ctrl.pos1[2])),
            16*(16*(object.chunk[1]-game.ctrl.chunk[1])+(object.pos[1]-game.ctrl.pos1[1])),
            10,3; active=true)
    end
    
    for item in game.m.items
        createSprite!(game,item.sprite,:objects,1,1,
            16*(16*(item.chunk[2]-game.ctrl.chunk[2])+(item.pos[2]-game.ctrl.pos1[2])),
            16*(16*(item.chunk[1]-game.ctrl.chunk[1])+(item.pos[1]-game.ctrl.pos1[1])),
            10,3; active=true)
    end

    return
end

function createNPCSprite!(game::GameState,npc::NPC)
    x = 16*(16*(npc.chunk[2]-game.ctrl.chunk[2])+(npc.pos1[2]-game.ctrl.pos1[2]))+
        dirs[npc.dir][1]*npc.c2
    y = 16*(16*(npc.chunk[1]-game.ctrl.chunk[1])+(npc.pos1[1]-game.ctrl.pos1[1]))-8+
        dirs[npc.dir][2]*npc.c2

    f = 1+3*(npc.dir-1-2*(npc.dir==4))+(1+sum(npc.pos1)%2)*(0<npc.c2<=8)
    
    createSprite!(game,npc.sprite,:npcs_all,npc.spriteid,f,x,y,10,3;
        wreverse=npc.dir==4,active=true)

    return
end


function stateCloseMap!(game::GameState)
    deleteArrayTexture!(game,:tiles)
    deleteSpriteSheets!(game,:mc1,:npcs_all,:objects)
    deleteBackground!(game,:textbox)
    deleteFrame!(game,:menu)
    deleteText!(game,:menu)

    killSprites!(game,:cursors)

    killCC!(game,:movemain)
    
    game.overworld = false

    return
end

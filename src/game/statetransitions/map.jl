


function stateInitMapCtrls!(game::GameState)
    game.ctrl.input.inputlock = false

    game.ctrl.input.map = true
    game.ctrl.input.move = true
end

function stateInitMap!(game::GameState)
    game.overworld = true    
    game.im.c.projection1[1:2,4] .= -game.ctrl.pos

    loadChunksAll!(game)

    loadArrayTexture!(game,"tilesets",tilesets,:tiles,16,16)
    loadSpriteSheet!(game,"main1.png",:mc,32,32,9; maxsprites=2)
    loadSpriteSheet!(game,"npcs_all.png",:npcs,16,32,9; maxsprites=128)
    loadSpriteSheet!(game,"cursors.png",:cursors,6,10,1; maxsprites=4)

    loadMapStrings!(game; reset=true)

    # loadNPCs!(game)

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.ctrl.dir,-1))

    createFrame!(game,:menu,7,18,48,-80,6; active=false)
    createText!(game,:menu,3,62,-66,6,game.str[2][1],
        [0x63,0x63,0x63,0xff],[0xd6,0xd6,0xce,0xff]; active=false,hpad=2)
    createSprite!(game,:cursor,:cursors,1,1,58,-59+game.ctrl.input.menu.select*16,0,6;
        active=false)

    createBackground!(game,:textbox,"textboxes/green.png",-120,32,6; active=false)

    createSprite!(game,:mc,:mc,1,1+3*(game.ctrl.dir-1),0,-8,10,3; active=true)
    
    if game.ctrl.dir == 4
        reverseSprite!(game,:mc,1)
    end

    # loadSpritesNPCs!(game)

    return
end

function stateMapTransition!(game::GameState,exit::Exit)
    

    return
end
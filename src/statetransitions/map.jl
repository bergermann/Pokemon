


function stateInitMapCtrls!(game::GameState)
    game.input.inputlock = false

    game.input.map = true
    game.input.move = true
end

function stateInitDrawMap!(game::GameState)
    drawMap!(game)
    game.overworld = true
    
    createSprite!(game,:main,:layer2,Position(80,128),min(3,game.direction),
        getSprite("im/sprites/main1",18); active=true)
    
    if game.direction == 4
        game.im.sprites[:main].vreverse = true
    end

    createCounter!(game,:movemain,0)
    createCallback!(game,:movemain,false,moveMain!,(game.direction,-1))

    loadSpritesNPCs!(game)
end

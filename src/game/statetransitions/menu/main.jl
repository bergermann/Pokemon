

function stateMenuMainOpen!(game::GameState,args::Tuple{})
    game.ctrl.input.move = false
    game.ctrl.input.map = false
    game.ctrl.input.menu.main = true
    unlockInput!(game)

    switchFrame!(game,:menu)
    switchText!(game,:menu)
    switchSprite!(game,:cursor)
    moveSprite!(game,:cursor,59,-56+game.ctrl.input.menu.select*16,true)

    return
end


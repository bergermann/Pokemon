

function inputMenuPkmn!(game::GameState,input::Input)
    if input._A
        if game.input.menu.menupkmn.select == game.trainer.pokemon.idx+1
            game.input.inputlock = true
            game.input.menu.pkmn = false
            game.input.menu.menupkmn.select = 1

            createCC!(game,:scenet,sceneTransition!,(16,8,
                stateMenuPkmnClose!,(),stateMenuMainOpen!,()); active=true,n=1)

            return
        end
    elseif input._B
        game.input.inputlock = true
        game.input.menu.pkmn = false
        game.input.menu.menupkmn.select = 1

        createCC!(game,:scenet,sceneTransition!,(16,8,
            stateMenuPkmnClose!,(),stateMenuMainOpen!,()); active=true,n=1)

        return
    elseif input._down
        if game.input.menu.menupkmn.select == game.trainer.pokemon.idx+1
            switchSlot!(game,game.input.menu.menupkmn.select,1)
        else
            switchSlot!(game,game.input.menu.menupkmn.select,
                game.input.menu.menupkmn.select+1)
        end
    elseif input._up
        if game.input.menu.menupkmn.select == 1
            switchSlot!(game,1,game.trainer.pokemon.idx+1)
        else
            switchSlot!(game,game.input.menu.menupkmn.select,
                game.input.menu.menupkmn.select-1)
        end
    elseif input._left || input._right
        if game.input.menu.menupkmn.select == 1
            switchSlot!(game,1,2)
        else
            switchSlot!(game,game.input.menu.menupkmn.select,1)
        end
    end
end
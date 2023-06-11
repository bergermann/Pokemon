function loadTeamStrings!(game::GameState)
    game.str = []
    
    push!(game.str,readlines("str/ger/system_pkmn.txt"))
end

function inputMenuPkmn!(game::GameState,input::Input)
    if game.input.menu.menupkmn.sub
        inputPkmnSub!(game,input)

        return
    end

    if game.input.menu.menupkmn.swap != 0
        if input._A
            if game.input.menu.menupkmn.select == game.trainer.pokemon.idx+1
                updateSprite!(game.im.sprites[Symbol(:slot,game.input.menu.menupkmn.swap)],1)
            
                game.input.menu.menupkmn.swap = 0

                return
            elseif game.input.menu.menupkmn.select == game.input.menu.menupkmn.swap
                updateSprite!(game.im.sprites[Symbol(:slot,game.input.menu.menupkmn.swap)],2)
            
                game.input.menu.menupkmn.swap = 0

                return
            end

            println("swap pokemons")

            # animSwapPokemons!()
            swap!(game.trainer.pokemon,game.input.menu.menupkmn.swap,
                game.input.menu.menupkmn.select)
            
            game.input.menu.menupkmn.swap = 0

            return
        elseif input._B
            updateSprite!(game.im.sprites[Symbol(:slot,game.input.menu.menupkmn.swap)],
                1+game.input.menu.menupkmn.swap==game.input.menu.menupkmn.select)

            if game.input.menu.menupkmn.select != game.trainer.pokemon.idx+1
                updateSprite!(game.im.sprites[Symbol(:slot,game.input.menu.menupkmn.select)],
                    2)
            end
            
            game.input.menu.menupkmn.swapping = false
            game.input.menu.menupkmn.swap = 0
        end
    end

    inputTeam!(game,input)
end

function inputTeam!(game::GameState,input::Input)
    if input._A
        if game.input.menu.menupkmn.select == game.trainer.pokemon.idx+1
            game.input.inputlock = true
            game.input.menu.pkmn = false
            game.input.menu.menupkmn.select = 1

            createCC!(game,:scenet,sceneTransition!,(16,8,
                stateMenuPkmnClose!,(),stateMenuMainOpen!,()); active=true,n=1)

            return
        end

        flushLayer!(game,:layer2)

        drawFrame!(game,:layer2,4,20,Position(24+128,16))
        drawText!(game,:layer2,game.str[1][3]*getPkmnName(game,
            game.trainer.pokemon[game.input.menu.menupkmn.select])*"?",
            UInt(2),Position(24+138,24))

        setChoice!(game,true,1,pkmnAction!,())

        drawChoiceMenu!(game,:layer4,game.str[1][6:9],10,P(104,192-16);
            c1=0x606060,c2=0xd0d0c8)
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
    
            game.input.menu.menupkmn.select = 1
        else
            switchSlot!(game,game.input.menu.menupkmn.select,
                game.input.menu.menupkmn.select+1)
    
            game.input.menu.menupkmn.select += 1
        end
    elseif input._up
        if game.input.menu.menupkmn.select == 1
            switchSlot!(game,1,game.trainer.pokemon.idx+1)
    
            game.input.menu.menupkmn.select = game.trainer.pokemon.idx+1
        else
            switchSlot!(game,game.input.menu.menupkmn.select,
                game.input.menu.menupkmn.select-1)
    
            game.input.menu.menupkmn.select -= 1
        end
    elseif input._left || input._right
        if game.input.menu.menupkmn.select == 1
            switchSlot!(game,1,2)
    
            game.input.menu.menupkmn.select = 2
        else
            switchSlot!(game,game.input.menu.menupkmn.select,1)
    
            game.input.menu.menupkmn.select = 1
        end
    end
end

function inputPkmnSub!(game::GameState,input::Input)
    return
end

function pkmnAction!(game::GameState)
    if game.input.choice.sel == 1
        resetChoice!(game)
        # createCC!(game,:scenet,sceneTransition!,
        #     (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

        # game.input.inputlock = true
        # game.input.menu.menupkmn.submode = 1
    elseif game.input.choice.sel == 2
        game.input.menu.menupkmn.swapping = true
        game.input.menu.menupkmn.swap = game.input.menu.menupkmn.select

        updateSprite!(game.im.sprites[Symbol(:slot,game.input.menu.menupkmn.select)],4)

        return
    elseif game.input.choice.sel == 3
        resetChoice!(game)
        # createCC!(game,:scenet,sceneTransition!,
        #     (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

        # game.input.inputlock = true
        # game.input.menu.menubags.submode = 3

        return
    end
    
    resetChoice!(game)
end




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

            game.input.inputlock = true
            createCC!(game,:pkmnswap,animMenuPkmnSwap!,(); active=true,n=1)

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
        if game.battle.active
            inputTeamActionBattle!(game)
        else
            inputTeamAction!(game)
        end
    elseif input._B
        game.input.inputlock = true
        game.input.menu.pkmn = false
        game.input.menu.menupkmn.select = 1

        if !game.battle.active
            createCC!(game,:scenet,sceneTransition!,(16,8,
                stateMenuPkmnClose!,(),stateMenuMainOpen!,()); active=true,n=1)
        else
            createCC!(game,:scenet,sceneTransition!,(16,8,
                stateBattlePkmnClose!,(),stateBattleCtrls!,()); active=true,n=1)
        end

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

function inputTeamAction!(game::GameState)
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
end

function inputTeamActionBattle!(game::GameState)
    if game.input.menu.menupkmn.select == game.trainer.pokemon.idx+1
        game.input.inputlock = true
        game.input.menu.pkmn = false
        game.input.menu.menupkmn.select = 1

        createCC!(game,:scenet,sceneTransition!,(16,8,
            stateBattlePkmnClose!,(),stateBattleCtrls!,()); active=true,n=1)

        return
    end

    flushLayer!(game,:layer2)

    drawFrame!(game,:layer2,4,20,Position(24+128,16))
    drawText!(game,:layer2,game.str[1][3]*getPkmnName(game,
        game.trainer.pokemon[game.input.menu.menupkmn.select])*"?",
        UInt(2),Position(24+138,24))

    setChoice!(game,true,1,pkmnActionBattle!,
        (game.trainer.pokemon[game.input.menu.menupkmn.select].stats.hp,))

    if game.trainer.pokemon[game.input.menu.menupkmn.select].stats.hp > 0
        drawChoiceMenu!(game,:layer4,game.str[1][[7,6,9]],10,P(104+16,192-16);
            c1=0x606060,c2=0xd0d0c8)
    else
        drawChoiceMenu!(game,:layer4,game.str[1][[6,9]],10,P(104+32,192-16);
            c1=0x606060,c2=0xd0d0c8)
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

function pkmnActionBattle!(game::GameState,hp::Int)
    if hp > 0
        if game.input.choice.sel == 1
            game.input.inputlock = true
            game.input.menu.pkmn = false

            createCC!(game,:scenet,sceneTransition!,
                (16,8,stateBattlePkmnClose!,(),stateBattlePkmnSelected!,
                ());
                active=true,n=1)
            
            return
        elseif game.input.choice.sel == 2
            resetChoice!(game)

            return
        end
        
        resetChoice!(game)
    else
        if game.input.choice.sel == 1
            resetChoice!(game)

            return
        end
        
        resetChoice!(game)
    end
end




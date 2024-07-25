
function inputMenuPkmn!(game::GameState,inputs::Inputs)
    if game.ctrl.input.menu.menupkmn.sub
        inputPkmnSub!(game,inputs)

        return
    end

    if game.ctrl.input.menu.menupkmn.swap != 0
        if inputs.A.press
            if game.ctrl.input.menu.menupkmn.select == game.p.pokemon.idx+1
                setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.swap),1,1)

                game.ctrl.input.menu.menupkmn.swap = 0

                return
            elseif game.ctrl.input.menu.menupkmn.select == game.ctrl.input.menu.menupkmn.swap
                setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.swap),1,2)
            
                game.ctrl.input.menu.menupkmn.swap = 0

                return
            end

            game.ctrl.input.inputlock = true
            createCC!(game,:pkmnswap,animMenuPkmnSwap!,(); active=true,n=1)

            return
        elseif inputs.B.press
            setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.swap),
                1,1+game.ctrl.input.menu.menupkmn.swap==game.ctrl.input.menu.menupkmn.select)

            if game.ctrl.input.menu.menupkmn.select != game.p.pokemon.idx+1
                setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.select),1,2)
            end
            
            game.ctrl.input.menu.menupkmn.swapping = false
            game.ctrl.input.menu.menupkmn.swap = 0
        end
    end

    inputTeam!(game,inputs)

    return
end

function switchSlot!(game::GameState,from::Int,to::Int)
    if from == game.p.pokemon.idx+1
        setSpriteFrame!(game,:exit,1)
        setSpriteFrame!(game,:ballexit,1)
    else
        setSprite!(game,Symbol(:slot,from),1+(game.ctrl.input.menu.menupkmn.swap==from),1)
        setSpriteFrame!(game,Symbol(:ball,from),1)
    end

    if to == game.p.pokemon.idx+1
        setSpriteFrame!(game,:exit,2)
        setSpriteFrame!(game,:ballexit,2)
    else
        setSprite!(game,Symbol(:slot,to),1+(game.ctrl.input.menu.menupkmn.swap!=0),2)
        setSpriteFrame!(game,Symbol(:ball,to),2)
    end

    return
end

function inputTeam!(game::GameState,inputs::Inputs)
    if inputs.A.press
        if game.battle.active
            inputTeamActionBattle!(game)
        else
            inputTeamAction!(game)
        end
    elseif inputs.B.press
        game.ctrl.input.inputlock = true
        game.ctrl.input.menu.pkmn = false
        game.ctrl.input.menu.menupkmn.select = 1

        if !game.battle.active
            createCC!(game,:scenet,sceneTransition!,(16,8,
                F(stateMenuPkmnClose!),F(stateMenuMainOpen!)); active=true,n=1)
        else
            createCC!(game,:scenet,sceneTransition!,(16,8,
                F(stateBattlePkmnClose!),F(stateBattleCtrls!)); active=true,n=1)
        end

        return
    elseif inputs.down.press
        if game.ctrl.input.menu.menupkmn.select == game.p.pokemon.idx+1
            switchSlot!(game,game.ctrl.input.menu.menupkmn.select,1)
    
            game.ctrl.input.menu.menupkmn.select = 1
        else
            switchSlot!(game,game.ctrl.input.menu.menupkmn.select,
                game.ctrl.input.menu.menupkmn.select+1)
    
            game.ctrl.input.menu.menupkmn.select += 1
        end
    elseif inputs.up.press
        if game.ctrl.input.menu.menupkmn.select == 1
            switchSlot!(game,1,game.p.pokemon.idx+1)
    
            game.ctrl.input.menu.menupkmn.select = game.p.pokemon.idx+1
        else
            switchSlot!(game,game.ctrl.input.menu.menupkmn.select,
                game.ctrl.input.menu.menupkmn.select-1)
    
            game.ctrl.input.menu.menupkmn.select -= 1
        end
    elseif inputs.left.press || inputs.right.press
        if game.ctrl.input.menu.menupkmn.select == 1
            switchSlot!(game,1,2)
    
            game.ctrl.input.menu.menupkmn.select = 2
        else
            switchSlot!(game,game.ctrl.input.menu.menupkmn.select,1)
    
            game.ctrl.input.menu.menupkmn.select = 1
        end
    end

    return
end

function inputTeamAction!(game::GameState)
    if game.ctrl.input.menu.menupkmn.select == game.p.pokemon.idx+1
        game.ctrl.input.inputlock = true
        game.ctrl.input.menu.pkmn = false
        game.ctrl.input.menu.menupkmn.select = 1

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateMenuPkmnClose!),F(stateMenuMainOpen!)); active=true,n=1)

        return
    end

    switchText!(game,:choose)
    switchFrame!(game,:choose)

    switchText!(game,:info)
    switchFrame!(game,:info)

    setText!(game,:info,game.str[1][3]*
        pkmnName(game,game.p.pokemon[game.ctrl.input.menu.menupkmn.select])*"?")

    setChoice!(game,true,1,F(pkmnAction!))

    drawChoiceMenu!(game,4,game.str[1][6:9],8,24,0)

    return
end

function inputTeamActionBattle!(game::GameState)
    if game.ctrl.input.menu.menupkmn.select == game.p.pokemon.idx+1
        game.ctrl.input.inputlock = true
        game.ctrl.input.menu.pkmn = false
        game.ctrl.input.menu.menupkmn.select = 1

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(stateBattlePkmnClose!),F(stateBattleCtrls!)); active=true,n=1)

        return
    end

    flushLayer!(game,2)

    drawFrame!(game,2,4,20,Position(24+128,16))
    drawText!(game,2,game.str[1][3]*getPkmnName(game,
        game.p.pokemon[game.ctrl.input.menu.menupkmn.select])*"?",
        UInt(2),Position(24+138,24))

    setChoice!(game,true,1,F(pkmnActionBattle!,
        (game.p.pokemon[game.ctrl.input.menu.menupkmn.select].stats.hp,)))

    if game.p.pokemon[game.ctrl.input.menu.menupkmn.select].stats.hp > 0
        drawChoiceMenu!(game,4,game.str[1][[7,6,9]],10,192-16-120,104+16-60)
    else
        drawChoiceMenu!(game,4,game.str[1][[6,9]],10,192-16-120,104+16-60)
    end
end

function inputPkmnSub!(game::GameState,inputs::Inputs)
    return
end

function pkmnAction!(game::GameState,args::Tuple{})
    if game.ctrl.input.choice.sel == 1
        resetChoice!(game)
        # createCC!(game,:scenet,sceneTransition!,
        #     (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

        # game.ctrl.input.inputlock = true
        # game.ctrl.input.menu.menupkmn.submode = 1
    elseif game.ctrl.input.choice.sel == 2
        game.ctrl.input.menu.menupkmn.swapping = true
        game.ctrl.input.menu.menupkmn.swap = game.ctrl.input.menu.menupkmn.select

        setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.select),2,2)

        return
    elseif game.ctrl.input.choice.sel == 3
        resetChoice!(game)
        # createCC!(game,:scenet,sceneTransition!,
        #     (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

        # game.ctrl.input.inputlock = true
        # game.ctrl.input.menu.menubags.submode = 3

        return
    end
    
    resetChoice!(game)

    return
end

function pkmnActionBattle!(game::GameState,hp::Int)
    if hp > 0
        if game.ctrl.input.choice.sel == 1
            game.ctrl.input.inputlock = true
            game.ctrl.input.menu.pkmn = false

            createCC!(game,:scenet,sceneTransition!,
                (16,8,stateBattlePkmnClose!,(),stateBattlePkmnSelected!,
                ());
                active=true,n=1)
            
            return
        elseif game.ctrl.input.choice.sel == 2
            resetChoice!(game)

            return
        end
        
        resetChoice!(game)
    else
        if game.ctrl.input.choice.sel == 1
            resetChoice!(game)

            return
        end
        
        resetChoice!(game)
    end
end




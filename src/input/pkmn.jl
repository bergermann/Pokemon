
function inputMenuPkmn!(game::GameState,inputs::Inputs)
    if game.ctrl.input.menu.menupkmn.swap != 0
        if inputs.A.press
            if game.ctrl.input.menu.menupkmn.select == game.p.pokemon.idx+1
                setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.swap),1,1)
            
                setText!(game,:choose,game.str[1][2])

                game.ctrl.input.menu.menupkmn.swap = 0

                return
            elseif game.ctrl.input.menu.menupkmn.select == game.ctrl.input.menu.menupkmn.swap
                setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.swap),1,2)
            
                setText!(game,:choose,game.str[1][2])
            
                game.ctrl.input.menu.menupkmn.swap = 0

                return
            end

            lockInput!(game)
            createCC!(game,:pkmnswap,animMenuPkmnSwap!,
                (game.ctrl.input.menu.menupkmn.swap,game.ctrl.input.menu.menupkmn.select);
                active=true,n=1)

            return
        elseif inputs.B.press
            setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.swap),1,1)
            setSprite!(game,Symbol(:slot,game.ctrl.input.menu.menupkmn.select),1,2)
            
            game.ctrl.input.menu.menupkmn.swapping = false
            game.ctrl.input.menu.menupkmn.swap = 0
            
            setText!(game,:choose,game.str[1][2])

            return
        end
    end

    inputTeam!(game,inputs)

    return
end

function switchSlot!(game::GameState,from::Int,to::Int)
    s = game.ctrl.input.menu.menupkmn.swap

    if from == game.p.pokemon.idx+1
        setSpriteFrame!(game,:exit,1)
        setSpriteFrame!(game,:ballexit,1)
    else
        idx = 1+(s==from)+2*isfainted(game,from)*(s!=from)

        setSprite!(game,mplabels[from].s,idx,1)
        setSpriteFrame!(game,mplabels[from].b,1)

        if from != 1; moveSpriteW!(game,mplabels[from].ic,-4); end
    end

    if to == game.p.pokemon.idx+1
        setSpriteFrame!(game,:exit,2)
        setSpriteFrame!(game,:ballexit,2)
    else
        idx = 1+(s!=0)+2*isfainted(game,to)*(s==0)
        
        setSprite!(game,mplabels[to].s,idx,2)
        setSpriteFrame!(game,mplabels[to].b,2)

        if to != 1; moveSpriteW!(game,mplabels[to].ic,4); end
    end

    return
end

function inputTeam!(game::GameState,inputs::Inputs)
    if inputs.A.press
        inputTeamAction!(game)
    elseif inputs.B.press
        if game.battle.active && game.battle.state.forceswitch1; return; end

        lockInput!(game)

        createCC!(game,:scenet,sceneTransition!,(16,8,
            F(statePkmnClose!),F0); active=true,n=1)
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
        if game.battle.active && game.battle.state.forceswitch1; return; end
        
        lockInput!(game)

        createCC!(game,:scenet,sceneTransition!,(16,8,F(statePkmnClose!),F0); active=true,n=1)

        return
    end

    switchText!(game,:choose)
    switchFrame!(game,:choose)

    switchText!(game,:info)
    switchFrame!(game,:info)

    setText!(game,:info,game.str[1][3]*
        pkmnName(game,game.p.pokemon[game.ctrl.input.menu.menupkmn.select])*"?")

    setChoice!(game,1,F(pkmnAction!); exit=-1)

    if game.battle.active
        if game.p.pokemon[game.ctrl.input.menu.menupkmn.select].stats.hp > 0
            drawChoiceMenu!(game,4,game.str[1][[7,6,9]],7,40,-8)
        else
            drawChoiceMenu!(game,4,game.str[1][[6,9]],7,40,0)
        end
    else
        drawChoiceMenu!(game,4,game.str[1][6:9],7,24,-16)
    end

    return
end

function pkmnAction!(game::GameState,args::Tuple{})
    n = game.ctrl.input.menu.menupkmn.select
    
    if game.battle.active
        if n > 1 && game.p.pokemon[n].stats.hp > 0
            if game.ctrl.input.choice.sel == 1
                lockInput!(game)
                
                if game.battle.state.forceswitch1
                    game.battle.state.forceswitch1 = false

                    swap!(game.p.pokemon,1,n)
                    game.battle.teamperm[1], game.battle.teamperm[n] = 
                        game.battle.teamperm[n], game.battle.teamperm[1]

                    game.battle.state.pkmn1 = PkmnBattle(game.p.pokemon[1],
                        getPkmnName(game,activePkmn(game)))

                    game.battle.state.pkmn1.command = CN0

                    push!(game.battle.state.animqueue,BattleAnimation(
                        :p1,128,"Los! "*getPkmnName(game,game.p.pokemon[1])*"!",
                        bswitchIn!,1
                    ))

                    createCC!(game,:scenet,sceneTransition!,
                        (16,8,F(statePkmnClose!),F(stateResumeBattleAnim!)); active=true,n=1)
                else
                    stateBattlePkmnSelected!(game)

                    createCC!(game,:scenet,sceneTransition!,
                        (16,8,F(statePkmnClose!),F(stateStartBattleAnim!)); active=true,n=1)
                end
                
                return
            elseif game.ctrl.input.choice.sel == 2
                switchText!(game,:choose); switchFrame!(game,:choose)
                switchText!(game,:info); switchFrame!(game,:info)

                return
            end
        else
            if game.ctrl.input.choice.sel == 1
                switchText!(game,:choose); switchFrame!(game,:choose)
                switchText!(game,:info); switchFrame!(game,:info)

                return
            end
            
            switchText!(game,:choose); switchFrame!(game,:choose)
            switchText!(game,:info); switchFrame!(game,:info)
        end
    else
        if game.ctrl.input.choice.sel == 1
            switchText!(game,:choose); switchFrame!(game,:choose)
            switchText!(game,:info); switchFrame!(game,:info)
            # createCC!(game,:scenet,sceneTransition!,
            #     (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

            # lockInput!(game)
            # game.ctrl.input.menu.menupkmn.submode = 1

            return
        elseif game.ctrl.input.choice.sel == 2
            game.ctrl.input.menu.menupkmn.swapping = true
            game.ctrl.input.menu.menupkmn.swap = n

            setSprite!(game,Symbol(:slot,n),2,2)

            switchText!(game,:choose); switchFrame!(game,:choose)
            switchText!(game,:info); switchFrame!(game,:info)
        
            setText!(game,:choose,game.str[1][4])

            return
        elseif game.ctrl.input.choice.sel == 3
            switchText!(game,:choose); switchFrame!(game,:choose)
            switchText!(game,:info); switchFrame!(game,:info)
            # createCC!(game,:scenet,sceneTransition!,
            #     (16,8,stateMenuPkmnSubOpen!,(),stateMenuPkmnSubCtrls!,()); active=true,n=1)

            # lockInput!(game)
            # game.ctrl.input.menu.menubags.submode = 3

            return
        end
    end

    switchText!(game,:choose); switchFrame!(game,:choose)
    switchText!(game,:info); switchFrame!(game,:info)

    return
end





function inputBattle!(game::GameState,input::Input)
    if game.input.battled
        if input._A || input._B || input._down
            inputBattleDialogue!(game::GameState,input::Input)
        end

        return
    end

    if game.input.battle1
        if input._A
            inputBattleMenuSelector!(game::GameState)
            return
        end

        if input._B
            game.input.battle1menu.select = 3
            return
        end

        if input._up
            game.input.battle1menu.select -= 2
        elseif input._down
            game.input.battle1menu.select += 2
        elseif input._left
            if game.input.battle1menu.select%2 == 0
                game.input.battle1menu.select += 1
            else
                game.input.battle1menu.select -= 1
            end
        elseif input._right
            if game.input.battle1menu.select%2 == 1
                game.input.battle1menu.select -= 1
            else
                game.input.battle1menu.select += 1
            end
        end

        if game.input.battle1menu.select < 0
            game.input.battle1menu.select += 4
        end

        game.input.battle1menu.select %= 4

        game.im.sprites[:cursor1].pos.h = 146+div(game.input.battle1menu.select,2)*16
        game.im.sprites[:cursor1].pos.w = 136+(game.input.battle1menu.select%2)*58

        return
    end

    if game.input.battle2
        if game.input.battle1menu.select < 0
            game.input.battle1menu.select += 4
        end

        game.input.battle1menu.select %= 4

        if input._A
            inputBattleAttackSelector!(game::GameState)
            return
        end

        if input._B
            game.input.battle1 = true
            game.input.battle2 = false
    
            game.draw.battle1 = true
            game.draw.battle2 = false

            game.im.sprites[:cursor1].active = true
            game.im.sprites[:cursor2].active = false

            flushLayer!(game,:layer4,Position(24+1+112,16+1),Position(48,240))
            flushLayer!(game,:layer5,Position(24+1+112,16+1),Position(48,240))

            return
        end

        if input._up
            if div(game.input.battle2menu.select,2) == 0
                game.input.battle2menu.select += 2
            else
                game.input.battle2menu.select -= 2
            end

            if game.input.battle2menu.select >=
                length(game.battle.state.pkmn1.pkmn.attacks)

                game.input.battle2menu.select -= 2
            end
        elseif input._down
            if div(game.input.battle2menu.select,2) == 0
                game.input.battle2menu.select += 2
            else
                game.input.battle2menu.select -= 2
            end

            if game.input.battle2menu.select >=
                length(game.battle.state.pkmn1.pkmn.attacks)

                game.input.battle2menu.select -= 2
            end
        elseif input._left
            if game.input.battle2menu.select%2 == 0
                game.input.battle2menu.select += 1
            else
                game.input.battle2menu.select -= 1
            end

            if game.input.battle2menu.select >=
                length(game.battle.state.pkmn1.pkmn.attacks)

                game.input.battle2menu.select -= 1
            end
        elseif input._right
            if game.input.battle2menu.select%2 == 1
                game.input.battle2menu.select -= 1
            else
                game.input.battle2menu.select += 1
            end

            if game.input.battle2menu.select >=
                length(game.battle.state.pkmn1.pkmn.attacks)

                game.input.battle2menu.select -= 1
            end
        end

        if game.input.battle1menu.select < 0
            game.input.battle1menu.select += 4
        end

        game.input.battle1menu.select %= 4

        game.im.sprites[:cursor2].pos.h = 146+div(game.input.battle2menu.select,2)*16
        game.im.sprites[:cursor2].pos.w = 24+(game.input.battle2menu.select%2)*64

        return
    end

    if game.input.battlebag
        inputBattleInventory!(game,input)
    end
end

function inputBattleDialogue!(game::GameState,input::Input)
    if input._A || input._B || input._down
        if game.dialogue.n < length(game.dialogue.str)
            game.dialogue.n += 0x01
        else
            game.dialogue.d = false
            game.dialogue.n = 1
            game.input.battled = false
            
            game.draw.battled = false

            game.dialogue.callback.func(game,game.dialogue.callback.args...)
        end
        
        flushLayer!(game,:layer3,Position(24+1+120,24+1),Position(32,208),0x68a0a0)
    end
end

function inputBattleMenuSelector!(game::GameState)
    if game.input.battle1menu.select == 0
        game.input.battle1 = false
        game.input.battle2 = true

        game.draw.battle1 = false
        game.draw.battle2 = true

        game.im.sprites[:cursor1].active = false
        game.im.sprites[:cursor2].active = true    
                
        flushLayer!(game,:layer4,Position(24+1+112,16+1),Position(48,240),
            0x4a4252)
    elseif game.input.battle1menu.select == 1
        game.input.inputlock = true
        game.input.battle1 = false

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateBattleBagsOpen!,(),stateBattleBagsCtrls!,());
            active=true,n=1)
    elseif game.input.battle1menu.select == 2
        game.input.inputlock = true
        game.input.battle1 = false

        createCC!(game,:scenet,sceneTransition!,
            (16,8,stateBattlePkmnOpen!,(),stateMenuPkmnCtrls!,());
            active=true,n=1)
    else
        stateBattleFlee!(game)
    end
end

function inputBattleAttackSelector!(game::GameState)
    if !checkAttack!(game)
        return
    end

    stateBattleAttackSelected!(game)
end

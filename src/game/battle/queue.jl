


function queueCheckStatus!(game::GameState,state::BattleState)::Bool
    F = false

    if state[1].pkmn.stats.hp == 0 && !fs(state,1)
        for i in Iterators.reverse(eachindex(state.actionqueue))
            if state.actionqueue[i].id == :p1; popat!(state.actionqueue,i); end
        end

        push!(state.animqueue,BattleAnimation(
            :p1,120,state[1].name*game.str[1][16],bfaint!,1
        ))

        state[1].pkmn.status = HSfainted
        fs!(state,1,true)

        F = true
    end
    
    if state[2].pkmn.stats.hp == 0
        for i in Iterators.reverse(eachindex(state.actionqueue))
            if state.actionqueue[i].id == :p2; popat!(state.actionqueue,i); end
        end

        push!(state.animqueue,BattleAnimation(
            :p2,120,state[2].name*game.str[1][16],bfaint!,2
        ))

        push!(state.animqueue,BattleAnimation(
            :p1,60,state[1].name*game.str[1][17]*
            string(calcXpDrop1(state,state[1],state[2]))*game.str[1][18],
            banimEmpty!,1
        ))

        state[2].pkmn.stats.hp = -1
        state[2].pkmn.status = HSfainted

        if state[1].pkmn.stats.level < 0x64
            queueCheckXp!(game,state)
        end

        F = true
    end

    if state.caught1
        empty!(state.actionqueue)

        push!(state.animqueue,BattleAnimation(
            :p1,60,state[1].name*game.str[1][17]*
                string(calcXpDrop1(state,state[1],state[2]))*game.str[1][18],
            banimEmpty!,1
        ))

        if state[1].pkmn.stats.level < 0x64
            queueCheckXp!(game,state)
        end

        if game.p.pokemon.idx < 6
            push!(state.animqueue,BattleAnimation(
                :p1,60,state[2].name*game.str[1][43],
                banimEmpty!,1
            ))
        else
            push!(state.animqueue,BattleAnimation(
                :p1,60,state[2].name*game.str[1][44],
                banimEmpty!,1
            ))
        end

        state.caught1 = false
        state.caught2 = true

        addPokemon!(game,state[2].pkmn)

        F = true
    end

    return F
end

function queueSetupActions!(game::GameState,state::BattleState)
    empty!(state.actionqueue)

    push!(state.actionqueue,BattleAction(
        :p1,getCommandPriority(state,1),
        state[1].pkmn.stats.rv[6]*getBuffMultiplier(state[1].buffs[5]),1,2
    ))

    push!(state.actionqueue,BattleAction(
        :p2,getCommandPriority(state,2),
        state[2].pkmn.stats.rv[6]*getBuffMultiplier(state[2].buffs[5]),2,1
    ))

    sortPriority!(state.actionqueue,state.env.room.trick>0x00)

    if state[1].command isa CommandAttack
        state[1].attack = state[1].command.n
    else
        state[1].attack = 0
    end

    if state[2].command isa CommandAttack
        state[2].attack = state[2].command.n
    else
        state[2].attack = 0
    end

    return
end

function queueSetupAnimation!(game::GameState,state::BattleState)
    user = state.actionqueue[1].user
    target = state.actionqueue[1].target
    command  = state[user].command

    if command isa CommandAttack
        state[user].attack = command.n

        queueAttack!(
            game,state,
            state[user],
            state[target],
            target,
            user == 1 ? :p1 : :p2
        )
    elseif command isa CommandItem
        queueItem!(
            game,state,
            user,
            state[command.target],
            command.item,
            user == 1 ? :p1 : :p2
        )
    elseif command isa CommandSwitch
        queueSwitch!(
            game,state,
            user,
            command.n,
            user == 1 ? :p1 : :p2
        )
    elseif command isa CommandFlee
        queueFlee!(game,state,state[user])
    end

    popfirst!(game.battle.state.actionqueue)

    # queueStatusCond!(state)
    # queueWeather!(state)

    return
end





function queueAttack!(game::GameState,state::BattleState,
        attacker::PkmnBattle,defender::PkmnBattle,target::Int,id::Symbol)
    
    attacker.hit = getHit(state,attacker,defender)
    attacker.crit = getCrit(attacker,defender)
    attacker.eff = getEff(attacker,defender)

    attacker.lastattack = attacker.attack
    attack = attacker.attacks[attacker.attack]
    attack.atk.ap -= 1

    if attack.class == ACstat || attack.class == ACnone
        attacker.dmgd = 0
        defender.dmgt = 0
    else
        setDmgFactors!(state,attacker,defender)
        attacker.dmgd = calcDamage(attacker.factors)
        defender.dmgt = min(defender.pkmn.stats.hp,attacker.dmgd)
    end
    
    push!(state.animqueue,BattleAnimation(
        id,120,attacker.name*game.str[1][31]*
            game.data.attacknames[attacker.attacks[attacker.attack].atk.id]*game.str[1][33],
            banimEmpty!,0))

    if !attacker.hit
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][37],banimEmpty!,0))

        return
    elseif attacker.eff == 0
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][36],banimEmpty!,0))

        return
    end

    push!(state.animqueue,BattleAnimation(
        id,60,"",bnoAnim!,target))

    push!(state.animqueue,BattleAnimation(
        id,48,"",bhpAnim!,target))

    if attacker.crit
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][39],banimEmpty!,0))
    end

    if attacker.eff < 1
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][34],banimEmpty!,0))
    elseif attacker.eff > 1
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][35],banimEmpty!,0))
    end

    return
end

function queueWeather!(state::BattleState)
    if state.env.weather == 0x00
        return
    end

    push!(state.animqueue,BattleAnimation(
        :w,120,"Wetter",banimEmpty!,0))

    return
end

function queueStatusCond!(state::BattleState)
    if state.pkmn1.pkmn.status != HSnormal
        0
    end

    if state.pkmn2.pkmn.status != HSnormal
        0
    end

    return
end





function queueItem!(game::GameState,state::BattleState,
        user::Int,target::PkmnBattle,item::ItemType,id::Symbol)

    m = game.ctrl.input.menu.battlebags
    
    push!(state.animqueue,BattleAnimation(
        id,30,game.p.name*game.str[1][31]*
            game.str[2+m.bag][getSelectedItem(game,m)]*game.str[1][33],
        banimEmpty!,0))

    if item isa MedicineHealth
        queueMedicine!(game,state,user,target,item,id)
    elseif item isa Pokeball
        queueBall!(game,state,target,item,id)
    end

    return
end

function queueBall!(game::GameState,state::BattleState,target::PkmnBattle,
        ball::ItemType,id::Symbol)

    m = game.ctrl.input.menu.battlebags

    push!(state.animqueue,BattleAnimation(
        id,160,game.p.name*game.str[1][31]*
            game.str[2+m.bag][getSelectedItem(game,m)]*game.str[1][33],
        bthrowBall!,2))

    s = UInt8(target.pkmn.status)

    x = *(
        3*target.pkmn.stats.rv[1]-2*target.pkmn.stats.hp,
        100,    # catchrate FIX
        ball.catchrate,
        1+0.5*(0x01<=s<=0x03)+1*(0x04<=s<=0x05),
        1/(3*target.pkmn.stats.rv[1])
    )

    # println("x: ",x)

    x = min(x,255)

    y = trunc(UInt16,65535/sqrt(sqrt(255/x)))
    # println("y:  ",y)

    w = 0

    for _ in 1:4
        if y <= rand(UInt16)
            break
        end

        w += 1
        
        if w == 4
            break
        end

        push!(state.animqueue,BattleAnimation(
            id,60,"",bwiggleBall!,w
        ))
    end

    if w == 4
        push!(state.animqueue,BattleAnimation(
            id,60,game.str[1][41]*target.name*game.str[1][42],
            bcaughtBall!,w
        ))
    else
        push!(state.animqueue,BattleAnimation(
            id,60,game.str[1][40],
            bbreakBall!,w
        ))
    end

    # if success
    #     push!(state.animqueue,BattleAnimation(
    #         id,60*w,"",bcaught!,2
    #     ))
    # else
    #     push!(state.animqueue,BattleAnimation(
    #         id,60*w,"",bescape!,2
    #     ))
    # end

    return
end





function queueSwitch!(game::GameState,state::BattleState,user::Int,
        target::Int,id::Symbol)
    
    push!(state.animqueue,BattleAnimation(
        id,48,game.str[1][22]*state[1].name*game.str[1][23],
        bswitchOut!,user
    ))
    
    push!(state.animqueue,BattleAnimation(
        id,128,game.str[1][24]*pkmnName(game,game.p.pokemon[target])*".",
        bswitchIn!,user
    ))

    return
end





function queueFlee!(game::GameState,state::BattleState,user::PkmnBattle)
    if state.actionqueue[1].user == 1
        if user.command.success
            state.counters.flee = -1

            empty!(state.actionqueue)
            empty!(state.animqueue); game.n[:animbattle].c = 1

            push!(state.animqueue,BattleAnimation(
                :p1,120,game.str[1][19],banimEmpty!,0
            ))
        else
            state.counters.flee += 1

            push!(state.animqueue,BattleAnimation(
                :p1,120,game.str[1][20],banimEmpty!,0
            ))
        end
    else
        state.counters.flee = -1

        empty!(state.actionqueue)
        empty!(state.animqueue); game.n[:animbattle].c = 1

        push!(state.animqueue,BattleAnimation(
            :p2,120,game.str[1][25],banimEmpty!,0
        ))
    end

    return
end





function checkFlee(state::BattleState)::Bool
    if !state.iswild || state[1].secstatus.escapeblock
        return false
    end

    return true
end

function queueCheckXp!(game::GameState,state::BattleState)
    xp.levelups = 0

    xp = state[1].pkmn.stats.xp; level = state[1].pkmn.stats.level
    xp.gain = calcXpGain(game,state[1],state[2])

    while xp.current+xp.gain > xpFormulas(xp.type,level+xp.levelups+1)
        xp.levelups += 1
    end

    xp.current += xpgain
    addEV!(state[1].pkmn,state[2].pkmn.id)
    
    if xp.levelups == 0
        push!(state.animqueue,BattleAnimation(
            :p1,60,"",bxpAnim!,1
        ))
    else
        push!(state.animqueue,BattleAnimation(
            :p1,60,"",bxpAnimLvUp!,1
        ))
        
        push!(state.animqueue,BattleAnimation(
            :p1,120,state[1].name*game.str[1][26]*string(level+xp.levelups)*"!",banimEmpty!,1
        ))

        push!(state.animqueue,BattleAnimation(
            :p1,60,"",bxpAnim!,1,
        ))
    end

    return
end
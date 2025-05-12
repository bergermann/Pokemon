

function queueSetupActions!(game::GameState,state::BattleStateWild)
    for i in 1:state.actionqueue.idx
        pop!(state.actionqueue)
    end

    push!(state.actionqueue,BattleAction(
        :p1,getCommandPriority(state,1),
        state[1].pkmn.stats.rv[6]*getBuffMultiplier(state[1].buffs[5]),1,2
    ))

    push!(state.actionqueue,BattleAction(
        :p2,getCommandPriority(state,2),
        state[2].pkmn.stats.rv[6]*getBuffMultiplier(state[2].buffs[5]),2,1
    ))

    sortPriority!(state.actionqueue,state.env.room.trick)

    if state[1].command isa CommandAttack
        state[1].attack = state[1].pkmn.attacks[state[1].command.n]
    else
        state[1].attack = Attack()
    end

    if state[2].command isa CommandAttack
        state[2].attack = state[2].pkmn.attacks[state[2].command.n]
    else
        state[2].attack = Attack()
    end

    return
end

function queueSetupAnimation!(game::GameState,state::BattleStateWild)
    command  = state[state.actionqueue[1].user].command
    
    if command isa CommandAttack
        queueAttack!(
            game,state,
            state[state.actionqueue[1].user],
            state[state.actionqueue[1].target],
            state.actionqueue[1].target,
            state.actionqueue[1].user == 1 ? :p1 : :p2
        )
    elseif command isa CommandItem
        queueItem!(
            game,state,
            state.actionqueue[1].user,
            state[command.target],
            command.item,
            state.actionqueue[1].user == 1 ? :p1 : :p2
        )
    elseif command isa CommandSwitch
        queueSwitch!(
            game,state,
            state.actionqueue[1].user,
            command.n,
            state.actionqueue[1].user == 1 ? :p1 : :p2
        )
    elseif command isa CommandFlee
        queueFlee!(game,state,state[state.actionqueue[1].user])
    end

    queueStatusCond!(state)
    queueWeather!(state)

    return
end





function queueAttack!(game::GameState,state::BattleState,
        attacker::PkmnBattle,defender::PkmnBattle,target::Int,id::Symbol)
    
    attacker.hit = getHit(state,attacker,defender)
    attacker.crit = getCrit(attacker,defender)
    attacker.eff = getEff(attacker,defender)

    setDmgFactors!(state,attacker,defender)
    attacker.dmgd = calcDamage(attacker.factors)
    defender.dmgt = min(defender.pkmn.stats.hp,attacker.dmgd)
    
    push!(state.animqueue,BattleAnimation(
        id,120,getPkmnName(game,attacker.pkmn)*game.str[1][31]*
            attacker.attack.name*game.str[1][33],banimEmpty!,0
    ))

    if !attacker.hit
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][37],banimEmpty!,0
        ))

        return
    elseif attacker.eff == 0
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][36],banimEmpty!,0
        ))

        return
    end


    push!(state.animqueue,BattleAnimation(
        id,60,"",bnoAnim!,target
    ))

    push!(state.animqueue,BattleAnimation(
        id,48,"",bhpAnim!,target
    ))

    if attacker.crit
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][39],banimEmpty!,0
        ))
    end

    if attacker.eff < 1
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][35],banimEmpty!,0
        ))
    elseif attacker.eff > 1
        push!(state.animqueue,BattleAnimation(
            id,120,game.str[1][34],banimEmpty!,0
        ))
    end

    return
end

function queueWeather!(state::BattleState)
    if state.env.weather == 0x00
        return
    end

    push!(state.animqueue,BattleAnimation(
        :w,120,"Wetter",banimEmpty!,0
    ))

    return
end

function queueStatusCond!(state::BattleState)
    if state.pkmn1.pkmn.status != 0x00
        0
    end

    if state.pkmn2.pkmn.status != 0x00
        0
    end

    return
end





function queueItem!(game::GameState,state::BattleState,
        user::Int,target::PkmnBattle,item::ItemType,id::Symbol)
    
    push!(state.animqueue,BattleAnimation(
        id,30,game.p.name*game.str[1][31]*
            game.str[3][getSelectedItem(game,game.ctrl.input.menu.battlebags)]*game.str[1][33],
        banimEmpty!,0
    ))

    if item isa MedicineHealth
        queueMedicine!(game,state,user,target,item,id)
    elseif item isa Pokeball
        queueBall!(game,state,target,item,id)
    end

    return
end

function queueBall!(game::GameState,state::BattleState,target::PkmnBattle,
        ball::ItemType,id::Symbol)

    push!(state.animqueue,BattleAnimation(
        id,160,game.p.name*game.str[1][31]*
            game.str[3][getSelectedItem(game,game.ctrl.input.menu.battlebags)]*game.str[1][33],
        bthrowBall!,2
    ))

    x = *(
        3*target.pkmn.stats.rv[1]-2*target.pkmn.stats.hp,
        100,    # catchrate FIX
        ball.catchrate,
        1+0.5*in(target.pkmn.status,[0x01,0x02,0x03])
            +1*in(target.pkmn.status,[0x04,0x05]),
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
            id,60,game.str[1][41]*getPkmnName(game,target.pkmn)*game.str[1][42],
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





function queueSwitch!(game::GameState,state::BattleStateWild,user::Int,
        target::Int,id::Symbol)
    
    push!(state.animqueue,BattleAnimation(
        id,60,game.str[1][22]*getPkmnName(game,state[1].pkmn)*game.str[1][23],
        bswitchOut!,user
    ))
    
    push!(state.animqueue,BattleAnimation(
        id,60,game.str[1][24]*getPkmnName(game,game.p.pokemon[target])*".",
        bswitchIn!,user
    ))

    return
end





function queueFlee!(game::GameState,state::BattleState,user::PkmnBattle)
    if state.actionqueue[1].user == 1
        if user.command.success
            state.stage = 250

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
        state.stage = 250

        push!(state.animqueue,BattleAnimation(
            :p2,120,game.str[1][25],banimEmpty!,0
        ))
    end

    return
end





function queueCheckStatus!(game::GameState,state::BattleStateWild)::Bool
    F = false

    if state[1].pkmn.stats.hp == 0
        F = false

        for i in eachindex(findall(x->x.id==:p1,
                state.actionqueue[1:state.actionqueue.idx]))
            popat!(state.actionqueue,:p1)
        end

        push!(state.animqueue,BattleAnimation(
            :p1,30,state[1].name*game.str[1][16],bfaint!,1
        ))

        state[1].pkmn.stats.hp = -1

        F = true
    end

    if state[2].pkmn.stats.hp == 0
        F = false

        for i in eachindex(findall(x->x.id==:p2,
                state.actionqueue[1:state.actionqueue.idx]))
            popat!(state.actionqueue,:p2)
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

        if state[1].pkmn.stats.level < 0x64
            queueCheckXp!(game,state)
        end

        state.stage = 251

        F = true
    end

    if state.caught
        F = false

        for i in eachindex(findall(x->x.id==:p2,
                state.actionqueue[1:state.actionqueue.idx]))
            popat!(state.actionqueue,:p2)
        end

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

        state.caught = false

        addPokemon!(game,state[2].pkmn)

        state.stage = 252

        F = true
    end

    return F
end

function checkFlee(state::BattleStateWild)::Bool
    if state.pkmn1.secstatus.escapeblock
        return false
    end

    return true
end

function queueCheckXp!(game::GameState,state::BattleState)
    levelups = 0

    xpdrop = Int(calcXpDrop1(state,state[1],state[2]))

    while state[1].pkmn.stats.xp+xpdrop > 
            xpFormulas(state[1].pkmn.stats.level+levelups+1,state[1].pkmn.xptype)
        levelups += 1
    end

    state[1].pkmn.stats.xp += xpdrop
    
    if levelups == 0
        push!(state.animqueue,BattleAnimation(
            :p1,60,"",bxpAnim!,Int(xpdrop)
        ))
    else
        push!(state.animqueue,BattleAnimation(
            :p1,60,"",bxpAnimLvUp!,levelups
        ))
        
        push!(state.animqueue,BattleAnimation(
            :p1,120,
            state[1].name*game.str[1][26]*string(state[1].pkmn.stats.level+levelups)*"!",
            banimEmpty!,1
        ))

        push!(state.animqueue,BattleAnimation(
            :p1,60,"",
            bxpAnim!,
            state[1].pkmn.stats.xp-
                Int(xpFormulas(state[1].pkmn.stats.level+levelups,state[1].pkmn.xptype))
                
        ))
    end

    return
end
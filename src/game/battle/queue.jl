

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
        queueFlee!(state,state[state.actionqueue[1].user])
    end

    queueStatusCond!(state)
    queueWeather!(state)
end





function queueAttack!(game::GameState,state::BattleState,
        attacker::PkmnBattle,defender::PkmnBattle,target::Int,id::Symbol)
    
    attacker.hit = getHit(state,attacker,defender)
    attacker.crit = getCrit(attacker,defender)
    attacker.eff = getEff(attacker,defender)

    setDmgFactors!(state,attacker,defender)
    attacker.dmg = calcDamage(attacker.factors)

    # println("$id D: ",attacker.dmg)
    
    push!(state.animqueue,BattleAnimation(
        id,120,getPkmnName(game,attacker.pkmn)*" setzt\\$(attacker.attack.name) ein.",
        banimEmpty!,0
    ))

    if !attacker.hit
        push!(state.animqueue,BattleAnimation(
            id,120,"Die Attacke hat\\ihr Ziel verfehlt...",banimEmpty!,0
        ))

        return
    elseif attacker.eff == 0
        push!(state.animqueue,BattleAnimation(
            id,120,"Es hat keine Wirkung...",banimEmpty!,0
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
            id,120,"Ein Volltreffer!",banimEmpty!,0
        ))
    end

    if attacker.eff < 1
        push!(state.animqueue,BattleAnimation(
            id,120,"Das ist nicht sehr effektiv...",banimEmpty!,0
        ))
    elseif attacker.eff > 1
        push!(state.animqueue,BattleAnimation(
            id,120,"Das ist sehr effektiv!",banimEmpty!,0
        ))
    end
end

function queueWeather!(state::BattleState)
    if state.env.weather == 0x00
        return
    end

    push!(state.animqueue,BattleAnimation(
        :w,120,"Wetter",banimEmpty!,0
    ))
end

function queueStatusCond!(state::BattleState)
    if state.pkmn1.pkmn.status != 0x00
        0
    end

    if state.pkmn2.pkmn.status != 0x00
        0
    end
end





function queueItem!(game::GameState,state::BattleState,
        user::Int,target::PkmnBattle,item::ItemType,id::Symbol)
    
    push!(state.animqueue,BattleAnimation(
        id,30,"$(game.trainer.name) setzt\\"*
            "$(game.str[2][getInvSlotID(game,game.input.battlebags)]) ein.",
        banimEmpty!,0
    ))

    if item isa MedicineHealth
        queueMedicine!(game,state,user,target,item,id)
    elseif item isa Pokeball
        queueBall!(game,state,target,item,id)
    end
end

function queueBall!(game::GameState,state::BattleState,target::PkmnBattle,
        ball::ItemType,id::Symbol)

    push!(state.animqueue,BattleAnimation(
        id,160,"$(game.trainer.name) setzt\\"*
            "$(game.str[2][getInvSlotID(game,game.input.battlebags)]) ein.",
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

    println("x: ",x)

    x = min(x,255)

    y = trunc(UInt16,65535/sqrt(sqrt(255/x)))
    println("y:  ",y)

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
            id,60,"Toll! $(getPkmnName(game,target.pkmn)) wurde gefangen.",
            bcaughtBall!,w
        ))
    else
        push!(state.animqueue,BattleAnimation(
            id,60,"Mist! Das wilde Pokémon hat sich befreit.",
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
end





function queueSwitch!(game::GameState,state::BattleStateWild,user::Int,
        target::Int,id::Symbol)
    
    push!(state.animqueue,BattleAnimation(
        id,60,"Genug, $(getPkmnName(game,state[1].pkmn)).\\Komm zurück!",
        bswitchOut!,user
    ))
    
    push!(state.animqueue,BattleAnimation(
        id,60,"Los, $(getPkmnName(game,game.trainer.pokemon[target])).",
        bswitchIn!,user
    ))
end





function queueFlee!(state::BattleState,user::PkmnBattle)
    if state.actionqueue[1].user == 1
        if user.command.success
            state.stage = 250

            push!(state.animqueue,BattleAnimation(
                :p1,120,"Du bist entkommen!",banimEmpty!,0
            ))
        else
            state.counters.flee += 1

            push!(state.animqueue,BattleAnimation(
                :p1,120,"Flucht gescheitert!",banimEmpty!,0
            ))
        end
    else
        state.stage = 250

        push!(state.animqueue,BattleAnimation(
            :p2,120,"Der Gegner ist geflohen!",banimEmpty!,0
        ))
    end
end





function queueCheckStatus!(game::GameState,state::BattleStateWild)
    F = false

    if state[1].pkmn.stats.hp == 0
        F = false

        for i in eachindex(findall(x->x.id==:p1,
                state.actionqueue[1:state.actionqueue.idx]))
            popat!(state.actionqueue,:p1)
        end

        push!(state.animqueue,BattleAnimation(
            :p1,30,"$(state[1].name) wurde besiegt.",bfaint!,1
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
            :p2,120,"$(state[2].name) wurde besiegt.",bfaint!,2
        ))

        push!(state.animqueue,BattleAnimation(
            :p1,60,"$(state[1].name) erhält $(calcXpDrop1(state,state[1],state[2])) E.-Punkte.",
            banimEmpty!,1
        ))

        state[2].pkmn.stats.hp = -1

        if state[1].pkmn.stats.level < 0x64
            queueCheckXp!(state)
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
            :p1,60,"$(state[1].name) erhält $(calcXpDrop1(state,state[1],state[2])) E.-Punkte.",
            banimEmpty!,1
        ))

        if state[1].pkmn.stats.level < 0x64
            queueCheckXp!(state)
        end

        if game.trainer.pokemon.idx < 6
            push!(state.animqueue,BattleAnimation(
                :p1,60,"$(state[2].name) wurde dem Team\\hinzugefügt.",
                banimEmpty!,1
            ))
        else
            push!(state.animqueue,BattleAnimation(
                :p1,60,"$(state[2].name) wurde auf den PC\\übertragen.",
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

function checkFlee(state::BattleStateWild)
    if state.pkmn1.secstatus.escapeblock
        return false
    end

    return true
end

function queueCheckXp!(state::BattleState)
    levelups = 0

    xpdrop = Int(calcXpDrop1(state,state[1],state[2]))

    while state[1].pkmn.stats.xp+xpdrop > 
            xpFormulas(state[1].pkmn.stats.level+levelups+1,state[1].pkmn.xptype)
        levelups += 1
    end

    state[1].pkmn.stats.xp += xpdrop
    
    if levelups == 0
        push!(state.animqueue,BattleAnimation(
            :p1,60,"",bxpAnim!,-Int(xpdrop)
        ))
    else
        push!(state.animqueue,BattleAnimation(
            :p1,60,"",bxpAnimLvUp!,levelups
        ))
        
        push!(state.animqueue,BattleAnimation(
            :p1,120,"$(state[1].name) erreicht Lv. $(state[1].pkmn.stats.level+levelups)!",
            banimEmpty!,1
        ))

        push!(state.animqueue,BattleAnimation(
            :p1,60,"",  # "$(state[1].name) erreicht Lv. $(state[1].pkmn.stats.level+levelups)!",
            bxpAnim!,
            Int(xpFormulas(state[1].pkmn.stats.level+levelups,state[1].pkmn.xptype))-
                state[1].pkmn.stats.xp
        ))
    end
end
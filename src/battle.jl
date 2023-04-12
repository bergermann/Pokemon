#battle manager stuff

function initBattleWild!(game::GameState)
    stateInitBattle!(game)

    pb1 = PkmnBattle(activePkmn(game),getPkmnName(game,activePkmn(game)))
    pb2 = PkmnBattle(generatePkmn(game,rand(0x0001:0x0097),rand(0x01:0x0a)))
    pb2.name = getPkmnName(game,pb2.pkmn)
    pb2.xpdrop = UInt32(max(1,rand(UInt8)))    #game.pkmndata.base[pb2.pkmn.id,x]

    # println(pb1.pkmn.stats.rv[6])
    # println(pb2.pkmn.stats.rv[6])

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
end

function initBattleWild!(game::GameState,ids::Vector{UInt16},levels::Vector{UInt8})
    stateInitBattle!(game)

    pb1 = PkmnBattle(activePkmn(game),getPkmnName(game,activePkmn(game)))
    pb2 = PkmnBattle(generatePkmn(game,rand(ids),rand(levels)))
    pb2.name = getPkmnName(game,pb2.pkmn)

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
end



#damage calculation

function floorProd(t::Type,args...)
    x = t(1)

    for arg in args
        x = floor(t,x*arg)
    end

    return x
end

function setDmgFactors!(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    attacker.factors.LVL = attacker.pkmn.stats.level

    attacker.factors.BP = attacker.attack.power
    attacker.factors.RH = 1+0.5*attacker.secstatus.righthand
    attacker.factors.CH = 1+1*attacker.secstatus.charge
    attacker.factors.IF = itemFactorAttacker(attacker)
    attacker.factors.MW = 1
        -0.5*state.env.wet*(attacker.attack.type==0x03)
        -0.5*state.env.mud*(attacker.attack.type==0x0c)
    attacker.factors.AA = abilityFactorAttacker(attacker)
    attacker.factors.AD = abilityFactorDefender(defender)
    attacker.factors.BD = calcBaseDamage(attacker.factors)

    attacker.factors.ATK = attackFactor(attacker)
    attacker.factors.DEF = defenseFactor(attacker,defender)*
        (1+0.5*(state.env.weather==0x03)*(attacker.attack.class==2))
    attacker.factors.CRIT = 1+0.5*attacker.crit
    attacker.factors.EFF = attacker.eff
    attacker.factors.STAB = 1+0.5*(attacker.attack.type in attacker.pkmn.type)

    attacker.factors.RAND = 100-rand(0:15)

    attacker.factors.BRT = 1-0.5*(attacker.pkmn.status==0x01)*
        (attacker.attack.class==0x01)
    attacker.factors.RFSC = screenFactor(state,attacker,defender)
    attacker.factors.MULT = 1
    attacker.factors.WEATHER = factorWeather(state,attacker)
    attacker.factors.F1 = factorF1(attacker.factors)

    attacker.factors.LO = 1+0.3*(attacker.pkmn.item==0xff)
    attacker.factors.ME = 1+0.1*min(attacker.factors.MC,10)
    attacker.factors.ET = 1
    attacker.factors.F2 = factorF2(attacker.factors)

    attacker.factors.FF = 1-0.5*attacker.crit*
        (defender.pkmn.ability==0xff || defender.pkmn.ability==0xff)
    attacker.factors.EB = 1+0.2*(attacker.eff>1)*(attacker.pkmn.item==0xff)
    attacker.factors.UP = 1+1*(attacker.eff<1)*(attacker.pkmn.ability==0xff)
    attacker.factors.BF = 1
    attacker.factors.F3 = factorF3(attacker.factors)
end

function itemFactorAttacker(attacker::PkmnBattle)
    return 1
end

function abilityFactorAttacker(attacker::PkmnBattle)
    return 1
end

function abilityFactorDefender(defender::PkmnBattle)
    return 1
end

function calcBaseDamage(f::DmgFactors)
    return floorProd(UInt16,
        f.RH,
        f.BP,
        f.IF,
        f.CH,
        f.MW,
        f.AA,
        f.AD
    )
end

function attackFactor(attacker::PkmnBattle)
    if attacker.attack.class == 1
        return attacker.pkmn.stats.rv[2]*
            max(getBuffMultiplier(attacker.buffs[1]),attacker.crit)*
            abilityFactorAttack(attacker)*
            itemFactorAttack(attacker)
    else
        return attacker.pkmn.stats.rv[4]*
            getBuffMultiplier(attacker.buffs[3])*
            abilityFactorAttack(attacker)*
            itemFactorAttack(attacker)
    end
end

function abilityFactorAttack(attacker::PkmnBattle)
    return 1
end

function itemFactorAttack(attacker::PkmnBattle)
    return 1
end

function defenseFactor(attacker::PkmnBattle,defender::PkmnBattle)
    if attacker.attack.class == 1
        return defender.pkmn.stats.rv[2]*
            getBuffMultiplier(defender.buffs[1])*
            abilityFactorDefense(defender)*
            itemFactorDefense(defender)
    else
        return defender.pkmn.stats.rv[4]*
            getBuffMultiplier(defender.buffs[3])*
            abilityFactorDefense(defender)*
            itemFactorDefense(defender)
    end
end

function abilityFactorDefense(defender::PkmnBattle)
    return 1
end

function itemFactorDefense(defender::PkmnBattle)
    return 1
end

function screenFactor(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    if typeof(state) == BattleStateWild
        return 1-0.5*!attacker.crit*
            (attacker.attack.class==1 ? defender.reflect : defender.screen)
    elseif typeof(state) == BattleStateTrainerDouble
        return 1-1/3*!attacker.crit*
            (attacker.attack.class==1 ? defender.reflect : defender.screen)
    end
end

function factorWeather(state::BattleState,attacker::PkmnBattle)
    return 1 - 
        0.5*(attacker.attack.type==0x03 && state.env.weather==0x02) -
        0.5*(attacker.attack.type==0x04 && state.env.weather==0x01) +
        0.5*(attacker.attack.type==0x03 && state.env.weather==0x01) +
        0.5*(attacker.attack.type==0x04 && state.env.weather==0x02)
end

function factorF1(f::DmgFactors)
    return *(
        f.BRT,
        f.RFSC,
        f.MULT,
        f.WEATHER,
        f.FC
    )
end

function factorF2(f::DmgFactors)
    return *(
        f.LO,
        f.ME,
        f.ET
    )
end

function factorF3(f::DmgFactors)
    return *(
        f.FF,
        f.EB,
        f.UP,
        f.BF
    )
end

function calcDamage(f::DmgFactors)
    return floorProd(UInt16,
        floorProd(UInt16,
            floor(UInt16,f.LVL*2/5+2),
            f.BD,
            f.ATK,
            1/(50*f.DEF),
            f.F1
        )+2,
        f.CRIT,
        f.F2,
        f.RAND/100,
        f.STAB,
        f.EFF,
        f.F3
    )
end




# managing battlephase

function checkAttack!(game::GameState)
    if game.battle.state.pkmn1.pkmn.attacks[game.input.battle2menu.select+1].ap == 0
        return false
    end

    return true
end

function getPriority(state::BattleStateWild)
    p1 = state.pkmn1.pkmn.attacks[state.pkmn1.command.n].priority
    p2 = state.pkmn2.pkmn.attacks[state.pkmn2.command.n].priority

    if p1 != p2
        if !state.env.room.wonder
            return (p1 > p2 ? (1,2) : (2,1))
        else
            return (p1 < p2 ? (1,2) : (2,1))
        end
    end

    p1 = state.pkmn1.pkmn.stats.rv[6]
    p1 *= getBuffMultiplier(state.pkmn1.buffs[6])

    p2 = state.pkmn2.pkmn.stats.rv[6]
    p2 *= getBuffMultiplier(state.pkmn2.buffs[6])

    if !state.env.room.wonder
        return (p1 > p2 ? (1,2) : (2,1))
    else
        return (p1 < p2 ? (1,2) : (2,1))
    end
end

function getBuffMultiplier(level::Int8)::Rational{Int8}
    if level >= 0
        return (2+level)/2
    else 
        return 2/(2-level)
    end
end

function getAccuracyMultiplier(attacker::PkmnBattle,defender::PkmnBattle)::Rational{Int8}
    level = attacker.buffs[7]-defender.buffs[8]

    if level >= 0
        return (3+level)/3
    else 
        return 3/(3-level)
    end
end

function getAccuracyFactor(state::BattleState,attacker::PkmnBattle,
        defender::PkmnBattle)::Rational{UInt8}
    return 0x01//0x01
end

function getHit(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    return rand(1:100) < attacker.attack.accuracy*
        getAccuracyFactor(state,attacker,defender)*
        getAccuracyMultiplier(attacker,defender)
end

function getEff(attacker::PkmnBattle,defender::PkmnBattle)
    return typetable[attacker.attack.type,defender.pkmn.type[1]]*
        (defender.pkmn.type[2]!=0x00 ?
            typetable[attacker.attack.type,defender.pkmn.type[2]] : 0x01//0x01)
end

function getCrit(attacker::PkmnBattle,defender::PkmnBattle)
    return rand() < (1/16,1/8,1/4,1/3,1/2)[clamp(
        attacker.attack.critrate+attacker.buffs[8],1,5)]
end

function getCommandPriority(state::BattleState,target::Int)
    if typeof(state[target].command) == CommandAttack
        return state[target].pkmn.attacks[state[target].command.n].priority
    else
        return 6
    end
end

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

    if typeof(state[1].command) == CommandAttack
        state[1].attack = state[1].pkmn.attacks[state[1].command.n]
    else
        state[1].attack = Attack()
    end

    if typeof(state[2].command) == CommandAttack
        state[2].attack = state[2].pkmn.attacks[state[2].command.n]
    else
        state[2].attack = Attack()
    end
end

function queueSetupAnimation!(game::GameState,state::BattleStateWild)
    command  = state[state.actionqueue[1].user].command

    if typeof(command) == CommandAttack
        queueAttack!(
            game,state,state[state.actionqueue[1].user],
            state[state.actionqueue[1].target],state.actionqueue[1].target,
            state.actionqueue[1].user == 1 ? :p1 : :p2
        )
    elseif typeof(command) == CommandItem
        queueItem!(state)
    elseif typeof(command) == CommandSwitch
        queueSwitch!(state)
    else typeof(command) == CommandFlee
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

function queueItem!(state::BattleState)
    0
end

function queueSwitch!(state::BattleState)
    0
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

function queueCheckStatus!(state::BattleStateWild)
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
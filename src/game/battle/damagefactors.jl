
#damage calculation

function floorProd(t::Type,args...)
    x = t(1)

    for arg in args
        x = floor(t,x*arg)
    end

    return x
end

function setDmgFactors!(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    attack = attacker.attacks[attacker.attack]
    
    attacker.factors.LVL = attacker.pkmn.stats.level

    attacker.factors.BP = attack.power
    attacker.factors.RH = 1+0.5*attacker.secstatus.righthand
    attacker.factors.CH = 1+1*attacker.secstatus.charge
    attacker.factors.IF = itemFactorAttacker(attacker)
    attacker.factors.MW = 1
        -0.5*state.env.wet*(attack.type==T_FIRE)
        -0.5*state.env.mud*(attack.type==T_ELECTRIC)
    attacker.factors.AA = abilityFactorAttacker(attacker)
    attacker.factors.AD = abilityFactorDefender(defender)
    attacker.factors.BD = calcBaseDamage(attacker.factors)

    attacker.factors.ATK = attackFactor(state,attacker)
    attacker.factors.DEF = defenseFactor(state,attacker,defender)
    attacker.factors.CRIT = 1+0.5*attacker.crit
    attacker.factors.EFF = attacker.eff
    attacker.factors.STAB = 1+0.5*hastype(attacker,attack.type)

    attacker.factors.RAND = 100-rand(0:15)

    attacker.factors.BRT = 1-0.5*(attacker.pkmn.status==HS_BURN)* (attack.class==AC_PHYS)
    attacker.factors.RFSC = screenFactor(state,attacker,defender)
    attacker.factors.MULT = 1
    attacker.factors.WEATHER = factorWeather(state,attacker)
    attacker.factors.F1 = factorF1(attacker.factors)

    attacker.factors.LO = 1+0.3*(attacker.pkmn.item==B_LIFEORB)
    attacker.factors.ME = 1+0.1*min(attacker.factors.MC,10)
    attacker.factors.ET = 1
    attacker.factors.F2 = factorF2(attacker.factors)

    attacker.factors.FF = 1-0.5*(attacker.eff>1)*
        (defender.pkmn.ability==A_SOLIDROCK || defender.pkmn.ability==A_FILTER)
    attacker.factors.EB = 1+0.2*(attacker.eff>1)*(attacker.pkmn.item==B_EXBELT)
    attacker.factors.UP = 1+1*(attacker.eff<1)*(attacker.pkmn.ability==A_TINTEDLENS)
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

function attackFactor(state::BattleState,attacker::PkmnBattle)
    if attacker.attacks[attacker.attack].class == AC_PHYS
        return attacker.pkmn.stats.rv[2]*
            max(getBuffMultiplier(attacker.buffs[1]),attacker.crit)*
            abilityFactorAttack(attacker)*
            itemFactorAttack(attacker)
    elseif attacker.attacks[attacker.attack].class == AC_SPEC
        return attacker.pkmn.stats.rv[4]*
            getBuffMultiplier(attacker.buffs[3])*
            abilityFactorAttack(attacker)*
            itemFactorAttack(attacker)
    else
        return 0
    end
end

function abilityFactorAttack(attacker::PkmnBattle)
    return 1
end

function itemFactorAttack(attacker::PkmnBattle)
    return 1
end

function defenseFactor(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    if attacker.attacks[attacker.attack].class == AC_PHYS
        return defender.pkmn.stats.rv[2]*
            getBuffMultiplier(defender.buffs[1])*
            abilityFactorDefense(defender)*
            itemFactorDefense(defender)*
            (1+0.5*(state.env.weather==W_SNOW)*hastype(defender,T_ICE))
    elseif attacker.attacks[attacker.attack].class == AC_SPEC
        return defender.pkmn.stats.rv[4]*
            getBuffMultiplier(defender.buffs[3])*
            abilityFactorDefense(defender)*
            itemFactorDefense(defender)*
            (1+0.5*(state.env.weather==W_SAND)*hastype(defender,T_ROCK))
    else
        return 0
    end
end

function abilityFactorDefense(defender::PkmnBattle)
    return 1
end

function itemFactorDefense(defender::PkmnBattle)
    return 1
end

function screenFactor(state::BattleState,attacker::PkmnBattle,defender::PkmnBattle)
    if !state.isdouble
        return 1-0.5*!attacker.crit*(attacker.attacks[attacker.attack].class==AC_PHYS ?
            defender.reflect : defender.screen)
    else
        return 1-1/3*!attacker.crit*(attacker.attacks[attacker.attack].class==AC_PHYS ?
            defender.reflect : defender.screen)
    end
end

function factorWeather(state::BattleState,attacker::PkmnBattle)
    attack = attacker.attacks[attacker.attack]

    return 1 - 
        0.5*(attack.type==T_FIRE  && state.env.weather==W_RAIN)  -
        0.5*(attack.type==T_WATER && state.env.weather==W_SUNNY) +
        0.5*(attack.type==T_FIRE  && state.env.weather==W_SUNNY) +
        0.5*(attack.type==T_WATER && state.env.weather==W_RAIN)
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
            f.F1)+2,
            f.CRIT,
            f.F2,
            f.RAND/100,
            f.STAB,
            f.EFF,
            f.F3
        )
end



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


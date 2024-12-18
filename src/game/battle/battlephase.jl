

# managing battlephase

function checkAttack!(game::GameState)
    if game.battle.state.pkmn1.pkmn.attacks[game.ctrl.input.battle.s2+1].ap == 0
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
    if state[target].command isa CommandAttack
        return state[target].pkmn.attacks[state[target].command.n].priority
    else
        return 6
    end
end

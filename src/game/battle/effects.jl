

# function template(state::BattleState,target::Int,args::Tuple{})
    
#     return
# end

function changeStat!(state::BattleState,target::Int,(stat,level,chance)::Tuple{Int,Int,Float64})
    if rand() < chance
        state[target].buffs[stat] += level
    end

    clamp!(state[target].buffs,-6,6)

    return
end

function applyStatus!(state::BattleState,target::Int,(status,chance,overwrite)::Tuple{})
    if (state[target].pkmn.status == 0x00 || overwrite) && rand() < chance
        state[target].pkmn.status = status
    end
    
    return
end

function applySecStatus!(state::BattleState,target::Int,(status,chance)::Tuple{})
    if rand() < chance
        setfield!(state[target].secstatus,status,true)
    end
    
    return
end

function blockAttack!(state::BattleState,target::Int,(attack,)::Tuple{})
    state[target].secstatus.attackblock[attack] = true
    
    return
end
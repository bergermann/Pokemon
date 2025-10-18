#behavior algorithms for enemy pokemon

function battleChoiceOpp(state::BattleState,user::Int)
    if state.iswild
        return battleChoiceWild(state,user)
    else
        ai = state.trainer1.ai

        if ai < 999
            return battleChoiceTrainer1(state,user)
        elseif ai < 9999
            return battleChoiceTrainer2(state,user)
        else
            return battleChoiceTrainer3(state,user)
        end
    end
end

function battleChoiceWild(state::BattleState,user::Int)
    return CommandAttack(rand(0x01:UInt8(length(state[user].attacks))))
end

function battleChoiceTrainer1(state::BattleState,user::Int)
    return CommandAttack(rand(0x01:UInt8(length(state[user].attacks))))
end

function battleChoiceTrainer2(state::BattleState,user::Int)
    return CommandAttack(rand(0x01:UInt8(length(state[user].attacks))))
end

function battleChoiceTrainer3(state::BattleState,user::Int)
    return CommandAttack(rand(0x01:UInt8(length(state[user].attacks))))
end
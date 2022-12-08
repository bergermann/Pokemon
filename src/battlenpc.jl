#behavior algorithms for enemy pokemon

function battleChoiceWild(game::GameState)
    return rand(0x01:0x04)
end

function battleChoiceTrainer1(game::GameState)
    return rand(0x01:0x04)
end

function battleChoiceTrainer2(game::GameState)
    return rand(0x01:0x04)
end

function battleChoiceTrainer3(game::GameState)
    return rand(0x01:0x04)
end
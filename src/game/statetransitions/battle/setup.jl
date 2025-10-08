

function resetBattleCounters!(state::BattleState)
    state.counters.turn = 0x00
    state.counters.flee = 0x00

    return
end

function resetBattleEnvironment!(state::BattleState)
    state.env.weather = 0x00
    state.env.weatherc = 0x00

    state.env.mud = false
    state.env.wet = false

    state.env.enthaz1.spikes = 0x00
    state.env.enthaz1.toxspikes = 0x00
    state.env.enthaz1.rocks = false
    state.env.enthaz1.sticky = false

    state.env.enthaz2.spikes = 0x00
    state.env.enthaz2.toxspikes = 0x00
    state.env.enthaz2.rocks = false
    state.env.enthaz2.sticky = false

    state.env.room.trick = 0x00
    state.env.room.magic = 0x00
    state.env.room.wonder = 0x00

    return
end

function resetBattleState!(game::GameState)
    state = game.battle.state

    resetBattleCounters!(state)
    resetBattleEnvironment!(state)

    empty!(state.animqueue)
    empty!(state.actionqueue)

    state.forceswitch .= false

    state.caught1 = false
    state.caught2 = false

    return
end



function setBattleState!(game::GameState,weather::UInt8,pkmn::Pkmn)
    state = game.battle.state

    game.battle.teamperm = collect(1:6); activePkmn!(game)

    state.pkmn1 = PkmnBattle(game,game.p.pokemon[1])
    state.pkmn2 = PB0
    state.pkmn3 = PkmnBattle(game,pkmn)
    state.pkmn4 = PB0

    state.iswild = true
    state.isdouble = false

    state.trainer1 = T0
    state.trainer2 = T0

    state.env.weather = weather
    state.env.weatherc = 0xff*(weather!=0x00)

    return
end

function setBattleState!(game::GameState,weather::UInt8,trainer::Trainer)
    state = game.battle.state

    game.battle.teamperm = collect(1:6); activePkmn!(game)

    state.pkmn1 = PkmnBattle(game,game.p.pokemon[1])
    state.pkmn2 = PB0
    state.pkmn3 = PkmnBattle(game,trainer.pokemon[1])
    state.pkmn4 = PB0

    state.iswild = false
    state.isdouble = false

    state.trainer1 = trainer
    state.trainer2 = T0

    state.env.weather = weather
    state.env.weatherc = 0xff*(weather!=0x00)

    return
end

function setBattleState!(game::GameState,weather::UInt8,trainer1::Trainer,trainer2::Trainer)
    state = game.battle.state

    game.battle.teamperm = collect(1:6); activePkmn!(game,2)

    state.pkmn1 = PkmnBattle(game,game.p.pokemon[1])
    state.pkmn2 = PkmnBattle(game,game.p.pokemon[2])
    state.pkmn3 = PkmnBattle(game,trainer1.pokemon[1])
    state.pkmn4 = PkmnBattle(game,trainer2.pokemon[1])

    state.iswild = false
    state.isdouble = true

    state.trainer1 = trainer1
    state.trainer2 = trainer1

    state.env.weather = weather
    state.env.weatherc = 0xff*(weather!=0x00)

    return
end
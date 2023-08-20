#battle manager stuff

include("attackanimations.jl")
include("battlenpc.jl")
include("damagefactors.jl")
include("battlephase.jl")
include("queue.jl")



function initBattleWild!(game::GameState)
    stateInitBattle!(game)

    pb1 = PkmnBattle(activePkmn(game),getPkmnName(game,activePkmn(game)))
    pb2 = PkmnBattle(generatePkmn(game,rand(0x0001:0x0097),rand(0x01:0x0a)))
    pb2.name = getPkmnName(game,pb2.pkmn)
    pb2.xpdrop = UInt32(max(1,rand(UInt8)))    #game.pkmndata.base[pb2.pkmn.id,x]

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
end

function initBattleWild!(game::GameState,ids::Vector{UInt16},levels::Vector{UInt8})
    stateInitBattle!(game)

    pb1 = PkmnBattle(activePkmn(game),getPkmnName(game,activePkmn(game)))
    pb2 = PkmnBattle(generatePkmn(game,rand(ids),rand(levels)))
    pb2.name = getPkmnName(game,pb2.pkmn)

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),pb1,pb2)
end



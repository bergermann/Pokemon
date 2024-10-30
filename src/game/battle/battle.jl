#battle manager stuff

include("attackanimations.jl")
include("battlenpc.jl")
include("damagefactors.jl")
include("battlephase.jl")
include("queue.jl")



function initBattleWild!(game::GameState)
    stateInitBattle!(game)

    data = getArea(game); idx = sample(fweights(data[:,4]))
    lvl = UInt8(clamp(randN(data[idx,2],data[idx,3]),2,100))

    pb1 = PkmnBattle(game.p.pokemon[1],getPkmnName(game,activePkmn(game)))
    pb2 = PkmnBattle(generatePkmn(game,data[idx,1],lvl))
    pb2.name = getPkmnName(game,pb2.pkmn)
    pb2.xpdrop = UInt32(max(1,rand(UInt8)))   # game.pkmndata.base[pb2.pkmn.id,x]

    game.battle.state = BattleStateWild(BattleCounters(),0,BattleEnvironment(),
        pb1,pb2)

    return
end

function getArea(game::GameState)::Matrix{UInt16}
    p = game.ctrl.mpos
    c = game.ctrl.chunk

    for area in game.m.areas.data[1:game.m.areas.idx]
        if 16*(area.cx-c[2])+area.px <= p[2] <= 16*(area.cx-c[2])+area.px+area.dx &&
                16*(area.cy-c[1])+area.py <= p[1] <= 16*(area.cy-c[1])+area.py+area.dy

            @info "in area $area.id"

            return area.data
        end
    end

    @warn "no area found, deploying default rattata"

    return UInt16[19 3 1 1]
end

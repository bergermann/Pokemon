#battle manager stuff

include("battlenpc.jl")
include("damagefactors.jl")
include("battlephase.jl")
include("queue.jl")

function initBattleTrainer!(game::GameState)    
    setBattleState!(game,0x00,loadTrainer!(game))
    
    stateInitBattle!(game)

    return
end

function getTrainer(game::GameState)
    for i in eachindex(game.m.npchit)
        if game.m.npchit[i]; return i; end
    end

    throw(ErrorException("No valid trainer has been found after hit."))

    return 0
end

function loadTrainer!(game::GameState)
    id = game.m.npcs[getTrainer(game)].trainerid

    return deserialize("data/trainers/$id.td")
end




function initBattleWild!(game::GameState)
    data = findArea(game); idx = sample(fweights(data[:,4]))
    lvl = UInt8(clamp(randN(data[idx,2],data[idx,3])+5,2,100))
    
    setBattleState!(game,0x00,generatePkmn(game,data[idx,1],lvl))
    
    stateInitBattle!(game)

    return
end

function findArea(game::GameState)::Matrix{UInt16}
    p = game.ctrl.mpos
    c = game.ctrl.chunk

    for ar in game.m.areas.data[1:game.m.areas.idx]
        if 16*(ar.cx-c.x)+ar.px <= p.x <= 16*(ar.cx-c.x)+ar.px+ar.dx &&
                16*(ar.cy-c.y)+ar.py <= p.y <= 16*(ar.cy-c.y)+ar.py+ar.dy

            @info "Me when i'm in area $(ar.id)."

            return ar.data
        end
    end

    @warn "No area found, deploying default Rattata."

    return UInt16[19 3 1 1]
end



function loadBattleAttacks(game::GameState,pkmn::Pkmn)
    ad = game.data.attacks
    attacks = Attack[]

    for i in 1:min(length(pkmn.attacks),4)
        atk = pkmn.attacks[i]

        push!(attacks,Attack(
            atk,            # atk

            ad[atk.id,1],   # type
            ad[atk.id,2],   # class
            ad[atk.id,3],   # power
            ad[atk.id,4],   # accuracy
            1,              # priority
            1,              # critrate

            AttackEffect[]
        ))
    end

    return attacks
end
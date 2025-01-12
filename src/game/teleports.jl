
function findTeleport(game::GameState)
    p = game.ctrl.mpos
    c = game.ctrl.chunk

    for (i,tp) in enumerate(game.m.teleports[1:game.m.teleports.idx])
        if 16*(tp.cx-c[2])+tp.px <= p[2] <= 16*(tp.cx-c[2])+tp.px+tp.dx &&
                16*(tp.cy-c[1])+tp.py <= p[1] <= 16*(tp.cy-c[1])+tp.py+tp.dy

            @info "at teleport $(tp.id)"

            return i
        end
    end

    @warn "No teleport found."

    return 0
end

function teleport!(game::GameState)
    idx = findTeleport(game)
    if idx == 0; return; end

    tp = game.m.teleports[idx]

    lockInput!(game)

    createCC!(game,)

    return
end
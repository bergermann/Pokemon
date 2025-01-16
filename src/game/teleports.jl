
function findTeleport(game::GameState)
    p = game.ctrl.mpos
    c = game.ctrl.chunk

    for (i,tp) in enumerate(game.m.teleports[1:game.m.teleports.idx])
        if game.ctrl.fg==tp.fg &&
                16*(tp.cx-c[2])+tp.px <= p[2] <= 16*(tp.cx-c[2])+tp.px+tp.dx &&
                16*(tp.cy-c[1])+tp.py <= p[1] <= 16*(tp.cy-c[1])+tp.py+tp.dy

            @info "At teleport $(ID(tp.id))."

            return i
        end
    end

    @warn "No teleport found."

    return 0
end

function checkTeleport!(game::GameState)
    idx = findTeleport(game)
    if idx == 0; return; end

    tp = game.m.teleports[idx]

    display(tp)

    lockInput!(game)

    createCC!(game,:scenet,sceneTransition!,(16,8,
        F(teleport!,(tp,)),F(stateInitMapCtrls!)); active=true,n=1)

    return
end

function teleport!(game::GameState,tx::Int,ty::Int,tcx::Int,tcy::Int)
    game.ctrl.pos1 .= tx, ty
    game.ctrl.pos2 .= game.ctrl.pos1
    
    game.ctrl.chunk .= tcx, tcy
    
    setProjection!(game)

    display(game.im.s.sprites)
    killSprites!(game,:npcs_all,:objects)
    display(game.im.s.sprites)

    loadChunksAll!(game)
    display(game.im.s.sprites)
    
    return
end

teleport!(game::GameState,(tp,)::Tuple{Teleport}) = teleport!(game,tp.tx,tp.ty,tp.tcx,tp.tcy)
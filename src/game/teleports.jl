
function findTeleport(game::GameState)
    p = game.ctrl.mpos
    c = game.ctrl.chunk

    for (i,tp) in enumerate(game.m.teleports[1:game.m.teleports.idx])
        if game.ctrl.fg==tp.fg &&
                16*(tp.cx-c.x)+tp.px <= p.x <= 16*(tp.cx-c.x)+tp.px+tp.dx &&
                16*(tp.cy-c.y)+tp.py <= p.y <= 16*(tp.cy-c.y)+tp.py+tp.dy

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

function teleport!(game::GameState,tx::Int,ty::Int,tcx::Int,tcy::Int,dir::Int)
    game.ctrl.pos1 .= tx, ty
    game.ctrl.pos2 .= game.ctrl.pos1
    
    game.ctrl.chunk .= tcx, tcy
    turn!(game,dir)
    
    setProjection!(game)
    loadChunksAll!(game)
    setSpriteFrame!(game,:mc,1+3*(dir-1-2*(dir == 4)))

    game.flags.general[0xc8] = false
    
    return
end

teleport!(game::GameState,tx::Int,ty::Int,tcx::Int,tcy::Int) =
    teleport!(game,tx,ty,tcx,tcy,game.ctrl.dir)

teleport!(game::GameState,(tp,)::Tuple{Teleport}) = 
    teleport!(game,tp.tx,tp.ty,tp.tcx,tp.tcy)
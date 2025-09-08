
include("movement.jl")
include("hit.jl")

# NPC related stuff

# pattern directions: clockwise from starting direction
# patterns              # static
# 0 dont return         # none
# 1 return              # return
# 2 line                # line
# 3 angle               # angle
# 4 T                   # T rand
# 5 T clockwise         # T cw
# 6 T cclockwise        # T ccw
# 7 circ clockwise      # cw
# 8 circ cclockwise     # ccw
# 9 rand                # rand

# patterns              # dynamic
# 0 rand                # none
# 1 linear              # linear
# 2 angle               # angle
# 3 rectangle cw        # cw
# 4 rectangle ccw       # ccw



function manageNPCs!(game::GameState)
    for npc in game.m.npcs
        if npc.dynamic
            manageDynamicNPC!(game,npc)
        else
            manageStaticNPC!(game,npc)
        end
    end
    
    checkHit(game)

    return
end

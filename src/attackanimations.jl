
function banimEmpty!(game::GameState,target::Int)
    return
end

function bnoAnim!(game::GameState,target::Int)
    if target == 1
        createCC!(game,:dmg,btakeDamage!,(:pkmn1,:tag1,); active=true)
    else
        createCC!(game,:dmg,btakeDamage!,(:pkmn2,:tag2,); active=true)
    end
end

function bhpAnim!(game::GameState,target::Int)
    if target == 1
        createCC!(game,:hp,bhpAnim!,(2,1,:tag1,P(20,49)); active=true)
    else
        createCC!(game,:hp,bhpAnim!,(1,2,:tag2,P(20,40)); active=true)
    end
end

function bhpAnim!(game::GameState,user::Int,target::Int,tag::Symbol,pos::Position)
    p = game.battle.state[target].pkmn
    dmg = min(game.battle.state[user].dmg,p.stats.hp)

    b1 = getHealthBar(p,p.stats.hp)
    b2 = getHealthBar(p,p.stats.hp-dmg)

    drawHealthBarBattle!(game.im.sprites[tag].im,
        b1-trunc(Int,(b1-b2)*(game.n.c[:hp].c+1)/48),pos)
    

    if target == 1
        game.im.sprites[:tag1].im[25:32,60:76] .= 0xf8f8d6
        
        drawText!(game,game.im.sprites[:tag1].im,
            string(game.battle.state[1].pkmn.stats.hp-trunc(Int,dmg*(game.n.c[:hp].c+1)/48)),
            UInt(1),Position(22,66),0x424242,0xded6b5)
    end
    
    if game.n.c[:hp].c == 47
        game.battle.state[target].pkmn.stats.hp -= dmg

        if game.battle.state[target].pkmn.stats.hp < 0x0000   # fix
            error("HP got below 0? it fucked up.")
        end

        game.battle.state[user].dmg = 0

        killCC!(game,:hp)

        return
    end

    game.n.c[:hp].c += 1
end

function btakeDamage!(game::GameState,target::Symbol,tag::Symbol)    #length: 30
    if game.n.c[:dmg].c == 0
        game.im.sprites[target].active = false
        posAdd!(game.im.sprites[tag].pos,1,0)
    elseif game.n.c[:dmg].c == 22
        posAdd!(game.im.sprites[tag].pos,-1,0)
    elseif game.n.c[:dmg].c%4 == 0
       game.im.sprites[target].active = !game.im.sprites[target].active
       posAdd!(game.im.sprites[tag].pos,2,0)
    elseif game.n.c[:dmg].c%4 == 2
        posAdd!(game.im.sprites[tag].pos,-2,0)
    elseif game.n.c[:dmg].c == 23
        killCC!(game,:dmg)

        return
    end

    game.n.c[:dmg].c += 1
end

function bfaint!(game::GameState,target::Int)
    if target == 1
        createCC!(game,:faint,bfaint!,(:pkmn1,:tag1); active=true)
    else
        createCC!(game,:faint,bfaint!,(:pkmn2,:tag2); active=true)
    end
end

function bfaint!(game::GameState,target::Symbol,tag::Symbol)
    if 60 <= game.n.c[:faint].c <= 75
        posAdd!(game.im.sprites[target].pos,4,0)
    end

    if game.n.c[:faint].c == 75
        game.im.sprites[target].active = false
    elseif game.n.c[:faint].c == 121
        game.im.sprites[tag].active = false

        killCC!(game,:faint)

        return
    end

    game.n.c[:faint].c += 1
end

# function bxpAnim!(game::GameState,levelups::Int)
#     createCC!(game,:xp,bxpAnim!,
#         (
#             Int(calcXpDrop1(game.battle.state,game.battle.state[1],game.battle.state[2])),
#             xpFormulas(game.battle.state[1].pkmn.stats.level+1,game.battle.state[1].pkmn.xptype) - 
#             game.battle.state[1].pkmn.stats.xp,
#             levelups
#         ); active=true)
# end

# function bxpAnim!(game::GameState,xpgain::Int,xpnext::Int,levelups::Int)
#     p = game.battle.state.pkmn1.pkmn

#     d = 0

#     if levelups > 0
#         d = xpFormulas(
#             game.battle.state[1].pkmn.stats.level+levelups,
#             game.battle.state[1].pkmn.xptype
#         ) - xpFormulas(
#             game.battle.state[1].pkmn.stats.level,game.battle.state[1].pkmn.xptype
#         )
#     end

#     drawXpBar!(game,game.im.sprites[:tag1].im,
#         getXpBar(p,trunc(Int,min(xpgain-d,xpnext)*game.n.c[:xp].c/64)),P(36,33))

#     if game.n.c[:xp].c == 59
#         if xpgain < xpnext
#             p.stats.xp += UInt32(xpgain)
#         elseif xpgain >= xpnext
#             drawXpBar!(game,game.im.sprites[:tag1].im,0,P(36,33))
#         elseif levelups > 0
#             p.stats.xp += UInt32(xpgain)
#             p.stats.level += UInt8(levelups)
#         end

#         killCC!(game,:xp)

#         return
#     end

#     game.n.c[:xp].c += 1
# end

function bxpAnim!(game::GameState,xp::Int)
    createCC!(game,:xp,bxpAnimXp!,(
        xp,
        xpFormulas(game.battle.state.pkmn1.pkmn.stats.level+1,game.battle.state.pkmn1.pkmn.xptype)-
        (game.battle.state.pkmn1.pkmn.stats.xp-calcXpDrop1(game.battle.state,
            game.battle.state.pkmn1,game.battle.state.pkmn2)),
        xpFormulas(game.battle.state.pkmn1.pkmn.stats.level+1,game.battle.state.pkmn1.pkmn.xptype)-
        xpFormulas(game.battle.state.pkmn1.pkmn.stats.level,game.battle.state.pkmn1.pkmn.xptype)
    ); active=true)
end

function bxpAnimXp!(game::GameState,xp::Int,xpnext::Int,xplevel::Int)
    # p = game.battle.state.pkmn1.pkmn

    println("xpnext: ",xpnext,", xplevel: ",xplevel)

    val = trunc(Int,64*(1-(xpnext+xp)/xplevel))+
        trunc(Int,64*xp/xplevel*(1-game.n.c[:xp].c/120))

    println(val)

    drawXpBar!(game,game.im.sprites[:tag1].im,val,P(36,33))

    if game.n.c[:xp].c == 119
        killCC!(game,:xp)

        return
    end

    game.n.c[:xp].c += 1
end

function bxpAnimLvUp!(game::GameState,levelups::Int)
    createCC!(game,:xp,bxpAnimLevelUp!,(levelups,); active=true)
end

function bxpAnimLevelUp!(game::GameState,levelups::Int)
    p = game.battle.state.pkmn1.pkmn

    xpnext = xpFormulas(p.stats.level+1,p.xptype)-(p.stats.xp-calcXpDrop1(game.battle.state,
        game.battle.state.pkmn1,game.battle.state.pkmn2))
    xplevel = xpFormulas(p.stats.level+1,p.xptype)-xpFormulas(p.stats.level,p.xptype)

    drawXpBar!(game,game.im.sprites[:tag1].im,
        64+trunc(Int,64*xpnext/xplevel*(1-game.n.c[:xp].c/120)),P(36,33))

    println("value: ",64+trunc(Int,64*xpnext/xplevel*(1-game.n.c[:xp].c/120)))

    if game.n.c[:xp].c == 119
        p.stats.level += levelups

        game.im.sprites[:tag1].im[4:10,86:96] .= 0xffffff
        
        drawText!(game,game.im.sprites[:tag1].im,string(game.battle.state.pkmn1.pkmn.stats.level),
            UInt(1),Position(4,86),0x424242,0xded6b5)

        drawXpBar!(game,game.im.sprites[:tag1].im,0,P(36,33))

        killCC!(game,:xp)

        return
    end

    game.n.c[:xp].c += 1
end










function bmoveHorizontal!(game::GameState,distance::Int,speed::Int,
        target::Symbol,kill::Bool)
    if distance%speed != 0
        error("Distance needs to integer multiple of speed.")
    end

    posAdd!(game.im.sprites[target].pos,0,speed)
    
    game.n.c[:moveh].c += 1

    if game.n.c[:moveh].c == div(distance,speed)
        if kill
            killSprite!(game,target)
        end

        killCC!(game,:moveh)

        return
    end
end

function bmoveVertical!(game::GameState,distance::Int,speed::Int,
        target::Symbol,kill::Bool)
    if distance%speed != 0
        error("Distance needs to integer multiple of speed.")
    end

    posAdd!(game.im.sprites[target].pos,speed,0)
    
    game.n.c[:movew].c += 1

    if game.n.c[:movew].c == div(distance,speed)
        if kill
            killSprite!(game,target)
        end
        
        killCC!(game,:movew)

        return
    end
end

function bmoveLinear!(game::GameState,distanceh::Int,distancew::Int,
        speedh::Int,speedw::Int,target::Symbol)
    
    if distanceh%speedh != 0 || distancew%speedw != 0
        error("Distance needs to integer multiple of speed.")
    end

    posAdd!(game.im.sprites[target].pos,speedh,speedw)
    
    game.n.c[:movel].c += 1

    if game.n.c[:movel].c == div(distanceh,speedh) ||
            game.n.c[:movel].c == div(distancew,speedw)

        killCC!(game,:movel)

        return
    end
end

function bTackle!(game::GameState,target::Int)
    
end
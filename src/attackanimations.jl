
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
        createCC!(game,:hp,bhpAnim!,(2,1,:tag1,P(20,49)); active=true,n=1)
    else
        createCC!(game,:hp,bhpAnim!,(1,2,:tag2,P(20,40)); active=true,n=1)
    end
end

function bhpAnim!(game::GameState,user::Int,target::Int,tag::Symbol,pos::Position)
    p = game.battle.state[target].pkmn
    dmg = min(game.battle.state[user].dmg,p.stats.hp)

    b1 = getHealthBar(p,p.stats.hp)
    b2 = getHealthBar(p,p.stats.hp-dmg)

    drawHealthBar!(game.im.sprites[tag].im,
        b1-trunc(Int,(b1-b2)*game.n.c[:hp].c/48),pos)
    

    if target == 1
        game.im.sprites[:tag1].im[25:32,60:76] .= 0xf8f8d6
        
        drawText!(game,game.im.sprites[:tag1].im,
            string(game.battle.state[1].pkmn.stats.hp-trunc(Int,dmg*(game.n.c[:hp].c+1)/48)),
            UInt(1),Position(22,66),0x424242,0xded6b5)
    end
    
    if game.n.c[:hp].c == 48
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
    elseif game.n.c[:faint].c == 119
        game.im.sprites[tag].active = false

        killCC!(game,:faint)

        return
    end

    game.n.c[:faint].c += 1
end

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
    val = trunc(Int,64*(1-(xpnext+xp)/xplevel))+
        trunc(Int,64*xp/xplevel*(1-game.n.c[:xp].c/30))

    drawXpBar!(game,game.im.sprites[:tag1].im,val,P(36,33))

    if game.n.c[:xp].c == 30
        killCC!(game,:xp)

        return
    end

    game.n.c[:xp].c += 1
end

function bxpAnimLvUp!(game::GameState,levelups::Int)
    createCC!(game,:xp,bxpAnimLevelUp!,(
        levelups,
        xpFormulas(game.battle.state.pkmn1.pkmn.stats.level+1,game.battle.state.pkmn1.pkmn.xptype)-
        (game.battle.state.pkmn1.pkmn.stats.xp-
            calcXpDrop1(game.battle.state,game.battle.state.pkmn1,game.battle.state.pkmn2)),
        xpFormulas(game.battle.state.pkmn1.pkmn.stats.level+1,game.battle.state.pkmn1.pkmn.xptype)-
        xpFormulas(game.battle.state.pkmn1.pkmn.stats.level,game.battle.state.pkmn1.pkmn.xptype)
    ); active=true,n=1)
end

function bxpAnimLevelUp!(game::GameState,levelups::Int,xpnext::Int,xplevel::Int)
    if 1 <= game.n.c[:xp].c <= 30
        val = trunc(Int,64-64*xpnext/xplevel*(1-game.n.c[:xp].c/30))

        drawXpBar!(game,game.im.sprites[:tag1].im,val,P(36,33))
    elseif 30 < game.n.c[:xp].c <= 48
        scaleColorTransparent!(game.im.sprites[:tag1].im,0xf5eeee,0x20,UInt8(game.n.c[:xp].c-30))
    end
    
    if game.n.c[:xp].c == 48
        evdrop = rand(0x00:0x03,6)   # fix this
        diffhp = calcHp(game.battle.state.pkmn1.pkmn,UInt8(levelups),evdrop[1])-
            game.battle.state.pkmn1.pkmn.stats.rv[1]

        game.battle.state.pkmn1.pkmn.stats.level += levelups
        game.battle.state.pkmn1.pkmn.stats.hp += diffhp
        game.battle.state.pkmn1.pkmn.stats.ev += evdrop

        updateStats!(game.battle.state.pkmn1.pkmn)

        updateSprite!(game.im.sprites[:tag1])
        drawBattleTagOwn!(game,game.battle.state.pkmn1.pkmn,game.im.sprites[:tag1].im)

        killCC!(game,:xp)

        return
    end

    game.n.c[:xp].c += 1
end



function bthrowBall!(game::GameState)
    if game.n.c[:throwball].c <= 54
        game.im.sprites[:throwball].pos.w += 4
        game.im.sprites[:throwball].pos.h =
            trunc(Int,0.00343*(game.im.sprites[:ballcatch].pos.w-108)^2+44)
    elseif game.n.c[:throwball].c == 55
        game.im.sprites[:pkmn2].active = false
    elseif game.n.c[:throwball].c <= 55+30
        game.im.sprites[:throwball].pos.h -= 1
    end
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
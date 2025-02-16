
function banimEmpty!(game::GameState,target::Int)
    return
end

function bnoAnim!(game::GameState,target::Int)
    createCC!(game,:dmg,btakeDamage!,(target,); active=true)

    return
end

function btakeDamage!(game::GameState,(target,)::Tuple{Int})    #length: 30
    if game.n[:dmg].c == 0
        switchSprite!(game,blabels[target].pkmn)
        moveSpriteH!(game,blabels[target].tag,-1)
    elseif game.n[:dmg].c == 22
        moveSpriteH!(game,blabels[target].tag,1)
    elseif game.n[:dmg].c%4 == 0
        switchSprite!(game,blabels[target].pkmn)
        moveSpriteH!(game,blabels[target].tag,-2)
    elseif game.n[:dmg].c%4 == 2
        moveSpriteH!(game,blabels[target].tag,2)
    elseif game.n[:dmg].c == 23
        killCC!(game,:dmg)

        return
    end

    game.n[:dmg].c += 1

    return
end

function bhpAnim!(game::GameState,target::Int)
    createCC!(game,:hp,bhpAnim!,(target,); active=true,n=1)

    return
end

function bhpAnim!(game::GameState,(target,)::Tuple{Int})
    p = game.battle.state[target]

    b1 = getHealthBar(p.pkmn,p.pkmn.stats.hp)
    b2 = getHealthBar(p.pkmn,p.pkmn.stats.hp-p.dmgt)

    setHPBar!(game,mplabels[target].h,round(Int,b1+(b2-b1)*game.n[:hp].c/48),
        +69*(1-target)+56*(2-target))

    # if target == 1
    #     setText!(game,:health1,
    #         string(p.pkmn.stats.hp-
    #         trunc(Int,dmg*(game.n[:hp].c)/48)))
    # end
    
    if game.n[:hp].c == 48
        p.pkmn.stats.hp -= p.dmgt

        if p.pkmn.stats.hp < 0x0000   # fix
            error("HP got below 0? it fucked up.")
        end

        killCC!(game,:hp)

        return
    end

    game.n[:hp].c += 1

    return
end

function bfaint!(game::GameState,target::Int)
    createCC!(game,:faint,bfaint!,(target,); active=true)

    return
end

function bfaint!(game::GameState,(target,)::Tuple{Int})
    if 60 <= game.n[:faint].c <= 75
        moveSpriteH!(game,blabels[target].pkmn,4)
    end

    if game.n[:faint].c == 75
        deactivateSprite!(game,blabels[target].pkmn)
    elseif game.n[:faint].c == 119
        deactivateSprite!(game,blabels[target].tag)
        deactivateText!(game,blabels[target].name)
        deactivateText!(game,blabels[target].level)

        killCC!(game,:faint)

        return
    end

    game.n[:faint].c += 1

    return
end

function bxpAnim!(game::GameState,dx::Int)
    p = game.battle.state.pkmn1.pkmn
    xl = xpFormulas(p.stats.level,p.xptype)

    createCC!(game,:xp,bxpAnimXp!,(
            dx,
            p.stats.xp,
            Int(xl),
            xpFormulas(p.stats.level+1,p.xptype)-xl
        ); active=true,n=1)

    return
end

function bxpAnimXp!(game::GameState,(dx,x1,xl,xn)::Tuple{Int,Int,Int,Int})
    val = floor(Int,64*(x1-xl-dx*(1-game.n[:xp].c/30))/xn)
    setXPBar!(game,:xp,val,40)

    if game.n[:xp].c == 30
        killCC!(game,:xp)

        return
    end

    game.n[:xp].c += 1

    return
end

function bxpAnimLvUp!(game::GameState,levelups::Int)
    p = game.battle.state.pkmn1.pkmn

    createCC!(game,:xp,bxpAnimLevelUp!,(
            levelups,
            xpFormulas(p.stats.level+1,p.xptype)-
            (p.stats.xp-
                calcXpDrop1(game.battle.state,game.battle.state.pkmn1,
                    game.battle.state.pkmn2)),
            xpFormulas(p.stats.level+1,p.xptype)-
            xpFormulas(p.stats.level,p.xptype)
        ); active=true,n=1)

    return
end

function bxpAnimLevelUp!(game::GameState,(levelups,xpnext,xplevel)::Tuple{Int,Int,Int})
    if game.n[:xp].c <= 30
        val = trunc(Int,64-64*xpnext/xplevel*(1-game.n[:xp].c/30))
        setXPBar!(game,:xp,val,40)
    elseif game.n[:xp].c <= 46
        setSpriteFrame!(game,:xp,game.n[:xp].c-30)
    end
    
    if game.n[:xp].c == 46
        evdrop = rand(0x00:0x03,6)   # fix this
        diffhp = calcHp(game.battle.state.pkmn1.pkmn,UInt8(levelups),evdrop[1])-
            game.battle.state.pkmn1.pkmn.stats.rv[1]

        game.battle.state.pkmn1.pkmn.stats.level += levelups
        game.battle.state.pkmn1.pkmn.stats.hp += diffhp
        game.battle.state.pkmn1.pkmn.stats.ev += evdrop

        updateStats!(game.battle.state.pkmn1.pkmn)

        setXPBar!(game,:xp,0,40)
        setSpriteFrame!(game,:xp,1)

        setText!(game,:lvl1,string(game.battle.state.pkmn1.pkmn.stats.level))

        killCC!(game,:xp)

        return
    end

    game.n[:xp].c += 1

    return
end

function bthrowBall!(game::GameState,w::Int)
    createSprite!(game,:ball,:ballsb,game.battle.state[1].command.item.id,1,-106,-16,0,5;
        active=false)

    createCC!(game,:throwball,bthrowBall!,();
        active=true,n=1)

    return
end

function bthrowBall!(game::GameState,args::Tuple{})
    if game.n[:throwball].c <= 37+5
        moveSpriteW!(game,:ball,4)
        moveSpriteH!(game,:ball,
            trunc(Int,(game.im.sprites[4][:ball].pos.w-(135+16))^2/300+(21+24)),true)
    elseif game.n[:throwball].c == 60
        setSpriteFrame!(game,:ball,2)
    elseif game.n[:throwball].c == 70
        deactivateSprite!(game,:pkmn2)
    elseif game.n[:throwball].c == 90
        setSpriteFrame!(game,:ball,1)
    elseif 100 < game.n[:throwball].c <= 110
        moveSpriteH!(game,:ball,+3)
    elseif 110 < game.n[:throwball].c <= 120
        moveSpriteH!(game,:ball,-2)
    elseif 120 < game.n[:throwball].c <= 130
        moveSpriteH!(game,:ball,+2)
    elseif 130 < game.n[:throwball].c <= 140
        moveSpriteH!(game,:ball,-1)
    elseif 140 < game.n[:throwball].c <= 150
        moveSpriteH!(game,:ball,+1)
    elseif game.n[:throwball].c == 160
        killCC!(game,:throwball)

        return
    end

    game.n[:throwball].c += 1

    return
end

function bwiggleBall!(game::GameState,w::Int)
    createCC!(game,:wiggleball,bwiggleBall!,((w%2==0 ? Int8(1) : Int8(-1)),);
        active=true,n=1)

    return
end

function bwiggleBall!(game::GameState,dir::Int8)
    if game.n[:wiggleball].c <= 15
        if game.n[:wiggleball].c%5 == 0
            moveSpriteW!(game,:ball,+dir)
        end
    elseif game.n[:wiggleball].c <= 30
        if game.n[:wiggleball].c%5 == 0
            moveSpriteW!(game,:ball,-dir)
        end
    elseif game.n[:wiggleball].c == 60
        killCC!(game,:wiggleball)

        return
    end

    game.n[:wiggleball].c += 1

    return
end

function bbreakBall!(game::GameState,w::Int)
    createCC!(game,:breakball,bbreakBall!,();
        active=true,n=1)

    return
end

function bbreakBall!(game::GameState)
    if game.n[:breakball].c == 1
        setSpriteFrame!(game,:ball,2)
    elseif game.n[:breakball].c == 20
        activateSprite!(game,:pkmn2)
    elseif game.n[:breakball].c == 30
        killSprite!(game,:ball)
        killCC!(game,:breakball)

        return
    end

    game.n[:breakball].c += 1

    return
end

function bcaughtBall!(game::GameState,w::Int)
    createCC!(game,:caughtball,bcaughtBall!,();
        active=true,n=1)

    return
end

function bcaughtBall!(game::GameState)
    if game.n[:caughtball].c == 1
        # game.im.sprites[4][:ball].colortransform.active = true
        # game.im.sprites[4][:ball].colortransform.func = scaleColor
        # game.im.sprites[4][:ball].colortransform.args = (0x0a0a0a,0x0a,0x01)
    elseif game.n[:caughtball].c <= 32
        if game.n[:caughtball].c%4 == 0
            # game.im.sprites[4][:ball].colortransform.args =
            #     (0x0a0a0a,0x0a,UInt8(game.n[:caughtball].c/4))
        end
    elseif game.n[:caughtball].c == 60
        killSprite!(game,:ball)
        killCC!(game,:caughtball)

        game.battle.state.caught = true

        return
    end

    game.n[:caughtball].c += 1

    return
end





function bswitchOut!(game::GameState,user::Int)
    createCC!(game,:switchout,bswitchOut!,();
        active=true,n=1)

    return
end

function bswitchOut!(game::GameState)
    if game.n[:switchout].c == 30
        deleteSpriteSheet!(game,:pkmn1)
    elseif game.n[:switchout].c == 60
        deactivateSprite!(game,:tag1)
        killCC!(game,:switchout)

        return
    end

    game.n[:switchout].c += 1

    return
end

function bswitchIn!(game::GameState,user::Int)
    createCC!(game,:switchin,bswitchIn!,();
        active=true,n=1)

    return
end

function bswitchIn!(game::GameState,args::Tuple{})
    if game.n[:switchin].c == 1
        n = game.battle.state.pkmn1.command.n

        swap!(game.p.pokemon,1,n)
        game.battle.teamperm[1], game.battle.teamperm[n] = 
            game.battle.teamperm[n], game.battle.teamperm[1]

        game.battle.state.pkmn1 = PkmnBattle(game.p.pokemon[1],
            getPkmnName(game,activePkmn(game)))

        game.battle.state.pkmn1.command = CommandSwitch(n)
    elseif game.n[:switchin].c == 30
        p1 = game.battle.state.pkmn1.pkmn
        path1 = "battle/battlers/back/$(p1.shiny ? "shiny" : "normal")/$(p1.id).png"

        loadSpriteSheet!(game,path1,:pkmn1,64,64,2; maxsprites=1)
        createSprite!(game,:pkmn1,:pkmn1,1,1,-48,24,10,3; wscale=1.,hscale=1.)

        setText!(game,:name1,game.battle.state.pkmn1.name)
        setText!(game,:pkmn1,string(p1.level))
        activateSprite!(game,:tag1)
    elseif game.n[:switchin].c == 60
        killCC!(game,:switchin)

        return
    end

    game.n[:switchin].c += 1
end








# function bmoveHorizontal!(game::GameState,distance::Int,speed::Int,
#         target::Symbol,kill::Bool)
    
#     if distance%speed != 0
#         error("Distance needs to integer multiple of speed.")
#     end

#     posAdd!(game.im.sprites[2][target].pos,0,speed)
    
#     game.n[:moveh].c += 1

#     if game.n[:moveh].c == div(distance,speed)
#         if kill
#             killSprite!(game,target)
#         end

#         killCC!(game,:moveh)

#         return
#     end
# end

# function bmoveVertical!(game::GameState,distance::Int,speed::Int,
#         target::Symbol,kill::Bool)

#     if distance%speed != 0
#         error("Distance needs to integer multiple of speed.")
#     end

#     posAdd!(game.im.sprites[2][target].pos,speed,0)
    
#     game.n[:movew].c += 1

#     if game.n[:movew].c == div(distance,speed)
#         if kill
#             killSprite!(game,target)
#         end
        
#         killCC!(game,:movew)

#         return
#     end
# end

# function bmoveLinear!(game::GameState,distanceh::Int,distancew::Int,
#         speedh::Int,speedw::Int,target::Symbol)
    
#     if distanceh%speedh != 0 || distancew%speedw != 0
#         error("Distance needs to integer multiple of speed.")
#     end

#     posAdd!(game.im.sprites[2][target].pos,speedh,speedw)
    
#     game.n[:movel].c += 1

#     if game.n[:movel].c == div(distanceh,speedh) ||
#             game.n[:movel].c == div(distancew,speedw)

#         killCC!(game,:movel)

#         return
#     end
# end

# function bTackle!(game::GameState,target::Int)
    
# end
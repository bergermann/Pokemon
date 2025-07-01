
function banimEmpty!(game::GameState,target::Int)
    return
end

function bnoAnim!(game::GameState,target::Int)
    createCC!(game,:dmg,btakeDamage!,(target,); active=true,n=1)

    return
end

function btakeDamage!(game::GameState,(target,)::Tuple{Int})    #length: 30
    if game.n[:dmg].c == 1
        switchSprite!(game,blabels[target].pkmn)
        moveSpriteH!(game,blabels[target].tag,-1)
    elseif game.n[:dmg].c == 23
        moveSpriteH!(game,blabels[target].tag,1)
    elseif game.n[:dmg].c%4 == 1
        switchSprite!(game,blabels[target].pkmn)
        moveSpriteH!(game,blabels[target].tag,-2)
    elseif game.n[:dmg].c%4 == 3
        moveSpriteH!(game,blabels[target].tag,2)
    elseif game.n[:dmg].c == 24
        killCC!(game,:dmg)

        return
    end

    game.n[:dmg].c += 1

    return
end

function bhpAnim!(game::GameState,target::Int)
    p = game.battle.state[target]

    b1 = getHealthBar(p.pkmn,p.pkmn.stats.hp)
    b2 = getHealthBar(p.pkmn,p.pkmn.stats.hp-p.dmgt)

    p.pkmn.stats.hp -= p.dmgt; @assert p.pkmn.stats.hp >= 0 "HP got below 0? it fucked up."

    createCC!(game,:hp,bhpAnim!,(target,b1,b2); active=true,n=1)

    return
end

function bhpAnim!(game::GameState,(target,b1,b2)::Tuple{Int,Int,Int})
    setHPBar!(game,mplabels[target].h,round(Int,b1+(b2-b1)*game.n[:hp].c/48),
        69*(1-target)+56*(2-target))

    # if target == 1
    #     setText!(game,:health1,
    #         string(p.pkmn.stats.hp-
    #         trunc(Int,dmg*(game.n[:hp].c)/48)))
    # end
    
    if game.n[:hp].c == 48; killCC!(game,:hp); return; end

    game.n[:hp].c += 1

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
    createSprite!(game,:ball,:ballsb,game.battle.state[1].command.item.id,1,-128,0,0,5;
        active=true)

    createCC!(game,:throwball,bthrowBall!,();
        active=true,n=1)

    return
end

function bthrowBall!(game::GameState,args::Tuple{})
    if game.n[:throwball].c <= 46
        moveSpriteW!(game,:ball,4)
        moveSpriteH!(game,:ball,trunc(Int,(getSpritePosW(game,:ball)-32)^2/300-54),true)
    elseif game.n[:throwball].c == 60
        setSpriteFrame!(game,:ball,2)
    elseif 64 < game.n[:throwball].c <= 84
        s = 1-(game.n[:throwball].c-64)/20
        scaleSprite!(game,:pkmn2,s,s,true)
    elseif game.n[:throwball].c == 90
        deactivateSprite!(game,:pkmn2)
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

function bwiggleBall!(game::GameState,(dir,)::Tuple{Int8})
    if game.n[:wiggleball].c <= 15
        rotateSprite!(game,:ball,2*Float64(dir))
        if game.n[:wiggleball].c%5 == 0
            moveSpriteW!(game,:ball,Int(+dir))
        end
    elseif game.n[:wiggleball].c <= 30
        rotateSprite!(game,:ball,-2*Float64(dir))
        if game.n[:wiggleball].c%5 == 0
            moveSpriteW!(game,:ball,Int(-dir))
        end
    elseif game.n[:wiggleball].c == 60
        killCC!(game,:wiggleball)

        return
    end

    game.n[:wiggleball].c += 1

    return
end

function bbreakBall!(game::GameState,w::Int)
    createCC!(game,:breakball,bbreakBall!,(); active=true,n=1)

    return
end

function bbreakBall!(game::GameState,args::Tuple{})
    if game.n[:breakball].c == 1
        setSpriteFrame!(game,:ball,2)
        moveSpriteL!(game,:ball,1)
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
    game.battle.state.caught1 = true

    createCC!(game,:caughtball,bcaughtBall!,(); active=true,n=1)

    return
end

function bcaughtBall!(game::GameState,args::Tuple{})
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

        return
    end

    game.n[:caughtball].c += 1

    return
end





function bfaint!(game::GameState,target::Int)
    createCC!(game,:faint,bfaint!,(target,); active=true,n=1)

    # game.battle.state[target].forceswitch = true

    return
end

function bfaint!(game::GameState,(target,)::Tuple{Int})
    if 60 < game.n[:faint].c <= 75
        moveSpriteH!(game,blabels[target].pkmn,4)
    end

    if game.n[:faint].c == 75
        deactivateSprite!(game,blabels[target].pkmn)
        # deleteSpriteSheet!(game,blabels[target].pkmn)
    elseif game.n[:faint].c == 120
        deactivateSprite!(game,blabels[target].tag)
        deactivateText!(game,blabels[target].name)
        deactivateText!(game,blabels[target].level)

        killCC!(game,:faint)

        return
    end

    game.n[:faint].c += 1

    return
end



function bswitchOut!(game::GameState,user::Int)
    createCC!(game,:switchout,bswitchOut!,(); active=true,n=1)

    bid = Int(game.battle.state.pkmn1.pkmn.ball)
    createSprite!(game,:ball,:ballsb,bid,2,-48,24,10,2; active=true,rot=0.)
    
    n = game.battle.state.pkmn1.command.n

    swap!(game.p.pokemon,1,n)
    game.battle.teamperm[1], game.battle.teamperm[n] = 
        game.battle.teamperm[n], game.battle.teamperm[1]

    game.battle.state.pkmn1 = PkmnBattle(game.p.pokemon[1],
        getPkmnName(game,activePkmn(game)))

    return
end

function bswitchOut!(game::GameState,args::Tuple{})
    if game.n[:switchout].c <= 20
        s = 1-game.n[:switchout].c/20
        scaleSprite!(game,:pkmn1,s,s,true)
    elseif game.n[:switchout].c == 20+1
        deleteSpriteSheet!(game,:pkmn1)
    elseif game.n[:switchout].c == 28
        setSpriteFrame!(game,:ball,1)
    elseif game.n[:switchout].c < 48
        moveSpriteH!(game,:ball,3)
    elseif game.n[:switchout].c == 48
        moveSpriteW!(game,:tag1,128)
        moveSpriteW!(game, :hp1,128)
        moveSpriteW!(game,  :xp,128)
        moveText!(game,:name1,128,0)
        moveText!(game, :lvl1,128,0)

        killSprite!(game,:ball)

        killCC!(game,:switchout)

        return
    end

    game.n[:switchout].c += 1

    return
end



function bswitchIn!(game::GameState,user::Int)
    createCC!(game,:switchin,bswitchIn!,(); active=true,n=1)

    p1 = game.battle.state.pkmn1.pkmn
    path1 = "battle/battlers/back/$(p1.shiny ? "shiny" : "normal")/$(p1.id).png"

    loadSpriteSheet!(game,path1,:pkmn1,64,64,2; maxsprites=1)
    createSprite!(game,:pkmn1,:pkmn1,1,1,-48,24,10,3; wscale=0.,hscale=0.,active=false)

    bid = Int(game.battle.state.pkmn1.pkmn.ball)
    createSprite!(game,:ball,:ballsb,bid,1,-48-80,24,10,2; active=true)

    activateSprite!(game,:tag1); activateSprite!(game,:hp1); activateSprite!(game,:xp);
    activateText!(game,:name1); activateText!(game,:lvl1)

    moveSprite!(game,:tag1,60+128,12,true)
    moveSprite!(game, :hp1,56+128,12,true); setHPBar!(game,:hp1,getHealthBar(p1),56+128)
    moveSprite!(game,  :xp,40+128,12,true); setXPBar!(game,:xp,getXPBar(p1,0),40+128)

    moveText!(game,:name1,24+128,-4,true)
    moveText!(game, :lvl1,93+128,-4,true)

    setText!(game,:name1,pkmnName(game,p1)); # moveText!(game,:name1,24,-4)
    setText!(game,:lvl1,string(p1.stats.level)); # moveText!(game,:lvl1,93,-4)

    for i in eachindex(p1.attacks)
        setText!(game,blabels[i].attack,p1.attacks[i].name)
    end
    
    for i in length(p1.attacks)+1:4
        setText!(game,blabels[i].attack,"---")
    end

    a = p1.attacks[1]
    setText!(game,:info2,string(a.ap)*"/"*string(a.apmax)*"\\"*game.str[2][a.type+1])

    for i in 1:10
        createSprite!(game,Symbol(:spark,i),:particles,1,1,-48,24,10,4; active=false)
    end

    return
end

function bswitchIn!(game::GameState,args::Tuple{})
    if game.n[:switchin].c < 40
        moveSpriteW!(game,:ball,2)
        t = game.n[:switchin].c
        moveSpriteH!(game,:ball,round(Int,24-2.4*t+0.06*t^2),true)
        rotateSprite!(game,:ball,18.)
    elseif game.n[:switchin].c == 40
        moveSprite!(game,:ball,-48,24,true)
        rotateSprite!(game,:ball,0.,true)
        setSpriteFrame!(game,:ball,2)
    elseif game.n[:switchin].c == 48
        activateSprite!(game,:pkmn1)
        for i in 1:10; activateSprite!(game,Symbol(:spark,i)); end
    elseif 48+1 <= game.n[:switchin].c <= 48+32
        t = game.n[:switchin].c-48
        scaleSprite!(game,:pkmn1,t/32,t/32,true)
        for i in 1:10
            moveSprite!(game,Symbol(:spark,i),
                round(Int,1.5t*cospi(t/32+i/5))-48,round(Int,-1.5t*sinpi(t/32+i/5))+24,true)
        end
    elseif game.n[:switchin].c == 48+32+1
        killSprites!(game,:particles)
        moveSpriteH!(game,:ball,3)
    elseif 48+32+1 < game.n[:switchin].c <= 48+32+8
        moveSpriteH!(game,:ball,3)
    elseif 96 < game.n[:switchin].c <= 96+16
        moveSpriteW!(game,:tag1,-8)
        moveSpriteW!(game, :hp1,-8)
        moveSpriteW!(game,  :xp,-8)
        moveText!(game,:name1,-8,0)
        moveText!(game, :lvl1,-8,0)
    elseif game.n[:switchin].c == 96+32
        killSprite!(game,:ball)

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
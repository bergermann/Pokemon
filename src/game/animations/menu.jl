


function animMenuPkmnWiggle!(game::GameState,args::Tuple{})
    for i in 1:game.p.pokemon.idx
        if i == game.ctrl.input.menu.menupkmn.select
            setSpriteFrame!(game,mplabels[i].ic,Int(div(game.frame%16,8)+1))

            if i == 1
                moveSpriteH!(game,mplabels[i].ic,
                    -44-2*Int(div(game.frame%16,8)),true)
            else
                moveSpriteH!(game,mplabels[i].ic,
                    -63+24*(i-2)-2*Int(div(game.frame%16,8)),true)
            end

            continue
        end

        setSpriteFrame!(game,mplabels[i].ic,Int(div((game.frame+2i)%20,10)+1))
    end

    return
end

function animMenuPkmnSwap!(game::GameState,(p1,p2)::Tuple{Int,Int})
    if game.n[:pkmnswap].c <= 30
        s1 = 8-12*(p1==1); s2 = 8-12*(p2==1)

        moveSprite!(game,mplabels[p1].s, s1,0)
        moveSprite!(game,mplabels[p1].b, s1,0)
        moveSprite!(game,mplabels[p1].st,s1,0)
        moveSprite!(game,mplabels[p1].i, s1,0)
        moveSprite!(game,mplabels[p1].ic,s1,0)
        moveSprite!(game,mplabels[p1].h, s1,0)
        moveSprite!(game,mplabels[p1].g, s1,0)
          moveText!(game,mplabels[p1].n, s1,0)
          moveText!(game,mplabels[p1].h, s1,0)

        moveSprite!(game,mplabels[p2].s, s2,0)
        moveSprite!(game,mplabels[p2].b, s2,0)
        moveSprite!(game,mplabels[p2].st,s2,0)
        moveSprite!(game,mplabels[p2].i, s2,0)
        moveSprite!(game,mplabels[p2].ic,s2,0)
        moveSprite!(game,mplabels[p2].h, s2,0)
        moveSprite!(game,mplabels[p2].g, s2,0)   
          moveText!(game,mplabels[p2].n, s2,0)
          moveText!(game,mplabels[p2].h, s2,0)
    elseif game.n[:pkmnswap].c == 31
        swap!(game.p.pokemon,p1,p2)

        setText!(game,mplabels[p1].n,
            pkmnName(game,game.p.pokemon[p1])*"\\   Lv.$(game.p.pokemon[p1].stats.level)")
        setText!(game,mplabels[p1].h,
            string(game.p.pokemon[p1].stats.hp)*"/"*string(game.p.pokemon[p1].stats.rv[1]);
            align=1)
        
        setText!(game,mplabels[p2].n,
            pkmnName(game,game.p.pokemon[p2])*"\\   Lv.$(game.p.pokemon[p2].stats.level)")
        setText!(game,mplabels[p2].h,
            string(game.p.pokemon[p2].stats.hp)*"/"*string(game.p.pokemon[p2].stats.rv[1]);
            align=1)

        swapSprites!(game,mplabels[p1].ic,mplabels[p2].ic)
        swapSprites!(game,mplabels[p1].i,mplabels[p2].i)
        swapSprites!(game,mplabels[p1].st,mplabels[p2].st)
        swapSprites!(game,mplabels[p1].h,mplabels[p2].h)
        swapSprites!(game,mplabels[p1].g,mplabels[p2].g)

        setHPBar!(game,mplabels[p1].h,getHPBar(game.p.pokemon[p1]),48,-208*(p1==1)+304*(p1>1))
        setHPBar!(game,mplabels[p2].h,getHPBar(game.p.pokemon[p2]),48,-208*(p2==1)+304*(p2>1))
    elseif game.n[:pkmnswap].c <= 61
        s1 = 12*(p1==1)-8; s2 = 12*(p2==1)-8

        moveSprite!(game,mplabels[p1].s, s1,0)
        moveSprite!(game,mplabels[p1].b, s1,0)
        moveSprite!(game,mplabels[p1].st,s1,0)
        moveSprite!(game,mplabels[p1].i, s1,0)
        moveSprite!(game,mplabels[p1].ic,s1,0)
        moveSprite!(game,mplabels[p1].h, s1,0)
        moveSprite!(game,mplabels[p1].g, s1,0)
          moveText!(game,mplabels[p1].n, s1,0)
          moveText!(game,mplabels[p1].h, s1,0)

        moveSprite!(game,mplabels[p2].s, s2,0)
        moveSprite!(game,mplabels[p2].b, s2,0)
        moveSprite!(game,mplabels[p2].st,s2,0)
        moveSprite!(game,mplabels[p2].i, s2,0)
        moveSprite!(game,mplabels[p2].ic,s2,0)
        moveSprite!(game,mplabels[p2].h, s2,0)
        moveSprite!(game,mplabels[p2].g, s2,0)
          moveText!(game,mplabels[p2].n, s2,0)
          moveText!(game,mplabels[p2].h, s2,0)
    elseif game.n[:pkmnswap].c == 62
        killCC!(game,:pkmnswap)

        setSprite!(game,mplabels[p1].s,1,1)
        setSprite!(game,mplabels[p1].b,1,1)
        
        setSprite!(game,mplabels[p2].s,1,2)
        setSprite!(game,mplabels[p2].b,1,2)

        setText!(game,:choose,game.str[1][2])

        game.ctrl.input.menu.menupkmn.swap = 0
        unlockInput!(game)

        return
    end

    game.n[:pkmnswap].c += 1

    return
end



function animArrowsMenu!(game::GameState,args::Tuple{})
    s = (game.frame%48) < 24

    moveSpriteW!(game,:left,-90-4*s-(1-2*s)*Int(div((game.frame%24),6)),true)
    moveSpriteW!(game,:right,-22+4*s+(1-2*s)*Int(div((game.frame%24),6)),true)
    moveSpriteH!(game,:up,-66-4*s-(1-2*s)*Int(div((game.frame%24),6)),true)
    moveSpriteH!(game,:down,66+4*s+(1-2*s)*Int(div((game.frame%24),6)),true)

    return
end

function animBagSwitch!(game::GameState,(m,dir,)::Tuple{MenuBags,Int,})
    for i in 1:5
        moveText!(game,mbslots[i],-8*dir,0)
    end

    if game.n[:bagswitch].c == 1
        moveSpriteW!(game,:marker,-84+8*m.bag,true)
        moveSpriteH!(game,:bag,-1)
        moveSpriteH!(game,:cursor,-71+16*m.cursor[m.bag],true)

        moveText!(game,:items,0,-63+16*(m.cursor[m.bag]-m.select[m.bag]),true)
        moveText!(game,:amounts,90,-63+16*(m.cursor[m.bag]-m.select[m.bag]),true)

        s = getSelectedItem(game,m)

        setSpriteFrame!(game,:bag,6)
        setText!(game,:items,getItemsStr(game,m))
        setText!(game,:amounts,getAmountsStr(game,m))
        setText!(game,:info,game.str[6+m.bag][isnothing(s) ? lastindex(game.str[6+m.bag]) : s])

        setSpriteIdx!(game,:item,itemIdx(s))


        switchSprite!(game,:left)
        switchSprite!(game,:right)
        deactivateSprite!(game,:up)
        deactivateSprite!(game,:down)
        switchSprite!(game,:cursor)
        switchSprite!(game,:item)
        
        switchText!(game,:info)
        switchText!(game,:items)
        switchText!(game,:amounts)
    elseif game.n[:bagswitch].c < 4
        moveSpriteH!(game,:bag,-1)
    elseif game.n[:bagswitch].c == 4
        moveSpriteH!(game,:bag,-1)
        setSpriteFrame!(game,:bag,m.bag)
    elseif game.n[:bagswitch].c < 8
        moveSpriteH!(game,:bag,1)
    else game.n[:bagswitch].c
        moveSpriteH!(game,:bag,1)

        for i in 1:5
            if game.im.text.texts[mbslots[i]].pos[1] > -56+64*2
                moveText!(game,mbslots[i],-64*5,0)
            elseif game.im.text.texts[mbslots[i]].pos[1] < -56-64*2
                moveText!(game,mbslots[i],64*5,0)
            end
        end

        switchSprite!(game,:left)
        switchSprite!(game,:right)
        switchSprite!(game,:cursor)
        switchSprite!(game,:item)

        switchText!(game,:info)
        switchText!(game,:items)
        switchText!(game,:amounts)

        game.callbacks[:bagswitch].active = false
        game.n[:bagswitch].c = 1

        unlockInput!(game)

        return
    end

    game.n[:bagswitch].c += 1

    return
end
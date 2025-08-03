
mdlabels = Base.ImmutableDict([i => Symbol(:p,i) for i in 1:5]...)


function stateMenuDexOpen!(game::GameState,args::Tuple{})
    stateCloseMap!(game)

    loadStringsDex!(game)

    loadSpriteSheets!(game,
        :dexwheel,:dexslider,:dexarrow,:dexball,:footprints,#:pokemons
    )
    loadSpriteSheet!(game,"battle/battlers/front/normal",["$i.png" for i in 0:151],:pkmn,64,64,2;
        maxsprites=6)
    
    createBackground!(game,:dex0,"backgrounds/dex0.png",-120,-80,1; active=true)
    createBackground!(game,:dex1,"backgrounds/dex1.png",-120,-80,2; active=true)
    createBackground!(game,:dex2,"backgrounds/dex2.png",-120,-80,1; active=false)
    createBackground!(game,:dex3,"backgrounds/dex3.png",-120,-80,1; active=false)
    createBackground!(game,:blck,"backgrounds/black.png",-120,-80,5; sx=240,sy=160,
        color=Float32[1.0,1.0,1.0,0.0],active=false)

    s = game.ctrl.input.menu.menudex.select

    createSprite!(game, :wheel, :dexwheel,1,1,-120,  0,0,2; active=true,rot=22.5*(s-1))
    createSprite!(game,:slider,:dexslider,1,1, 110,-60+round(Int,120*(s-1)/649),0,2; active=true)
    createSprite!(game,:arrow1, :dexarrow,1,1,  64,-72,0,2; active=false)
    createSprite!(game,:arrow2, :dexarrow,1,1,  64, 72,0,2; active=false,hreverse=true)
    createSprite!(game, :foot,:footprints,1,1,  87, -8,0,2; active=false)

    for i in 1:5
        idx = game.p.dex[clamp(s+i-2,1,649),1]*clamp(s+i-3,0,649-1)+1
        createSprite!(game,mdlabels[i],:pkmn,idx,1,
            -24,3*-64+64*i,0,1; active=1<=s+i-3<=649,hscale=1-2*abs(i-3)/16)
    end
    
    game.im.s.sheets[:dexball].idx .= 1
    game.im.s.sheets[:dexball].active[1,:] .= game.p.dex[:,2]
    game.im.s.sheets[:dexball].pos[1,:] .= 20
    game.im.s.sheets[:dexball].pos[2,:] .= 1+16*(s-2)
    game.im.s.sheets[:dexball].pos[4,:] .= 1
    game.im.s.sheets[:dexball].scale .= 1
    game.im.s.sheets[:dexball].alpha .= 1
    game.im.s.sheets[:dexball].slots .= true

    numbers = zeros(UInt8,4*649)
    names = fill(0x20,11,649)
    for i in 1:649
        numbers[1+4*(i-1)] = 0x30+UInt8(div(i,100)%10)
        numbers[2+4*(i-1)] = 0x30+UInt8(div(i,10)%10)
        numbers[3+4*(i-1)] = 0x30+UInt8(i%10)
        numbers[4+4*(i-1)] = 0x5c
        
        if game.p.dex[i,1]
            name = game.pkmndata.names[i]
            l = length(name)
            names[1:l,i] .= codeunits(name)
        else
            names[1:5,i] .= codeunits(game.str[1][9])
        end
        
        names[11,i] = 0x5c

        game.im.s.sheets[:dexball].pos[2,i] += 16*i
    end

    # names = replace!(read("str/ger/pkmn_names.txt"),0x0a=>0x5c)

    # vorne 50, hinten 90

    createText!(game,:numbers,2,24,-7-16*(s-1),1,String(numbers),
        [0x00,0x00,0x00,0xff],[0xbd,0xbd,0xbd,0xff]; active=true,hpad=1,maxchar=3*649)
    createText!(game,  :names,2,44,-7-16*(s-1),1,String(names[:]),
        [0x00,0x00,0x00,0xff],[0xbd,0xbd,0xbd,0xff]; active=true,hpad=1,maxchar=10*649)

    seen = sum(game.p.dex[:,1]); caught = sum(game.p.dex[:,2])
    createText!(game,:stats,1,-90,-30,3,
        game.str[1][1]*string(seen)*game.str[1][2]*string(caught),
        [0xff,0xff,0xff,0xff],[0x00,0x00,0x00,0xff]; active=true,hpad=0,maxchar=32,align=0)

    createText!(game,:info1,2,-24,-54,1,"",#game.str[1][3]*
        [0x00,0x00,0x00,0xff],[0xbd,0xbd,0xbd,0xff]; maxchar=48,active=false)
    createText!(game,:info2,2,-24,-23,1,"",#game.str[1][4],
        [0x00,0x00,0x00,0xff],[0xbd,0xbd,0xbd,0xff]; maxchar=24,active=false,hpad=1)
    createText!(game,:info3,2, 63,-23,1,"",#h*game.str[1][5]*w*game.str[1][6],
        [0x00,0x00,0x00,0xff],[0xbd,0xbd,0xbd,0xff]; maxchar=24,hpad=1,align=1,active=false)
    createText!(game,:info4,2,-112,15,1,"",#info,
        [0x00,0x00,0x00,0xff],[0xbd,0xbd,0xbd,0xff]; maxchar=256,active=false)
    
    createCallback!(game,:arrows,animDexWiggle!,(); active=true)
    createCC!(game,:scroll,animDexScroll!,(); active=false)

    return
end

function stateMenuDexCtrls!(game::GameState,args::Tuple{})
    unlockInput!(game)
    game.ctrl.input.menu.dex = true

    return
end

function stateMenuDexClose!(game::GameState,args::Tuple{})
    killCallback!(game,:arrows)
    killCC!(game,:scroll)
    killSpritesAll!(game)
    
    deleteBackgrounds!(game,:dex0,:dex1,:dex2,:dex3,:blck)
    deleteSpriteSheets!(game,:dexwheel,:dexslider,:dexarrow,:dexball,:pkmn,:footprints)

    deleteTextsAll!(game)
    deleteFramesAll!(game)

    stateOpenMap!(game)
    stateMenuMainOpen!(game,())

    return
end

function animDexWiggle!(game::GameState,args::Tuple{})
    s = (game.frame%32) >= 16
    offset = Int((game.frame%16) >> 1)

    moveSpriteH!(game,:arrow1,-72-8*s-!s*offset+s*offset,true)
    moveSpriteH!(game,:arrow2, 72+8*s+!s*offset-s*offset,true)

    game.im.s.sheets[:dexarrow].active[1,1] = game.ctrl.input.menu.menudex.select > 1
    game.im.s.sheets[:dexarrow].active[1,2] = game.ctrl.input.menu.menudex.select < 649

    return
end

function animDexScroll!(game::GameState,args::Tuple{})
    game.n[:scroll].c += 1

    s = game.ctrl.input.menu.menudex.select
    d = game.n[:scroll].c*game.ctrl.input.menu.menudex.speed/16
    
    moveSpritesH!(game,:dexball,-game.ctrl.input.menu.menudex.speed)
    moveSpritesH!(game,   :pkmn,-game.ctrl.input.menu.menudex.speed*4)
    moveTextH!(game,:numbers,-game.ctrl.input.menu.menudex.speed)
    moveTextH!(game,  :names,-game.ctrl.input.menu.menudex.speed)
        
    rotateSprite!(game,:wheel,22.5*(s-1+d),true)

    if game.n[:scroll].c >= div(16,abs(game.ctrl.input.menu.menudex.speed))
        game.ctrl.input.menu.menudex.select += sign(game.ctrl.input.menu.menudex.speed)
        s = game.ctrl.input.menu.menudex.select

        game.n[:scroll].c = 0
        
        moveSpriteH!(game,:slider,
            -60+round(Int,120*(s-1)/(649-1)),true)

        moveSpritesH!(game,:pkmn,64*sign(game.ctrl.input.menu.menudex.speed))

        for i in 1:5
            setSpriteIdx!(game,mdlabels[i],
                    game.p.dex[clamp(s+i-3,1,649),1]*clamp(s+i-3,1,151)+1)
            activateSprite!(game,mdlabels[i],649+1>s+i-3>0)
        end
        
        unlockInput!(game)
        deactivateCallback!(game,:scroll)
    end

    return
end

function animDexInfo!(game::GameState,args::Tuple{})
    if game.n[:infot].c == 0
        copySprite!(game,mdlabels[3],:pinfo)
        deactivateSprite!(game,mdlabels[3])
        activateSprite!(game,:pinfo); moveSpriteL!(game,:pinfo,5)
        activateBackground!(game,:blck)
    elseif game.n[:infot].c <= 16
        moveSprite!(game,:pinfo,-1,-1)
        game.im.b.backgrounds[:blck].color[4] = Float32(game.n[:infot].c/16)
    elseif game.n[:infot].c == 24+1
        s = game.ctrl.input.menu.menudex.select

        if game.p.dex[s,2]
            activateBackground!(game,:dex2)
        else
            activateBackground!(game,:dex3)
        end
        deactivateBackground!(game,:dex0)
        deactivateBackground!(game,:dex1)

        for i in 1:5
            deactivateSprite!(game,mdlabels[i])
        end
        deactivateSprite!(game,:wheel)
        deactivateSprite!(game,:slider)
        deactivateSprite!(game,:arrow1)
        deactivateSprite!(game,:arrow2)
        game.im.s.sheets[:dexball].active[1,:] .= false

        activateText!(game,:info1)

        deactivateText!(game,:numbers)
        deactivateText!(game,:names)
        deactivateText!(game,:stats)

        setSpriteIdx!(game,:foot,s)

        if game.p.dex[s,2]
            activateSprite!(game,:foot)

            cat,h,w,info = split(readline("str/ger/dex/$s.txt"),'|')
            setText!(game,:info1,
                game.str[1][3]*string(s,pad=3)*" "*game.str[2][s]*"\\ "*cat*"-Pokémon")
            setText!(game,:info2,game.str[1][4])
            setText!(game,:info3,h*game.str[1][5]*w*game.str[1][6],align=1)
            setText!(game,:info4,info)

            activateText!(game,:info2)
            activateText!(game,:info3)
            activateText!(game,:info4)
        elseif game.p.dex[s,1]
            deactivateSprite!(game,:foot)

            setText!(game,:info1,
                game.str[1][3]*string(s,pad=3)*" "*game.str[2][s]*"\\ "*game.str[1][8])
            setText!(game,:info2,game.str[1][4])
            setText!(game,:info3,game.str[1][7]*game.str[1][7],align=1)
            setText!(game,:info4,"")

            activateText!(game,:info2)
            activateText!(game,:info3)
            deactivateText!(game,:info4)
        else
            deactivateSprite!(game,:foot)

            setText!(game,:info1,game.str[1][3]*string(s,pad=3)*" "*game.str[1][8])
            setText!(game,:info2,game.str[1][4])
            setText!(game,:info3,game.str[1][7]*game.str[1][7],align=1)
            setText!(game,:info4,"")

            deactivateText!(game,:info2)
            deactivateText!(game,:info3)
            deactivateText!(game,:info4)
        end

        GC.gc()
    elseif game.n[:infot].c <= 24+1
        moveSprite!(game,:pinfo,-1,-1)
    elseif game.n[:infot].c <= 48+1
        moveSpriteW!(game,:pinfo,-1)
    elseif game.n[:infot].c <= 48+16+1
        game.im.b.backgrounds[:blck].color[4] = Float32(1.0-(game.n[:infot].c-(48+1))/16)
    else
        deactivateBackground!(game,:blck)
        unlockInput!(game)

        
        killCC!(game,:infot)
    end
    
    game.n[:infot].c += 1

    return
end

function stateDexInfoSwitch!(game::GameState,args::Tuple{})
    s = game.ctrl.input.menu.menudex.select
    
    deactivateBackground!(game,:dex2)
    deactivateBackground!(game,:dex3)
    if game.p.dex[s,2]
        activateBackground!(game,:dex2)
    else
        activateBackground!(game,:dex3)
    end

    setSpriteIdx!(game,:pinfo,s*game.p.dex[s,1]+1)
    setSpriteIdx!(game,:foot,s)

    if game.p.dex[s,2]
        activateSprite!(game,:foot)
        
        cat,h,w,info = split(readline("str/ger/dex/$s.txt"),'|')
        setText!(game,:info1,
            game.str[1][3]*string(s,pad=3)*" "*game.str[2][s]*"\\ "*cat*"-Pokémon")
        setText!(game,:info2,game.str[1][4])
        setText!(game,:info3,h*game.str[1][5]*w*game.str[1][6],align=1)
        setText!(game,:info4,info)

        activateText!(game,:info2)
        activateText!(game,:info3)
    elseif game.p.dex[s,1]
        deactivateSprite!(game,:foot)
        
        setText!(game,:info1,
            game.str[1][3]*string(s,pad=3)*" "*game.str[2][s]*"\\ "*game.str[1][8])
        setText!(game,:info2,game.str[1][4])
        setText!(game,:info3,game.str[1][7]*game.str[1][7],align=1)
        setText!(game,:info4,"")

        activateText!(game,:info2)
        activateText!(game,:info3)
    else
        deactivateSprite!(game,:foot)

        setText!(game,:info1,game.str[1][3]*string(s,pad=3)*" "*game.str[1][8])
        setText!(game,:info2,game.str[1][4])
        setText!(game,:info3,game.str[1][7]*game.str[1][7],align=1)
        setText!(game,:info4,"")

        deactivateText!(game,:info2)
        deactivateText!(game,:info3)
    end

    return
end

function stateDexInfoClose!(game::GameState,args::Tuple{})
    s = game.ctrl.input.menu.menudex.select
    
    activateBackground!(game,:dex0)
    activateBackground!(game,:dex1)
    deactivateBackground!(game,:dex2)
    deactivateBackground!(game,:dex3)

    killSprite!(game,:pinfo)
    
    deactivateText!(game,:info1)
    deactivateText!(game,:info2)
    deactivateText!(game,:info3)
    deactivateText!(game,:info4)

    deactivateSprite!(game,:foot)

    for i in 1:5
        activateSprite!(game,mdlabels[i],1<=s+i-3<=649)
        idx = game.p.dex[clamp(s+i-2,1,649),1]*clamp(s+i-3,0,649-1)+1
        setSpriteIdx!(game,mdlabels[i],idx)
    end

    moveSpriteH!(game,:slider,-60+round(Int,120*(s-1)/649),true)
    rotateSprite!(game,:wheel,22.5*(s-1),true)

    activateSprite!(game,:slider)
    activateSprite!(game,:wheel)

    game.im.s.sheets[:dexball].active[1,:] .= game.p.dex[:,2]
    game.im.s.sheets[:dexball].pos[2,:] .= 1-16*s
    for i in 1:649
        game.im.s.sheets[:dexball].pos[2,i] += 16*i
    end

    moveTextH!(game,:numbers,-7-16*(s-1),true)
    moveTextH!(game,  :names,-7-16*(s-1),true)

    activateText!(game,:numbers)
    activateText!(game,  :names)
    activateText!(game,  :stats)

    activateCallback!(game,:arrows)

    return
end
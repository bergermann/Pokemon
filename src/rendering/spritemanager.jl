
function setupSprites(game::GameState)
    game.im.s.ulocsize = glGetUniformLocation(game.im.programs[4],"size")

    return
end

function loadSpriteSheet!(game::GameState,dir::String,textures::Vector{String},name::Symbol,
        width::Int,height::Int,nframes::Int; maxsprites::Int=128)

    loadArrayTexture!(game,joinpath("sprites",dir),textures,name,width,height; addempty=true)
    loadSpriteSheet!(game,name,width,height,nframes; maxsprites=maxsprites)

    return
end

function loadSpriteSheet!(game::GameState,file::String,name::Symbol,
        width::Int,height::Int,nframes::Int; maxsprites::Int=128)

    loadArrayTexture!(game,joinpath("sprites",file),name,width,height; addempty=true)
    loadSpriteSheet!(game,name,width,height,nframes; maxsprites=maxsprites)

    return
end

function loadSpriteSheet!(game::GameState,name::Symbol,
        width::Int,height::Int,nframes::Int; maxsprites::Int=128)

    sheet = SpriteSheet(width,height,nframes,maxsprites)
    game.im.s.sheets[name] = sheet 

    m = sheet.maxsprites
    glBindVertexArray(sheet.vao)
    glBindBuffer(GL_ARRAY_BUFFER,sheet.vbo)
    
    glBufferData(GL_ARRAY_BUFFER,43*m,C_NULL,GL_DYNAMIC_DRAW)

    glVertexAttribIPointer(0,2,GL_UNSIGNED_INT, 8,ptr(0))
    glVertexAttribIPointer(1,4,GL_INT,16,ptr(8*m))

    glVertexAttribPointer(2,2,GL_FLOAT,false,8,ptr(24*m))
    glVertexAttribPointer(3,1,GL_FLOAT,false,4,ptr(32*m))
    glVertexAttribPointer(4,1,GL_FLOAT,false,4,ptr(36*m))

    glVertexAttribIPointer(5,2,GL_UNSIGNED_BYTE,2,ptr(40*m))
    glVertexAttribIPointer(6,1,GL_UNSIGNED_BYTE,1,ptr(42*m))

    glEnableVertexAttribArray(0)
    glEnableVertexAttribArray(1)
    glEnableVertexAttribArray(2)
    glEnableVertexAttribArray(3)
    glEnableVertexAttribArray(4)
    glEnableVertexAttribArray(5)
    glEnableVertexAttribArray(6)

    glBindBuffer(GL_ARRAY_BUFFER,0)
    glBindVertexArray(0)

    checkError("loading sprite sheet $name 2")

    return
end

function deleteSpriteSheet!(game::GameState,name::Symbol)
    deleteArrayTexture!(game,name)

    glDeleteVertexArrays(1,pointer([game.im.s.sheets[name].vao]))
    glDeleteBuffers(1,pointer([game.im.s.sheets[name].vbo]))
    
    killSprites!(game,name)

    pop!(game.im.s.sheets,name)

    return
end

function createSprite!(game::GameState,
        id::Symbol,sheetname::Symbol,
        idx::Int,frame::Int,
        x::Int,y::Int,z::Int,layer::Int;
        wscale::Float64=1.0,hscale::Float64=1.0,
        wreverse::Bool=false,hreverse::Bool=false,
        rot::Float64=0.0,alpha::Float64=1.0,
        active::Bool=false)

    sheet = game.im.s.sheets[sheetname]

    slot = findfirst(!,sheet.slots)

    @assert !isnothing(slot) "Spritesheet $sheetname is full!"

    game.im.s.sprites[id] = Sprite(sheetname,slot)

    sheet.idx[1,slot] = (idx-1)*sheet.nframes+1; sheet.idx[2,slot] = frame

    sheet.pos[1,slot] = x; sheet.pos[2,slot] = y
    sheet.pos[3,slot] = z; sheet.pos[4,slot] = layer

    sheet.scale[1,slot] = wscale
    sheet.scale[2,slot] = hscale

    sheet.rev[1,slot] = wreverse; sheet.rev[2,slot] = hreverse

    sheet.rot[1,slot] = rot

    sheet.alpha[1,slot] = alpha
    
    sheet.active[1,slot] = active

    sheet.slots[slot] = true

    return
end

function setSpriteAttrib!(game::GameState,id::Symbol,attrib::Symbol,args...)
    s = game.im.s.sprites[id]
    
    f = getfield(game.im.s.sheets[s.sheet],attrib); f[:,s.slot] .= args

    return
end

function moveSprite!(game::GameState,id::Symbol,w::Int,h::Int,absolute::Bool=false)
    s = game.im.s.sprites[id]

    if absolute
        game.im.s.sheets[s.sheet].pos[1,s.slot] = w
        game.im.s.sheets[s.sheet].pos[2,s.slot] = h
    else
        game.im.s.sheets[s.sheet].pos[1,s.slot] += w
        game.im.s.sheets[s.sheet].pos[2,s.slot] += h
    end

    return
end

function moveSpriteW!(game::GameState,id::Symbol,w::Int,absolute::Bool=false)
    s = game.im.s.sprites[id]

    if absolute
        game.im.s.sheets[s.sheet].pos[1,s.slot] = w
    else
        game.im.s.sheets[s.sheet].pos[1,s.slot] += w
    end

    return
end

function moveSpriteH!(game::GameState,id::Symbol,h::Int,absolute::Bool=false)
    s = game.im.s.sprites[id]

    if absolute
        game.im.s.sheets[s.sheet].pos[2,s.slot] = h
    else
        game.im.s.sheets[s.sheet].pos[2,s.slot] += h
    end

    return
end

function moveSprites!(game::GameState,sheet::Symbol,d::Pos)
    @views game.im.s.sheets[sheet].pos[1:2,:] .+= d

    # @inbounds @simd for i in axes(game.im.s.sheets[sheet].pos,2)
    #     game.im.s.sheets[sheet].pos[1,i] += d[1]
    #     game.im.s.sheets[sheet].pos[2,i] += d[2]
    # end

    return
end

function moveSprites!(game::GameState,sheet::Symbol,d::Pos,n::Int)
    dx = n*d[1]; dy = n*d[2]

    @inbounds @simd for i in axes(game.im.s.sheets[sheet].pos,2)
        game.im.s.sheets[sheet].pos[1,i] += dx
        game.im.s.sheets[sheet].pos[2,i] += dy
    end

    return
end

function moveSpritesAll!(game::GameState,d::Pos)
    for (name,sheet) in game.im.s.sheets
        sheet.pos[1:2,:] .+= d
    end

    return
end

function rotateSprite!(game::GameState,id::Symbol,rotation::Float64,absolute::Bool=false)
    s = game.im.s.sprites[id]

    if absolute
        game.im.s.sheets[s.sheet].rot[s.slot] = rotation
    else
        game.im.s.sheets[s.sheet].rot[s.slot] += rotation
    end

    return
end

function activateSprite!(game::GameState,id::Symbol)
    s = game.im.s.sprites[id]
    
    game.im.s.sheets[s.sheet].active[s.slot] = true

    return
end

function deactivateSprite!(game::GameState,id::Symbol)
    s = game.im.s.sprites[id]
    
    game.im.s.sheets[s.sheet].active[s.slot] = false

    return
end

function switchSprite!(game::GameState,id::Symbol)
    s = game.im.s.sprites[id]
    
    game.im.s.sheets[s.sheet].active[s.slot] = !game.im.s.sheets[s.sheet].active[s.slot]

    return
end

function reverseSprite!(game::GameState,id::Symbol,dir::Int,absolute::Bool=false)
    s = game.im.s.sprites[id]
    
    if absolute
        game.im.s.sheets[s.sheet].rev[dir,s.slot] = true
    else
        game.im.s.sheets[s.sheet].rev[dir,s.slot] =
            !game.im.s.sheets[s.sheet].rev[dir,s.slot]
    end

    return
end

function reverseSpriteW!(game::GameState,id::Symbol,value::Bool)
    s = game.im.s.sprites[id]
    
    game.im.s.sheets[s.sheet].rev[1,s.slot] = value

    return
end

function reverseSpriteH!(game::GameState,id::Symbol,value::Bool)
    s = game.im.s.sprites[id]
    
    game.im.s.sheets[s.sheet].rev[2,s.slot] = value

    return
end

function scaleSprite!(game::GameState,id::Symbol,w::Float64,h::Float64,absolute::Bool=false)
    s = game.im.s.sprites[id]

    if absolute
        game.im.s.sheets[s.sheet].scale[1,s.slot] = w
        game.im.s.sheets[s.sheet].scale[2,s.slot] = h
    else
        game.im.s.sheets[s.sheet].scale[1,s.slot] += w
        game.im.s.sheets[s.sheet].scale[2,s.slot] += h
    end

    return
end

function setSpriteFrame!(game::GameState,id::Symbol,frame::Int)
    s = game.im.s.sprites[id]
    
    game.im.s.sheets[s.sheet].idx[2,s.slot] = frame

    return
end

function setSpriteIdx!(game::GameState,id::Symbol,idx::Int)
    s = game.im.s.sprites[id]
    
    game.im.s.sheets[s.sheet].idx[1,s.slot] = (idx-1)*game.im.s.sheets[s.sheet].nframes+1

    return
end

function setSprite!(game::GameState,id::Symbol,idx::Int,frame::Int)
    s = game.im.s.sprites[id]
    
    game.im.s.sheets[s.sheet].idx[1,s.slot] = (idx-1)*game.im.s.sheets[s.sheet].nframes+1
    game.im.s.sheets[s.sheet].idx[2,s.slot] = frame

    return
end

function killSprite!(game::GameState,id::Symbol)
    s = game.im.s.sprites[id]
    sheet = game.im.s.sheets[s.sheet]
    
    sheet.active[1,s.slot] = false
    sheet.idx[:,s.slot] .= 0
    sheet.slots[s.slot] = false

    pop!(game.im.s.sprites,id)

    return
end

function killSprites!(game::GameState,sheet::Symbol)
    sheet = game.im.s.sheets[sheet]

    sheet.active .= false
    sheet.idx .= 0
    sheet.slots .= false

    for (id,sprite) in game.im.s.sprites
        if sprite.sheet == sheet
            pop!(game.im.s.sprites,id)
        end
    end

    return
end

function killSpritesAll!(game::GameState)
    for (name,sheet) in game.im.s.sheets
        sheet.active .= false
        sheet.idx .= 0
        sheet.slots .= false
    end

    empty!(game.im.s.sprites)

    return
end

function swapSprites!(game::GameState,name1::Symbol,name2::Symbol)
    s1 = game.im.s.sprites[name1]
    s2 = game.im.s.sprites[name2]
    S1 = game.im.s.sheets[s1.sheet]
    S2 = game.im.s.sheets[s2.sheet]
    
    # S1.idx[:,s1.slot], S2.idx[:,s2.slot] = S2.idx[:,s2.slot], S1.idx[:,s1.slot]
    S1.pos[:,s1.slot], S2.pos[:,s2.slot] = S2.pos[:,s2.slot], S1.pos[:,s1.slot]
    S1.scale[:,s1.slot], S2.scale[:,s2.slot] = S2.scale[:,s2.slot], S1.scale[:,s1.slot]
    S1.rot[:,s1.slot], S2.rot[:,s2.slot] = S2.rot[:,s2.slot], S1.rot[:,s1.slot]
    S1.alpha[:,s1.slot], S2.alpha[:,s2.slot] = S2.alpha[:,s2.slot], S1.alpha[:,s1.slot]
    S1.rev[:,s1.slot], S2.rev[:,s2.slot] = S2.rev[:,s2.slot], S1.rev[:,s1.slot]
    S1.active[:,s1.slot], S2.active[:,s2.slot] = S2.active[:,s2.slot], S1.active[:,s1.slot]

    game.im.s.sprites[name1], game.im.s.sprites[name2] =
        game.im.s.sprites[name2], game.im.s.sprites[name1]

    return
end





function getSpritePos!(game::GameState,id::Symbol)
    s = game.im.s.sprites[id]

    return game.im.s.sheets[s.sheet].pos[:,s.slot]
end

function getSpritePosW!(game::GameState,id::Symbol)
    s = game.im.s.sprites[id]

    return game.im.s.sheets[s.sheet].pos[1,s.slot]
end

function getSpritePosH!(game::GameState,id::Symbol)
    s = game.im.s.sprites[id]

    return game.im.s.sheets[s.sheet].pos[2,s.slot]
end
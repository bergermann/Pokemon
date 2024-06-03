


function loadImage(path::String)
    img = transpose(load(joinpath("textures",path)))
        
    data = zeros(N0f8,length(img)*4)
    
    w,h = size(img)

    c = 1
    for p in img
        data[c] = p.r; c += 1
        data[c] = p.g; c += 1
        data[c] = p.b; c += 1
        data[c] = p.alpha; c += 1
    end

    return data, w, h
end

function loadTexture!(game::GameState,path::String,name::Symbol)
    @assert length(game.im.t.textures) < game.im.t.maxtextures "Max textures reached!"

    tex, w, h = loadImage(path)
    
    # t = zeros(UInt32,1); glGenTextures(1,pointer(t)); t = t[1]
    t = glGenTexture()
    
    game.im.t.textures[name] = (handle=t,width=w,height=h)

    glBindTexture(GL_TEXTURE_2D,t)

    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,w,h,0,GL_RGBA,GL_UNSIGNED_BYTE,pointer(tex))

    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)

    glBindTexture(GL_TEXTURE_2D,0)

    return
end

const loadTex! = loadTex = loadTexture!

function loadTextures!(game::GameState,paths::Vector{String},names::Vector{Symbol})
    n = length(paths)

    @assert n == length(names) "Unequal lengths of pathes and names."
    @assert length(game.im.t.textures)+n <= game.im.t.maxtextures "Max textures reached!"

    ts = zeros(UInt32,n)
    glGenTextures(n,pointer(ts))

    for (i,path) in enumerate(paths)
        tex, w, h = loadImage(path)
    
        game.im.t.textures[name[i]] = (handle=ts[i],width=w,height=h)
    
        glBindTexture(GL_TEXTURE_2D,ts[i])
    
        glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,w,h,0,GL_RGBA,GL_UNSIGNED_BYTE,pointer(tex))

        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)
    end

    glBindTexture(GL_TEXTURE_2D,0)

    return
end

loadTextures!(game::GameState,dir::String,files::Vector{String},
    names::Vector{String}) = loadTextures!(game,dir.*files,names)





function loadArrayImage(path::String,width::Int,height::Int)
    img = transpose(load(joinpath("textures",path)))

    data = zeros(N0f8,length(img)*4)

    w,h = size(img)
    nw = div(w,width); nh = div(h,height)

    c = 1
    @views for j in 1:nh, i in 1:nw
        for p in img[width*(i-1)+1:width*i,height*(j-1)+1:height*j]
            data[c] = p.r; c += 1
            data[c] = p.g; c += 1
            data[c] = p.b; c += 1
            data[c] = p.alpha; c += 1
        end
    end

    return data, nw*nh
end



function loadArrayTexture!(game::GameState,path::String,name::Symbol,width::Int,height::Int;
        addempty::Bool=false)

    @assert length(game.im.t.atextures) < game.im.t.maxtextures "Max textures reached!"

    tex, l = loadArrayImage(path,width,height)

    if addempty
        prepend!(tex,zeros(N0f8,width*height*4)); l += 1
    end
    
    t = glGenTexture()
    
    game.im.t.atextures[name] = (handle=t,width=width,height=height,layers=l)

    glBindTexture(GL_TEXTURE_2D_ARRAY,t)

    glTexStorage3D(GL_TEXTURE_2D_ARRAY,1,GL_RGBA8,width,height,l)
    glTexSubImage3D(GL_TEXTURE_2D_ARRAY,0,0,0,0,width,height,l,GL_RGBA,
        GL_UNSIGNED_BYTE,pointer(tex))

    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)

    glBindTexture(GL_TEXTURE_2D_ARRAY,0)

    return
end

function loadArrayTexture!(game::GameState,dir::String,textures::Vector{String},
        name::Symbol,width::Int,height::Int; addempty::Bool=false)

    @assert length(game.im.t.atextures) < game.im.t.maxtextures "Max textures reached!"

    tex = Vector{N0f8}([]); l = 0

    if addempty
        prepend!(tex,zeros(N0f8,width*height*4)); l += 1
    end

    for texture in textures
        tex_, l_ = loadArrayImage(joinpath(dir,texture),width,height)
        append!(tex,tex_); l += l_
    end

    t = glGenTexture()
    
    game.im.t.atextures[name] = (handle=t,width=width,height=height,layers=l)

    glBindTexture(GL_TEXTURE_2D_ARRAY,t)

    glTexStorage3D(GL_TEXTURE_2D_ARRAY,1,GL_RGBA8,width,height,l)
    glTexSubImage3D(GL_TEXTURE_2D_ARRAY,0,0,0,0,width,height,l,GL_RGBA,
        GL_UNSIGNED_BYTE,pointer(tex))

    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)

    glBindTexture(GL_TEXTURE_2D_ARRAY,0)

    return
end

const loadATex! = loadATex = loadArrayTexture!


    
function deleteTexture!(game::GameState,name::Symbol)
    glDeleteTextures(1,pointer([game.im.t.textures[name]]))

    pop!(game.im.t.textures,name)

    return
end

function deleteTextures!(game::GameState,names::Vector{Symbol})
    for name in names
        deleteTexture!(game,name)
    end

    return
end

const deleteTex! = deleteTex = deleteTexture!
    
function deleteArrayTexture!(game::GameState,name::Symbol)
    glDeleteTextures(1,pointer([game.im.t.atextures[name]]))

    pop!(game.im.t.atextures,name)

    return
end

function deleteArrayTextures!(game::GameState,names::Vector{Symbol})
    for name in names
        deleteArrayTexture!(game,name)
    end

    return
end

const deleteATex! = deleteATex = deleteArrayTexture!



bindTexture(game::GameState,name::Symbol) =
    glBindTexture(GL_TEXTURE_2D,game.im.t.textures[name].handle)
bindATexture(game::GameState,name::Symbol) =
    glBindTexture(GL_TEXTURE_2D_ARRAY,game.im.t.atextures[name].handle)


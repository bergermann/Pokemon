
function getColorID(color,colors)
    return findfirst(isequal(color),colors)
end

function setupFonts(game::GameState)
    for i in 1:4
        p = joinpath("textures","fonts","")
        if !isfile(p*"$i.font")
            push!(game.im.text.fonts,Font(Dict(),0,P(0,0)))

            continue
        end

        font, (ch,data), (img,w,h) = deserialize(p*"$i.font")

        img = UInt32.(img)

        d = Dict{Char,Tuple{UInt8,UInt8,UInt8}}()

        c = 1
        for char in font
            d[char] = Tuple{UInt8,UInt8,UInt8}(data[1+3*(c-1):3*c])
            c += 1
        end

        push!(game.im.text.fonts,Font(d,ch,P(w,h)))

        glBindTexture(GL_TEXTURE_2D,game.im.text.texs[i]); checkError("setup fonts $i.1")

        glTexImage2D(GL_TEXTURE_2D,0,GL_R32UI,w,h,0,GL_RED_INTEGER,GL_UNSIGNED_INT,
            pointer(img)); checkError("setup fonts $i.2")

        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE)
        checkError("setup fonts $i.3")
    end

    glBindTexture(GL_TEXTURE_2D,0); checkError("setup fonts")

    game.im.text.ulocpos = glGetUniformLocation(game.im.programs[3],"pos")
    game.im.text.uloccolors = glGetUniformLocation(game.im.programs[3],"colors")

    return
end



function string2buffer!(buffer::Matrix,font::Font,str::AbstractString,maxchar::Int,
        wpad::Int,hpad::Int,align::Int)

    ch = font.charheight

    c = 1; l=0; x = 0; y = 0; cw = 0
    for (i,char) in enumerate(str)
        if char == '\\'
            if align == 0
                # buffer[4*l+1:4:4*c] .-= div(x,2)
                buffer[1:4:end,l+1:c] .-= div(x,2)
            elseif align == 1
                # buffer[4*l+1:4:4*c] .-= x
                buffer[1:4:end,l+1:c] .-= x
            end

            x = 0
            y += ch + hpad
            l = c-1

            continue
        end

        cx, cy, cw = font.chars[char]

        buffer[ 1,c] = x                            # 1st vertex - 1st triangle
        buffer[ 2,c] = y
        buffer[ 3,c] = cx
        buffer[ 4,c] = cy

        buffer[ 5,c] = x + cw                       # 2nd vertex
        buffer[ 6,c] = y
        buffer[ 7,c] = cx + cw
        buffer[ 8,c] = cy

        buffer[ 9,c] = x                            # 3rd vertex
        buffer[10,c] = y + ch
        buffer[11,c] = cx
        buffer[12,c] = cy + ch

        buffer[13,c] = x + cw                       # 1st vertex - 2nd triangle
        buffer[14,c] = y
        buffer[15,c] = cx + cw
        buffer[16,c] = cy

        buffer[17,c] = x                            # 2nd vertex
        buffer[18,c] = y + ch
        buffer[19,c] = cx
        buffer[20,c] = cy + ch

        buffer[21,c] = x + cw                       # 3rd vertex
        buffer[22,c] = y + ch
        buffer[23,c] = cx + cw
        buffer[24,c] = cy + ch

        x += cw + wpad
        c += 1

        if (c >= maxchar+1) || (i == length(str))
            if align == 0
                # buffer[4*l+1:4:end] .-= div(x,2)
                buffer[1:4:end,l+1:end] .-= div(x,2)
            elseif align == 1
                # buffer[4*l+1:4:end] .-= x
                buffer[1:4:end,l+1:end] .-= x
            end

            break
        end
    end

    buffer[3:4:end,:] ./= font.imsize[1]
    buffer[4:4:end,:] ./= font.imsize[2]

    return buffer
end

function setTextColors!(text::Text,
        color0::Vector{UInt8},color1::Vector{UInt8},color2::Vector{UInt8})

    text.colors[:,1] .= color0/255
    text.colors[:,2] .= color1/255
    text.colors[:,3] .= color2/255

    return
end

function setTextColors!(text::Text,
        color0::RGBA{N0f8},color1::RGBA{N0f8},color2::RGBA{N0f8})

    text.colors[:,1] = color0.r, color0.g, color0.b, color0.alpha
    text.colors[:,2] = color1.r, color1.g, color1.b, color1.alpha
    text.colors[:,3] = color2.r, color2.g, color2.b, color2.alpha

    return
end

function createText!(game::GameState,name::Symbol,font::Int,x::Int,y::Int,layer::Int,
        str::AbstractString,color1::Vector{UInt8},color2::Vector{UInt8};
        maxchar::Int=0,active::Bool=true,nchar::Int=-1,wpad::Int=0,hpad::Int=0,
        color0::Vector{UInt8}=UInt8[0,0,0,0],align::Int=-1)

    if maxchar == 0
        maxchar = length(str)
    end

    if nchar < 0
        nchar = maxchar
    end

    t = Text(active,x,y,layer,font,maxchar,nchar,wpad,hpad)

    setTextColors!(t,color0,color1,color2)

    # buffer = MMatrix{24,maxchar}(zeros(Float32,24,maxchar))
    buffer = zeros(Float32,24,maxchar)
    string2buffer!(buffer,game.im.text.fonts[font],str,maxchar,wpad,hpad,align)

    glBindVertexArray(t.vao)
    glBindBuffer(GL_ARRAY_BUFFER,t.vbo)

    glVertexAttribPointer(0,2,GL_FLOAT,false,16,ptr(0))
    glVertexAttribPointer(1,2,GL_FLOAT,false,16,ptr(8))

    glEnableVertexAttribArray(0)
    glEnableVertexAttribArray(1)

    glBufferData(GL_ARRAY_BUFFER,sizeof(buffer),pointer(buffer),GL_DYNAMIC_DRAW)    

    glBindVertexArray(0)
    glBindBuffer(GL_ARRAY_BUFFER,0)

    game.im.text.texts[name] = t

    return
end

function setText!(game::GameState,name::Symbol,str::AbstractString;
        nchar::Int=-1,align::Int=-1)
        
    t = game.im.text.texts[name]

    if nchar < 0
        nchar = t.maxchar
    end

    t.nchar = nchar

    # buffer = MMatrix{24,t.maxchar}(zeros(Float32,24,t.maxchar))
    buffer = zeros(Float32,24,t.maxchar)
    string2buffer!(buffer,game.im.text.fonts[t.font],str,t.maxchar,
        t.wpad,t.hpad,align)

    glBindVertexArray(t.vao)
    glBindBuffer(GL_ARRAY_BUFFER,t.vbo)

    glBufferSubData(GL_ARRAY_BUFFER,0,sizeof(buffer),pointer(buffer))  

    glBindVertexArray(0)
    glBindBuffer(GL_ARRAY_BUFFER,0)

    return
end

function deleteText!(game::GameState,name::Symbol)
    glDeleteVertexArrays(1,pointer([game.im.text.texts[name].vao]))
    glDeleteBuffers(1,pointer([game.im.text.texts[name].vbo]))

    pop!(game.im.text.texts,name)

    return
end

function deleteTextsAll!(game::GameState)
    v = values(game.im.text.texts)
    glDeleteVertexArrays(length(v),pointer((v->v.vao).(v)))
    glDeleteBuffers(length(v),pointer((v->v.vbo).(v)))
    
    empty!(game.im.text.texts)

    return
end

function switchText!(game::GameState,name::Symbol)
    game.im.text.texts[name].active = !game.im.text.texts[name].active

    return
end

function activateText!(game::GameState,name::Symbol)
    game.im.text.texts[name].active = true

    return
end

function deactivateText!(game::GameState,name::Symbol)
    game.im.text.texts[name].active = false

    return
end

function moveText!(game::GameState,name::Symbol,w::Int,h::Int,absolute::Bool=false)
    if absolute
        game.im.text.texts[name].pos[1:2] .= w,h
    else
        game.im.text.texts[name].pos[1:2] .+= w,h
    end

    return
end

function moveTextW!(game::GameState,name::Symbol,w::Int,absolute::Bool=false)
    if absolute
        game.im.text.texts[name].pos[1] = w
    else
        game.im.text.texts[name].pos[1] += w
    end

    return
end

function moveTextH!(game::GameState,name::Symbol,h::Int,absolute::Bool=false)
    if absolute
        game.im.text.texts[name].pos[2] = h
    else
        game.im.text.texts[name].pos[2] += h
    end

    return
end


function getColourID(colour,colours)
    return findfirst(isequal(colour),colours)
end

function setupFonts(game::GameState)
    for i in 1:3
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
    game.im.text.uloccolours = glGetUniformLocation(game.im.programs[3],"colours")

    return
end



function string2buffer!(buffer::MMatrix,font::Font,str::String,maxchar::Int,
        wpad::Int,hpad::Int)

    ch = font.charheight

    c = 1; x = 0; y = 0
    for char in str
        if char == '/'
            x = 0
            y += ch + hpad

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

        if c == maxchar+1
            break
        end
    end

    buffer[3:4:end,:] ./= font.imsize[1]
    buffer[4:4:end,:] ./= font.imsize[2]

    return buffer
end

function setTextColours!(text::Text,
        colour0::Vector{UInt8},colour1::Vector{UInt8},colour2::Vector{UInt8})

    text.colours[:,1] .= colour0/255
    text.colours[:,2] .= colour1/255
    text.colours[:,3] .= colour2/255

    return
end

function setTextColours!(text::Text,
        colour0::RGBA{N0f8},colour1::RGBA{N0f8},colour2::RGBA{N0f8})

    text.colours[:,1] = colour0.r, colour0.g, colour0.b, colour0.alpha
    text.colours[:,2] = colour1.r, colour1.g, colour1.b, colour1.alpha
    text.colours[:,3] = colour2.r, colour2.g, colour2.b, colour2.alpha

    return
end

function createText!(game::GameState,name::Symbol,font::Int,x::Int,y::Int,layer::Int,
        str::String,colour1::Vector{UInt8},colour2::Vector{UInt8};
        maxchar::Int=128,active::Bool=true,nchar::Int=-1,wpad::Int=1,hpad::Int=0,
        colour0::Vector{UInt8}=UInt8[0,0,0,0])

    if nchar < 0
        nchar = maxchar
    end

    t = Text(active,x,y,layer,font,maxchar,nchar,wpad,hpad)

    setTextColours!(t,colour0,colour1,colour2)

    buffer = MMatrix{24,maxchar}(zeros(Float32,24,maxchar))
    string2buffer!(buffer,game.im.text.fonts[font],str,maxchar,wpad,hpad)

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

function setText!(game::GameState,name::Symbol,str::String; nchar::Int=-1)
    t = game.im.text.texts[name]

    if nchar < 0
        nchar = t.maxchar
    end

    t.nchar = nchar

    buffer = MMatrix{24,maxchar}(zeros(Float32,24,maxchar))
    string2buffer!(buffer,game.im.text.fonts[t.font],str,t.maxchar,
        t.wpad,t.hpad)

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

function shadertype(path::AbstractString)
    p, ext = splitext(path)
    ext == ".comp" && return GL_COMPUTE_SHADER
    ext == ".vert" && return GL_VERTEX_SHADER
    ext == ".frag" && return GL_FRAGMENT_SHADER
    ext == ".geom" && return GL_GEOMETRY_SHADER
    @error "$ext not a valid shader extension."
end

function getProgram(paths::AbstractString...)
    program = glCreateProgram()
    checkError("P.1")

    ids = UInt32[]

    for (i,file) in enumerate(paths)
        type = shadertype(file)
        id = glCreateShader(type); checkError("P.1.$i.1")
        
        source = Vector{UInt8}(read(open(joinpath(PATH,"src","rendering","shaders",file)),String))
        sourceptrs = Ptr{UInt8}[pointer(source)]
        glShaderSource(id, 1, sourceptrs, Ref{GLint}(length(source)))
        checkError("P.1.$i.2")

        glCompileShader(id); checkError("P.1.$i.3")

        glAttachShader(program,id); checkError("P.1.$i.4")
        push!(ids,id)
    end

    glLinkProgram(program); checkError("P.2")
    
    validateLink(program)

    for id in ids
        glDetachShader(program,id); checkError("P.3.$id.1")
        glDeleteShader(id); checkError("P.3.$id.2")
    end

    validateProgram(program)

    return program
end
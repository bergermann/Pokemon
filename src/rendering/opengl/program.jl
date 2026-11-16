
function shadertype(path::AbstractString)
    p, ext = splitext(path)
    ext == ".comp" && return GL_COMPUTE_SHADER
    ext == ".vert" && return GL_VERTEX_SHADER
    ext == ".frag" && return GL_FRAGMENT_SHADER
    ext == ".geom" && return GL_GEOMETRY_SHADER
    @error "$ext not a valid shader extension."
end

function getProgram(paths::AbstractString...)
    program = glCreateProgram(); checkError("P.1")

    shaders = UInt32[]

    for (i,file) in enumerate(paths)
        type = shadertype(file)
        shader = glCreateShader(type); checkError("P.1.$i.1")

        source = Vector{UInt8}(read(open(joinpath("src","rendering","shaders",file)),String))
        sourceptrs = Ptr{UInt8}[pointer(source)]
        glShaderSource(shader, 1, sourceptrs, Ref{GLint}(length(source)))
        checkError("P.1.$i.2")

        glCompileShader(shader); checkError("P.1.$i.3")

        glAttachShader(program,shader); checkError("P.1.$i.4")
        push!(shaders,shader)
    end

    glLinkProgram(program); checkError("P.2.1")

    validateLink(program); checkError("P.2.2")
    validateProgram(program); checkError("P.2.3")

    for shader in shaders
        glDetachShader(program,shader); checkError("P.3.$shader.1")
        glDeleteShader(shader); checkError("P.3.$shader.2")
    end

    return program
end
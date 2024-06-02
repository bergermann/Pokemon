

mutable struct Textures
    maxtextures::Int

    textures::Dict{Symbol,NamedTuple{(:handle,:width,:height),Tuple{UInt32,Int,Int}}}
    atextures::Dict{Symbol,NamedTuple{(:handle,:width,:height,:layers),
        Tuple{UInt32,Int,Int,Int}}}

    function Textures(maxtextures)
        new(maxtextures,Dict(),Dict())
    end
end

mutable struct Im
    window::GLFW.Window
    windowsize::NamedTuple{(:width,:height),Tuple{Int32,Int32}}
    bbsize::NamedTuple{(:h,:w),Tuple{Int32,Int32}}
    screenprojection::Mat4{Float32}

    programs::Vector{UInt32}

    l::Layers

    t::Textures
    
    b::Backgrounds
    c::Chunks
    s::Sprites
    f::Frames
    text::Texts

    function Im(windowscale::Int=4,renderdistance::Int=2,maxtextures::Int=64;)
        window = genWindow(windowscale); checkError(1)
        windowsize = GLFW.GetWindowSize(window)
        GLFW.SetWindowSizeCallback(window,resizeCallback)
    
        projection = Matn(Float32,1.,1.,1.,1.)
        # projection *= trans(Float32,-1,-1,0)
        # projection *= scale(Float32,240,160,1)
        # projection *= scale(Float32,2/240,2/160,1)
    
        programs = zeros(UInt32,16)
    
        programs[1] = getProgram("map.vert","map.geom","basic array.frag")
        checkError("program creation chunks")
        programs[2] = getProgram("frames.vert","basic.frag")
        checkError("program creation frames")
        programs[3] = getProgram("text.vert","text.frag")
        checkError("program creation text")
        programs[4] = getProgram("sprites.vert","sprites.geom","basic array.frag")
        checkError("program creation sprites")
        programs[5] = getProgram("background.vert","basic.frag")
        checkError("program creation background")
        programs[15] = getProgram("basic.vert","postprocess.frag")
        checkError("program creation postprocess")
        programs[16] = getProgram("basic.vert","basic.frag")
        checkError("program creation basic")
        
        backbuffersize = (h=Int32(160),w=Int32(240))
    
        new(
            window,
            windowsize,
            backbuffersize,
            projection,
    
            programs,

            Layers(),
    
            Textures(maxtextures),
            
            Backgrounds(),
            Chunks(renderdistance),
            Sprites(),
            Frames(),
            Texts(),
        )
    end
end



using Serialization


const tilesetordering = Dict(
    "base" =>               (0x01,0x0000,0x10),
    "ledges" =>             (0x02,0x0010,0x20),
    "edges" =>              (0x03,0x0030,0x30),
    "vegetation1" =>        (0x04,0x0060,0x60),
    "decorations1" =>       (0x05,0x00c0,0x60),
    "grass1" =>             (0x06,0x0120,0x30),
    "grass2"  =>            (0x07,0x0150,0x50),
    "borders1" =>           (0x08,0x01a0,0x20),

    "patchesgrasslight" =>  (0x09,0x01c0,0x20),
    "patchesberry" =>       (0x0a,0x01e0,0x40),

    "pokecenter" =>         (0x0b,0x0220,0x40),
    "gym1" =>               (0x0c,0x0260,0x40),
    "lab1" =>               (0x0d,0x02a0,0x40),
    "house1" =>             (0x0e,0x02e0,0x50),
    "house2" =>             (0x0f,0x0330,0x60),

    "water1" =>             (0x10,0x0390,0xc0),
    "flowers1" =>           (0x11,0x0450,0x10),
    "flowers2" =>           (0x12,0x0460,0x40),
    "flowers3" =>           (0x13,0x04a0,0x40),

    "interior1" =>          (0x14,0x0600,0x0140),
)


function readlines(file,n::Integer)
    for _ in 1:n
        readline(file)
    end
end

function extractMaps(ids::Integer...)
    for id in ids
        println("opening map $id")
        file = open("maps/$id.tmx")
        
        try
        offh = 0
        offe = 0

        d = []
        tilesets = []
            
        readlines(file,5)
        println("reading ordering")
        s = split(readline(file)[3:end-2],' ')

        while s[1] == "tileset"
            fg = parse(Int,s[2][11:end-1])
            name = String(s[3][9:end-5])

            if name == "heights"
                offh = fg
            elseif name == "events"
                offe = fg
            else
                push!(d,(name,fg))
                push!(tilesets,tilesetordering[name][1])
            end

            s = split(readline(file)[3:end-2],' ')
        end
        println("reading map size")
        
        w = parse(Int,s[4][8:end-1])
        h = parse(Int,s[5][9:end])

        tm = Pokemon.TileMap(h,w)
        tm.tilesets[tilesets] .= true

        println(h,", ",w)

        readline(file)
        
        for i in 1:5
            println("reading tilemap $i")
            m = zeros(Int,h,w)

            for j in 1:h
                s = readline(file)
                s_ = parse.(UInt16,split(s,',')[1:end-1*(j!=h)])
                m[j,:] .= s_
            end

            m[m .== -1] .= 0

            setTileIDs!(tm.map[i],m,tilesetordering,d)

            readlines(file,4)
        end

        println("reading heightmap")

        for j in 1:h
            s = readline(file)
            tm.height[j,:] .= UInt8.(parse.(Int,split(s,',')[1:end-1*(j!=h)]).-offh)
        end

        readlines(file,4)

        println("reading collision map")
        
        for j in 1:h
            s = readline(file)
            tm.collision[j,:] .= UInt8.(parse.(Int,split(s,',')[1:end-1*(j!=h)]).-offe)
        end

        close(file)

        serialize("maps/$id/tilemap.map",tm)

        println("done")
        catch e
        println(e)
        close(file)
        end
    end
end


function setTileIDs!(tm::Matrix{UInt16},m::Matrix{Int},ordering::Dict,
        d::Vector)
    println("setting tile ids")
    # println.("d:\n",d,"\n")
    for d_ in d
        state = d_[2]
        ord = ordering[d_[1]]
        offset = ord[2]-state

        println(d_,", ",state,", ",ord,", ",offset)

        r = state:(state+ord[3])

        tm[m .∈ (r,)] .= UInt16.(m[m .∈ (r,)] .+ offset)

        tm[tm .== 0xffff] .= 0x0000
    end
end
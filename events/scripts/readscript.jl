using Serialization

struct EventQueue
    sheets::Vector{Symbol}
    npcs::Vector{Symbol}
    sprites::Vector{Symbol}

    flags::FlagSet

    queue::Matrix{Int}
end

commands = Dict{String,Int}(
    "endevent"      => 0,
    "setbranch"     => 1,
    "dialogue"      => 2,
    "choice"        => 3,

    "mcwalk"        => 5,
    "mcturn"        => 6,
    "mcemote"       => 7,

    "npcadd"        => 10,
    "npcadd"        => 11,
    "npcdel"        => 12,
    "npcwalk"       => 13,
    "npcturn"       => 14,
    "npcemote"      => 15,

    "spriteadd"     => 20,
    "spritedel"     => 21,
    "spritemove"    => 22,
    "spriteidx"     => 23,
    "spriteframe"   => 24,

    "cameramove"    => 26,
    "camerazoom"    => 27,
    "teleport"      => 28,
    "delay"         => 29,
    "setflag"       => 30,
    "setcounter"    => 31,

    "gainitem"      => 33,
    "gainpkmn"      => 34,

    "startbattle"   => 36,
)

dirs = Dict{String,Int}(
    "up"    => 1,
    "right" => 2,
    "down"  => 3,
    "left"  => 4,
)

emotes = Dict{String,Int}(
    "!"     => 1,
    "?"     => 2,
    "jump"  => 3,
)

# command: [branch, command, data...]

function readEvent(file::String)
    if occursin("commands",file); return; end

    f = open(joinpath("events","scripts",file)); lines = readlines(f); close(f)
    name = file[1:end-4]

    strf = open(joinpath("str","ger","events",file),"w+")

    queue = zeros(Int,10,0); command = zeros(Int,10)

    sheets = Symbol[]; npcs = Symbol[]; sprites = Symbol[]
    flags = []; counters = []; seen = []; caught = []; has = []
    cline = 1; csheet = 1; cnpc = 1; csprite = 1
    branch = 0

    for line in lines
        l = split(line," ")
        if length(line) == 0 || line[1] == "-" || line[1] == " "; continue; end
        
        c = l[1]

        if c == "flag"
            push!(flags,parse.(Int,(l[2],l[3],l[4]))); continue
        elseif c == "counter"
            push!(counters,parse.(Int,(l[2],l[3],l[4]))); continue
        elseif c == "hasdex"
            if l == "seen"
                push!(seen,parse(Int,l[2])); continue
            else
                push!(caught,parse(Int,l[2])); continue
            end
        elseif c == "haspkmn"
            push!(has,parse(Int,l[2])); continue
        end

        if c == "#BRANCH"; branch = parse(Int,l[2]); continue; end

        command .= 0; command[1] = branch; command[2] = commands[c]

        if c == "endevent"
        elseif c == "setbranch"
            command[3] = parse(Int,l[2])
        elseif c == "dialogue"
            command[3] = cline; cline += 1
            str = getStrings(line)
            write(strf,str[1])
        elseif c == "choice"
            str = getStrings(line)
            command[3] = parse(Int,l[3])
            command[4] = cline; cline += length(str) 
            command[5] = length(str)-1;
            write.(strf,str) 
        elseif c == "mcwalk"
            command[3] = dirs[l[2]]
            command[4] = parse(Int,l[3])
        elseif c == "mcturn"
            command[3] = dirs[l[2]]
        elseif c == "mcemote"
            command[3] = emotes[l[2]]
        elseif c == "npcadd"
            id = Symbol(l[2])
            @assert !occursin(id,npcs) "NPC already exists."
            push!(npcs,id); command[3] = cnpc; cnpc += 1
            if length(l) == 6
                command[4:7] .= parse.(Int,l[3:end])
            else
                command[4:9] .= parse.(Int,l[3:end]); command[10] = 1
            end
        elseif c == "npcdel"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id,npcs))
            @assert !isnothing(id_) "NPC not found."
            command[3] = id_
        elseif c == "npcwalk"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id,npcs))
            @assert !isnothing(id_) "NPC not found."
            command[3] = id_
            command[4:5] .= parse.(Int,l[3:4])
        elseif c == "npcturn"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id,npcs))
            @assert !isnothing(id_) "NPC not found."
            command[3] = id_
            command[4] .= parse.(Int,l[3])
        elseif c == "npcemote"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id,npcs))
            @assert !isnothing(id_) "NPC not found."
            command[3] = id_
            command[4] = emotes[l[3]]
        elseif c == "spriteadd"
        elseif c == "spritedel"
        elseif c == "spritemove"
        elseif c == "spriteidx"
        elseif c == "spriteframe"
        elseif c == "cameramove"
        elseif c == "camerazoom"
        elseif c == "teleport"
            command[3:8] = parse.(Int,l[2:end])
        elseif c == "delay"
            command[3] = parse(Int,l[2])
        elseif c == "setflag"
            command[3:5] = parse.(Int,l[2:4])
        elseif c == "setcounter"
            command[3:4] = parse.(Int,l[2:3])
        elseif c == "gainitem"
            command[3:4] = parse.(Int,l[2:3])
        elseif c == "gainpkmn"
            command[3:4] = parse.(Int,l[2:3])
        elseif c == "startbattle"
            command[3] = parse(Int,l[2])
        end
            
        queue = hcat(queue,command)
    end

    F = FlagSet(flags,counters,seen,caught,has)
    event = EventQueue(sheets,npcs,sprites,F,queue)

    serialize(joinpath("events",name*".eq"),event)

    return
end

function getStrings(str::String)
    n = count("\"",str)
    @assert iseven(n) "Uneven number of quotations detected."

    s = String[]; idx2 = 0
    for _ in 1:div(n,2)
        idx1 = findnext('\"',str,idx2+1)
        idx2 = findnext('\"',str,idx1+1)
        push!(s,str[idx1+1:idx2-1])
    end

    return s
end
using Serialization

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
    "spritereverse" => 25,
    "spriterotate"  => 26,

    "cameramove"    => 30,
    "camerazoom"    => 31,
    "teleport"      => 32,
    "delay"         => 33,
    "setflag"       => 34,
    "setcounter"    => 35,

    "gainitem"      => 37,
    "gainpkmn"      => 38,

    "startbattle"   => 40,
)

dirnames = Dict{String,Int}(
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

flagtypes = Dict{String,Int}(
    "general"   => 1,
    "progress"  => 2,
    "items"     => 3,
    "trainers"  => 4,
)

# command: [branch, command, data...]

function readEvent(file::String)
    if occursin("commands",file) || occursin(".jl",file); return; end

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
        if length(line) == 0 || line[1] == '-' || line[1] == ' '; continue; end
        
        c = l[1]

        if c == "flag"
            flag = (parse(Int,l[2]),flagtypes[l[3]],Int(parse(Bool,l[4])))
            push!(flags,flag); continue
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
            write(strf,str[1],"\n")
        elseif c == "choice"
            str = getStrings(line)
            command[3] = parse(Int,l[2])
            command[4] = cline; cline += length(str) 
            command[5] = length(str)-1;
            for str_ in str; write(strf,str_,"\n"); end
        elseif c == "mcwalk"
            command[3] = dirnames[l[2]]
            command[4] = parse(Int,l[3])
        elseif c == "mcturn"
            command[3] = dirnames[l[2]]
        elseif c == "mcemote"
            command[3] = emotes[l[2]]
        elseif c == "npcadd"
            id = Symbol(l[2])
            @assert !(id in npcs) "NPC already exists."
            push!(npcs,id); command[3] = cnpc; cnpc += 1
            if length(l) == 6
                command[4:6] .= parse.(Int,l[3:end-1])
                command[7] = dirnames[l[end]]
            else
                command[4:8] .= parse.(Int,l[3:end-1]); command[10] = 1
                command[9] = dirnames[l[end]]
            end
        elseif c == "npcdel"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id),npcs)
            @assert !isnothing(id_) "NPC not found."
            command[3] = id_
        elseif c == "npcwalk"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id),npcs)
            @assert !isnothing(id_) "NPC not found."
            command[3] = id_
            command[4] = dirnames[l[3]]
            command[5] = parse(Int,l[4])
        elseif c == "npcturn"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id),npcs)
            @assert !isnothing(id_) "NPC not found."
            command[3] = id_
            command[4] = dirnames[l[3]]
        elseif c == "npcemote"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id),npcs)
            @assert !isnothing(id_) "NPC not found."
            command[3] = id_
            command[4] = emotes[l[3]]
        elseif c == "spriteadd"
            sheet = Symbol(l[2])
            sheet_ = findfirst(isequal(sheet),sheets)
            if isnothing(sheet_); push!(sheets,sheet); sheet_ = csheet; csheet += 1; end
            command[3] = sheet_
            id = Symbol(l[3])
            id_ = findfirst(isequal(id),sprites)
            @assert isnothing(id_) "Sprite already exists."
            push!(sprites,id); command[4] = csprite; csprite += 1
        elseif c == "spritedel"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id),sprites)
            @assert !isnothing(id_) "Sprite not found."
            command[3] = id_
        elseif c == "spritemove"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id),sprites)
            @assert !isnothing(id_) "Sprite not found."
            command[3] = id_
            command[4:6] .= parse.(Int,l[3:5])
        elseif c == "spriteidx"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id),sprites)
            @assert !isnothing(id_) "Sprite not found."
            command[3] = id_
            command[4] = parse(Int,l[3])
        elseif c == "spriteframe"
            id = Symbol(l[2])
            id_ = findfirst(isequal(id),sprites)
            @assert !isnothing(id_) "Sprite not found."
            command[3] = id_
            command[4] = parse(Int,l[3])
        elseif c == "cameramove"
            command[3:5] .= parse(Int,l[2:end])
        elseif c == "camerazoom"
            command[3] = parse(Int,l[2])
        elseif c == "teleport"
            command[3:8] .= parse.(Int,l[2:end])
        elseif c == "delay"
            command[3] = parse(Int,l[2])
        elseif c == "setflag"
            command[3:5] .= parse.(Int,l[2:4])
        elseif c == "setcounter"
            command[3:4] .= parse.(Int,l[2:3])
        elseif c == "gainitem"
            command[3:4] .= parse.(Int,l[2:3])
        elseif c == "gainpkmn"
            command[3:4] .= parse.(Int,l[2:3])
        elseif c == "startbattle"
            command[3] = parse(Int,l[2])
        end
            
        queue = hcat(queue,command)
    end

    close(strf)

    F = Pokemon.FlagSet(; flags=flags,counters=counters,hasseen=seen,hascaught=caught,inteam=has)
    event = Pokemon.EventQueue(sheets,npcs,sprites,F,queue)

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

function readEvents()
    for file in readdir("events/scripts")
        readEvent(file)
    end

    return
end

# readEvent("test.txt")
readEvents()

# ev = deserialize("events/test.eq")




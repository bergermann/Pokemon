

const P = Pos = Position = Position = MVector{2,Int}

Base.println(p::Position) = println("P($(p[1]),$(p[2]))")



mutable struct CallbackFunction
    id::Symbol

    active::Bool

    func::Function
    args::Tuple

    function CallbackFunction()
        new(Symbol(),false,emptyCallback,())
    end

    function CallbackFunction(func)
        new(Symbol(),false,func,())
    end

    function CallbackFunction(func,args)
        new(Symbol(),false,func,args)
    end

    function CallbackFunction(id,func,args)
        new(id,true,func,args)
    end

    function CallbackFunction(id,active,func,args)
        new(id,active,func,args)
    end
end

const F = CallbackFunction

mutable struct Counter
    id::Symbol
    c::Int

    function Counter(id::Symbol)
        new(id,0)
    end

    function Counter(id::Symbol,n::Int)
        new(id,n)
    end

    function Counter()
        new(Symbol(),0)
    end
end




mutable struct ArrayList{T}
    data::Vector{T}
    idx::Int

    function ArrayList(T::Type,n::Int)
        new{T}(Vector{T}(undef,n),0)
    end
end

function Base.getindex(a::ArrayList, inds...)
    return getindex(a.data, inds...)
end

function Base.setindex!(a::ArrayList, x, inds...)
    return setindex!(a.data,x,inds...)
end

function Base.getindex(a::ArrayList,id::Symbol)
    return getindex(a.data, findfirst(x -> x.id==id, a.data))
end

function Base.setindex!(a::ArrayList, x, id::Symbol)
    return setindex!(a.data,x,findfirst(x -> x.id==id, a.data))
end

function Base.eachindex(a::ArrayList)
    return eachindex(a.data[1:a.idx])
end

function Base.push!(a::ArrayList, x)
    if a.idx >= length(a.data)           
        error("ArrayList is full, can't push new element."); return
    end

    a.idx += 1
    a.data[a.idx] = x

    return
end

function Base.pushfirst!(a::ArrayList,x)
    if a.idx >= length(a.data)
        error("ArrayList is full, can't push new element."); return
    end

    a.idx += 1
    a.data[2:a.idx] = a.data[1:a.idx-1]
    a.data[1] = x

    return
end

function pushat!(a::ArrayList,x,idx::Int)
    if a.idx >= length(a.data)
        error("ArrayList is full, can't push new element."); return
    end

    a.idx += 1
    a.data[idx+1:a.idx] = a.data[idx:a.idx-1]
    a.data[idx] = x

    return
end

function Base.pop!(a::ArrayList)
    if a.idx == 0
        # error("ArrayList is empty, can't pop element.");
        return
    end

    a.data[a.idx] = eltype(a.data).name.wrapper()
    a.idx -= 1

    return
end

function Base.popat!(a::ArrayList,id::Symbol)
    if a.idx == 0
        # error("ArrayList is empty, can't pop element."); return
        return
    end
    i = findfirst(x -> x.id==id, a.data[1:a.idx])
    if isnothing(i); return; end

    a.data[i:a.idx-1] = a.data[i+1:a.idx]
    a[a.idx] = eltype(a.data).name.wrapper()

    a.idx -= 1

    return
end

function Base.popat!(a::ArrayList,ids::Symbol...)
    for id in ids
        popat!(a,id)
    end

    return
end

function Base.popat!(a::ArrayList,i::Int)
    if a.idx == 0
        error("ArrayList is empty, can't pop element."); return
    elseif i < 1 || i > a.idx
        error("Invalid index, can't pop element."); return
    end

    a[i] = eltype(a.data).name.wrapper()

    a.data[i:a.idx-1] = a.data[i+1:a.idx-1]
    a.idx -= 1

    return
end

function popall!(a::ArrayList)
    for i in 1:a.idx
        a.data[i] = eltype(a.data).name.wrapper()
    end

    a.idx = 0

    return
end

function Base.popfirst!(a::ArrayList)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    if a.idx == 1
        a.data[1] = eltype(a.data).name.wrapper()
        a.idx -= 1

        return
    end

    a.data[1:a.idx-1] = a.data[2:a.idx]
    a.data[a.idx] = eltype(a.data).name.wrapper()
    a.idx -= 1

    return
end

function swap!(a::ArrayList,idx1::Int,idx2::Int)
    a[idx1], a[idx2] = a[idx2], a[idx1]

    return
end

function swap!(a::ArrayList,id1::Symbol,id2::Symbol)
    a[id1], a[id2] = a[id2], a[id1]

    return
end

function swapfields!(struct1,struct2,fieldname::Symbol)
    x = getfield(struct1,fieldname); y = getfield(struct2,fieldname)
    setfield!(struct1,fieldname,y); setfield!(struct2,fieldname,x)

    return
end

function swapfields!(a::ArrayList,fieldname::Symbol,id1::Symbol,id2::Symbol)
    swapfields!(a[id1],a[id2],fieldname)

    return
end

function Base.permute!(a::ArrayList,p::AbstractVector)
    @views permute!(a.data[1:a.idx],p)
end

function Base.findfirst(a::ArrayList,id::Symbol)
    return findfirst(x->x.id==id,a[1:a.idx])
end

function Base.in(item,a::ArrayList)
    return in(item,a.data[1:a.idx])
end

function Base.iterate(a::ArrayList)
    return @views iterate(a.data[1:a.idx])
end

function Base.iterate(a::ArrayList,t::Tuple{Any,Any})
    return @views iterate(a.data[1:a.idx],t)
end

function Base.length(a::ArrayList)
    return a.idx
end


function Base.print(a::ArrayList)
    println("")
    println("Type: ",eltype(a.data))
    println("Len:  ",a.idx)
    println("Max:  ",length(a.data))

    for i in 1:a.idx
        println(a.data[i])
    end

    return
end

Base.println(a::ArrayList) = begin print(a); println("") end




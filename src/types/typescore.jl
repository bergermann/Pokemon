
mutable struct Position
    h::Int32
    w::Int32

    function Position()
        new(0,0)
    end

    function Position(h,w)
        new(h,w)
    end
end

const P = Position

Base.copy(p::Position) = Position(p.h,p.w)

Base.println(p::Position) = println("P($(p.h),$(p.w))")

function Base.isequal(p1::Position,p2::Position)
    return (p1.h == p2.h) && (p1.w == p2.w)
end

function Base.isequal(p1::Position,p2::Position,dh::Int,dw::Int)
    return (p1.h+dh == p2.h) && (p1.w+dw == p2.w)
end

function Base.isequal(p1::Position,p2::Position,dp::Position)
    return (p1.h+dp.h == p2.h) && (p1.w+dp.w == p2.w)
end

function posAdd(a::Position,b::Position)
    return Position(a.h+b.h,a.w+b.w)
end

function posAdd!(a::Position,b::Position)
    a.h += b.h; a.w += b.w

    return
end

function posAdd!(p::Position,h::Int,w::Int)
    p.h += h; p.w += w

    return
end

function posSub(a::Position,b::Position)
    return Position(a.h-b.h,a.w-b.w)
end

function posSub!(a::Position,b::Position)
    a.h -= b.h; a.w -= b.w

    return
end

function posMult(p::Position,n::Signed)
    return Position(n*p.h,n*p.w)
end

function posMult!(p::Position,n::Signed)
    p.h *= n; p.w *= n

    return
end

function posAddMult(a::Position,b::Position,n::Signed)
    return P(a.h+b.h*n,a.w+b.w*n)
end

function posAddMult!(a::Position,b::Position,n::Signed)
    a.h += b.h*n; a.w += b.w*n

    return
end

function setPos!(pos::Position,h::Int,w::Int)
    pos.h = h
    pos.w = w

    return
end

function swap!(p1::Position,p2::Position)
    p1.h, p2.h = p2.h, p1.h
    p1.w, p2.w = p2.w, p1.w

    return
end



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
    setindex!(a.data,x,inds...)
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
        error("ArrayList is full, can't push new element.")
    end

    a.idx += 1
    a.data[a.idx] = x
end

function Base.pushfirst!(a::ArrayList,x)
    if a.idx >= length(a.data)
        error("ArrayList is full, can't push new element.")
    end

    a.idx += 1
    a.data[2:a.idx] = a.data[1:a.idx-1]
    a.data[1] = x
end

function pushat!(a::ArrayList,x,idx::Int)
    if a.idx >= length(a.data)
        error("ArrayList is full, can't push new element.")
    end

    a.idx += 1
    a.data[idx+1:a.idx] = a.data[idx:a.idx-1]
    a.data[idx] = x
end

function Base.pop!(a::ArrayList)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    a.data[a.idx] = eltype(a.data).name.wrapper()
    a.idx -= 1
end

function Base.popat!(a::ArrayList,id::Symbol)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    end

    i = findfirst(x -> x.id==id, a.data[1:a.idx])
    a.data[i:a.idx-1] = a.data[i+1:a.idx]

    a[a.idx] = eltype(a.data).name.wrapper()

    a.idx -= 1
end

function Base.popat!(a::ArrayList,ids::Symbol...)
    for id in ids
        popat!(a,id)
    end
end

function Base.popat!(a::ArrayList,i::Int)
    if a.idx == 0
        error("ArrayList is empty, can't pop element.")
    elseif i < 1 || i > a.idx
        error("Invalid index, can't pop element.")
    end

    a[i] = eltype(a.data).name.wrapper()

    a.data[i:a.idx-1] = a.data[i+1:a.idx-1]
    a.idx -= 1
end

function popall!(a::ArrayList)
    for i in 1:a.idx
        a.data[i] = eltype(a.data).name.wrapper()
    end

    a.idx = 0
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



function Base.print(a::ArrayList)
    println("")
    println("Type: ",eltype(a.data))
    println("Len:  ",a.idx)
    println("Max:  ",length(a.data))

    for i in 1:a.idx
        println(a.data[i])
    end
end

Base.println(a::ArrayList) = begin print(a); println("") end





mutable struct Counters
    frame::UInt
    c::ArrayList{Counter}

    function Counters(n::Int)
        new(0,ArrayList(Counter,n))
    end
end
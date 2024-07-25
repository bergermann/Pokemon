
using StaticArrays: MVector, MMatrix, MArray, SVector, SMatrix, SArray

const P = Pos = Position = Position = MVector{2,Int}

import Base.getindex
Base.getindex(A::AbstractMatrix,p::Position) = Base.getindex(A,p[1],p[2])
Base.getindex(A::AbstractMatrix,p::Position,l::Int) = Base.getindex(A,p[1],p[2],l)

Base.println(p::Position) = println("P($(p[1]),$(p[2]))")

const Mat2{T} = MMatrix{2,2,T}
const Vec2{T} = MVector{2,T}
const Mat3{T} = MMatrix{3,3,T}
const Vec3{T} = MVector{3,T}
const Mat4{T} = MMatrix{4,4,T}
const Vec4{T} = MVector{4,T}

function Matn(diag::Number...)
    l = length(diag)
    m = MMatrix{l,l}(zeros(eltype(diag),l,l))

    for d in eachindex(diag)
        m[d,d] = diag[d]
    end

    return m
end

function Matn(T::Type,diag::Number...)
    l = length(diag)
    m = MMatrix{l,l}(zeros(T,l,l))

    for d in eachindex(diag)
        m[d,d] = diag[d]
    end

    return m
end

const SMat2{T} = SMatrix{2,2,T}
const SVec2{T} = SVector{2,T}
const SMat3{T} = SMatrix{3,3,T}
const SVec3{T} = SVector{3,T}
const SMat4{T} = SMatrix{4,4,T}
const SVec4{T} = SVector{4,T}

function trans(x::Real,y::Real,z::Real)
    m = zeros(typeof(x),4,4)

    m[1:5:16] .= 1
    m[13] = x; m[14] = y; m[15] = z

    return Mat4(m)
end

function trans(T::Type,x::Real,y::Real,z::Real)
    m = zeros(T,4,4)

    m[1:5:16] .= T(1)
    m[13] = T(x); m[14] = T(y); m[15] = T(z)

    return Mat4{T}(m)
end

function scale(sx::Real,sy::Real,sz::Real)
    m = zeros(typeof(sx),4,4)

    m[1] = sx; m[6] = sy; m[11] = sz; m[16] = 1

    return Mat4(m)
end

function scale(T::Type,sx::Real,sy::Real,sz::Real)
    return Mat4{T}([sx 0 0 0
                 0 sy 0 0
                 0 0 sz 0
                 0 0 0 1])
end

scale(s::Real) = scale(s,s,s)

function rotx(ϕ::Real)
    return Mat4([1      0       0 0
                 0 cos(ϕ) -sin(ϕ) 0
                 0 sin(ϕ)  cos(ϕ) 0
                 0      0       0 1])
end

function rotx(T::Type,ϕ::Real)
    return Mat4{T}([1      0       0 0
                    0 cos(ϕ) -sin(ϕ) 0
                    0 sin(ϕ)  cos(ϕ) 0
                    0      0       0 1])
end

function roty(θ::Real)
    return Mat4([cos(θ)  0 sin(θ) 0
                 0       1      0 0
                 -sin(θ) 0 cos(θ) 0
                 0       0      0 1])
end

function roty(T::Type,θ::Real)
    return Mat4{T}([cos(θ)  0 sin(θ) 0
                 0       1      0 0
                 -sin(θ) 0 cos(θ) 0
                 0       0      0 1])
end

function rotz(ψ::Real)
    return Mat4([cos(ψ) -sin(ψ) 0 0
                 sin(ψ)  cos(ψ) 0 0
                 0            0 1 0
                 0            0 0 1])
end

function rotz(T::Type,ψ::Real)
    return Mat4{T}([cos(ψ) -sin(ψ) 0 0
                 sin(ψ)  cos(ψ) 0 0
                 0            0 1 0
                 0            0 0 1])
end

function rot(ϕ::Real,θ::Real,ψ::Real)
    return rotx(ψ)*roty(θ)*rotx(ϕ)
end

function rot(T::Type,ϕ::Real,θ::Real,ψ::Real)
    return rotx(T,ψ)*roty(T,θ)*rotx(T,ϕ)
end

function rot!(m::Mat4,ϕ::Real,θ::Real,ψ::Real)
    T = eltype(m)
    m *= rotx(T,ψ)
    m *= roty(T,θ)
    m *= rotx(T,ϕ)

    return 
end



mutable struct Callback
    id::Symbol

    active::Bool

    func::Function
    args::Tuple

    function Callback()
        new(Symbol(),false,emptyCallback,())
    end

    function Callback(func)
        new(Symbol(),false,func,())
    end

    function Callback(func,args)
        new(Symbol(),false,func,args)
    end

    function Callback(id,func,args)
        new(id,true,func,args)
    end

    function Callback(id,active,func,args)
        new(id,active,func,args)
    end
end

const F = Callback

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





include("stateflags.jl")
include("evolve.jl")

import Base.==
==(x,y::Enum{T}) where T = x == Integer(y)

getindex(a::AbstractArray,enum::Enum{T}) where T = getindex(a,Integer(enum))
setindex!(a::AbstractArray,enum::Enum{T}) where T = setindex!(a,Integer(enum))

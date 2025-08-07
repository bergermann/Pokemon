
include("stateflags.jl")
include("evolve.jl")
include("status.jl")

import Base.==, Base.getindex, Base.setindex!
==(x::Integer,y::Enum{T}) where T = x == Integer(y)

getindex(a::AbstractArray,enum::Enum{T}) where T = getindex(a,Integer(enum))
setindex!(a::AbstractArray,x,enum::Enum{T}) where T = setindex!(a,x,Integer(enum))

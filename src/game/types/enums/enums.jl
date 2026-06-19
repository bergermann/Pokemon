
include("lang.jl")
include("pkmn.jl")
include("stateflags.jl")
include("items.jl")
include("abilities.jl")
include("weather.jl")


import Base.==, Base.getindex, Base.setindex!
==(x::Integer,y::T) where T <: Enum = T(x) == y
==(y::T,x::Integer) where T <: Enum = T(x) == y

getindex(a::AbstractArray,enum::Enum{T}) where T = getindex(a,Integer(enum))
getindex(a::AbstractArray,enum1::Enum{T},enum2::Enum{T}) where T =
    getindex(a,Integer(enum1),Integer(enum2))
setindex!(a::AbstractArray,x,enum::Enum{T}) where T = setindex!(a,x,Integer(enum))

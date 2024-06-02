
using StaticArrays

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
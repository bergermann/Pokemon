

function add(a::Real,b::Real)
    return a+b
end

function add(a::Complex,b::Complex)
    return (a.re+b.re) + (a.im + b.im)*1im
end

add


function solveNavierStokes(a,b::Float64,c::Tuple{Any,String})::Bool
    x = findAnswerToTheUniverse(a,b)
    y = getNobelPrize(c)

    return x == y
end



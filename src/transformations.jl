#image transformation algorithms

function xShear(im::Matrix{UInt32},α::Real)
    h,w = size(im)

    im_ = zeros(UInt32,h,w)

    for i in 1:h
        δ = floor(Int,sin(α)*((h+1)/2-i)+1)

        for j in max(1,δ):min(w,w+δ-1)
            im_[i,j] = im[i,j-δ+1]
        end
    end

    return im_
end

function xShear!(im::Matrix{UInt32},α::Real)
    h,w = size(im)

    for i in 1:h
        δ = floor(Int,sin(α)*((h+1)/2-i)+1)

        if δ <= 0
            for j in max(1,δ):min(w,w+δ-1)
                im[i,j] = im[i,j-δ+1]
            end
        else
            for j in min(w,w+δ-1):-1:max(1,δ)
                im[i,j] = im[i,j-δ+1]
            end
        end
    end
end

function yShear(im::Matrix{UInt32},α::Real)
    h,w = size(im)

    im_ = zeros(UInt32,h,w)

    for j in 1:w
        δ = floor(Int,sin(α)*((w+1)/2-j)+1)

        for i in max(1,δ):min(h,h+δ-1)
            im_[i,j] = im[i-δ+1,j]
        end
    end

    return im_
end

function yShear!(im::Matrix{UInt32},α::Real)
    h,w = size(im)

    for j in 1:w
        δ = floor(Int,sin(α)*((w+1)/2-j)+1)

        if δ <= 0
            for i in max(1,δ):min(h,h+δ-1)
                im[i,j] = im[i-δ+1,j]
            end
        else
            for i in min(h,h+δ-1):-1:max(1,δ)
                im[i,j] = im[i-δ+1,j]
            end
        end
    end
end

function rotate(im::Matrix{UInt32},θ::Real)
    im_ = xShear(im,tand(θ/2))
    yShear!(im_,-sind(θ))
    xShear!(im_,tand(θ/2))

    return im_
end

function rotate!(im::Matrix{UInt32},θ::Real)
    xShear!(im,tand(θ/2))
    yShear!(im,-sind(θ))
    xShear!(im,tand(θ/2))
end

function channels(i::UInt32)
    r = i & 0xff0000
    g = i & 0x00ff00
    b = i & 0x0000ff

    return r,g,b
end

function scaleChannels(i::UInt32,denom::UInt8,num::UInt8)
    r = div(i & 0xff0000,denom)*num & 0xff0000
    g = div(i & 0x00ff00,denom)*num & 0x00ff00
    b = div(i & 0x0000ff,denom)*num

    return |(r,g,b)
end

function scaleChannels!(im::Matrix{UInt32},denom::UInt8,num::UInt8)
    @inbounds for i in eachindex(A)
        im[i] = |(
            div(im[i] & 0xff0000,denom)*num & 0xff0000,
            div(im[i] & 0x00ff00,denom)*num & 0x00ff00,
            div(im[i] & 0x0000ff,denom)*num
        )
    end
end





function combine(imbase::Matrix{UInt32},imover::Matrix{UInt32},
        denom::UInt8,num::UInt8)

    if denom < num
        return error("ArgumentError: Fraction must be between 0 and 1.")
    end

    im_ = copy(imbase)

    @inbounds for i in eachindex(imbase)
        im_[i] += scaleChannels(imover[i],denom,num)
        im_[i] -= scaleChannels(imbase[i],denom,num)
    end

    return im_
end

function combine!(imbase::Matrix{UInt32},imover::Matrix{UInt32},
        denom::UInt8,num::UInt8)

    if denom < num
        return error("ArgumentError: Fraction must be between 0 and 1.")
    end

    @inbounds for i in eachindex(imbase)
        imbase[i] -= scaleChannels(imbase[i],denom,num)
        imbase[i] += scaleChannels(imover[i],denom,num)
    end
end

function combine(imbase::Matrix{UInt32},color::UInt32,
        denom::UInt8,num::UInt8)

    if denom < num
        return error("ArgumentError: Fraction must be between 0 and 1.")
    end

    if num == 0
        return copy(imbase)
    end

    color_ = scaleChannels(color,denom,num)

    im_ = copy(imbase)

    for i in eachindex(imbase)
        im_[i] -= scaleChannels(imbase[i],denom,num)
        im_[i] += color_
    end

    return im_
end

function combine!(imbase::Matrix{UInt32},color::UInt32,
        denom::UInt8,num::UInt8)

    if denom < num
        return error("ArgumentError: Fraction must be between 0 and 1.")
    end

    if num == 0
        return
    end

    color_ = scaleChannels(color,denom,num)

    for i in eachindex(imbase)
        imbase[i] -= scaleChannels(imbase[i],denom,num)
        imbase[i] += color_
    end
end





function scaleColor!(imbase::Matrix{UInt32},color::UInt32,
        denom::UInt8,num::UInt8)

    if denom < num
        return error("ArgumentError: Fraction must be between 0 and 1.")
    end

    color_ = div(color,demon)*num

    @inbounds for i in eachindex(imbase)
        imbase[i] -= scaleChannels(imbase[i],denom,num)
        imbase[i] += color_
    end
end

function fadeLinear!(im::Matrix{UInt32},denom::UInt8,num::UInt8)
    
    if denom < num
        return error("ArgumentError: Fraction must be between 0 and 1.")
    end

    @inbounds for i in eachindex(im)
        im[i] -= div(im[i],denom)*num
    end
end

function fadeLinear!(im::Matrix{UInt32},denom::UInt8,num::UInt8,frame::UInt8)
    
    if denom < num
        return error("ArgumentError: Fraction must be between 0 and 1.")
    end

    @inbounds for i in eachindex(im)
        im[i] -= div(im[i],denom)*num*frame
    end
end

function shutterHorizontal!(im::Matrix{UInt32},center::Int,n::Int)
    for i in eachindex(view(im,:,1))
        if !(center-n < i < center+n)
            im[i,:] .= 0x000001
        end
    end
end

function scaleUp(im::Matrix{UInt32},factor::UInt)
    if factor < 2
        error("Factor needs to at least 2.")
    end

    im_ = zeros(UInt32,size(im).*factor)

    for i in 1:size(im)[1], j in 1:size(im)[2]
        im_[1+(i-1)*factor:factor+(i-1)*factor,
            1+(j-1)*factor:factor+(j-1)*factor] .= im[i,j]
    end

    return im_
end

#=
function zoomIn!(im::Matrix{UInt32},factor::UInt,pos::Position,size::Position)
    if factor < 2
        error("Factor needs to be at least 2.")
    end

    v = view(im,pos.h+1:pos.h+size.h,pos.w+1:pos.w+size.w)

    for i in size.h:-1:1, j in size.w:-1:1
        im[i]
    end
end
=#

function horizontalShifts!(im::Matrix{UInt32},nshift::Int,nrows::Int)
    if nshift == 0
        return
    end

    for nh in 0:size(im)[1]-1
        if nh%nrows == 0
            horizontalShiftRowRight!(im,nshift,nh+1)
        else
            horizontalShiftRowLeft!(im,nshift,nh+1)
        end
    end
end

        
function horizontalShiftRowRight!(im::Matrix{UInt32},nshift::Int,row::Int)
    for i in size(im)[2]:-1:1
        if i > nshift
            im[row,i] = im[row,i-nshift]
        else
            im[row,i] = 0x000001
        end
    end
end

function horizontalShiftRowLeft!(im::Matrix{UInt32},nshift::Int,row::Int)
    w = size(im)[2]

    for i in 1:w
        if i < w-nshift
            im[row,i] = im[row,i+nshift]
        else
            im[row,i] = 0x000001
        end
    end
end

function empty(im::Matrix{UInt32})
    return
end

function shiftV!(A::Matrix,shift::Int)
    if shift == 0
        return
    end

    if shift > 0
        @views copy!(A[1+shift:end,:],A[1:end-shift,:])
    else
        @views copy!(A[1:shift+end,:],A[1-shift:end,:])
    end
    
    return
end

function shift!(A::Matrix,shift::Tuple{Int,Int})
    cs = CartesianIndex(shift)
    for i in eachindex(view(A,
            1:height(A),
            1:width(A)))
        if !checkbounds(Bool,A,i-cs)
            continue
        end

        A[i] = A[i-cs]
    end
end

function shift1!(A::Matrix,shift::Tuple{Int,Int})
    for h in (shift[1] >= 0 ? (height(A):-1:1) : (1:height(A))), w in (shift[2] >= 0 ? (width(A):-1:1) : (1:width(A)))
        if !checkbounds(Bool,A,h-shift[1],w-shift[2])
            continue
        end

        A[h,w] = A[h-shift[1],w-shift[2]]
    end
end

function shift2!(A::Matrix,shift::Tuple{Int,Int})
    cs = CartesianIndex(shift)

    if shift[1] <= 0 && shift[2] <= 0
        for i in eachindex(view(A,1:height(A),1:width(A)))
            if !checkbounds(Bool,A,i-cs)
                continue
            end

            A[i] = A[i-cs]
        end
    elseif shift[1] <= 0 && shift[2] > 0
        c_ = CartesianIndex(0,width(A)+1)

        for i in eachindex(view(A,1:height(A),1:width(A)))
            i[2] = c_[2] - i[2]

            if !checkbounds(Bool,A,i-cs)
                continue
            end

            A[i] = A[i-cs]
        end
    elseif shift[1] > 0 && shift[2] <= 0
        c_ = CartesianIndex(height(A)+1,0)

        for i in eachindex(view(A,1:height(A),1:width(A)))
            i[1] = c_[1] - i[1]

            if !checkbounds(Bool,A,i-cs)
                continue
            end

            A[i] = A[i-cs]
        end
    else
        c_ = CartesianIndex(height(A)+1,width(A)+1)

        for i in eachindex(view(A,1:height(A),1:width(A)))
            i = c_ - i

            if !checkbounds(Bool,A,i-cs)
                continue
            end

            A[i] = A[i-cs]
        end
    end
end


# countertypes
# -1 -> equal less      counter <= value
#  0 -> equal           counter == value
#  1 -> equal greater   counter >= value 

struct FlagSet{N1,N2}
           flags::NTuple{N1,UInt8}
        flagvals::NTuple{N1, Bool}
       flagtypes::NTuple{N1,  Int}
        counters::NTuple{N2,UInt8}
     countervals::NTuple{N2,UInt8}
    countertypes::NTuple{N2, Int8}
    
    empty::Bool

    function FlagSet()
        new{0,0}([],[],[],[],[],[],true)
    end

    function FlagSet(flags,flagvals,flagtypes,counters,countervals,countertypes)
        @assert length(flags) == length(flagvals) == length(flagtypes) "Flags need same lengths."
        @assert length(counters) == length(countervals) == length(countertypes) "Counters need same lengths."

        N1 = length(flags); N2 = length(counters)

        new{N1,N2}(flags,flagvals,flagtypes,counters,countervals,countertype,N1==0 && N2==0)
    end

    function FlagSet(; flags::AbstractVector=[],
            counters::AbstractVector=[])

        N1 = length(flags); N2 = length(counters)

        flags_ = zeros(UInt8,N1)
        flagvals = zeros(Bool,N1)
        flagtypes = zeros(Int,N1)

        for i in eachindex(flags)
            flags_[i]    = flags[i][1]
            flagvals[i]  = flags[i][2]
            flagtypes[i] = flags[i][3]
        end

        counters_ = zeros(UInt8,N1)
        countervals = zeros(UInt8,N1)
        countertypes = zeros(Int8,N1)

        for i in eachindex(counters)
            counters_[i]    = counters[i][1]
            countervals[i]  = counters[i][2]
            countertypes[i] = counters[i][3]
        end

        new{N1,N2}(
            NTuple{N1,UInt8}(flags_),
            NTuple{N1, Bool}(flagvals),
            NTuple{N1,  Int}(flagtypes),
            NTuple{N2,UInt8}(counters_),
            NTuple{N2,UInt8}(countervals),
            NTuple{N2, Int8}(countertypes),
            N1==0 && N2==0
        )
    end
end

import Base: size
Base.size(::FlagSet{N1,N2}) where {N1,N2} = (N1,N2)

isempty(flags::FlagSet) = flags.empty



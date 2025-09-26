
# countertypes
# -1 -> equal less      counter <= value
#  0 -> equal           counter == value
#  1 -> equal greater   counter >= value 

struct FlagSet{N1,N2,N3,N4,N5}
           flags::NTuple{N1,UInt8}
        flagvals::NTuple{N1, Bool}
       flagtypes::NTuple{N1,  Int}
        counters::NTuple{N2,UInt8}
     countervals::NTuple{N2,UInt8}
    countertypes::NTuple{N2, Int8}
         hasseen::NTuple{N3,  Int}
       hascaught::NTuple{N4,  Int}
          inteam::NTuple{N5,  Int}
    
    empty::Bool

    # function FlagSet()
    #     new{0,0,0,0,0}([],[],[],[],[],[],[],[],[],true)
    # end

    function FlagSet(flags,flagvals,flagtypes,counters,countervals,countertypes,
            hasseen,hascaught,inteam)
        
        @assert length(flags) == length(flagvals) == length(flagtypes) "Flags need same lengths."
        @assert length(counters) == length(countervals) == length(countertypes) "Counters need same lengths."

        N1 = length(flags); N2 = length(counters);
        N3 = length(hasseen); N4 = length(hascaught); N5 = length(inteam)

        new{N1,N2,N3,N4,N5}(flags,flagvals,flagtypes,counters,countervals,countertype,
            hasseen,hascaught,inteam,(N1+N2+N3+N4+N5)==0)
    end

    function FlagSet(; flags::AbstractVector=[],counters::AbstractVector=[],
            hasseen::AbstractVector=[],hascaught::AbstractVector=[],inteam::AbstractVector=[])

        N1 = length(flags); N2 = length(counters);
        N3 = length(hasseen); N4 = length(hascaught); N5 = length(inteam)

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

        new{N1,N2,N3,N4,N5}(
            NTuple{N1,UInt8}(flags_),
            NTuple{N1, Bool}(flagvals),
            NTuple{N1,  Int}(flagtypes),
            NTuple{N2,UInt8}(counters_),
            NTuple{N2,UInt8}(countervals),
            NTuple{N2, Int8}(countertypes),
            NTuple{N3,  Int}(hasseen),
            NTuple{N4,  Int}(hascaught),
            NTuple{N5,  Int}(inteam),
            (N1+N2+N3+N4+N5)==0
        )
    end
end

import Base: size, isempty

Base.size(::FlagSet{N1,N2,N3,N4,N5}) where {N1,N2,N3,N4,N5} = (N1,N2,N3,N4,N5)
Base.isempty(flags::FlagSet)::Bool = flags.empty



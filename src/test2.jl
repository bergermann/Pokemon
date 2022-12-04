using BenchmarkTools

str = readlines(open("str/pkmn_list.csv"))

for i in 2:650
    s_ = split(str[i],",")

    open("str/names_ger.txt","a") do io
        write(io,s_[3]*"\n")
    end

    open("str/names_eng.txt","a") do io
        write(io,s_[4]*"\n")
    end
end

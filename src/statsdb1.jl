#stuff that needs to be stored in a DB:
#name, basevalues, genderweight, xpyield, maxxp, evolveconds, ability, dex, evyield
#levelupattacks ? multiple?
#evolveattacks ? -1:never, 0:evolve
#tms
#types: 
#normal     1
#grass      2
#fire       3
#water      4
#fighting   5
#flying     6
#poison     7
#ground     8
#rock       9
#bug        10
#ghost      11
#electric   12
#psycho     13
#ice        14
#dragon     15
#dark       16
#steel      17
#fairy      18

using SQLite
using CSV
using Tables
using BenchmarkTools

types = Dict{String,UInt8}(
    "Null" => 0,
    "Normal" => 1,
    "Pflanze" => 2,
    "Feuer" => 3,
    "Wasser" => 4,
    "Kampf" => 5,
    "Flug" => 6,
    "Gift" => 7,
    "Boden" => 8,
    "Gestein" => 9,
    "Käfer" => 10,
    "Geist" => 11,
    "Elektro" => 12,
    "Psycho" => 13,
    "Eis" => 14,
    "Drache" => 15,
    "Unlicht" => 16,
    "Stahl" => 17,
    "Fee" => 18,
)

pkmn_data = SQLite.DB("pkmn stats.db")

SQLite.execute(pkmn_data, "CREATE TABLE IF NOT EXISTS stats_base
    (
    id INTEGER PRIMARY KEY,
    type1 INTEGER, type2 INTEGER,
    bv_kp INTEGER, bv_at INTEGER, bv_def INTEGER,
    bv_spat INTEGER, bv_spdef INTEGER, bv_init INTEGER,
    ability1 INTEGER, ability2 INTEGER, ability3 INTEGER,
    xp_max INTEGER, 
    weightg1 INTEGER, weightg2 INTEGER, weightg3 INTEGER
    )
")

SQLite.execute(pkmn_data, "CREATE TABLE IF NOT EXISTS stats_opp
    (
    id INTEGER PRIMARY KEY,
    xp_yield INTEGER,
    ev_kp INTEGER, ev_at INTEGER, ev_def INTEGER,
    ev_spat INTEGER, ev_spdef INTEGER, ev_init INTEGER
    )
")

#=
for i in 1:649
    SQLite.execute(pkmn_data, "INSERT INTO stats_base (id, type1, type2,
        bv_kp, bv_at, bv_def, bv_spat, bv_spdef, bv_init,
        ability1, ability2, ability3, xp_max, weightg1, weightg2, weightg3)

        VALUES ($i,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    ")
end
=#

a = CSV.File("a.csv"; delim=",",select=["#","Pokémon","KP","Ang.","Ver.","Sp.-A.","Sp.-V.","Init."])
b = CSV.File("b.csv"; delim=",",select=["Deutsch","Englisch","Typ"],types=fill(String,9))

for i in eachindex(a)
    if a[i][1] > 649
        continue
    end

    if occursin(" Mega",a[i][2])
        continue
    end

    bv_kp = a[i][3]
    bv_at = a[i][4]
    bv_def = a[i][5]
    bv_spat = a[i][6]
    bv_spdef = a[i][7]
    bv_init = a[i][8]
    id = a[i][1]

    SQLite.execute(pkmn_data, "UPDATE stats_base SET
        bv_kp = $bv_kp,
        bv_at = $bv_at,
        bv_def = $bv_def,
        bv_spat = $bv_spat,
        bv_spdef = $bv_spdef,
        bv_init = $bv_init
        WHERE id = $id;
    ")
end

for i in eachindex(b)
    if i > 649
        break
    end

    str = split(b[i][3],"\u00a0")

    t1 = types[str[1]]

    if length(str) == 2
        t2 = types[str[2]]
    else
        t2 = 0
    end

    SQLite.execute(pkmn_data, "UPDATE stats_base SET
        type1 = $t1,
        type2 = $t2
        WHERE id = $i;
    ")
end

function getStatsBase1(id::Int)
    q = DBInterface.execute(pkmn_data,"SELECT * FROM stats_base WHERE id = $id;")
    t = Tables.matrix(q)
end

function getStatsBase2(id::Int)
    q = DBInterface.execute(pkmn_data,"SELECT * FROM stats_base WHERE id = $id;") |> Tables.matrix
end

function getStatsBase3(id::Int)
    q = CSV.read("pkmn_data.csv",Tables.matrix; skipto=id+1,limit=1)
end

function getStatsBase4(id::Int)
    q = CSV.read("pkmn_data.csv",DataFrame; skipto=id+1,limit=1)
end

function getStatsBase5(id::Int)
    q = CSV.read("pkmn_data.csv",DataFrame; skipto=id+1,limit=1)
end

function func(id::Int)
    A = parse.(UInt,split(readlines("pkmn_data.csv")[id+1],","))
end

function main()
    @btime getStatsBase1(1)
    @btime getStatsBase2(1)
    @btime getStatsBase3(1)
    @btime getStatsBase4(1)
end

main()
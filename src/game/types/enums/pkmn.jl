
# mutable struct Pkmn
#     ball::BallID

#     stats::Stats
#     item::ItemID

#     attacks::Vector{Atk}
#     ability::Ability

#     evolve::UInt16
# end

@enum Gender::UInt8 Gnone Gmale Gfemale

@enum PType::UInt8 begin
    Tnone
    Tnormal
    Tgrass
    Tfire
    Twater
    Tfight
    Tflying
    Tpoison
    Tground
    Trock
    Tbug
    Tghost
    Telectric
    Tpsycho
    Tice
    Tdragon
    Tdark
    Tsteel
    Tfairy
end

@enum HealthStatus::UInt8 begin
    HSnormal = 0x00
    HSpoison
    HSburn
    HSparalyse
    HSsleep
    HSfrozen
    HSfainted
    HSall
end

# @enum Nature::UInt8 begin

# end

@enum EvolType::UInt16 begin
    EVnone = 0x0001
    EVlevelup
    EVitem
    EVitemheld
    EVitemtrade
    EVtrade
    EVfriendship
    EVhasattack
    EVarea
end

@enum BallID::UInt8 begin
    Bpoke = 0x01
    Bgreat
    Bultra
    Bmaster
    Bdive
    Bluxury
    Bnest
    Bnet
    Bpremier
    Brepeat
    Bsafari
    Btimer
end

@enum AttackClass::UInt8 begin
    ACnone = 0x00
    ACphys
    ACspec
    ACstat
end
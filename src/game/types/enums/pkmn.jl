

@enum Gender::UInt8 G_NONE G_MALE G_FEMALE

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

@enum XPtype::UInt8 begin
    XP_ERRATIC = 0x01
    XP_FAST
    XP_SEMIFAST
    XP_SEMISLOW
    XP_SLOW
    XP_FLUCTUATE
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

@enum AttackClass::UInt8 begin
    ACnone = 0x00
    ACphys
    ACspec
    ACstat
end
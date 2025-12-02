# items (battleitems, medicine n such)

items = Dict{ItemID,Item}(
    POT_POTION  => MedicineHealth( 20,false,HSnormal),   # trank
    POT_SUPER   => MedicineHealth( 50,false,HSnormal),   # supertrank
    POT_HYPER   => MedicineHealth(200,false,HSnormal),   # hypertrank
    POT_MAX     => MedicineHealth(100, true,HSnormal),   # top trank
    POT_FULL    => MedicineHealth(100, true,HSall),      # top genesung
    POT_WATER   => MedicineHealth( 50,false,HSnormal),   # tafelwasser
    POT_SODA    => MedicineHealth( 60,false,HSnormal),   # sprudel
    POT_LIMO    => MedicineHealth( 80,false,HSnormal),   # limonade
    POT_MOO     => MedicineHealth(100,false,HSnormal),   # kuh-muh milch
    POT_ROOT    => MedicineHealth( 50,false,HSnormal),   # energiestaub
    POT_POWDER  => MedicineHealth(200,false,HSnormal),   # kraftwurzel

    ST_POISON   => MedicineHealth(  0,false,HSpoison),   # gegengift
    ST_BURN     => MedicineHealth(  0,false,HSburn),     # feuerheiler
    ST_PARA     => MedicineHealth(  0,false,HSparalyse), # paraheiler
    ST_SLEEP    => MedicineHealth(  0,false,HSsleep),    # aufwecker
    ST_ICE      => MedicineHealth(  0,false,HSfrozen),   # eisheiler
    ST_ALL      => MedicineHealth(  0,false,HSall),      # hyperheiler
    ST_COOKIE   => MedicineHealth(  0,false,HSall),      # lavakeks

    REV_REV     => MedicineHealth( 50, true,HSfainted),  # beleber
    REV_MAX     => MedicineHealth(100, true,HSfainted),  # top beleber
    REV_VITAL   => MedicineHealth(100, true,HSfainted),  # vitalkraut

    AP_ETHER    => MedicineAP( 10,false),                # äther
    AP_ETHERTOP => MedicineAP(100,false),                # top äther
    AP_ELIX     => MedicineAP( 10, true),                # elixier
    AP_ELIXTOP  => MedicineAP(100, true),                # top-elixier

    B_LIFEORB   => BattleCarry(),
    B_EXBELT    => BattleCarry(),
)

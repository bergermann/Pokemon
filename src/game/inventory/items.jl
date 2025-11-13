# items (battleitems, medicine n such)

items = Dict{ItemID,Item}(
    IIpotion    => MedicineHealth( 20,false,HSnormal),   # trank
    IIsuper     => MedicineHealth( 50,false,HSnormal),   # supertrank
    IIhyper     => MedicineHealth(200,false,HSnormal),   # hypertrank
    IImaxp      => MedicineHealth(100, true,HSnormal),   # top trank
    IIfull      => MedicineHealth(100, true,HSall),      # top genesung
    IIwater     => MedicineHealth( 50,false,HSnormal),   # tafelwasser
    IIsoda      => MedicineHealth( 60,false,HSnormal),   # sprudel
    IIlimo      => MedicineHealth( 80,false,HSnormal),   # limonade
    IImoo       => MedicineHealth(100,false,HSnormal),   # kuh-muh milch
    IIenp       => MedicineHealth( 50,false,HSnormal),   # energiestaub
    IIenr       => MedicineHealth(200,false,HSnormal),   # kraftwurzel

    IIpoison    => MedicineHealth(  0,false,HSpoison),   # gegengift
    IIburn      => MedicineHealth(  0,false,HSburn),     # feuerheiler
    IIpara      => MedicineHealth(  0,false,HSparalyse), # paraheiler
    IIsleep     => MedicineHealth(  0,false,HSsleep),    # aufwecker
    IIice       => MedicineHealth(  0,false,HSfrozen),   # eisheiler
    IIall       => MedicineHealth(  0,false,HSall),      # hyperheiler
    IIheal      => MedicineHealth(  0,false,HSall),      # heilpuder
    IIlava      => MedicineHealth(  0,false,HSall),      # lavakeks

    IIrev       => MedicineHealth( 50, true,HSfainted),  # beleber
    IImaxrev    => MedicineHealth(100, true,HSfainted),  # top beleber
    IIvital     => MedicineHealth(100, true,HSfainted),  # vitalkraut

    IIether     => MedicineAP( 10,false), # äther
    IIethtop    => MedicineAP(100,false), # top äther
    IIelix      => MedicineAP( 10, true), # elixier
    IIelixtop   => MedicineAP(100, true), # top-elixier
)



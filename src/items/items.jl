# items (battleitems, medicine n such)

items = Base.ImmutableDict(
    21 => MedicineHealth(20,false,0),   # trank
    22 => MedicineHealth(50,false,0),   # supertrank
    23 => MedicineHealth(200,false,0),  # hypertrank
    24 => MedicineHealth(100,true,0),   # top trank
    25 => MedicineHealth(100,true,6), #  top genesung
    26 => MedicineHealth(50,false,0),   # tafelwasser
    27 => MedicineHealth(60,false,0),   # sprudel
    28 => MedicineHealth(80,false,0),   # limonade
    29 => MedicineHealth(100,false,0),  # kuh-muh milch
    30 => MedicineHealth(50,false,0),   # energiestaub

    31 => MedicineHealth(0,false,1),    # gegengift
    32 => MedicineHealth(0,false,2),    # feuerheiler
    33 => MedicineHealth(0,false,3),    # paraheiler
    34 => MedicineHealth(0,false,4),    # aufwecker
    35 => MedicineHealth(0,false,5),    # eisheiler
    36 => MedicineHealth(0,false,6),    # hyperheiler
    37 => MedicineHealth(0,false,6),    # heilpuder
    38 => MedicineHealth(0,false,6),    # lavakeks

    38 => MedicineHealth(50,true,7),    # beleber
    39 => MedicineHealth(100,true,7),   # top beleber
    40 => MedicineHealth(100,true,7),   # vitalkraut

    41 => MedicineAP(10,false),         # äther
    42 => MedicineAP(100,false),        # top äther
    43 => MedicineAP(10,true),          # elixier
    44 => MedicineAP(100,true),         # top-elixier
)



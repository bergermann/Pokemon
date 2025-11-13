# poke balls

pokeballs = Dict{ItemID,Pokeball}(
    IBpoke      => Pokeball(1.0,0, 1),  # poke ball
    IBgreat     => Pokeball(1.5,0, 2),  # great ball
    IBultra     => Pokeball(2.0,0, 3),  # ultra ball
    IBmaster    => Pokeball(1e9,0, 4),  # master ball
    IBdive      => Pokeball(1.0,1, 5),  # dive ball
    IBluxury    => Pokeball(1.0,0, 6),  # luxury ball
    IBnest      => Pokeball(1.0,2, 7),  # nest ball
    IBnet       => Pokeball(1.0,3, 8),  # net ball
    IBpremier   => Pokeball(1.0,0, 9),  # premier ball
    IBrepeat    => Pokeball(1.0,4,10),  # repeat ball
    IBsafari    => Pokeball(1.5,0,11),  # safari ball
    IBtimer     => Pokeball(1.0,5,12),  # timer ball
)
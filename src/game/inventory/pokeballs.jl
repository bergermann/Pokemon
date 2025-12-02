# poke balls

pokeballs = Dict{BallID,Pokeball}(
    BALL_POKE      => Pokeball(1.0,0, 1),  # poke ball
    BALL_GREAT     => Pokeball(1.5,0, 2),  # great ball
    BALL_ULTRA     => Pokeball(2.0,0, 3),  # ultra ball
    BALL_MASTER    => Pokeball(1e9,0, 4),  # master ball
    BALL_DIVE      => Pokeball(1.0,1, 5),  # dive ball
    BALL_LUXURY    => Pokeball(1.0,0, 6),  # luxury ball
    BALL_NEST      => Pokeball(1.0,2, 7),  # nest ball
    BALL_NET       => Pokeball(1.0,3, 8),  # net ball
    BALL_PREMIER   => Pokeball(1.0,0, 9),  # premier ball
    BALL_REPEAT    => Pokeball(1.0,4,10),  # repeat ball
    BALL_SAFARI    => Pokeball(1.5,0,11),  # safari ball
    BALL_TIMER     => Pokeball(1.0,5,12),  # timer ball
)
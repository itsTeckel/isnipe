GameStates =
{
    -- There is no gamestate, used for initialization
    None = 0,

    -- Warmup time, waiting for everyone to ready up
    Warmup = 1,

    -- After warmup, going into knife round transition
    Playing = 2,

    -- End of a match
    EndGame = 3,

    Max = 4
}
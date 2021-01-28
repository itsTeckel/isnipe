require ("__shared/GameTypes")

iSNConfig =
{
    -- ==========
    -- Debug mode options
    -- ==========
    DebugMode = true,
    DebugPass = "iSnipe", --change me

    -- ==========
    -- Client configuration options
    -- ==========

    -- Maximum Ready up time
    MaxReadyUpTime = 1.5,

    MinPlayers = 1,

    -- When up tick rup game logic
    MaxRupTick = 1.0,

    -- When we send the countdown time to all players
    TimeTick = 5.0,

    -- When to tick name update logic
    MaxNameTick = 5.0,

    -- ==========
    -- Shared configuration options
    -- ==========


    -- ==========
    -- Server configuration options
    -- ==========
    MatchDefaultRounds = 12,

    -- Round time (default: 10 minutes)
    MaxRoundTime = 910.0,

    -- Game end time (default: 20 sec)
    MaxEndgameTime = 10.0,

    -- Squad size
    SquadSize = 1,

    -- Default gametype is GameTypes.Public
    GameType = GameTypes.Public,
}

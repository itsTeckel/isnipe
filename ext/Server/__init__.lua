class "iSNServer"

require ("__shared/iSNConfig")
require ("__shared/GameStates")
require ("__shared/Utils")
require ("__shared/GameTypes")

require ("Team")
require ("LoadoutManager")
require ("Match")

function iSNServer:__init()
    print("server initialization")

    -- Register all of our needed events
    self:RegisterEvents()

    -- Hold gamestate information
    if iSNConfig.GameType == GameTypes.Public then
        self.m_GameState = GameStates.Warmup
    else
        self.m_GameState = GameStates.None
    end

    -- Create our team information
    self.m_Attackers = Team(TeamId.Team2, "Attackers", "") -- RUS
    self.m_Defenders = Team(TeamId.Team1, "Defenders", "") -- US

    -- Loadout manager
    self.m_LoadoutManager = LoadoutManager()

    -- Create a new match
    self.m_Match = Match(self, self.m_Attackers, self.m_Defenders, iSNConfig.MatchDefaultRounds, self.m_LoadoutManager, iSNConfig.GameType)

    -- Ready up tick
    self.m_RupTick = 0.0

    -- Name update
    self.m_NameTick = 0.0

    -- Match management
    self.m_AllowedGuids = { }

    -- Callbacks
    self.m_MatchStateCallbacks = { }

    ServerUtils:SetCustomGameModeName("iSnipe")
end

function iSNServer:RegisterEvents()
    -- Engine tick
    self.m_EngineUpdateEvent = Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)

    self.m_PlayerJoiningEvent = Events:Subscribe("Player:Joining", self, self.OnPlayerJoining)
    self.m_PlayerLeaveEvent = Events:Subscribe("Player:Left", self, self.OnPlayerLeft)

    -- Team management
    self.m_PlayerFindBestSquadHook = Hooks:Install("Player:FindBestSquad", 1, self, self.OnPlayerFindBestSquad)
    self.m_PlayerSelectTeamHook = Hooks:Install("Player:SelectTeam", 1, self, self.OnPlayerSelectTeam)

    -- Damage hooks
    self.m_SoldierDamageHook = Hooks:Install("Soldier:Damage", 1, self, self.OnSoldierDamage)
    self.m_PlayerKilledEvent = Events:Subscribe("Player:Killed", self, self.OnPlayerKilled)

    -- TODO: This is a debug only function
    self.m_ToggleRupEvent = NetEvents:Subscribe("iSN:ToggleRup", self, self.OnToggleRup)
    self.m_ForceToggleRupEvent = NetEvents:Subscribe("iSN:ForceToggleRup", self, self.OnForceToggleRup)
    self.m_PlayerConnectedEvent = NetEvents:Subscribe("iSN:PlayerConnected", self, self.OnPlayerConnected)
    self.m_PlayerSetSelectedTeamEvent = NetEvents:Subscribe("iSN:PlayerSetSelectedTeam", self, self.OnPlayerSetSelectedTeam)
    self.m_PlayerSetSelectedKitEvent = NetEvents:Subscribe("iSN:PlayerSetSelectedKit", self, self.OnPlayerSetSelectedKit)

    -- Chat events
    self.m_PlayerChatEvent = Events:Subscribe("Player:Chat", self, self.OnPlayerChat)

    -- Partition events
    self.m_PartitionLoadedEvent = Events:Subscribe("Partition:Loaded", self, self.OnPartitionLoaded)

    -- Level events
    self.m_LevelDestroyedEvent = Events:Subscribe("Level:Destroy", self, self.OnLevelDestroyed)
    self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
end

function iSNServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)

    -- Update the match
    self.m_Match:OnEngineUpdate(self.m_GameState, p_DeltaTime)

    -- Check if the name
    if self.m_NameTick >= iSNConfig.MaxNameTick then
        -- Reset the name tick
        self.m_NameTick = 0.0

        local l_PingTable = {}

        -- Iterate all players
        local s_Players = PlayerManager:GetPlayers()
        for l_Index, l_Player in ipairs(s_Players) do
            -- Get the player team and name
            local l_Team = l_Player.teamId
            local l_Name = l_Player.name
            l_PingTable[l_Player.id] = l_Player.ping
            NetEvents:Broadcast('Player:Ping', l_PingTable)
        end
    end
    self.m_NameTick = self.m_NameTick + p_DeltaTime
end

function iSNServer:OnPlayerJoining(p_Name, p_Guid, p_IpAddress, p_AccountGuid)
    -- Here we can send the event to whichever state we are running in
    print("info: player " .. p_Name .. " is joining the server")
end

function iSNServer:OnPlayerConnected(p_Player)
    if p_Player == nil then
        print("err: invalid player tried to connect.")
        return
    end

    self.m_Match:ForceUpdateHeader(p_Player)

    -- Send out gamestate information if he connects or reconnects
    NetEvents:SendTo("iSN:GameStateChanged", p_Player, GameStates.None, self.m_GameState)

    -- Send out the gametype if he connects or reconnects
    NetEvents:SendTo("iSN:GameTypeChanged", p_Player, iSNConfig.GameType)

    -- Send out the teams if he connects or reconnects
    NetEvents:SendTo("iSN:UpdateTeams", p_Player, self.m_Attackers:GetTeamId(), self.m_Defenders:GetTeamId())

    NetEvents:SendTo("iSN:UpdateTeams", p_Player, self.m_Attackers:GetTeamId(), self.m_Defenders:GetTeamId())

    p_Player.teamId = self:GetTeam(p_Player)
    p_Player.squadId = 1
end

function iSNServer:OnPlayerKilled(p_Player, p_inflictor, position, weapon, isRoadKill, isHeadShot, wasVictimInReviveState, info)
    -- Validate player
    if p_Player == nil or p_inflictor == nil then
        return
    end

    --Suicide
    if p_Player.id == p_inflictor.id then
        return
    end

    if isHeadShot then
        NetEvents:SendTo("iSN:PlayAudio", p_inflictor, "headshot")
    else
        NetEvents:SendTo("iSN:PlayAudio", p_inflictor, "kill")
    end    
end

function iSNServer:GetTeam(p_Player)
    if p_Player == nil then
        return
    end

    local teamId = 1

    local s_Players = PlayerManager:GetPlayers()
    local teams = {}
    for l_Index, l_Player in ipairs(s_Players) do
        if teams[l_Player.teamId] == nil then
            teams[l_Player.teamId] = 0
        end
        teams[l_Player.teamId] = teams[l_Player.teamId] + 1
    end

    local lowest = 999
    for possibleTeamId = 16,1,-1 --4
    do 
        if teams[possibleTeamId] ~= nil and teams[possibleTeamId] < lowest then
            lowest = teams[possibleTeamId]
            teamId = possibleTeamId
        end
        if teams[possibleTeamId] == nil then
            lowest = 0
            teamId = possibleTeamId
        end
    end
    print(teamId .. "for " .. p_Player.name)
    return teamId
end

function iSNServer:OnPlayerLeft(p_Player)
    print("info: player " .. p_Player.name .. " has left the server")
    self.m_LoadoutManager:DeletePlayerLoadout(p_Player)
end

function iSNServer:OnPlayerSetSelectedTeam(p_Player, p_Team)
    if p_Player == nil then
        print("Could not spawn player")
        return
    end

    p_Player.teamId = self:GetTeam(p_Player)
    p_Player.squadId = 1
    print("set team")

    if p_Player.soldier ~= nil then
        self.m_Match:KillPlayer(p_Player, false)
    end
end

function iSNServer:OnPlayerSetSelectedKit(p_Player, p_Data)
    if p_Player == nil or p_Data == nil then
        return
    end

    local l_Data = json.decode(p_Data)

    if l_Data["primaryAttachments"] == nil then
        print(l_Data)
        print("err: invalid kit.")
        return
    end
    
    self.m_LoadoutManager:SetPlayerLoadout(p_Player, l_Data)
        local l_SoldierBlueprint = ResourceManager:SearchForDataContainer('Characters/Soldiers/MpSoldier')
        if p_Player.soldier ~= nil then
            self.m_Match:KillPlayer(p_Player, false)
        end
end

function iSNServer:OnPlayerFindBestSquad(p_Hook, p_Player)
    -- TODO: Force squad
    print("OnPlayerFindBestSquad")
end

function iSNServer:OnPlayerSelectTeam(p_Hook, p_Player, p_Team)
    -- p_Team is R/W
    -- p_Player is RO
     print("OnPlayerSelectTeam")
end

function iSNServer:OnPartitionLoaded(p_Partition)
    -- Validate our partition
    if p_Partition == nil then
        return
    end

    -- Send event to the loadout manager
    self.m_LoadoutManager:OnPartitionLoaded(p_Partition)
end

function iSNServer:OnSoldierDamage(p_Hook, p_Soldier, p_Info, p_GiverInfo)
    if p_Soldier == nil then
        return
    end

    if p_Info == nil then
        return
    end
end

function iSNServer:OnToggleRup(p_Player)
    -- Check to see if we have a valid player
    if p_Player == nil then
        print("err: invalid player tried to rup.")
        return
    end

    -- Get the player information
    local s_PlayerName = p_Player.name
    local s_PlayerId = p_Player.id

    -- We only care if we are in warmup state, otherwise rups mean nothing
    if self.m_GameState ~= GameStates.Warmup then
        print("err: player " .. s_PlayerName .. " tried to rup in non-warmup?")
        return
    end

    -- Update the match information
    self.m_Match:OnPlayerRup(p_Player)
end

-- TODO: This is a debug only function
function iSNServer:OnForceToggleRup(p_Player)
    if p_Player == nil then
        print("err: invalid player.")
        return
    end

    local s_PlayerName = p_Player.name
    local s_PlayerId = p_Player.id

    if self.m_GameState ~= GameStates.Warmup then
        return
    end

    self.m_Match:ForceAllPlayerRup()
end

function iSNServer:OnPlayerChat(p_Player, p_RecipientMask, p_Message)
    -- Check the player
    if p_Player == nil then
        return
    end

    -- Check the message
    if p_Message == nil then
        return
    end

    -- Check the length of the message
    if #p_Message <= 0 then
        return
    end
end

function iSNServer:OnLevelDestroyed()
    -- Forward event to loadout mananager
    self.m_LoadoutManager:OnLevelDestroyed()
    self.m_Match:OnLevelDestroyed()
end

function iSNServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
    self:SetupVariables()
    self.m_Match:RestartMatch()
end

-- Helper functions
function iSNServer:ChangeGameState(p_GameState)
    if p_GameState < GameStates.None or p_GameState > GameStates.EndGame then
        print("err: attempted to switch to an invalid gamestate.")
        return
    end

    local s_OldGameState = self.m_GameState
    self.m_GameState = p_GameState

    NetEvents:Broadcast("iSN:GameStateChanged", s_OldGameState, p_GameState)
end

function iSNServer:SetClientTimer(p_Time, p_Player)
    if p_Time == nil then
        print("err: no time to send to the clients")
        return
    end

    if p_Player ~= nil then
        NetEvents:SendTo("iSN:StartWebUITimer", p_Player, p_Time)
    else
        NetEvents:Broadcast("iSN:StartWebUITimer", p_Time)
    end
end

function iSNServer:SetRoundEndInfoBox(p_WinnerTeamId)
    if p_WinnerTeamId == nil then
        print("err: no winner to send to the clients")
        return
    end

    NetEvents:Broadcast("iSN:SetRoundEndInfoBox", p_WinnerTeamId)
end

function iSNServer:SetGameEnd(p_WinnerTeamId)
    -- Watch out, this can be nil if the game is draw
    NetEvents:Broadcast("iSN:SetGameEnd", p_WinnerTeamId)
end

function iSNServer:SetupVariables()
    -- Hold a dictionary of all of the variables we want to change
    local s_VariablePair = {
        ["vars.soldierHealth"] = "100",
        ["vars.regenerateHealth"] = "true",
        ["vars.onlySquadLeaderSpawn"] = "false",
        -- ["vars.3dSpotting"] = "false",
        ["vars.miniMap"] = "true",
        ["vars.autoBalance"] = "false",
        ["vars.teamKillCountForKick"] = "99999",
        ["vars.teamKillValueForKick"] = "99999",
        ["vars.teamKillValueIncrease"] = "0",
        ["vars.teamKillValueDecreasePerSecond"] = "1",
        ["vars.idleTimeout"] = "300",
        ["vars.3pCam"] = "false",
        ["vars.killCam"] = "false",
        ["vars.roundStartPlayerCount"] = "0",
        ["vars.roundRestartPlayerCount"] = "0",
        ["vars.hud"] = "false",
        -- ["vu.SquadSize"] = tostring(iSNConfig.SquadSize),
        ["vu.ColorCorrectionEnabled"] = "false",
        ["vu.SunFlareEnabled"] = "false",
        ["vu.SuppressionMultiplier"] = "0",
        ["vu.DestructionEnabled"] = "false",
        ["vars.gameModeCounter"] = "99999",
    }

    -- Iterate through all of the commands and set their values via rcon
    for l_Command, l_Value in pairs(s_VariablePair) do
        local s_Result = RCON:SendCommand(l_Command, { l_Value })

        if #s_Result >= 1 then
            if s_Result[1] ~= "OK" then
                print("command: " .. l_Command .. " returned: " .. s_Result[1])
            end
        end
    end

    print("RCON Variables Setup")
end

return iSNServer()

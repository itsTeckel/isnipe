class "iSNClient"

require("ClientCommands")
require("UICleanup")
require("__shared/GameStates")
require("__shared/iSNConfig")
require("__shared/MapsConfig")
require("__shared/LevelNameHelper")


function iSNClient:__init()
    -- Start the client initialization
    print("client initialization")

    -- Extension events
    self.m_ExtensionLoadedEvent = nil
    self.m_ExtensionUnloadedEvent = nil

    self.m_PartitionLoadedEvent = nil

    -- These are the specific events that are required to kick everything else off
    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)
    self.m_DrawHudEvent = Events:Subscribe('UI:DrawHud', self, self.OnDrawHud)

    -- Ready-Up Inputs
    self.m_RupHeldTime = 0.0
    self.m_RupHeldReady = false

    self.m_PlayerInputs = true
    self.debug = false
    self.spawns = {}

    -- Tab / Scoreboard Inputs
    self.m_TabHeldTime = 0.0
    self.m_spawnCheckTime = 0.0
    self.m_ScoreboardActive = false
    
    -- The current gamestate, this is read-only and should only be changed by the SERVER
    if iSNConfig.GameType == GameTypes.Public then
        self.m_GameState = GameStates.Warmup
    else
        self.m_GameState = GameStates.None
    end
    
    -- The current gametype
    self.m_GameType = iSNConfig.GameType

    self.m_AttackersTeamId = TeamId.Team2
    self.m_DefendersTeamId = TeamId.Team1

    self.m_FirstSpawn = false

    self.m_ExplosionEntityData = nil
end

function iSNClient:OnDrawHud()
    if self.debug then
        for index, spawn in pairs(self.spawns) do
            local pos = Vec3(spawn[4][1], spawn[4][2], spawn[4][3])



            local localPlayer = PlayerManager:GetLocalPlayer()
            if localPlayer == nil then
                return
            end

            local localSoldier = localPlayer.soldier
            if localSoldier == nil then
                return
            end
            --player coordinates
            local soldierLinearTransform = localSoldier.worldTransform
            --player distance to spawnpoints
            local distance = self:Distance(spawn[4][1], spawn[4][2], spawn[4][3], soldierLinearTransform.trans.x, soldierLinearTransform.trans.y, soldierLinearTransform.trans.z)

            if distance < 5 then
                DebugRenderer:DrawText2D(1080, 200, spawn[5][1], Vec4(0, 0, 1, 0.5), 5)
            end


            DebugRenderer:DrawSphere(pos, 0.15, Vec4(0, 0, 1, 0.5), true, false)
        end
    end
end

function iSNClient:Distance( x1, y1, z1, x2, y2, z2 )
    return math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1))
end

-- ==========
-- Extensions
-- ==========

function iSNClient:OnExtensionLoaded()
    -- Register all of the console variable commands
    self:RegisterCommands()

    -- Register all of the events
    self:RegisterEvents()

    -- Initialize the WebUI
    WebUI:Init()

    -- Show the WebUI
    WebUI:Show()
end

function iSNClient:OnExtensionUnloaded()
    self:UnregisterCommands()
    self:UnregisterEvents()
end

-- ==========
-- Events
-- ==========
function iSNClient:RegisterEvents()
    print("registering events")

    -- Install input hooks
    self.m_InputPreUpdateHook = Hooks:Install("Input:PreUpdate", 1, self, self.OnInputPreUpdate)
    self.m_UIInputConceptHook = Hooks:Install('UI:InputConceptEvent', 1, self, self.OnUIInputConceptEvent)

    -- Engine tick
    self.m_EngineUpdateEvent = Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)

    self.m_PartitionLoadedEvent = Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)

    -- Game State events
    self.m_GameStateChangedEvent = NetEvents:Subscribe("iSN:GameStateChanged", self, self.OnGameStateChanged)

    -- Game Type events
    self.m_GameTypeChangedEvent = NetEvents:Subscribe("iSN:GameTypeChanged", self, self.OnGameTypeChanged)

    -- Ready Up State Update
    self.m_RupStateEvent = NetEvents:Subscribe("iSN:RupStateChanged", self, self.OnRupStateChanged)

    -- Update ping table
    self.m_PlayerPing = NetEvents:Subscribe("Player:Ping", self, self.OnPlayerPing)
    self.m_PingTable = {}

    self.m_PlayerReadyUpPlayers = NetEvents:Subscribe("Player:ReadyUpPlayers", self, self.OnReadyUpPlayers)
    self.m_PlayerReadyUpPlayersTable = {}

    -- Player Events
    self.m_PlayerRespawnEvent = Events:Subscribe("Player:Respawn", self, self.OnPlayerRespawn)
    self.m_PlayerKilledEvent = Events:Subscribe("Player:Killed", self, self.OnPlayerKilled)
    self.m_SoldierHealthActionEvent = Events:Subscribe("Soldier:HealthAction", self, self.OnSoldierHealthAction)
    self.m_PlayerDeletedEvent = Events:Subscribe("Player:Deleted", self, self.OnPlayerDeleted)

    -- Level events
    self.m_LevelDestroyEvent = Events:Subscribe("Level:Destroy", self, self.OnLevelDestroyed)
    self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    self.m_LevelLoadResourcesEvent = Events:Subscribe("Level:LoadResources", self, self.OnLevelLoadResources)

    -- Client events
    self.m_ClientUpdateInputEvent = Events:Subscribe('Client:UpdateInput', self, self.OnUpdateInput)

    -- WebUI
    self.m_SetSelectedTeamEvent = Events:Subscribe("WebUISetSelectedTeam", self, self.OnSetSelectedTeam)
    self.m_SetSelectedLoadoutEvent = Events:Subscribe("WebUISetSelectedLoadout", self, self.OnSetSelectedLoadout)
    self.m_WebUICalculatedSpawnEvent = Events:Subscribe("WebUICalculatedSpawn", self, self.OnCalculatedSpawn)
    self.m_WebUIDebugEvent = Events:Subscribe("WebUIDebug", self, self.OnDebug)

    self.m_StartWebUITimerEvent = NetEvents:Subscribe("iSN:StartWebUITimer", self, self.OnStartWebUITimer)
    self.m_UpdateHeaderEvent = NetEvents:Subscribe("iSN:UpdateHeader", self, self.OnUpdateHeader)
    self.m_SetRoundEndInfoBoxEvent = NetEvents:Subscribe("iSN:SetRoundEndInfoBox", self, self.OnSetRoundEndInfoBox)
    self.m_SetGameEndEvent = NetEvents:Subscribe("iSN:SetGameEnd", self, self.OnSetGameEnd)
    self.m_ResetUIEvent = NetEvents:Subscribe("iSN:ResetUI", self, self.OnResetUI)
    self.m_PlaySoundPlantingEvent = NetEvents:Subscribe("iSN:PlayAudio", self, self.OnPlayAudio)

    self.m_UpdateTeamsEvent = NetEvents:Subscribe("iSN:UpdateTeams", self, self.OnUpdateTeams)

    self.m_DisablePlayerInputsEvent = NetEvents:Subscribe("iSN:DisablePlayerInputs", self, self.OnDisablePlayerInputs)
    self.m_EnablePlayerInputsEvent = NetEvents:Subscribe("iSN:EnablePlayerInputs", self, self.OnEnablePlayerInputs)

    -- Cleanup Events
    self.m_CleanupEvent = NetEvents:Subscribe("iSN:Cleanup", self, self.OnCleanup)
end

function iSNClient:OnPartitionLoaded(p_Partition)

end

function iSNClient:UnregisterEvents()
    print("unregistering events")
end

function iSNClient:OnSetSelectedTeam(p_Team)
    if p_Team == nil then
        return
    end

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if p_Team == 3 then -- auto-join
        local s_Attackers = PlayerManager:GetPlayersByTeam(self.m_AttackersTeamId)
        local s_Defenders = PlayerManager:GetPlayersByTeam(self.m_DefendersTeamId)

        local s_AttackersCount = 0
        for index, l_Player in pairs(s_Attackers) do
            s_AttackersCount = s_AttackersCount + 1
        end

        local s_DefendersCount = 0
        for index, l_Player in pairs(s_Defenders) do
            s_DefendersCount = s_DefendersCount + 1
        end

        if s_AttackersCount > s_DefendersCount then
            NetEvents:Send("iSN:PlayerSetSelectedTeam", self.m_DefendersTeamId)
        elseif s_AttackersCount < s_DefendersCount then
            NetEvents:Send("iSN:PlayerSetSelectedTeam", self.m_AttackersTeamId)
        else
            NetEvents:Send("iSN:PlayerSetSelectedTeam", self.m_AttackersTeamId)
        end
    elseif p_Team == 2 then -- attackers
        NetEvents:Send("iSN:PlayerSetSelectedTeam", self.m_AttackersTeamId)
    else -- defenders
        NetEvents:Send("iSN:PlayerSetSelectedTeam", self.m_DefendersTeamId)
    end
end

function iSNClient:OnSetSelectedLoadout(p_Data)
    if p_Data == nil then
        return
    end

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    -- If the player never spawned we should force him to pick a team and a loadout first
    if self.m_FirstSpawn == false then
        self.m_FirstSpawn = true
    end

    NetEvents:Send("iSN:PlayerSetSelectedKit", p_Data)

    local localPlayer = PlayerManager:GetLocalPlayer()
    if localPlayer ~= nil then
        WebUI:ExecuteJS(string.format("exports.SS_SetDetails(\"%s\");", localPlayer.name))
        return
    end
end

-- ==========
-- Console Commands
-- ==========
function iSNClient:RegisterCommands()
    self.m_debug = Console:Register("debug", "Sets debug mode on for iSnipe", ClientCommands.Debug)
end

function iSNClient:UnregisterCommands()
    Console:Deregister("iSN_force_ready_up")
end

function iSNClient:OnLevelDestroyed()
    print('OnLevelDestroyed')
    WebUI:ExecuteJS("OnDeath();")
    
    self.m_PingTable = {}
    self.m_PlayerReadyUpPlayersTable = {}
    self.m_RupHeldTime = 0.0
    self.m_RupHeldReady = false
    self.m_PlayerInputs = true

    self.m_TabHeldTime = 0.0
    self.m_ScoreboardActive = false
    
    --if iSNConfig.GameType == GameTypes.Public then
    --    self.m_GameState = GameStates.Warmup
    --else
        self.m_GameState = GameStates.None
    --end
    
    self.m_GameType = iSNConfig.GameType
    
    self.m_AttackersTeamId = TeamId.Team2
    self.m_DefendersTeamId = TeamId.Team1

    self.m_FirstSpawn = false
    self.m_ExplosionEntityData = nil
    self.levelLoaded = false

    WebUI:ExecuteJS('ResetUI();')
end

function iSNClient:OnLevelLoaded()
    self.levelLoaded = true
    NetEvents:Send("iSN:PlayerConnected")
    WebUI:ExecuteJS("OpenCloseTeamMenu(true);")
    WebUI:ExecuteJS("RoundCount(" .. iSNConfig.MatchDefaultRounds .. ");")
    WebUI:ExecuteJS("ChangeState(" .. self.m_GameState .. ");")
end

function iSNClient:OnLevelLoadResources()
    print('OnLevelLoadResources')
    self.m_ExplosionEntityData = nil
    self.levelLoaded = false
end

function iSNClient:OnUpdateInput(p_DeltaTime)
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_F9) then
        local localPlayer = PlayerManager:GetLocalPlayer()
        if localPlayer == nil then
            return
        end

        -- Check to see if the player is alive
        if localPlayer.alive == false then
            return
        end

        -- Get the local soldier instance
        local localSoldier = localPlayer.soldier
        if localSoldier == nil then
            return
        end

        -- Get the soldier LinearTransform
        local soldierLinearTransform = localSoldier.worldTransform

        -- Get the position vector

        -- Return the formatted string (x, y, z)
        print("coordinate: [[" .. soldierLinearTransform.left.x .. ", " .. soldierLinearTransform.left.y .. ", " .. soldierLinearTransform.left.z .. "], [" .. soldierLinearTransform.up.x .. ", " .. soldierLinearTransform.up.y .. ", " .. soldierLinearTransform.up.z .. "], [" .. soldierLinearTransform.forward.x .. ", " .. soldierLinearTransform.forward.y .. ", " .. soldierLinearTransform.forward.z .. "], [" .. soldierLinearTransform.trans.x .. ", " .. soldierLinearTransform.trans.y .. ", " .. soldierLinearTransform.trans.z .. "]]")
    end

    -- Open Loadout menu
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_F10) then
        --current camera position
        local soldierLinearTransform = ClientUtils:GetCameraTransform()
        print("coordinate: [[" .. soldierLinearTransform.left.x .. ", " .. soldierLinearTransform.left.y .. ", " .. soldierLinearTransform.left.z .. "], [" .. soldierLinearTransform.up.x .. ", " .. soldierLinearTransform.up.y .. ", " .. soldierLinearTransform.up.z .. "], [" .. soldierLinearTransform.forward.x .. ", " .. soldierLinearTransform.forward.y .. ", " .. soldierLinearTransform.forward.z .. "], [" .. soldierLinearTransform.trans.x .. ", " .. soldierLinearTransform.trans.y .. ", " .. soldierLinearTransform.trans.z .. "]]")


        -- If the player never spawned we should force him to pick a team and a loadout first
        if self.m_FirstSpawn then
            WebUI:ExecuteJS("OpenCloseLoadoutMenu();")
        end
    end
end

function iSNClient:OnUIInputConceptEvent(p_Hook, p_EventType, p_Action)    
    if p_Action == UIInputAction.UIInputAction_Tab then
        local s_Player = PlayerManager:GetLocalPlayer()
        if s_Player ~= nil then
            if p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
                if not self.m_ScoreboardActive then
                    self.m_ScoreboardActive = true
                    self:OnUpdateScoreboard()
                    WebUI:ExecuteJS("OpenCloseScoreboard(" .. string.format('%s', true) .. ");")
                end
            else
                if self.m_ScoreboardActive then
                    self.m_ScoreboardActive = false
                    WebUI:ExecuteJS("OpenCloseScoreboard(" .. string.format('%s', false) .. ");")
                end
            end
            p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
        end
    end
end

function iSNClient:OnInputPreUpdate(p_Hook, p_Cache, p_DeltaTime)
    -- Validate our cache
    if p_Cache == nil then
        print("err: invalid input cache.")
        return
    end

    -- Get the local player id
    local s_Player = PlayerManager:GetLocalPlayer()
    if s_Player == nil then
        return
    end

    -- Check to see if we are in the warmup state to get rup status
    if self.m_GameState == GameStates.Warmup then
        -- Get the interact level
        local s_InteractLevel = p_Cache:GetLevel(InputConceptIdentifiers.ConceptInteract)
        
        -- If the player is holding the interact key then update our variables and clear it for the next frame
        if s_InteractLevel > 0.0 then
            self.m_RupHeldTime = self.m_RupHeldTime + p_DeltaTime
            p_Cache:SetLevel(InputConceptIdentifiers.ConceptInteract, 0.0)
        else
            if self.m_RupHeldReady then
                self.m_RupHeldReady = false
            end
            -- If the client isn't holding interact reset our time
            self.m_RupHeldTime = 0.0
        end

        -- Toggle the rup state
        if self.m_RupHeldTime >= iSNConfig.MaxReadyUpTime then
            if not self.m_RupHeldReady then
                NetEvents:Send("iSN:ToggleRup")
                WebUI:ExecuteJS("RupInteractProgress(" .. tostring(0) ..", " .. tostring(iSNConfig.MaxReadyUpTime) .. ");")
                self.m_RupHeldReady = true
            end
        else
            WebUI:ExecuteJS("RupInteractProgress(" .. tostring(self.m_RupHeldTime) ..", " .. tostring(iSNConfig.MaxReadyUpTime) .. ");")
        end
    end
end

function iSNClient:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    if self.levelLoaded == false then
        return
    end

    if self.m_TabHeldTime >= 3.0 then
        if self.m_ScoreboardActive then
            self:OnUpdateScoreboard()
        end
        self.m_TabHeldTime = 0.0
    end

    if self.m_spawnCheckTime >= 3.0 then
        self:GetSpawn()
        self.m_spawnCheckTime = 0.0
        WebUI:ExecuteJS("ChangeState(" .. self.m_GameState .. ");")
        --print("SpawnChecktime over 3 seconds")
    end

    self.m_TabHeldTime = self.m_TabHeldTime + p_DeltaTime
    self.m_spawnCheckTime = self.m_spawnCheckTime + p_DeltaTime
end

function iSNClient:OnRupStateChanged(p_WaitingOnPlayers, p_LocalRupStatus)
    --[[if p_WaitingOnPlayers == nil then
        print("err: invalid waiting on player count.")
        return
    end

    if p_LocalRupStatus == nil then
        print("err: invalid local rup status.")
        return
    end]]
end

function iSNClient:OnPlayerPing(p_PingTable)
    self.m_PingTable = p_PingTable
end

function iSNClient:OnReadyUpPlayers(p_ReadyUpPlayers)
    self.m_PlayerReadyUpPlayersTable = p_ReadyUpPlayers
end

function iSNClient:OnGameStateChanged(p_OldGameState, p_GameState)
    -- Validate our gamestates
    if p_OldGameState == nil or p_GameState == nil then
        print("err: invalid gamestate from server")
        return
    end

    if p_OldGameState == p_GameState then
        -- Removed the warning, on first connect it tries to update the local GameState to GameState.None, 
        -- later on when the player reconnects the local GameState going to change for him
        return
    end

    print("info: gamestate " .. p_OldGameState .. " -> " .. p_GameState)
    self.m_GameState = p_GameState

    if self.m_AlarmEntity ~= nil then
        self.m_AlarmEntity:FireEvent('Stop')
        self.m_AlarmEntity = nil
    end

    -- Update the WebUI
    if self.levelLoaded then
        WebUI:ExecuteJS("ChangeState(" .. self.m_GameState .. ");")
    end
end

function iSNClient:OnGameTypeChanged(p_GameType)
    -- Validate our gametype
    if p_GameType == nil then
        print("err: invalid gametype")
        return
    end

    print("info: gametype " .. p_GameType)
    self.m_GameType = p_GameType

    -- Update the WebUI
    WebUI:ExecuteJS("ChangeType(" .. self.m_GameType .. ");")
end

function iSNClient:OnUpdateHeader(p_AttackerPoints, p_DefenderPoints, p_Rounds)
        WebUI:ExecuteJS('UpdateHeader(' .. p_AttackerPoints .. ', ' .. p_DefenderPoints .. ', ' .. (p_Rounds + 1) .. ');')
end

function iSNClient:OnUpdateTeams(p_AttackersTeamId, p_DefendersTeamId)
    if self.m_AttackersTeamId ~= p_AttackersTeamId then
        self.m_AttackersTeamId = p_AttackersTeamId
    end

    if self.m_DefendersTeamId ~= p_DefendersTeamId then
        self.m_DefendersTeamId = p_DefendersTeamId
    end
end

function iSNClient:OnUpdateScoreboard()
    local l_PlayerList = PlayerManager:GetPlayers()
    local p_Player = PlayerManager:GetLocalPlayer()
    if p_Player == nil then
        return
    end

    table.sort(l_PlayerList, function(a, b) 
		return a.kills > b.kills
    end)

    local l_PlayersObject = {}
    l_PlayersObject["all"] = {}
    
    local l_PlayerClientIndex = 0
    for index, l_Player in pairs(l_PlayerList) do
		local l_Ping = "0"
		if self.m_PingTable[l_Player.id] ~= nil and self.m_PingTable[l_Player.id] >= 0 and self.m_PingTable[l_Player.id] < 999 then
			l_Ping = self.m_PingTable[l_Player.id]
        end

        if l_Player.name == p_Player.name then
            l_PlayerClientIndex = index
        end
        
		table.insert(l_PlayersObject["all"], {
            ["id"] = l_Player.id,
            ["name"] = l_Player.name,
            ["ping"] = l_Ping,
            ["kill"] = l_Player.kills,
            ["death"] = l_Player.deaths,
            ["isDead"] = not l_Player.alive,
            ["index"] = index,
            ["team"] = l_Player.teamId,
        })
    end

    local l_PlayerClient = {
        ["id"] = p_Player.id,
        ["name"] = p_Player.name,
        ["ping"] = l_Ping,
        ["kill"] = p_Player.kills,
        ["death"] = p_Player.deaths,
        ["isDead"] = not p_Player.alive,
        ["index"] = l_PlayerClientIndex,
        ["team"] = p_Player.teamId,
    }

    WebUI:ExecuteJS(string.format("UpdatePlayers(%s, %s);", json.encode(l_PlayersObject), json.encode(l_PlayerClient)))
end

--request, called every 3 ticks
function iSNClient:GetSpawn() 
    local s_Player = PlayerManager:GetLocalPlayer()
    if s_Player ~= nil then
        if s_Player.alive then
            return
        end
    end

    local l_PlayerList = PlayerManager:GetPlayers()
    local players = {}
    for index, l_Player in pairs(l_PlayerList) do
        if s_Player.teamId ~= l_Player.teamId then
            if l_Player.alive then
                -- Get the local soldier instance
                local soldier = l_Player.soldier
                if soldier ~= nil then
                    -- Get the soldier LinearTransform
                    local soldierLinearTransform = soldier.worldTransform
                    local coordinates = {}
                    table.insert(coordinates, soldierLinearTransform.trans.x)
                    table.insert(coordinates, soldierLinearTransform.trans.y)
                    table.insert(coordinates, soldierLinearTransform.trans.z)
                    table.insert(players, coordinates)
                end
            end
        end
    end
    if self.debug then
        print(string.format("exports.SS_GetSpawn(%s, \"%s\");", json.encode(players), LevelNameHelper:GetLevelName()))
    end
    WebUI:ExecuteJS(string.format("exports.SS_GetSpawn(%s, \"%s\");", json.encode(players), LevelNameHelper:GetLevelName()))
end

-- response back from JS
function iSNClient:OnCalculatedSpawn(p_Data)
    if p_Data == nil then
        return
    end
    if self.debug then
        print("OnCalculatedSpawn")
        print(p_Data)
    end
    --Send it to server
    NetEvents:Send("iSN:SetSpawn", p_Data)
end

function iSNClient:OnDebug(spawns_data)
    if self.debug then
        self.debug = false
    else
        self.debug = true
    end
    self.spawns = json.decode(spawns_data)
end

function iSNClient:OnStartWebUITimer(p_Time)
    WebUI:ExecuteJS(string.format("SetTimer(%s);", p_Time))
end

function iSNClient:OnSetRoundEndInfoBox(p_WinnerTeamId)
    local s_IsPlayerWinner = false

    local s_Player = PlayerManager:GetLocalPlayer()
    if s_Player == nil then
        return
    end

    if s_Player.teamId == p_WinnerTeamId then
        s_IsPlayerWinner = true
    end
    
    if p_WinnerTeamId == self.m_AttackersTeamId then
        WebUI:ExecuteJS('UpdateRoundEndInfoBox('.. tostring(s_IsPlayerWinner) .. ', "attackers");')
    else
        WebUI:ExecuteJS('UpdateRoundEndInfoBox('.. tostring(s_IsPlayerWinner) .. ', "defenders");')
    end

    WebUI:ExecuteJS("ShowHideRoundEndInfoBox(true)")
end

function iSNClient:OnSetGameEnd(p_WinnerTeamId)
    local s_IsPlayerWinner = false

    if p_WinnerTeamId == nil then
        WebUI:ExecuteJS('SetGameEnd('.. tostring(s_IsPlayerWinner) .. ', "draw");')
    else
        local s_Player = PlayerManager:GetLocalPlayer()
        if s_Player == nil then
            return
        end

        if s_Player.teamId == p_WinnerTeamId then
            s_IsPlayerWinner = true
        end
        
        if p_WinnerTeamId == self.m_AttackersTeamId then
            WebUI:ExecuteJS('SetGameEnd('.. tostring(s_IsPlayerWinner) .. ', "attackers");')
        else
            WebUI:ExecuteJS('SetGameEnd('.. tostring(s_IsPlayerWinner) .. ', "defenders");')
        end
    end
end


function iSNClient:OnResetUI()
    WebUI:ExecuteJS('ResetUI();')
end

function iSNClient:OnPlayAudio(track)
    if track == nil then
		return
    end
    if track == "headshot" then
        print("headshot")
        WebUI:ExecuteJS("exports.SS_OnKill();") -- inform spawn system of a kill
        WebUI:ExecuteJS("OnHeadShot();")
        return
    end
    if track == "kill" then
        print("Kill")
        WebUI:ExecuteJS("exports.SS_OnKill();") -- inform spawn system of a kill
        WebUI:ExecuteJS("OnKill();")
        return
    end
    print(track .. "is not mapped")
end

function iSNClient:OnCleanup(p_EntityType)
    if p_EntityType == nil then
        return
    end
    local l_Entities = {}

    local l_Iterator = EntityManager:GetIterator(p_EntityType)
    local l_Entity = l_Iterator:Next()
    while l_Entity do
        l_Entities[#l_Entities+1] = Entity(l_Entity)
        l_Entity = l_Iterator:Next()
    end

    for _, l_Entity in pairs(l_Entities) do
        if l_Entity ~= nil then
            l_Entity:Destroy()
        end
    end
end

function iSNClient:OnPlayerRespawn(p_Player)
    -- Validate player
    if p_Player == nil then
        return
    end

    local s_Player = PlayerManager:GetLocalPlayer()
    -- Validate local player
    if s_Player == nil then
        return
    end

    self:OnUpdateScoreboard()

    if p_Player.name == s_Player.name then
        --self.m_SpecCam:Disable()
        --IngameSpectator:disable()
        WebUI:ExecuteJS('SpectatorEnabled('.. tostring(false) .. ');')
        if self.debug then
            print(string.format("exports.SS_OnSpawned(%s);", json.encode(self:PlayerCoordinates(s_Player))))
        end
        WebUI:ExecuteJS(string.format("exports.SS_OnSpawned(%s);", json.encode(self:PlayerCoordinates(s_Player))))-- inform spawn system of our spawn
    end
end

function iSNClient:PlayerCoordinates(player)
    if player == nil then
        return nil
    end

    local soldier = player.soldier
    if soldier == nil then
        return nil
    end

    -- Get the soldier LinearTransform
    local soldierLinearTransform = soldier.worldTransform
    local result = {}
    table.insert(result, soldierLinearTransform.trans.x)
    table.insert(result, soldierLinearTransform.trans.y)
    table.insert(result, soldierLinearTransform.trans.z)
    return result
end

--XP4_FD SquadDeathMatch0 1
function iSNClient:OnPlayerKilled(p_Player)
    -- Validate player
    if p_Player == nil then
        return
    end

    local s_Player = PlayerManager:GetLocalPlayer()
    -- Validate local player
    if s_Player == nil then
        return
    end

    if p_Player.id == s_Player.id then
        self:EnablePlayerInputs()

        --IngameSpectator:enable()
        WebUI:ExecuteJS("OnDeath();")--deathstreak

        -- inform spawn system of our death
        if self.debug then
            print(string.format("exports.SS_OnDeath(%s);", json.encode(self:PlayerCoordinates(s_Player))))
        end
        WebUI:ExecuteJS(string.format("exports.SS_OnDeath(%s);", json.encode(self:PlayerCoordinates(s_Player))))
    end
    self:GetSpawn()
end

function iSNClient:OnSoldierHealthAction(p_Soldier, p_Action)
    local s_Player = PlayerManager:GetLocalPlayer()
    -- Validate local player
    if s_Player == nil then
        return
    end

    if p_Action == HealthStateAction.OnKilled or
        p_Action == HealthStateAction.OnDead or
        p_Action == HealthStateAction.OnDeathAnimationDone
    then
        self:OnUpdateScoreboard(s_Player)
    end
end

function iSNClient:OnPlayerDeleted(p_Player)
    -- Validate player
    if p_Player == nil then
        return
    end
    print('OnPlayerDeleted')
end

function iSNClient:OnDisablePlayerInputs()
    self:DisablePlayerInputs()
end

function iSNClient:DisablePlayerInputs()
    if self.m_PlayerInputs then
        local s_Player = PlayerManager:GetLocalPlayer()
        if s_Player ~= nil then
            s_Player:EnableInput(EntryInputActionEnum.EIAFire, false)
            s_Player:EnableInput(EntryInputActionEnum.EIAJump, false)
            s_Player:EnableInput(EntryInputActionEnum.EIAThrowGrenade, false)
            s_Player:EnableInput(EntryInputActionEnum.EIAThrottle, false)
            s_Player:EnableInput(EntryInputActionEnum.EIAStrafe, false)
            s_Player:EnableInput(EntryInputActionEnum.EIAMeleeAttack, false)
            s_Player:EnableInput(EntryInputActionEnum.EIAChangePose, false)
            s_Player:EnableInput(EntryInputActionEnum.EIAProne, false)
            s_Player:EnableInput(EntryInputActionEnum.EIASprint, false)
            self.m_PlayerInputs = false
        end
    end
end

function iSNClient:OnEnablePlayerInputs()
    self:EnablePlayerInputs()
end

function iSNClient:EnablePlayerInputs()
    if not self.m_PlayerInputs then
        local s_Player = PlayerManager:GetLocalPlayer()
        if s_Player ~= nil then
            s_Player:EnableInput(EntryInputActionEnum.EIAFire, true)
            s_Player:EnableInput(EntryInputActionEnum.EIAJump, true)
            s_Player:EnableInput(EntryInputActionEnum.EIAThrowGrenade, true)
            s_Player:EnableInput(EntryInputActionEnum.EIAThrottle, true)
            s_Player:EnableInput(EntryInputActionEnum.EIAStrafe, true)
            s_Player:EnableInput(EntryInputActionEnum.EIAMeleeAttack, true)
            s_Player:EnableInput(EntryInputActionEnum.EIAChangePose, true)
            s_Player:EnableInput(EntryInputActionEnum.EIAProne, true)
            s_Player:EnableInput(EntryInputActionEnum.EIASprint, true)
            self.m_PlayerInputs = true
        end
    end
end

return iSNClient()

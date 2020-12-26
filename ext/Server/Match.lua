local Match = class("Match")
require ("__shared/MapsConfig")
require ("__shared/GameStates")
require ("__shared/kPMConfig")
require ("__shared/LevelNameHelper")
require ("__shared/GameTypes")
require ("__shared/Util/TableHelper")

require ("Team")
require ("LoadoutManager")
require ("LoadoutDefinitions")

function Match:__init(p_Server, p_TeamAttackers, p_TeamDefenders, p_RoundCount, p_LoadoutManager, p_GameType)
    if p_GameType ~= GameTypes.Public then
        print("Only public gametype is supported as of now.")
        return
    end

    -- Save server reference
    self.m_Server = p_Server

    self.m_Attackers = p_TeamAttackers
    self.m_Defenders = p_TeamDefenders

    -- Number of rounds to play in total (divide by 2 for rounds per half)
    self.m_RoundCount = p_RoundCount

    -- The current round being played, starts at 1, value of 0 means invalid
    self.m_CurrentRound = 0

    -- Keep track of ready up status
    -- This uses the (PlayerId, bool) to prevent memory references
    self.m_ReadyUpPlayers = { }

    -- Last game state (so if we are going to timeout->gameplay we know which half we are in)
    self.m_CurrentState = GameStates.None
    self.m_LastState = GameStates.None

    -- State callbacks
    self.m_UpdateStates = { }
    self.m_UpdateStates[GameStates.Warmup] = self.OnWarmup
    self.m_UpdateStates[GameStates.Playing] = self.OnPlaying
    self.m_UpdateStates[GameStates.EndGame] = self.OnEndGame

    -- State ticks
    self.m_UpdateTicks = { }
    self.m_UpdateTicks[GameStates.None] = 0.0
    self.m_UpdateTicks[GameStates.Warmup] = 0.0
    self.m_UpdateTicks[GameStates.Playing] = 0.0
    self.m_UpdateTicks[GameStates.EndGame] = 0.0

    self.m_LoadoutManager = p_LoadoutManager

    self.m_KillQueue = { }
    self.m_SpawnQueue = { }
    self.m_UpdateManagerUpdateEvent = Events:Subscribe("UpdateManager:Update", self, self.OnUpdateManagerUpdate)

    self.m_RestartQueue = false

    self.m_GameType = p_GameType

    self.m_BombSite = nil
    self.m_BombLocation = nil
    self.m_BombTime = nil
end

function Match:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
    if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
        if not TableHelper:empty(self.m_KillQueue) then
            self:KillQueuedPlayers()
        end
        
        if not TableHelper:empty(self.m_SpawnQueue) then
            self:SpawnQueuedPlayers()
        end

        if self.m_RestartQueue then
            self:RestartMatch()
            RCON:SendCommand('mapList.runNextRound')
            self.m_RestartQueue = false
        end
    end
end

-- ==========
-- Logic Update Callbacks
-- ==========

function Match:OnEngineUpdate(p_GameState, p_DeltaTime)
    local s_Callback = self.m_UpdateStates[p_GameState]
    if s_Callback == nil then
        return
    end

    if self.m_CurrentState ~= p_GameState then
        if kPMConfig.DebugMode then
            print("transitioning from " .. self.m_LastState .. " to " .. p_GameState)
        end

        -- Reset tickets
        TicketManager:SetTicketCount(self.m_Attackers:GetTeamId(), 0)
        TicketManager:SetTicketCount(self.m_Defenders:GetTeamId(), 0)

        self.m_LastState = self.m_CurrentState
    end

    self.m_CurrentState = p_GameState

    s_Callback(self, p_DeltaTime)
end

function Match:OnWarmup(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.Warmup] == 0.0 then
        self.m_Server:SetClientTimer(0)
    end

    -- Check to see if the current time is greater or equal than our max
    if self.m_UpdateTicks[GameStates.Warmup] >= kPMConfig.MaxRupTick then
        self.m_UpdateTicks[GameStates.Warmup] = 0.0

        -- Check if all players are readied up
        if self:IsAllPlayersRup() then
            -- First change the game state so we have no logic running
            self.m_Server:ChangeGameState(GameStates.None)
            --ChatManager:Yell("All players have readied up, starting knife round...", 2.0)

            -- Handle resetting all players or spawning them
            self.m_Server:ChangeGameState(GameStates.Playing)
        end

        -- Update status to all players
        local s_Players = PlayerManager:GetPlayers()
        for l_Index, l_Player in ipairs(s_Players) do
            -- Check if this specific player is readied up
            local l_PlayerRup = self:IsPlayerRup(l_Player.id)
            
            -- Send to client to update WebUI
            NetEvents:SendTo("kPM:RupStateChanged", l_Player, self:GetPlayerNotRupCount(), l_PlayerRup)
        end
    end

    -- Add the delta time to our rup timer
    self.m_UpdateTicks[GameStates.Warmup] = self.m_UpdateTicks[GameStates.Warmup] + p_DeltaTime
end

function Match:GetPlayerCounts()
    local s_AttackerAliveCount = 0
    local s_DefenderAliveCount = 0

    local s_AttackerTotalCount = 0
    local s_DefenderTotalCount = 0

    local s_AttackerDeadCount = 0
    local s_DefenderDeadCount = 0

    -- Get the attacker and defender team ids
    local s_AttackerId = self.m_Attackers:GetTeamId()
    local s_DefenderId = self.m_Defenders:GetTeamId()

    -- Iterate and check alive status
    local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
        -- Validate player
        if l_Player == nil then
            goto _on_knife_round_continue_
        end

        local s_Team = l_Player.teamId

        if not l_Player.alive then
            if s_Team == s_AttackerId then
                s_AttackerDeadCount = s_AttackerDeadCount + 1
            elseif s_Team == s_DefenderId then
                s_DefenderDeadCount = s_DefenderDeadCount + 1
            end
        else
            if s_Team == s_AttackerId then
                s_AttackerAliveCount = s_AttackerAliveCount + 1
            elseif s_Team == s_DefenderId then
                s_DefenderAliveCount = s_DefenderAliveCount + 1
            end
        end

        if s_Team == s_AttackerId then
            s_AttackerTotalCount = s_AttackerTotalCount + 1
        elseif s_Team == s_DefenderId then
            s_DefenderTotalCount = s_DefenderTotalCount + 1
        end
        ::_on_knife_round_continue_::
    end

    return s_AttackerAliveCount, s_AttackerDeadCount, s_AttackerTotalCount, s_DefenderAliveCount, s_DefenderDeadCount, s_DefenderTotalCount
end


function Match:OnPlaying(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.Playing] == 0.0 then
        self.m_Server:SetClientTimer(kPMConfig.MaxRoundTime)
    end

    if self.m_UpdateTicks[GameStates.Playing] >= kPMConfig.MaxRoundTime then
        self:KillAllPlayers(false)
        self.m_Server:ChangeGameState(GameStates.EndGame)
    end

    self.m_UpdateTicks[GameStates.Playing] = self.m_UpdateTicks[GameStates.Playing] + p_DeltaTime
end


function Match:OnEndGame(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.EndGame] == 0.0 then
        self:DisablePlayerInputs()
        if self.m_Attackers:CountRoundWon() == self.m_Defenders:CountRoundWon() then
            print('Game end: Draw')
            self.m_Server:SetGameEnd(nil)
        else
            if self.m_Attackers:CountRoundWon() > self.m_Defenders:CountRoundWon() then
                print('Game end: Attackers win')
                self.m_Server:SetGameEnd(self.m_Attackers:GetTeamId())
            else
                print('Game end: Defenders win')
                self.m_Server:SetGameEnd(self.m_Defenders:GetTeamId())
            end
        end

        self.m_Server:SetClientTimer(kPMConfig.MaxEndgameTime)
    end

    if self.m_UpdateTicks[GameStates.EndGame] >= kPMConfig.MaxEndgameTime then
        -- Set the restart queue so we can trigger an rcon restart or something like that
        self.m_RestartQueue = true
    end

    self.m_UpdateTicks[GameStates.EndGame] = self.m_UpdateTicks[GameStates.EndGame] + p_DeltaTime
end

function Match:ForceUpdateHeader(p_Player)
    if p_Player == nil then
        return
    end

    NetEvents:SendTo("kPM:UpdateHeader", p_Player, self.m_Attackers:CountRoundWon(), self.m_Defenders:CountRoundWon(), self.m_CurrentRound)
end

function Match:DisablePlayerInputs()
    --[[local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
        l_Player:EnableInput(EntryInputActionEnum.EIAFire, false)
        l_Player:EnableInput(EntryInputActionEnum.EIAJump, false)
        l_Player:EnableInput(EntryInputActionEnum.EIAThrowGrenade, false)
        l_Player:EnableInput(EntryInputActionEnum.EIAThrottle, false)
        l_Player:EnableInput(EntryInputActionEnum.EIAStrafe, false)
        l_Player:EnableInput(EntryInputActionEnum.EIAMeleeAttack, false)
        l_Player:EnableInput(EntryInputActionEnum.EIAChangePose, false)
        l_Player:EnableInput(EntryInputActionEnum.EIAProne, false)
    end]]
    NetEvents:Broadcast("kPM:DisablePlayerInputs")
end

function Match:EnablePlayerInputs()
    --[[local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
        l_Player:EnableInput(EntryInputActionEnum.EIAFire, true)
        l_Player:EnableInput(EntryInputActionEnum.EIAJump, true)
        l_Player:EnableInput(EntryInputActionEnum.EIAThrowGrenade, true)
        l_Player:EnableInput(EntryInputActionEnum.EIAThrottle, true)
        l_Player:EnableInput(EntryInputActionEnum.EIAStrafe, true)
        l_Player:EnableInput(EntryInputActionEnum.EIAMeleeAttack, true)
        l_Player:EnableInput(EntryInputActionEnum.EIAChangePose, true)
        l_Player:EnableInput(EntryInputActionEnum.EIAProne, true)
    end]]
    NetEvents:Broadcast("kPM:EnablePlayerInputs")
end

function Match:ClearReadyUpState()
    -- Clear out all ready up state entries
    self.m_ReadyUpPlayers = { }
end

function Match:OnPlayerRup(p_Player)
    if p_Player == nil then
        print("err: invalid player tried to rup.")
        return
    end

    -- Get the player id
    local s_PlayerId = p_Player.id

    -- Player does not exist in our ready up state yet
    self.m_ReadyUpPlayers[s_PlayerId] = true
    print("info: player " .. p_Player.name .. " ready up!")
    NetEvents:Broadcast('Player:ReadyUpPlayers', self.m_ReadyUpPlayers)
end

function Match:ForceAllPlayerRup()
    for index, l_Player in pairs(PlayerManager:GetPlayers()) do
		self.m_ReadyUpPlayers[l_Player.id] = true
    end
end

function Match:IsAllPlayersRup()
    -- Get the player count
    local s_TotalPlayerCount = PlayerManager:GetPlayerCount()

    -- Check to make sure that we have enough players to start
    if s_TotalPlayerCount < kPMConfig.MinPlayerCount then
        return false
    end

    -- Get all players in the server
    local s_Players = PlayerManager:GetPlayers()

    local s_Rup_Player_Count = 0

    -- Iterate over all players and check the rup state
    for l_Index, l_Player in ipairs(s_Players) do
        -- Check that the player is valid
        if l_Player == nil then
            print("err: invalid player in player manager.")
            goto _rup_continue_
        end

        -- Get the player id
        local l_PlayerId = l_Player.id

        -- Check to see if this player has *any* rup state
        if self.m_ReadyUpPlayers[l_PlayerId] == nil then
            goto _rup_continue_
        end

        -- Is this player not readied up
        if self.m_ReadyUpPlayers[l_PlayerId] == false then
            goto _rup_continue_
        end

        s_Rup_Player_Count = s_Rup_Player_Count + 1

        ::_rup_continue_::
    end


    if self.m_GameType == GameTypes.Public then
        if s_Rup_Player_Count >= (s_TotalPlayerCount / 2) then
            return true
        else
            return false
        end
    else
        if s_Rup_Player_Count >= s_TotalPlayerCount then
            return true
        else
            return false
        end
    end
end

function Match:IsPlayerRup(p_PlayerId)
    local s_PlayerId = p_PlayerId

     -- Player does not exist in our ready up state yet
    if self.m_ReadyUpPlayers[s_PlayerId] == nil then
        return false
    end

    -- Player has already been added, but has not readied up yet
    return self.m_ReadyUpPlayers[s_PlayerId] == true
end

function Match:GetPlayerNotRupCount()
    local l_Count = 0;
    local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
        -- Check that the player is valid
        if l_Player == nil then
            print("err: invalid player in player manager.")
            return 0
        end

        local l_PlayerId = l_Player.id

        if self.m_ReadyUpPlayers[l_PlayerId] == nil or self.m_ReadyUpPlayers[l_PlayerId] == false then
            l_Count = l_Count + 1
        end
    end

    return l_Count
end

function Match:KillAllPlayers(p_IsAllowedToSpawn)
    -- Kill all alive players
    local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
        -- Validate our player
        if l_Player == nil then
            goto _knife_continue_
        end

        -- Kill the player
        self:KillPlayer(l_Player, p_IsAllowedToSpawn)

        ::_knife_continue_::
    end
end

function Match:KillPlayer(p_Player, p_IsAllowedToSpawn)
    if p_Player == nil then
        return
    end

    -- Disable players ability to spawn
    p_Player.isAllowedToSpawn = p_IsAllowedToSpawn

    -- If the player is not alive skip on
    if not p_Player.alive then
        return
    end

    if TableHelper:contains(self.m_KillQueue, p_Player.name) then
        -- Player is already in the kill queue
        return
    end

    self:AddPlayerToKillQueue(p_Player.name)
end

function Match:KillQueuedPlayers()
    for l_Index, l_PlayerName in ipairs(self.m_KillQueue) do
        print('KillQueuedPlayer: ' .. l_PlayerName)
        RCON:SendCommand('admin.killPlayer', {l_PlayerName})
        table.remove(self.m_KillQueue, l_Index)
    end
end

function Match:SpawnQueuedPlayers()
    for l_Index, l_Spawn in ipairs(self.m_SpawnQueue) do
        if not TableHelper:contains(self.m_KillQueue, l_Spawn["p_Player"].name) then
            print('SpawnQueuedPlayer: ' .. l_Spawn["p_Player"].name)
            self:SpawnPlayer(
                l_Spawn["p_Player"],
                l_Spawn["p_Transform"],
                l_Spawn["p_Pose"],
                l_Spawn["p_SoldierBp"],
                l_Spawn["p_KnifeOnly"],
                l_Spawn["p_SelectedKit"]
            )
            table.remove(self.m_SpawnQueue, l_Index)
        end
    end
end

function Match:SpawnAllPlayers(p_KnifeOnly)
    if p_KnifeOnly == nil then
        p_KnifeOnly = false
    end

    self:Cleanup();

    local s_SoldierBlueprint = ResourceManager:SearchForDataContainer('Characters/Soldiers/MpSoldier')

    local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
        -- Validate our player
        if l_Player == nil then
            goto _knife_continue_
        end

        self:AddPlayerToSpawnQueue(
            l_Player, 
            self:GetRandomSpawnpoint(l_Player), 
            CharacterPoseType.CharacterPoseType_Stand, 
            s_SoldierBlueprint, 
            p_KnifeOnly,
            self.m_LoadoutManager:GetPlayerLoadout(l_Player)
        )

        ::_knife_continue_::
    end
end

function Match:AddPlayerToSpawnQueue(p_Player, p_Transform, p_Pose, p_SoldierBp, p_KnifeOnly, p_SelectedKit)
    print('AddPlayerToSpawnQueue: ' .. p_Player.name)
    table.insert(self.m_SpawnQueue, {
        ["p_Player"] = p_Player,
        ["p_Transform"] = p_Transform,
        ["p_Pose"] = p_Pose,
        ["p_SoldierBp"] = p_SoldierBp,
        ["p_KnifeOnly"] = p_KnifeOnly,
        ["p_SelectedKit"] = p_SelectedKit,
    })
end

function Match:AddPlayerToKillQueue(p_PlayerName)
    print('AddPlayerToKillQueue: ' .. p_PlayerName)
    table.insert(self.m_KillQueue, p_PlayerName)
end

function Match:SpawnPlayer(p_Player, p_Transform, p_Pose, p_SoldierBp, p_KnifeOnly, p_SelectedKit)
    if p_Player == nil then
        return
    end

    if p_Player.alive then
        return
    end

    if p_SelectedKit == nil then
        return
    end

    local l_SoldierAsset = nil
    local l_Appearance = nil
    if p_Player.teamId == self.m_Defenders:GetTeamId() then
        -- US
        l_SoldierAsset = ResourceManager:SearchForDataContainer(Kits[p_SelectedKit["Class"]]["DEFENDER"]["KIT"])
        l_Appearance = ResourceManager:SearchForDataContainer(Kits[p_SelectedKit["Class"]]["DEFENDER"]["APPEARANCE"])
    else
        -- RUS
        l_SoldierAsset = ResourceManager:SearchForDataContainer(Kits[p_SelectedKit["Class"]]["ATTACKER"]["KIT"])
        l_Appearance = ResourceManager:SearchForDataContainer(Kits[p_SelectedKit["Class"]]["ATTACKER"]["APPEARANCE"])
    end

    if l_SoldierAsset == nil or l_Appearance == nil then
        return
    end

    if p_KnifeOnly then
        local knife = ResourceManager:SearchForDataContainer('Weapons/Knife/U_Knife')
        p_Player:SelectWeapon(WeaponSlot.WeaponSlot_5, knife, {})
        p_Player:SelectWeapon(WeaponSlot.WeaponSlot_7, knife, {})
    else
        local l_Loadout = p_SelectedKit.Weapons
        if l_Loadout == nil then
            print("err: something is really wrong here, spawn with a knife then...")
            local knife = ResourceManager:SearchForDataContainer('Weapons/Knife/U_Knife')
            p_Player:SelectWeapon(WeaponSlot.WeaponSlot_5, knife, {})
            p_Player:SelectWeapon(WeaponSlot.WeaponSlot_7, knife, {})
        end

        local l_WeaponIndex = 0;
        local l_IsAmmoOrMedicBag = false;
        for l_Index, l_LoadoutItem in ipairs(l_Loadout) do
            if l_LoadoutItem == nil then
                goto _weapon_continue_
            end

            local l_Attachments = {}
            if l_WeaponIndex == 0 then
                l_Attachments = p_SelectedKit.Attachments
            end

            if l_WeaponIndex == 0 then --primary
                p_Player:SelectWeapon(WeaponSlot.WeaponSlot_0, l_LoadoutItem, l_Attachments)
            elseif l_WeaponIndex == 1 then --secondary
                p_Player:SelectWeapon(WeaponSlot.WeaponSlot_1, l_LoadoutItem, l_Attachments)
            elseif l_WeaponIndex == 2 then --tactical
                local s_Asset = Asset(l_LoadoutItem)
                local s_AssetName = s_Asset.name:match("/U_.+"):sub(4)
                if s_AssetName ~= nil and (s_AssetName == "Medkit" or s_AssetName == "Ammobag") then
                    l_IsAmmoOrMedicBag = true
                end

                if l_IsAmmoOrMedicBag then
                    p_Player:SelectWeapon(WeaponSlot.WeaponSlot_4, l_LoadoutItem, l_Attachments)
                else
                    p_Player:SelectWeapon(WeaponSlot.WeaponSlot_3, l_LoadoutItem, l_Attachments)
                end
            elseif l_WeaponIndex == 3 then --lethal
                p_Player:SelectWeapon(WeaponSlot.WeaponSlot_6, l_LoadoutItem, l_Attachments)
            elseif l_WeaponIndex == 4 then --knife
                p_Player:SelectWeapon(WeaponSlot.WeaponSlot_7, l_LoadoutItem, l_Attachments)
            end
    
            l_WeaponIndex = l_WeaponIndex + 1;

            ::_weapon_continue_::
        end
    end
    
    p_Player:SelectUnlockAssets(l_SoldierAsset, { l_Appearance })

    local l_SpawnedSoldier = p_Player:CreateSoldier(p_SoldierBp, p_Transform)
    
	p_Player:SpawnSoldierAt(l_SpawnedSoldier, p_Transform, p_Pose)
	p_Player:AttachSoldier(l_SpawnedSoldier)

    return l_SpawnedSoldier
end

function Match:GetRandomSpawnpoint(p_Player)
    if p_Player == nil then
        print("err: no player?")
        return
    end

    local l_LevelName = LevelNameHelper:GetLevelName()
    if l_LevelName == nil then
        print("err: no level??")
        return
    end

    -- TODO: Don't spawn on an already taken spawnpoint
    l_SpawnTrans = MapsConfig[l_LevelName]["SPAWNS"][ math.random( #MapsConfig[l_LevelName]["SPAWNS"] ) ]

    if l_SpawnTrans == nil then
        return
    end

    return l_SpawnTrans
end

function Match:Cleanup()
    self:CleanupSpecificEntity("ServerPickupEntity")
    NetEvents:Broadcast("kPM:Cleanup", "ClientPickupEntity")

    self:CleanupSpecificEntity("ServerMedicBagEntity")
    self:CleanupSpecificEntity("ServerMedicBagHealingSphereEntity")
    NetEvents:Broadcast("kPM:Cleanup", "ClientMedicBagEntity")
    NetEvents:Broadcast("kPM:Cleanup", "ClientMedicBagHealingSphereEntity")

    self:CleanupSpecificEntity("ServerSupplySphereEntity")
    NetEvents:Broadcast("kPM:Cleanup", "ClientSupplySphereEntity")

    self:CleanupSpecificEntity("ServerExplosionEntity")
    self:CleanupSpecificEntity("ServerExplosionPackEntity")
    NetEvents:Broadcast("kPM:Cleanup", "ClientExplosionEntity")
    NetEvents:Broadcast("kPM:Cleanup", "ClientExplosionPackEntity")

    self:CleanupSpecificEntity("ServerGrenadeEntity")
    NetEvents:Broadcast("kPM:Cleanup", "ClientGrenadeEntity")
end

function Match:CleanupSpecificEntity(p_EntityType)
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

function Match:FireEventForSpecificEntity(p_EntityType, p_EventString)
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
            l_Entity:FireEvent(p_EventString)
        end
    end
end

function Match:RestartMatch()
    self.m_CurrentRound = 0

    self.m_ReadyUpPlayers = { }
    NetEvents:Broadcast('Player:ReadyUpPlayers', self.m_ReadyUpPlayers)

    self.m_CurrentState = GameStates.None
    self.m_LastState = GameStates.None

    self.m_UpdateTicks = { }
    self.m_UpdateTicks[GameStates.None] = 0.0
    self.m_UpdateTicks[GameStates.Warmup] = 0.0
    self.m_UpdateTicks[GameStates.Playing] = 0.0
    self.m_UpdateTicks[GameStates.EndGame] = 0.0

    self.m_KillQueue = { }
    self.m_SpawnQueue = { }

    self.m_RestartQueue = false

    self.m_BombSite = nil
    self.m_BombLocation = nil
    self.m_BombTime = nil

    self.m_Attackers:RoundReset()
    self.m_Defenders:RoundReset()

    self.m_Server:ChangeGameState(GameStates.Warmup)

    NetEvents:Broadcast("kPM:ResetUI")

    self:KillAllPlayers(false)
end

return Match

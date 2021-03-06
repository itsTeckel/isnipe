local Match = class("Match")
require ("__shared/MapsConfig")
require ("__shared/GameStates")
require ("__shared/iSNConfig")
require ("__shared/LevelNameHelper")
require ("__shared/GameTypes")
require ("__shared/TickType")
require ("__shared/Util/TableHelper")

require ("Team")
require ("LoadoutManager")

function Match:__init(p_Server, p_TeamAttackers, p_TeamDefenders, p_RoundCount, loadoutManager, p_GameType)
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

    -- Game state ticks
    self.m_UpdateTicks = { }
    self.m_UpdateTicks[GameStates.None] = 0.0
    self.m_UpdateTicks[GameStates.Warmup] = 0.0
    self.m_UpdateTicks[GameStates.Playing] = 0.0
    self.m_UpdateTicks[GameStates.EndGame] = 0.0

    -- Update ticks
    self.stateTicks = {}
    self.stateTicks[TickType.Spawns] = 0.0
    self.stateTicks[TickType.Timer] = 0.0

    self.loadoutManager = loadoutManager

    self.m_KillQueue = { }
    self.m_SpawnQueue = { }
    self.m_UpdateManagerUpdateEvent = Events:Subscribe("UpdateManager:Update", self, self.OnUpdateManagerUpdate)
    self.m_SetSpawnEvent = NetEvents:Subscribe("iSN:SetSpawn", self, self.OnSetSpawn)

    self.m_RestartQueue = false

    self.m_GameType = p_GameType
    self.m_defaultSpawn = nil
    self.spawns = {}
end

function Match:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
    -- reset previously spawned players. So we don't spawn people on the same spawn
    if self.stateTicks[TickType.Spawns] == nil or self.stateTicks[TickType.Spawns] >= 3 then
        self.spawns = {}
        self.stateTicks[TickType.Spawns] = 0
    end

    
    if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
        if self.m_RestartQueue == false and self.m_CurrentState ~= GameStates.EndGame then
            if not TableHelper:empty(self.m_KillQueue) then
                self:KillQueuedPlayers()
            end
            
            if not TableHelper:empty(self.m_SpawnQueue) then
                self:SpawnQueuedPlayers()
            end
        end

        if self.m_RestartQueue then
            self.m_RestartQueue = false
            print("runNextRound")
            --RCON:SendCommand('mapList.endRound 1')
            RCON:SendCommand('mapList.runNextRound')
        end
    end

    self.stateTicks[TickType.Spawns] = self.stateTicks[TickType.Spawns] + p_DeltaTime 
end

-- ==========
-- Logic Update Callbacks
-- ==========

function Match:OnEngineUpdate(p_GameState, p_DeltaTime)
    if self.m_RestartQueue then
        return
    end
    local s_Callback = self.m_UpdateStates[p_GameState]
    if s_Callback == nil then
        return
    end

    if self.m_CurrentState ~= p_GameState then
        if iSNConfig.DebugMode then
            print("transitioning from " .. self.m_LastState .. " to " .. p_GameState)
        end

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
    if self.m_UpdateTicks[GameStates.Warmup] >= iSNConfig.MaxRupTick then
        self.m_UpdateTicks[GameStates.Warmup] = 0.0

        local players = Match:GetPlayers()
        if players < iSNConfig.MinPlayers then
            -- print("Waiting. Not enough players...." .. players)
            return
        end

        -- First change the game state so we have no logic running
        self.m_Server:ChangeGameState(GameStates.None)
        --ChatManager:Yell("All players have readied up, starting knife round...", 2.0)

        -- Handle resetting all players or spawning them
        self.m_Server:ChangeGameState(GameStates.Playing)
    end

    -- Add the delta time to our rup timer
    self.m_UpdateTicks[GameStates.Warmup] = self.m_UpdateTicks[GameStates.Warmup] + p_DeltaTime
end

function Match:OnPlaying(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.Playing] == 0.0 then
        self.m_Server:SetClientTimer(iSNConfig.MaxRoundTime)
    end

    if self.m_UpdateTicks[GameStates.Playing] >= iSNConfig.MaxRoundTime then
        self.m_Server:ChangeGameState(GameStates.EndGame)
    end

    if self.stateTicks[TickType.Timer] >= iSNConfig.TimeTick then
        self.stateTicks[TickType.Timer] = 0.0

        -- Reset tickets
        TicketManager:SetTicketCount(1, 0)
        TicketManager:SetTicketCount(2, 0)
        TicketManager:SetTicketCount(3, 0)
        TicketManager:SetTicketCount(4, 0)
        TicketManager:SetTicketCount(5, 0)
        TicketManager:SetTicketCount(6, 0)
        TicketManager:SetTicketCount(7, 0)
        TicketManager:SetTicketCount(8, 0)
        TicketManager:SetTicketCount(9, 0)
        TicketManager:SetTicketCount(10, 0)
        TicketManager:SetTicketCount(11, 0)
        TicketManager:SetTicketCount(12, 0)
        TicketManager:SetTicketCount(13, 0)
        TicketManager:SetTicketCount(14, 0)
        TicketManager:SetTicketCount(15, 0)
        TicketManager:SetTicketCount(16, 0)

        self.m_Server:SetClientTimer(iSNConfig.MaxRoundTime - self.m_UpdateTicks[GameStates.Playing])
    end

    self.m_UpdateTicks[GameStates.Playing] = self.m_UpdateTicks[GameStates.Playing] + p_DeltaTime
    self.stateTicks[TickType.Timer] = self.stateTicks[TickType.Timer] + p_DeltaTime
end


function Match:OnEndGame(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.EndGame] == 0.0 then
        self:DisablePlayerInputs()
        self.m_Server:SetGameEnd(nil)
        self.m_Server:SetClientTimer(iSNConfig.MaxEndgameTime)
    end

    if self.m_UpdateTicks[GameStates.EndGame] >= iSNConfig.MaxEndgameTime then
        -- Set the restart queue so we can trigger an rcon restart or something like that
        self.m_RestartQueue = true
        self.m_UpdateTicks[GameStates.EndGame] = 0
    end

    self.m_UpdateTicks[GameStates.EndGame] = self.m_UpdateTicks[GameStates.EndGame] + p_DeltaTime
end

function Match:ForceUpdateHeader(p_Player)
    if p_Player == nil then
        return
    end

    NetEvents:SendTo("iSN:UpdateHeader", p_Player, self.m_Attackers:CountRoundWon(), self.m_Defenders:CountRoundWon(), self.m_CurrentRound)
end

function Match:OnPartitionLoaded(p_Partition)
    if p_Partition == nil then
        return
    end
end

function Match:DisablePlayerInputs()
    NetEvents:Broadcast("iSN:DisablePlayerInputs")
end

function Match:EnablePlayerInputs()
   NetEvents:Broadcast("iSN:EnablePlayerInputs")
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
        table.remove(self.m_SpawnQueue, l_Index)
        local p_SelectedKit = self.loadoutManager:GetPlayerLoadout(l_Spawn["p_Player"])
        if not TableHelper:contains(self.m_KillQueue, l_Spawn["p_Player"].name) and p_SelectedKit ~= nil then
            print('SpawnQueuedPlayer: ' .. l_Spawn["p_Player"].name)
            self:SpawnPlayer(
                l_Spawn["p_Player"],
                l_Spawn["p_Transform"],
                l_Spawn["p_Pose"],
                l_Spawn["p_SoldierBp"],
                l_Spawn["p_KnifeOnly"],
                p_SelectedKit
            )
        end
    end
end

function Match:GetPlayers()
    local result = 0
    for l_Index, player in ipairs(PlayerManager:GetPlayers()) do
        if player ~= nil and player.alive then
            result = result + 1
        end
    end
    return result
end

function Match:closestDistance(p_Player, x, y, z)
    local result = 9999
    for index, player in pairs(PlayerManager:GetPlayers()) do
        if p_Player.teamId ~= player.teamId then
            if player.alive then
                local soldier = player.soldier
                if soldier ~= nil then
                    -- Get the soldier LinearTransform
                    local soldierLinearTransform = soldier.worldTransform
                    local coordinates = {}
                    local distance = self:Distance(x, y, z, soldierLinearTransform.trans.x, soldierLinearTransform.trans.y, soldierLinearTransform.trans.z)
                    if distance < result then
                        result = distance;
                    end
                    if result < 10 then
                        return result
                    end
                end
            end
        end
    end
    return result
end

function Match:Distance( x1, y1, z1, x2, y2, z2 )
    return math.sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1))
end

function Match:OnSetSpawn(p_player, p_Data)
    local l_Data = json.decode(p_Data)

    if l_Data == nil or l_Data[1] == nil then
        print("Invalid data received")
        print(p_Data)
        return
    end

    if self.m_RestartQueue then
        return
    end

    if p_player == nil then
        print("p_Player is nil")
        return
    end

    local p_SelectedKit = self.loadoutManager:GetPlayerLoadout(p_player)
    if p_SelectedKit == nil then
        return
    end
    
    local l_SoldierBlueprint = ResourceManager:SearchForDataContainer('Characters/Soldiers/MpSoldier')
    self:KillPlayer(p_Player, false)

    if l_Data[1] == 0 then
        --debug. Press f10 to get new coordinates.
        --if self.m_defaultSpawn ~= nil then
            -- self:AddPlayerToSpawnQueue(
            --    p_player, 
            --    LinearTransform(Vec3(-0.54228591918945, 4.193862146451e-09, -0.84019422531128), Vec3(-0.15022599697113, 0.9838855266571, 0.096960246562958), Vec3(0.82665491104126, 0.17879919707775, -0.53354722261429), Vec3(195.79644775391, 96.914398193359, -105.33582305908)),
            --    CharacterPoseType.CharacterPoseType_Stand, 
            --    l_SoldierBlueprint, 
            --    false
            -- )
        --end
        return
    end

    if l_Data[2] == nil or l_Data[2][1] == nil or l_Data[2][1][1] == nil then
        print("Invalid data received")
        print(p_Data)
        return
    end

    if l_Data[1] <= 15 then
        print(l_Data[1] .. "is too close " .. p_player.name)
    end
    
    local p_Transform = LinearTransform(Vec3(l_Data[2][1][1], l_Data[2][1][2], l_Data[2][1][3]), Vec3(l_Data[2][2][1], l_Data[2][2][2], l_Data[2][2][3]), Vec3(l_Data[2][3][1], l_Data[2][3][2], l_Data[2][3][3]), Vec3(l_Data[2][4][1], l_Data[2][4][2], l_Data[2][4][3]))

    self:AddPlayerToSpawnQueue(
        p_player, 
        p_Transform,
        CharacterPoseType.CharacterPoseType_Stand, 
        l_SoldierBlueprint, 
        false
    )
end

function Match:AddPlayerToSpawnQueue(p_Player, p_Transform, p_Pose, p_SoldierBp, p_KnifeOnly)
    if TableHelper:contains(self.m_SpawnQueue, p_Player.name) then
        return
    end
    local key = p_Transform.trans.x + p_Transform.trans.y + p_Transform.trans.z
    local distance = self.spawns[key]
    local hasSpawned = distance ~= nil
    if distance == nil then
        distance = Match:closestDistance(p_Player, p_Transform.trans.x, p_Transform.trans.y, p_Transform.trans.z)
    end
    self.spawns[key] = distance
    if distance < 10 then
        print(distance .. " is too close " .. p_Player.name)
        return
    end
    if hasSpawned == true then
        print("someone else has already spawned")
        print(distance)
        return
    end
    
    print('AddPlayerToSpawnQueue: ' .. p_Player.name)
    table.insert(self.m_SpawnQueue, {
        ["p_Player"] = p_Player,
        ["p_Transform"] = p_Transform,
        ["p_Player"] = p_Player,
        ["p_Pose"] = p_Pose,
        ["p_SoldierBp"] = p_SoldierBp,
        ["p_KnifeOnly"] = p_KnifeOnly,
    })
end

function Match:AddPlayerToKillQueue(p_PlayerName)
    print('AddPlayerToKillQueue: ' .. p_PlayerName)
    table.insert(self.m_KillQueue, p_PlayerName)
end

function Match:SpawnPlayer(p_Player, p_Transform, p_Pose, p_SoldierBp, p_KnifeOnly, p_SelectedKit)
    if p_Player == nil then
        print("WARN: p_Player is nil")
        return
    end

    if p_Player.alive then
        print("WARN: p_Player is alive")
        return
    end

    if p_SelectedKit == nil then
        print("WARN: p_SelectedKit is nil")
        return
    end

    local l_SoldierAsset = nil
    local l_Appearance = nil
    local kits = nil

    local appearances = {
        "Persistence/Unlocks/Soldiers/Visual/MP/RU/MP_RU_Assault_Appearance01",
        "Persistence/Unlocks/Soldiers/Visual/MP_XP4/RU/MP_RU_Assault_Appearance_Desert02"
        --"Persistence/Unlocks/Soldiers/Visual/MP_XP4/RU/MP_RU_Assault_Appearance_DrPepper",
        --"Persistence/Unlocks/Soldiers/Visual/MP_XP4/RU/MP_RU_Assault_Appearance_ExpForce",
        --"Persistence/Unlocks/Soldiers/Visual/MP_XP4/RU/MP_RU_Assault_Appearance_Green"
    }

    local kits = {
        "Gameplay/Kits/RUAssault",
        "Gameplay/Kits/RURecon_XP4"
    }
    for l_Index, kit in ipairs(kits) do
    l_SoldierAsset = ResourceManager:SearchForDataContainer(kit)
        if l_SoldierAsset ~= nil then
            --print(kit)
            break
        end
    end

    for l_Index, appearance in ipairs(appearances) do
        l_Appearance = ResourceManager:SearchForDataContainer(appearance)
        if l_Appearance ~= nil then
            --print(appearance)
            break
        end
    end

--     l_Appearance:MakeWritable()
--     l_Appearance.linkedTo.clear()
--     l_Appearance.linkedTo.add(UnlockAsset(Guid("FE8E28B6-ED7E-436A-85BB-05BF7F36D568")))
--     l_Appearance.linkedTo.add(UnlockAsset(Guid("5652EDE2-057D-4A97-A3A5-95FCAC23CE25")))
--     l_Appearance.linkedTo.add(UnlockAsset(Guid("AA45CCE2-738A-47BC-B9A5-5A6C00C7A66D")))

    --local abu = ResourceManager:SearchForDataContainer("Characters/Soldiers/Customizations/PLR_AlBazir")
    --if abu == nil then
    --    print("abu is er niet... :(")
    --end

    if l_SoldierAsset == nil or l_Appearance == nil then
        print("WARN: l_SoldierAsset or l_Appearance is nil")
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
        --local knife = ResourceManager:SearchForDataContainer('Weapons/Knife/U_Knife')
        --p_Player:SelectWeapon(WeaponSlot.WeaponSlot_5, knife, {})

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

function Match:Cleanup()
    self:CleanupSpecificEntity("ServerPickupEntity")
    NetEvents:Broadcast("iSN:Cleanup", "ClientPickupEntity")

    self:CleanupSpecificEntity("ServerMedicBagEntity")
    self:CleanupSpecificEntity("ServerMedicBagHealingSphereEntity")
    NetEvents:Broadcast("iSN:Cleanup", "ClientMedicBagEntity")
    NetEvents:Broadcast("iSN:Cleanup", "ClientMedicBagHealingSphereEntity")

    self:CleanupSpecificEntity("ServerSupplySphereEntity")
    NetEvents:Broadcast("iSN:Cleanup", "ClientSupplySphereEntity")

    self:CleanupSpecificEntity("ServerExplosionEntity")
    self:CleanupSpecificEntity("ServerExplosionPackEntity")
    NetEvents:Broadcast("iSN:Cleanup", "ClientExplosionEntity")
    NetEvents:Broadcast("iSN:Cleanup", "ClientExplosionPackEntity")

    self:CleanupSpecificEntity("ServerGrenadeEntity")
    NetEvents:Broadcast("iSN:Cleanup", "ClientGrenadeEntity")
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

function Match:OnLevelDestroyed()
    self.m_CurrentState = GameStates.EndGame
    self:RestartMatch()
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

    self.loadoutManager.m_PlayerLoadouts = {}
    self.m_ReadyUpPlayers = { }
    self.m_CurrentState = GameStates.None
    self.m_LastState = GameStates.None

    self.m_UpdateTicks = {}
    self.m_UpdateTicks[GameStates.None] = 0.0
    self.m_UpdateTicks[GameStates.Warmup] = 0.0
    self.m_UpdateTicks[GameStates.Playing] = 0.0
    self.m_UpdateTicks[GameStates.EndGame] = 0.0

    self.m_KillQueue = {}
    self.m_SpawnQueue = {}

    self.m_RestartQueue = false

    self.m_Attackers:RoundReset()
    self.m_Defenders:RoundReset()

    self.m_Server:ChangeGameState(GameStates.Warmup)

    NetEvents:Broadcast("iSN:ResetUI")

    self:KillAllPlayers(false)
end

return Match

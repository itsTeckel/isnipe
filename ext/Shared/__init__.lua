class "kPMShared"

require("__shared/MapsConfig")
require("__shared/LevelNameHelper")
require("__shared/Generators/MapMarkerEntityDataGenerator")

function kPMShared:__init()
    print("shared initialization")

    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)

    self.m_LevelName = nil

    self.s_CustomMapMarkerEntityAGuid = Guid('261E43BF-259B-41D2-BF3B-42069ASITE')
    self.s_CustomMapMarkerEntityBGuid = Guid('271E43CF-269C-42D2-CF3C-69420BSITE')
end

function kPMShared:OnExtensionLoaded()
    -- Register all of the events
    self:RegisterEvents()

    -- Register all of the hooks
    self:RegisterHooks()
end

function kPMShared:OnExtensionUnloaded()
    self:UnregisterEvents()
    self:UnregisterHooks()
end

-- ==========
-- Events
-- ==========
function kPMShared:RegisterEvents()
    print("registering events")

    -- Level events
    self.m_LevelRegisterEntityResourcesEvent = Events:Subscribe('Level:RegisterEntityResources', self, self.OnLevelRegisterEntityResources)
    self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    self.m_PartitionLoadedEvent = Events:Subscribe("Partition:Loaded", self, self.OnPartitionLoaded)
    self.m_LevelLoadResourcesEvent = Events:Subscribe("Level:LoadResources", self, self.OnLevelLoadResources)
end

function kPMShared:OnLevelLoadResources()
    ResourceManager:MountSuperBundle('Levels/COOP_010/COOP_010')
end

function kPMShared:UnregisterEvents()
    print("unregistering events")
end

function kPMShared:OnLevelRegisterEntityResources()
    if self.m_LevelName == nil then
        self.m_LevelName = LevelNameHelper:GetLevelName()
    end

    local s_Registry = RegistryContainer()
    
    if s_Registry == nil then
        error('s_Registry not found')
        return
    end

    local s_CustomMapMarkerEntityAData = MapMarkerEntityData(ResourceManager:SearchForInstanceByGuid(self.s_CustomMapMarkerEntityAGuid))
    if s_CustomMapMarkerEntityAData == nil then
        error('s_CustomMapMarkerEntityAData not found')
        return
    end

    local s_CustomMapMarkerEntityBData = MapMarkerEntityData(ResourceManager:SearchForInstanceByGuid(self.s_CustomMapMarkerEntityBGuid))
    if s_CustomMapMarkerEntityBData == nil then
        error('s_CustomMapMarkerEntityBData not found')
        return
    end

    s_Registry:MakeWritable()
    s_Registry.entityRegistry:add(s_CustomMapMarkerEntityAData)
    s_Registry.entityRegistry:add(s_CustomMapMarkerEntityBData)
    ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

function kPMShared:OnLevelLoaded(p_LevelName, p_GameMode)

end

function kPMShared:OnPartitionLoaded(p_Partition)
    if self.m_LevelName == nil then
        self.m_LevelName = LevelNameHelper:GetLevelName()
    end

    if self.m_LevelName ~= nil then
        if MapsConfig[self.m_LevelName]["EFFECTS_WORLD_PART_DATA"] ~= nil then
            if p_Partition.guid == MapsConfig[self.m_LevelName]["EFFECTS_WORLD_PART_DATA"]["PARTITION"] then
                for _, l_Instance in pairs(p_Partition.instances) do
                    if l_Instance.instanceGuid == MapsConfig[self.m_LevelName]["EFFECTS_WORLD_PART_DATA"]["INSTANCE"] then
                        local l_EffectsWorldData = WorldPartData(l_Instance)
                        for _, l_Object in pairs(l_EffectsWorldData.objects) do
                            if l_Object:Is("EffectReferenceObjectData") then
                                local l_EffectReferenceObjectData = EffectReferenceObjectData(l_Object)
                                l_EffectReferenceObjectData:MakeWritable()
                                l_EffectReferenceObjectData.excluded = true
                            end
                        end
                    end
                end
            end
        end

        if MapsConfig[self.m_LevelName]["CAMERA_ENTITY_DATA"] ~= nil then
            if p_Partition.guid == MapsConfig[self.m_LevelName]["CAMERA_ENTITY_DATA"]["PARTITION"] then
                for _, l_Instance in pairs(p_Partition.instances) do
                    if l_Instance.instanceGuid == MapsConfig[self.m_LevelName]["CAMERA_ENTITY_DATA"]["INSTANCE"] then
                        local l_CameraEntityData = CameraEntityData(l_Instance)
                        l_CameraEntityData:MakeWritable()
                        l_CameraEntityData.enabled = false
                    end
                end
            end
        end
    end

    if p_Partition.guid == Guid("3E80FB04-9283-4A39-81A1-280936590079") then
        for _, l_Instance in pairs(p_Partition.instances) do
            if l_Instance.instanceGuid == Guid("678635B2-D620-4588-BB02-CA349C657376") then
                local l_ConeOutputNodeData = ConeOutputNodeData(l_Instance)
                l_ConeOutputNodeData:MakeWritable()
                l_ConeOutputNodeData.gain = 20.0
            end
        end
    end

    if p_Partition.guid == Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189") then
        for _, l_Instance in pairs(p_Partition.instances) do
            if l_Instance.instanceGuid == Guid("A988B874-7307-49F8-8D18-30A68DDBC3F3") then
                local l_VeniceFPSCameraData = VeniceFPSCameraData(l_Instance)
                l_VeniceFPSCameraData:MakeWritable()
                l_VeniceFPSCameraData.suppressionBlurAmountMultiplier = 0.0
                l_VeniceFPSCameraData.suppressionBlurSizeMultiplier = 0.0
            end
        end
    end

    for _, l_Instance in pairs(p_Partition.instances) do
        if l_Instance:Is('EntityVoiceOverInfo') then
            if l_Instance ~= nil then
                local l_EntityVoiceOverInfo = EntityVoiceOverInfo(l_Instance)
                l_EntityVoiceOverInfo:MakeWritable()
                l_EntityVoiceOverInfo.voiceOverType = nil
            end
        end
        if l_Instance.instanceGuid == self.s_CustomMapMarkerEntityAGuid or l_Instance.instanceGuid == self.s_CustomMapMarkerEntityBGuid then
			return
		end
    end

    local s_EntityDataA = MapMarkerEntityDataGenerator:Create(self.s_CustomMapMarkerEntityAGuid, "A")
    p_Partition:AddInstance(s_EntityDataA)

    local s_EntityDataB = MapMarkerEntityDataGenerator:Create(self.s_CustomMapMarkerEntityBGuid, "B")
    p_Partition:AddInstance(s_EntityDataB)
end

-- ==========
-- Hooks
-- ==========
function kPMShared:RegisterHooks()
    print("registering hooks")

    Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
        if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
            bundles = {
                bundles[1],
                'Levels/COOP_010/COOP_010',
                'Levels/COOP_010/AB01_Parent',
                'Levels/COOP_010/AB01_Art_Parent',
                'Levels/COOP_010/AB06_Parent',
            }
            
            hook:Pass(bundles, compartment)
        end
    end)
end

function kPMShared:UnregisterHooks()
    print("unregistering hooks")
end

return kPMShared()

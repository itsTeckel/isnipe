class "kPMShared"

require("__shared/MapsConfig")
require("__shared/LevelNameHelper")
require("__shared/Generators/MapMarkerEntityDataGenerator")

function kPMShared:__init()
    print("shared initialization")

    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)

    self.m_LevelName = nil
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
    Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
        if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
            print('Injecting bundles.')

            bundles = {
                'levels/sp_paris/sp_paris',
                'levels/sp_paris/parkingdeck',
                'levels/xp5_002/xp5_002',
                'levels/xp5_002/cql',
                bundles[1],
            }

            hook:Pass(bundles, compartment)
        end
    end)
end

function kPMShared:OnLevelLoadResources()
    -- bicycle bundles
    ResourceManager:MountSuperBundle('spchunks')
    ResourceManager:MountSuperBundle('levels/sp_paris/sp_paris')
    -- dirtbike bundles
    ResourceManager:MountSuperBundle('xp5chunks')
    ResourceManager:MountSuperBundle('levels/xp5_002/xp5_002')
end

function kPMShared:UnregisterEvents()
    print("unregistering events")
end

function kPMShared:OnLevelRegisterEntityResources()
    if self.m_LevelName == nil then
        self.m_LevelName = LevelNameHelper:GetLevelName()
    end
end

function kPMShared:OnLevelLoaded(p_LevelName, p_GameMode)

end

function kPMShared:OnPartitionLoaded(p_Partition)
    if self.m_LevelName == nil then
        self.m_LevelName = LevelNameHelper:GetLevelName()
    end

    if p_Partition.guid == Guid("92002FDC-62A7-41A7-A95C-15AC0DE28F3A") then
        for _, l_Instance in pairs(p_Partition.instances) do
            if l_Instance.instanceGuid == Guid("A7A90928-FA6A-4013-96BA-AE559BA8B74F") then
                local soldier = UnlockAsset(l_Instance)
                soldier:MakeWritable()
                local a = UnlockAsset(Guid("54FBFD32-5EF4-4E77-AD9F-146FEE0B80DE"))
--                 soldier.linkedTo.clear()
--                 soldier.linkedTo.add(UnlockAsset(Guid("54FBFD32-5EF4-4E77-AD9F-146FEE0B80DE")))
--                 soldier.linkedTo.add(UnlockAsset(Guid("786F3073-C32E-4B76-9B19-DEAAEC6AFB95")))
--                 soldier.linkedTo.add(UnlockAsset(Guid("90DE83D4-89D3-4596-8A12-3BEBE5D4F3FA")))
                print("Abu patched")
            end
        end
    end

end

-- ==========
-- Hooks
-- ==========
function kPMShared:RegisterHooks()
    print("registering hooks")
end

function kPMShared:UnregisterHooks()
    print("unregistering hooks")
end

return kPMShared()

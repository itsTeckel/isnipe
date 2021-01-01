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
end

function kPMShared:OnLevelLoadResources()
    -- ResourceManager:MountSuperBundle('levels/sp_paris/sp_paris')
    -- ResourceManager:MountSuperBundle('levels/sp_finale/sp_finale')
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

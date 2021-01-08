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

--    out of bounds for damavand peak
   local cqLogicPartitionGuid = Guid('75BE465D-33C4-4F3E-859F-7006515E8530')
   local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('640f05bf-d964-4a08-ba62-a018037b5ad2'), function(instance)
   print("dikke rat")
   	instance = VolumeVectorShapeData(instance)
   	instance:MakeWritable()
   	instance.points:clear()
   	local points = {
           Vec3(28.097088, 214.940765, 139.254929),
           Vec3(39.687817, 214.940781, 129.449310),
           Vec3(47.206718, 214.940781, 118.325317),
           Vec3(44.865845, 215.034515, 43.593414),
           Vec3(40.422733, 214.909531, 28.668194),
           Vec3(30.658836, 214.847031, 6.745863),
           Vec3(19.195883, 214.848038, -9.016213),
           Vec3(14.428810, 214.936111, -11.932655),
           Vec3(5.425369, 214.878296, -15.903084),
           Vec3(-13.331827, 214.940765, -21.030334),
           Vec3(-25.056051, 214.914017, -23.663925),
           Vec3(-28.402523, 214.899185, -21.131464),
           Vec3(-28.793598, 215.024368, -13.744431),
           Vec3(-29.904449, 214.909546, -13.710128),
           Vec3(-29.697725, 214.940765, 48.790920),
           Vec3(-31.354425, 214.918625, 48.784012),
           Vec3(-31.344233, 214.919281, 65.123756),
           Vec3(-29.858303, 215.041580, 65.169441),
           Vec3(-29.804850, 215.037598, 80.378967),
           Vec3(-27.320080, 215.037582, 80.465477),
           Vec3(-27.224403, 214.937088, 108.548004),
           Vec3(-24.027187, 215.030106, 112.429474),
           Vec3(-23.984104, 215.026688, 114.956543),
           Vec3(-24.259531, 214.940781, 115.132179),
           Vec3(-25.988514, 214.942520, 115.147400),
           Vec3(-25.918358, 214.940781, 138.920151),
           Vec3(-7.319374, 214.940796, 138.764572),
           Vec3(7.409395, 214.940781, 137.338379)
    }

   	for _,point in pairs(points) do
   		instance.points:add(point)
   	end
   end)

   --    out of bounds for noshar
      local cqLogicPartitionGuid = Guid('A7946CAA-746F-4164-9DFB-9843A5CC0E1E')
      local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('ad37fe92-0d8d-4ed2-b71c-198e2f69e7b4'), function(instance)
      print("dikke rat")
      	instance = VolumeVectorShapeData(instance)
      	instance:MakeWritable()
      	instance.points:clear()
      	local points = {
           Vec3(-327.102997, 70.473213, 195.504471),
           Vec3(-389.290497, 70.708168, 257.854156),
           Vec3(-397.733063, 69.294632, 266.068237),
           Vec3(-402.796265, 59.742702, 283.678589),
           Vec3(-392.627808, 64.038147, 308.652679),
           Vec3(-370.362640, 60.117039, 328.647156),
           Vec3(-351.400330, 59.735661, 338.623840),
           Vec3(-325.082855, 59.735283, 355.104736),
           Vec3(-297.002197, 59.735287, 330.581818),
           Vec3(-286.837799, 59.735283, 314.315063),
           Vec3(-268.131653, 59.737343, 292.331696),
           Vec3(-260.506927, 59.735287, 276.566711),
           Vec3(-302.449554, 70.434326, 230.032806)
       }

      	for _,point in pairs(points) do
      		instance.points:add(point)
      	end
      end)


    -- Hooks:Install('ResourceManager:LoadBundles', 100, function(hook, bundles, compartment)
    --     if #bundles == 1 and bundles[1] == SharedUtils:GetLevelName() then
    --         print('Injecting bundles.')

    --         bundles = {
    --             'levels/sp_paris/sp_paris',
    --             'levels/sp_paris/parkingdeck',
    --             'levels/xp5_002/xp5_002',
    --             'levels/xp5_002/cql',
    --             bundles[1],
    --         }

    --         hook:Pass(bundles, compartment)
    --     end
    -- end)
end

function kPMShared:OnLevelLoadResources()
    -- -- bicycle bundles
    -- ResourceManager:MountSuperBundle('spchunks')
    -- ResourceManager:MountSuperBundle('levels/sp_paris/sp_paris')
    -- -- dirtbike bundles
    -- ResourceManager:MountSuperBundle('xp5chunks')
    -- ResourceManager:MountSuperBundle('levels/xp5_002/xp5_002')
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

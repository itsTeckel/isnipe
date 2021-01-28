--local cqLogicPartitionGuid = Guid('FillInMapLogicPartitionID')
--local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('FillInVolumeVectorShapeData'), function(instance)
--    print("patched red zone")
--    instance = VolumeVectorShapeData(instance)
--    instance:MakeWritable()
--    instance.points:clear()
--    local points = {
--
--    }
--
--    for _,point in pairs(points) do
--        instance.points:add(point)
--    end
--end)


function Bounds()
    --    out of bounds for Talah Market
    local cqLogicPartitionGuid = Guid('71C3D342-5E82-47F4-A4E9-26D436884494')
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('6e1a052d-0c31-413b-8b9b-39037f218d0c'), function(instance)
        print("Talah Market: patched red zone")
        instance = VolumeVectorShapeData(instance)
        instance:MakeWritable()
        instance.points:clear()
        local points = {
            Vec3(101.960320, 75.398651, 5.610607),
            Vec3(100.094688, 72.641167, 16.422693),
            Vec3(85.371178, 70.681267, 22.708332),
            Vec3(82.214584, 70.620598, 25.985714),
            Vec3(69.771690, 70.057343, 41.860531),
            Vec3(67.664749, 69.322319, 44.511108),
            Vec3(42.990353, 66.860542, 42.608849),
            Vec3(35.205639, 65.718872, 22.711123),
            Vec3(33.681835, 67.265968, 12.650743),
            Vec3(33.006851, 67.675064, 3.309906),
            Vec3(32.424755, 67.900078, -6.504072),
            Vec3(32.977818, 65.723656, -22.813391),
            Vec3(47.892406, 67.324158, -28.833387),
            Vec3(61.463093, 69.743774, -40.740135),
            Vec3(66.135139, 69.248871, -46.829292),
            Vec3(81.587029, 69.361938, -45.324787),
            Vec3(97.504768, 72.376007, -21.240591),
            Vec3(102.766167, 75.232719, -4.726771),
            Vec3(119.384232, 77.560440, -5.562759),
            Vec3(119.707085, 77.594429, 6.080595)
        }

        for _,point in pairs(points) do
            instance.points:add(point)
        end
    end)


    --    out of bounds for Damavand Peak
    local cqLogicPartitionGuid = Guid('75BE465D-33C4-4F3E-859F-7006515E8530')
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('640f05bf-d964-4a08-ba62-a018037b5ad2'), function(instance)
        print("Damavand Peak: patched red zone")
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

    --    out of bounds for Noshar Canals
    local cqLogicPartitionGuid = Guid('2D132495-AF01-49E3-B460-2E095044D8CF')
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('ad37fe92-0d8d-4ed2-b71c-198e2f69e7b4'), function(instance)
        print("Noshar Canals: patched red zone")
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

    -- XP5_001 Operation Riverside
    local cqLogicPartitionGuid = Guid('3D62C4AF-4143-43AE-85A5-9A9434A6759B')
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('57b0ac93-03b5-416d-9a2c-4a5395e08e5b'), riverside)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('f8c9f008-810a-4eea-91fe-d0ca4d48abf0'), riverside)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('9095600c-baf3-458d-99d5-c21b9124bcff'), riverside)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('4a732d6c-c0d4-4e50-b6ad-8e405fb7c729'), riverside)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('766b85b5-447f-4cfe-a6fe-b287800ac0f1'), riverside)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('cb871d52-6daa-45f5-a394-c3ae6ecdb8f3'), riverside)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('0fc98981-f114-4dec-8324-7cb0d7976cf6'), riverside)


    -- XP3_Valley Death Valley
    local cqLogicPartitionGuid = Guid('ECCB562C-6AC5-48CD-89E3-A23C9CF183A7')
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('dc6825ee-35b5-4a38-a877-bb861ab005f7'), valley)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('50ba20e7-47df-402b-8cff-39139882a2ac'), valley)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('ffc16338-1ff5-40cf-9c2a-555c5789f196'), valley)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('b8b7a25f-6c8e-4c44-be0f-b8eaaafbe4d3'), valley)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('f5ca9aba-8c65-41cf-99ce-6f59f7eed7e9'), valley)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('ba38ff38-be2c-4e78-884b-e5de8e0298c9'), valley)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('c0890ca1-4d84-4e6b-ab8a-7da23d0ffc53'), valley)

    -- XP4_Parl: Azadi Palace out of bounds
    local cqLogicPartitionGuid = Guid('2D132495-AF01-49E3-B460-2E095044D8CF')
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('898d55c9-61d1-49d9-a980-d828c1ba5683'), azadi)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('e3123bdd-fa4a-462b-9a71-9b10dc2cd2d5'), azadi)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('d5856b91-c1da-4649-9ab5-ecb8405c6f53'), azadi)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('a118c55d-f8b4-4184-aaf5-a58399f933e3'), azadi)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('bc35e029-12e7-412c-97b2-7ed0f786561e'), azadi)
    local usRedzoneVectorData = ResourceManager:RegisterInstanceLoadHandler(cqLogicPartitionGuid, Guid('298050a7-9974-45d2-aec9-1b68d5e0c7ff'), azadi)



end







function riverside(instance) --valley has multiple VolumeVectorShapeData
    print("Operation Riverside: patched red zone")
    instance = VolumeVectorShapeData(instance)
    instance:MakeWritable()
    instance.points:clear()
    local points = {
        Vec3(151.409912, 111.226173, -95.167702),
        Vec3(142.239365, 110.939194, -82.788254),
        Vec3(130.087921, 111.060020, -91.900658),
        Vec3(110.806030, 110.939194, -61.897068),
        Vec3(89.616814, 111.246590, -75.367775),
        Vec3(74.859970, 110.966644, -51.950924),
        Vec3(109.209724, 110.939201, -30.155554),
        Vec3(100.316566, 111.066772, -5.293375),
        Vec3(122.514336, 110.958961, 3.851096),
        Vec3(143.706467, 110.755722, 3.968064),
        Vec3(151.532135, 110.938812, -8.491898),
        Vec3(196.417511, 111.685028, 23.615294),
        Vec3(205.751450, 110.923569, 22.587420),
        Vec3(228.800278, 110.979881, -11.365573),
        Vec3(230.917068, 110.939201, -34.886276),
        Vec3(232.262100, 111.083359, -40.411755),
        Vec3(218.886017, 110.939194, -49.308945),
        Vec3(163.318985, 111.315361, -87.037216),
        Vec3(157.395157, 111.324425, -91.448494)
    }

    for _,point in pairs(points) do
        instance.points:add(point)
    end
end

function valley(instance) --valley has multiple VolumeVectorShapeData
    print("Death Valley: patched red zone")
    instance = VolumeVectorShapeData(instance)
    instance:MakeWritable()
    instance.points:clear()
    local points = {
        Vec3(-138.645935, 137.845840, 269.647644),
        Vec3(-173.904236, 137.939621, 262.321899),
        Vec3(-175.023987, 137.939621, 267.726318),
        Vec3(-190.101212, 137.845856, 264.574463),
        Vec3(-192.878174, 137.068695, 277.348328),
        Vec3(-187.849106, 137.934235, 278.661285),
        Vec3(-189.981888, 137.175323, 289.997925),
        Vec3(-194.756790, 137.251633, 312.473877),
        Vec3(-192.740845, 138.056702, 328.574707),
        Vec3(-201.644547, 141.177094, 376.358612),
        Vec3(-193.503387, 138.988739, 376.213928),
        Vec3(-198.947754, 147.697403, 394.112915),
        Vec3(-165.403427, 146.750793, 399.321259),
        Vec3(-151.349640, 137.492691, 372.028992),
        Vec3(-146.611496, 137.882370, 341.442749),
        Vec3(-143.353058, 137.834824, 329.028412),
        Vec3(-150.941193, 137.921494, 327.579407)
    }

    for _,point in pairs(points) do
        instance.points:add(point)
    end
end





function azadi(instance) --azadi has multiple VolumeVectorShapeData
    print("Azadi Palace: patched red zone")
    instance = VolumeVectorShapeData(instance)
    instance:MakeWritable()
    instance.points:clear()
    local points = {
        Vec3(-306.314209, 78.090385, -53.664673),
        Vec3(-317.379822, 79.680161, -53.749924),
        Vec3(-361.994171, 79.000580, -53.048931),
        Vec3(-364.686432, 78.262741, -48.545704),
        Vec3(-367.672943, 78.193031, -14.822686),
        Vec3(-370.047974, 67.262657, 17.186066),
        Vec3(-337.182648, 78.934860, 23.849195),
        Vec3(-321.469635, 78.934853, 23.895369),
        Vec3(-305.759155, 79.964577, 7.704772)
    }

    for _,point in pairs(points) do
        instance.points:add(point)
    end
end
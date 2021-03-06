require ("__shared/iSNConfig")

ClientCommands = 
{
    errInvalidCommand = "Invalid Command",

    PlayerPosition = function(args)
        -- If we have any arguments, ignore them
        if #args ~= 0 then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local player
        local localPlayer = PlayerManager:GetLocalPlayer()
        if localPlayer == nil then
            return ClientCommands.errInvalidCommand
        end

        -- Check to see if the player is alive
        if localPlayer.alive == false then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local soldier instance
        local localSoldier = localPlayer.soldier
        if localSoldier == nil then
            return ClientCommands.errInvalidCommand
        end

        -- Get the soldier LinearTransform
        local soldierLinearTransform = localSoldier.worldTransform

        -- Get the position vector
        local position = soldierLinearTransform.trans

        -- Return the formatted string (x, y, z)
        return "(" .. position.x .. ", " .. position.y .. ", " .. position.z .. ")"        
    end,

    ReadyUp = function(args)
        if #args ~= 0 then
            return ClientCommands.errInvalidCommand
        end

        -- Send the toggle event to the server
        NetEvents:Send("iSN:ToggleRup")

        return "Toggled Ready Up State"
    end,

    ForceReadyUp = function(args)
        if #args ~= 0 then
            return ClientCommands.errInvalidCommand
        end

        local localPlayer = PlayerManager:GetLocalPlayer()
        if localPlayer == nil then
            return ClientCommands.errInvalidCommand
        end

        -- Send the toggle event to the server
        NetEvents:Send("iSN:ForceToggleRup")

        return "Froced all players to Ready Up State"
    end,

    -- Enables debug mode, showing spawns etc.
    Debug = function(args)
        if #args ~= 1 then  
            return ClientCommands.errInvalidCommand
        end

        if args[1] ~= iSNConfig.DebugPass then
            return ClientCommands.errInvalidCommand
        end

        WebUI:ExecuteJS('OnDebug();')
        return "Toggled Debug mode"
    end,
}

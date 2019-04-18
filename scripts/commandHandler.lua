local commandHandler = {}

function commandHandler.ProcessCommand(pid, cmd)
    if cmd[1] == nil then
        local message = "Please use a command after the / symbol.\n"
        tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
        return false
    else
        -- The command itself should always be lowercase
        cmd[1] = string.lower(cmd[1])
    end

    local serverOwner = false
    local admin = false
    local moderator = false

    if Players[pid]:IsServerOwner() then
        serverOwner = true
        admin = true
        moderator = true
    elseif Players[pid]:IsAdmin() then
        admin = true
        moderator = true
    elseif Players[pid]:IsModerator() then
        moderator = true
    end

    if cmd[1] == "message" or cmd[1] == "msg" then
        if pid == tonumber(cmd[2]) then
            tes3mp.SendMessage(pid, "You can't message yourself.\n")

        elseif cmd[3] == nil then
            tes3mp.SendMessage(pid, "You cannot send a blank message.\n")

        elseif logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local targetName = Players[targetPid].name
            message = logicHandler.GetChatName(pid) .. " to " .. logicHandler.GetChatName(targetPid) .. ": "
            message = message .. tableHelper.concatenateFromIndex(cmd, 3) .. "\n"
            tes3mp.SendMessage(pid, message, false)
            tes3mp.SendMessage(targetPid, message, false)
        end

	elseif cmd[1] == "rest" then
		targetCell = tes3mp.GetCell(pid)
		basicNeeds.rest(pid, targetCell)
		
	elseif cmd[1] == "showneeds" then
		hunger = tonumber(Players[pid].data.playerNeeds.hunger)
		thirst = tonumber(Players[pid].data.playerNeeds.thirst)
		fatigue = tonumber(Players[pid].data.playerNeeds.fatigue)
		message = color.Aqua .. "[Basic Needs]:" .. color.White .. " Your hunger is currently at " .. color.Orange .. "\n" .. hunger .. color.Aqua .. "\n[Basic Needs]:" .. color.White .. " Your thirst is currently at " .. color.Orange .. "\n" .. thirst .. color.Aqua .. "\n[Basic Needs]:" .. color.White .. " Your fatigue is currently at " .. color.Orange .. "\n" .. fatigue .. "\n"
		tes3mp.SendMessage(pid, message, false)
	
	elseif cmd[1] == "debug" and config.debugMode == true then
		if cmd[2] == "enable" then
			Players[pid].data.debugMode = true
			tes3mp.SendMessage(pid, color.Cyan .. "[SYSTEM]: " .. color.White .. "debugMode enabled\n", false)
		elseif cmd[2] == "disable" then
			Players[pid].data.debugMode = false
			tes3mp.SendMessage(pid, color.Cyan ..  "[SYSTEM]: " .. color.White .. "debugMode disabled\n", false)
		elseif cmd[2] == "hunger" and Players[pid].data.debugMode == true then
			if cmd[3] == "enable" then
				Players[pid].data.debugFlags.haltTracking = false
				tes3mp.SendMessage(pid, color.Cyan ..  "[SYSTEM]: " .. color.White .. "Needs tracking enabled", false)
				basicNeeds.startTic(pid)
			elseif cmd[3] == "disable" then
				Players[pid].data.debugFlags.haltTracking = true
				tes3mp.SendMessage(pid, color.Cyan ..  "[SYSTEM]: " .. color.White .. "Needs tracking disable", false)
			end
		elseif cmd[2] == "bakeSpells" then
			basicNeeds.spellInit(pid)
		elseif cmd[2] == "cleanSpells" then
			basicNeeds.spellClean(pid)
		else
			tes3mp.SendMessage(pid, "Invalid debugMode flag, please use enable/disable\n", false)
		end

	elseif cmd[1] == "craftskill" then
		local armorSmithVal = Players[pid].data.craftSkills["armorSmithing"]
		local weaponSmithVal = Players[pid].data.craftSkills["weaponSmithing"]
        tes3mp.SendMessage(pid, color.Aqua .. "===================================================\n" .. "Your crafting skills are currently:\n" .. "------------------------------------------------" .. "\nArmor Smithing: " .. armorSmithVal .. "\n" .. "Weapon Smithing: " .. weaponSmithVal .. "\n" .. "===================================================\n")

	
	
	elseif cmd[1] == "disableHunger" and config.debugMode == true and Players[pid].data.debugMode == true then
		Players[pid].data.debugFlags.haltTracking = true
		

	
    --[[elseif cmd[1] == "me" and cmd[2] ~= nil then
        local message = logicHandler.GetChatName(pid) .. " " .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
        tes3mp.SendMessage(pid, message, true)

    elseif (cmd[1] == "local" or cmd[1] == "l") and cmd[2] ~= nil then
        local cellDescription = Players[pid].data.location.cell

        if logicHandler.IsCellLoaded(cellDescription) == true then
            for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do

                local message = logicHandler.GetChatName(pid) .. " to local area: "
                message = message .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
                tes3mp.SendMessage(visitorPid, message, false)
            end
        end]]--

    elseif (cmd[1] == "greentext" or cmd[1] == "gt") and cmd[2] ~= nil then
        local message = logicHandler.GetChatName(pid) .. ": " .. color.GreenText ..
            ">" .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
        tes3mp.SendMessage(pid, message, true)

    elseif cmd[1] == "ban" and moderator then

        if cmd[2] == "ip" and cmd[3] ~= nil then
            local ipAddress = cmd[3]

            if not tableHelper.containsValue(banList.ipAddresses, ipAddress) then
                table.insert(banList.ipAddresses, ipAddress)
                SaveBanList()

                tes3mp.SendMessage(pid, ipAddress .. " is now banned.\n", false)
                tes3mp.BanAddress(ipAddress)
            else
                tes3mp.SendMessage(pid, ipAddress .. " was already banned.\n", false)
            end
        elseif (cmd[2] == "name" or cmd[2] == "player") and cmd[3] ~= nil then
            local targetName = tableHelper.concatenateFromIndex(cmd, 3)
            logicHandler.BanPlayer(pid, targetName)

        elseif type(tonumber(cmd[2])) == "number" and logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local targetName = Players[targetPid].name
            logicHandler.BanPlayer(pid, targetName)
        else
            tes3mp.SendMessage(pid, "Invalid input for ban.\n", false)
        end

    elseif cmd[1] == "unban" and moderator and cmd[3] ~= nil then

        if cmd[2] == "ip" then
            local ipAddress = cmd[3]

            if tableHelper.containsValue(banList.ipAddresses, ipAddress) == true then
                tableHelper.removeValue(banList.ipAddresses, ipAddress)
                SaveBanList()

                tes3mp.SendMessage(pid, ipAddress .. " is now unbanned.\n", false)
                tes3mp.UnbanAddress(ipAddress)
            else
                tes3mp.SendMessage(pid, ipAddress .. " is not banned.\n", false)
            end
        elseif cmd[2] == "name" or cmd[2] == "player" then
            local targetName = tableHelper.concatenateFromIndex(cmd, 3)
            logicHandler.UnbanPlayer(pid, targetName)
        else
            tes3mp.SendMessage(pid, "Invalid input for unban.\n", false)
        end

    elseif cmd[1] == "banlist" and moderator then

        local message

        if cmd[2] == "names" or cmd[2] == "name" or cmd[2] == "players" then
            if #banList.playerNames == 0 then
                message = "No player names have been banned.\n"
            else
                message = "The following player names are banned:\n"

                for index, targetName in pairs(banList.playerNames) do
                    message = message .. targetName

                    if index < #banList.playerNames then
                        message = message .. ", "
                    end
                end

                message = message .. "\n"
            end
        elseif cmd[2] ~= nil and (string.lower(cmd[2]) == "ips" or string.lower(cmd[2]) == "ip") then
            if #banList.ipAddresses == 0 then
                message = "No IP addresses have been banned.\n"
            else
                message = "The following IP addresses unattached to players are banned:\n"

                for index, ipAddress in pairs(banList.ipAddresses) do
                    message = message .. ipAddress

                    if index < #banList.ipAddresses then
                        message = message .. ", "
                    end
                end

                message = message .. "\n"
            end
        end

        if message == nil then
            message = "Please specify whether you want the banlist for IPs or for names.\n"
        end

        tes3mp.SendMessage(pid, message, false)

    elseif (cmd[1] == "ipaddresses" or cmd[1] == "ips") and moderator and cmd[2] ~= nil then
        local targetName = tableHelper.concatenateFromIndex(cmd, 2)
        local targetPlayer = logicHandler.GetPlayerByName(targetName)

        if targetPlayer == nil then
            tes3mp.SendMessage(pid, "Player " .. targetName .. " does not exist.\n", false)
        elseif targetPlayer.data.ipAddresses ~= nil then
            local message = "Player " .. targetPlayer.accountName .. " has used the following IP addresses:\n"

            for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
                message = message .. ipAddress

                if index < #targetPlayer.data.ipAddresses then
                    message = message .. ", "
                end
            end

            message = message .. "\n"
            tes3mp.SendMessage(pid, message, false)
        end

    elseif cmd[1] == "players" or cmd[1] == "list" then
        guiHelper.ShowPlayerList(pid)

    elseif cmd[1] == "cells" and moderator then
        guiHelper.ShowCellList(pid)

    elseif cmd[1] == "regions" and moderator then
        guiHelper.ShowRegionList(pid)

    elseif (cmd[1] == "teleport" or cmd[1] == "tp") and moderator then
        if cmd[2] ~= "all" then
            logicHandler.TeleportToPlayer(pid, cmd[2], pid)
        else
            for iteratorPid, player in pairs(Players) do
                if iteratorPid ~= pid then
                    if player:IsLoggedIn() then
                        logicHandler.TeleportToPlayer(pid, iteratorPid, pid)
                    end
                end
            end
        end

    elseif (cmd[1] == "teleportto" or cmd[1] == "tpto") and moderator then
        logicHandler.TeleportToPlayer(pid, pid, cmd[2])

    elseif (cmd[1] == "setauthority" or cmd[1] == "setauth") and moderator and #cmd > 2 then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local cellDescription = tableHelper.concatenateFromIndex(cmd, 3)

            -- Get rid of quotation marks
            cellDescription = string.gsub(cellDescription, '"', '')

            if logicHandler.IsCellLoaded(cellDescription) == true then
                local targetPid = tonumber(cmd[2])
                logicHandler.SetCellAuthority(targetPid, cellDescription)
            else
                tes3mp.SendMessage(pid, "Cell \"" .. cellDescription .. "\" isn't loaded!\n", false)
            end
        end

    elseif cmd[1] == "kick" and moderator then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local message

            if Players[targetPid]:IsAdmin() then
                message = "You cannot kick an Admin from the server.\n"
                tes3mp.SendMessage(pid, message, false)
            elseif Players[targetPid]:IsModerator() and not admin then
                message = "You cannot kick a fellow Moderator from the server.\n"
                tes3mp.SendMessage(pid, message, false)
            else
                message = logicHandler.GetChatName(targetPid) .. " was kicked from the server by " ..
                    logicHandler.GetChatName(pid) .. ".\n"
                tes3mp.SendMessage(pid, message, false)
                Players[targetPid]:Kick()
            end
        end

    elseif cmd[1] == "addadmin" and serverOwner then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local targetName = Players[targetPid].name
            local message

            if Players[targetPid]:IsAdmin() then
                message = targetName .. " is already an Admin.\n"
                tes3mp.SendMessage(pid, message, false)
            else
                message = targetName .. " was promoted to Admin!\n"
                tes3mp.SendMessage(pid, message, false)
                Players[targetPid].data.settings.staffRank = 2
                Players[targetPid]:Save()
            end
        end

    elseif cmd[1] == "removeadmin" and serverOwner then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local targetName = Players[targetPid].name
            local message

            if Players[targetPid]:IsServerOwner() then
                message = "Cannot demote " .. targetName .. " because they are a Server Owner.\n"
                tes3mp.SendMessage(pid, message, false)
            elseif Players[targetPid]:IsAdmin() then
                message = targetName .. " was demoted from Admin to Moderator!\n"
                tes3mp.SendMessage(pid, message, false)
                Players[targetPid].data.settings.staffRank = 1
                Players[targetPid]:Save()
            else
                message = targetName .. " is not an Admin.\n"
                tes3mp.SendMessage(pid, message, false)
            end
        end

    elseif cmd[1] == "addmoderator" and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local targetName = Players[targetPid].name
            local message

            if Players[targetPid]:IsAdmin() then
                message = targetName .. " is already an Admin.\n"
                tes3mp.SendMessage(pid, message, false)
            elseif Players[targetPid]:IsModerator() then
                message = targetName .. " is already a Moderator.\n"
                tes3mp.SendMessage(pid, message, false)
            else
                message = targetName .. " was promoted to Moderator!\n"
                tes3mp.SendMessage(pid, message, true)
                Players[targetPid].data.settings.staffRank = 1
                Players[targetPid]:Save()
            end
        end

    elseif cmd[1] == "removemoderator" and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local targetName = Players[targetPid].name
            local message

            if Players[targetPid]:IsAdmin() then
                message = "Cannot demote " .. targetName .. " because they are an Admin.\n"
                tes3mp.SendMessage(pid, message, false)
            elseif Players[targetPid]:IsModerator() then
                message = targetName .. " was demoted from Moderator!\n"
                tes3mp.SendMessage(pid, message, false)
                Players[targetPid].data.settings.staffRank = 0
                Players[targetPid]:Save()
            else
                message = targetName .. " is not a Moderator.\n"
                tes3mp.SendMessage(pid, message, false)
            end
        end

    elseif cmd[1] == "setrace" and admin then

        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local newRace = tableHelper.concatenateFromIndex(cmd, 3)

            Players[targetPid].data.character.race = newRace
            tes3mp.SetRace(targetPid, newRace)
            tes3mp.SetResetStats(targetPid, false)
            tes3mp.SendBaseInfo(targetPid)
        end

    elseif cmd[1] == "sethead" and admin then

        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local newHead = tableHelper.concatenateFromIndex(cmd, 3)

            Players[targetPid].data.character.head = newHead
            tes3mp.SetHead(targetPid, newHead)
            tes3mp.SetResetStats(targetPid, false)
            tes3mp.SendBaseInfo(targetPid)
        end

    elseif cmd[1] == "sethair" and admin then

        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local newHair = tableHelper.concatenateFromIndex(cmd, 3)

            Players[targetPid].data.character.hair = newHair
            tes3mp.SetHair(targetPid, newHair)
            tes3mp.SetResetStats(targetPid, false)
            tes3mp.SendBaseInfo(targetPid)
        end

    elseif cmd[1] == "setattr" and moderator then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local targetName = Players[targetPid].name

            if cmd[3] ~= nil and cmd[4] ~= nil and tonumber(cmd[4]) ~= nil then
                local attrId
                local value = tonumber(cmd[4])

                if tonumber(cmd[3]) ~= nil then
                    attrId = tonumber(cmd[3])
                else
                    attrId = tes3mp.GetAttributeId(cmd[3])
                end

                if attrId ~= -1 and attrId < tes3mp.GetAttributeCount() then
                    tes3mp.SetAttributeBase(targetPid, attrId, value)
                    tes3mp.SendAttributes(targetPid)

                    local message = targetName .. "'s " .. tes3mp.GetAttributeName(attrId) ..
                        " is now " .. value .. "\n"
                    tes3mp.SendMessage(pid, message, false)
                    Players[targetPid]:SaveAttributes()
                end
            end
        end

    elseif cmd[1] == "setskill" and moderator then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
            local targetPid = tonumber(cmd[2])
            local targetName = Players[targetPid].name

            if cmd[3] ~= nil and cmd[4] ~= nil and tonumber(cmd[4]) ~= nil then
                local skillId
                local value = tonumber(cmd[4])

                if tonumber(cmd[3]) ~= nil then
                    skillId = tonumber(cmd[3])
                else
                    skillId = tes3mp.GetSkillId(cmd[3])
                end

                if skillId ~= -1 and skillId < tes3mp.GetSkillCount() then
                    tes3mp.SetSkillBase(targetPid, skillId, value)
                    tes3mp.SendSkills(targetPid)

                    local message = targetName .. "'s " .. tes3mp.GetSkillName(skillId) ..
                        " is now " .. value .. "\n"
                    tes3mp.SendMessage(pid, message, false)
                    Players[targetPid]:SaveSkills()
                end
            end
        end

    elseif cmd[1] == "setmomentum" and moderator then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local xValue = tonumber(cmd[3])
            local yValue = tonumber(cmd[4])
            local zValue = tonumber(cmd[5])

            if type(xValue) == "number" and type(yValue) == "number" and
               type(zValue) == "number" then

                tes3mp.SetMomentum(targetPid, xValue, yValue, zValue)
                tes3mp.SendMomentum(targetPid)
            else
                tes3mp.SendMessage(pid, "Not a valid argument. Use /setmomentum <pid> <x> <y> <z>\n", false)
            end
        end

    elseif cmd[1] == "setext" and admin then
        tes3mp.SetExterior(pid, cmd[2], cmd[3])

    elseif cmd[1] == "getpos" and moderator then
        logicHandler.PrintPlayerPosition(pid, cmd[2])

    elseif (cmd[1] == "setdifficulty" or cmd[1] == "setdiff") and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local difficulty = cmd[3]

            if type(tonumber(difficulty)) == "number" then
                difficulty = tonumber(difficulty)
            end

            if difficulty == "default" or type(difficulty) == "number" then
                Players[targetPid]:SetDifficulty(difficulty)
                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Difficulty for " .. Players[targetPid].name .. " is now " ..
                    difficulty .. "\n", true)
            else
                tes3mp.SendMessage(pid, "Not a valid argument. Use /setdifficulty <pid> <value>\n", false)
                return false
            end
        end

    elseif cmd[1] == "setconsole" and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local targetName = ""
            local state = ""

            if cmd[3] == "on" then
                Players[targetPid]:SetConsoleAllowed(true)
                state = " enabled.\n"
            elseif cmd[3] == "off" then
                Players[targetPid]:SetConsoleAllowed(false)
                state = " disabled.\n"
            elseif cmd[3] == "default" then
                Players[targetPid]:SetConsoleAllowed("default")
                state = " reset to default.\n"
            else
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setconsole <pid> on/off/default\n", false)
                 return false
            end

            Players[targetPid]:LoadSettings()
            tes3mp.SendMessage(pid, "Console for " .. Players[targetPid].name .. state, false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "Console" .. state, false)
            end
        end

    elseif cmd[1] == "setbedrest" and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local targetName = ""
            local state = ""

            if cmd[3] == "on" then
                Players[targetPid]:SetBedRestAllowed(true)
                state = " enabled.\n"
            elseif cmd[3] == "off" then
                Players[targetPid]:SetBedRestAllowed(false)
                state = " disabled.\n"
            elseif cmd[3] == "default" then
                Players[targetPid]:SetBedRestAllowed("default")
                state = " reset to default.\n"
            else
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setbedrest <pid> on/off/default\n", false)
                 return false
            end

            Players[targetPid]:LoadSettings()
            tes3mp.SendMessage(pid, "Bed resting for " .. Players[targetPid].name .. state, false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "Bed resting" .. state, false)
            end
        end

    elseif (cmd[1] == "setwildernessrest" or cmd[1] == "setwildrest") and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local targetName = ""
            local state = ""

            if cmd[3] == "on" then
                Players[targetPid]:SetWildernessRestAllowed(true)
                state = " enabled.\n"
            elseif cmd[3] == "off" then
                Players[targetPid]:SetWildernessRestAllowed(false)
                state = " disabled.\n"
            elseif cmd[3] == "default" then
                Players[targetPid]:SetWildernessRestAllowed("default")
                state = " reset to default.\n"
            else
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setwildrest <pid> on/off/default\n", false)
                 return false
            end

            Players[targetPid]:LoadSettings()
            tes3mp.SendMessage(pid, "Wilderness resting for " .. Players[targetPid].name .. state, false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "Wilderness resting" .. state, false)
            end
        end

    elseif cmd[1] == "setwait" and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local targetName = ""
            local state = ""

            if cmd[3] == "on" then
                Players[targetPid]:SetWaitAllowed(true)
                state = " enabled.\n"
            elseif cmd[3] == "off" then
                Players[targetPid]:SetWaitAllowed(false)
                state = " disabled.\n"
            elseif cmd[3] == "default" then
                Players[targetPid]:SetWaitAllowed("default")
                state = " reset to default.\n"
            else
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setwait <pid> on/off/default\n", false)
                 return false
            end

            Players[targetPid]:LoadSettings()
            tes3mp.SendMessage(pid, "Waiting for " .. Players[targetPid].name .. state, false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "Waiting" .. state, false)
            end
        end

    elseif (cmd[1] == "setphysicsfps" or cmd[1] == "setphysicsframerate") and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local physicsFramerate = cmd[3]

            if type(tonumber(physicsFramerate)) == "number" then
                physicsFramerate = tonumber(physicsFramerate)
            end

            if physicsFramerate == "default" or type(physicsFramerate) == "number" then
                Players[targetPid]:SetPhysicsFramerate(physicsFramerate)
                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Physics framerate for " .. Players[targetPid].name
                    .. " is now " .. physicsFramerate .. "\n", true)
            else
                tes3mp.SendMessage(pid, "Not a valid argument. Use /setphysicsfps <pid> <value>\n", false)
                return false
            end
        end

    elseif (cmd[1] == "setloglevel" or cmd[1] == "setenforcedloglevel") and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local logLevel = cmd[3]

            if type(tonumber(logLevel)) == "number" then
                logLevel = tonumber(logLevel)
            end

            if logLevel == "default" or type(logLevel) == "number" then
                Players[targetPid]:SetEnforcedLogLevel(logLevel)
                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Enforced log level for " .. Players[targetPid].name
                    .. " is now " .. logLevel .. "\n", true)
            else
                tes3mp.SendMessage(pid, "Not a valid argument. Use /setloglevel <pid> <value>\n", false)
                return false
            end
        end

    elseif cmd[1] == "setscale" and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local targetName = ""
            local scale = cmd[3]

            if type(tonumber(scale)) == "number" then
                scale = tonumber(scale)
            else
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setscale <pid> <value>.\n", false)
                 return false
            end

            Players[targetPid]:SetScale(scale)
            Players[targetPid]:LoadShapeshift()
            tes3mp.SendMessage(pid, "Scale for " .. Players[targetPid].name .. " is now " .. scale .. "\n", false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "Your scale is now " .. scale .. "\n", false)
            end
        end

    elseif cmd[1] == "setwerewolf" and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local targetName = ""
            local state = ""

            if cmd[3] == "on" then
                Players[targetPid]:SetWerewolfState(true)
                state = " enabled.\n"
            elseif cmd[3] == "off" then
                Players[targetPid]:SetWerewolfState(false)
                state = " disabled.\n"
            else
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setwerewolf <pid> on/off.\n", false)
                 return false
            end

            Players[targetPid]:LoadShapeshift()
            tes3mp.SendMessage(pid, "Werewolf state for " .. Players[targetPid].name .. state, false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "Werewolf state" .. state, false)
            end
        end

    elseif cmd[1] == "disguise" and admin then

        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local creatureRefId = tableHelper.concatenateFromIndex(cmd, 3)

            Players[targetPid].data.shapeshift.creatureRefId = creatureRefId
            tes3mp.SetCreatureRefId(targetPid, creatureRefId)
            tes3mp.SendShapeshift(targetPid)

            if creatureRefId == "" then
                creatureRefId = "nothing"
            end

            tes3mp.SendMessage(pid, Players[targetPid].accountName .. " is now disguised as " ..
                creatureRefId .. "\n", false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "You are now disguised as " .. creatureRefId .. "\n", false)
            end
        end

    elseif cmd[1] == "usecreaturename" and admin then

        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local nameState

            if cmd[3] == "on" then
                nameState = true
            elseif cmd[3] == "off" then
                nameState = false
            else
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /usecreaturename <pid> on/off\n", false)
                 return false
            end

            Players[targetPid].data.shapeshift.displayCreatureName = nameState
            tes3mp.SetCreatureNameDisplayState(targetPid, nameState)
            tes3mp.SendShapeshift(targetPid)
        end

    elseif cmd[1] == "sethour" and moderator then

        local inputValue = tonumber(cmd[2])

        if type(inputValue) == "number" then

            if inputValue == 24 then
                inputValue = 0
            end

            if inputValue >= 0 and inputValue < 24 then
                WorldInstance.data.time.hour = inputValue
                WorldInstance:Save()
                WorldInstance:LoadTime(pid, true)
                hourCounter = inputValue
            else
                tes3mp.SendMessage(pid, "There aren't that many hours in a day.\n", false)
            end
        end

    elseif cmd[1] == "setday" and moderator then

        local inputValue = tonumber(cmd[2])

        if type(inputValue) == "number" then

            local daysInMonth = WorldInstance.monthLengths[WorldInstance.data.time.month]

            if inputValue <= daysInMonth then
                WorldInstance.data.time.day = inputValue
                WorldInstance:Save()
                WorldInstance:LoadTime(pid, true)
            else
                tes3mp.SendMessage(pid, "There are only " .. daysInMonth .. " days in the current month.\n", false)
            end
        end

    elseif cmd[1] == "setmonth" and moderator then

        local inputValue = tonumber(cmd[2])

        if type(inputValue) == "number" then
            WorldInstance.data.time.month = inputValue
            WorldInstance:Save()
            WorldInstance:LoadTime(pid, true)
        end

    elseif cmd[1] == "settimescale" and moderator then

        local inputValue = tonumber(cmd[2])

        if type(inputValue) == "number" then
            WorldInstance.data.time.timeScale = inputValue
            WorldInstance:Save()
            WorldInstance:LoadTime(pid, true)
            frametimeMultiplier = inputValue / WorldInstance.defaultTimeScale
        end

    elseif cmd[1] == "setcollision" and admin then

        local collisionState

        if cmd[2] ~= nil and cmd[3] == "on" then
            collisionState = true
        elseif cmd[2] ~= nil and cmd[3] == "off" then
            collisionState = false
        else
             tes3mp.SendMessage(pid, "Not a valid argument. Use /setcollision <category> on/off\n", false)
             return false
        end

        local categoryInput = string.upper(cmd[2])
        local categoryValue = enumerations.objectCategories[categoryInput]

        if categoryValue == enumerations.objectCategories.PLAYER then
            tes3mp.SetPlayerCollisionState(collisionState)
        elseif categoryValue == enumerations.objectCategories.ACTOR then
            tes3mp.SetActorCollisionState(collisionState)
        elseif categoryValue == enumerations.objectCategories.PLACED_OBJECT then
            tes3mp.SetPlacedObjectCollisionState(collisionState)

            if cmd[4] == "on" then
                tes3mp.UseActorCollisionForPlacedObjects(true)
            elseif cmd[4] == "off" then
                tes3mp.UseActorCollisionForPlacedObjects(false)
            end
        else
            tes3mp.SendMessage(pid, categoryInput .. " is not a valid object category. Valid choices are " ..
                tableHelper.concatenateTableIndexes(enumerations.objectCategories, ", ") .. "\n", false)
            return false
        end

        tes3mp.SendWorldCollisionOverride(pid, true)
        tes3mp.SendMessage(pid, "Collision for " .. categoryInput .. " is now " .. cmd[3] ..
            " for all newly loaded cells.\n", false)

    elseif cmd[1] == "overridecollision" and admin then

        local collisionState
        local refId = cmd[2]

        if refId ~= nil and cmd[3] == "on" then
            collisionState = true
        elseif refId ~= nil and cmd[3] == "off" then
            collisionState = false
        else
            Players[pid]:Message("Use /addcollision <refId> on/off\n")
            return false
        end

        local message = "A collision-enabling override "

        if tableHelper.containsValue(config.enforcedCollisionRefIds, refId) then
            if collisionState then
                message = message .. "is already on"
            else
                tableHelper.removeValue(config.enforcedCollisionRefIds, refId)
                message = message .. "is now off"
            end
        else
            if collisionState then
                table.insert(config.enforcedCollisionRefIds, refId)
                message = message .. "is now on"
            else
                message = message .. "is already off"
            end
        end

        logicHandler.SendConfigCollisionOverrides(pid, true)
        Players[pid]:Message(message .. " for " .. refId .. " in newly loaded cells\n")

    elseif cmd[1] == "suicide" then
        if config.allowSuicideCommand == true then
            tes3mp.SetHealthCurrent(pid, 0)
            tes3mp.SendStatsDynamic(pid)
        else
            tes3mp.SendMessage(pid, "That command is disabled on this server.\n", false)
        end

    elseif cmd[1] == "fixme" then
        if config.allowFixmeCommand == true then
            local currentTime = os.time()

            if not tes3mp.IsInExterior(pid) then
                local message = "Sorry! You can only use " .. color.Yellow .. "/fixme" ..
                    color.White .. " in exteriors.\n"
                tes3mp.SendMessage(pid, message, false)
            elseif Players[pid].data.customVariables.lastFixMe == nil or
                currentTime >= Players[pid].data.customVariables.lastFixMe + config.fixmeInterval then

                logicHandler.RunConsoleCommandOnPlayer(pid, "fixme")
                Players[pid].data.customVariables.lastFixMe = currentTime
                tes3mp.SendMessage(pid, "You have fixed your position!\n", false)
            else
                local remainingSeconds = Players[pid].data.customVariables.lastFixMe +
                    config.fixmeInterval - currentTime
                local message = "Sorry! You can't use " .. color.Yellow .. "/fixme" ..
                    color.White .. " for another "

                if remainingSeconds > 1 then
                    message = message .. color.Yellow .. remainingSeconds .. color.White .. " seconds"
                else
                    message = message .. " second"
                end

                message = message .. "\n"
                tes3mp.SendMessage(pid, message, false)
            end
        else
            tes3mp.SendMessage(pid, "That command is disabled on this server.\n", false)
        end

    elseif cmd[1] == "storeconsole" and cmd[2] ~= nil and cmd[3] ~= nil and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            Players[targetPid].storedConsoleCommand = tableHelper.concatenateFromIndex(cmd, 3)

            tes3mp.SendMessage(pid, "That console command is now stored for player " .. targetPid .. "\n", false)
        end

    elseif cmd[1] == "runconsole" and cmd[2] ~= nil and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])

            if Players[targetPid].storedConsoleCommand == nil then
                tes3mp.SendMessage(pid, "There is no console command stored for player " .. targetPid ..
                    ". Please run /storeconsole on them first.\n", false)
            else
                local consoleCommand = Players[targetPid].storedConsoleCommand
                logicHandler.RunConsoleCommandOnPlayer(targetPid, consoleCommand)

                local count = tonumber(cmd[3])

                if count ~= nil and count > 1 then

                    count = count - 1
                    local interval = 1

                    if tonumber(cmd[4]) ~= nil and tonumber(cmd[4]) > 1 then
                        interval = tonumber(cmd[4])
                    end

                    local loopIndex = tableHelper.getUnusedNumericalIndex(ObjectLoops)
                    local timerId = tes3mp.CreateTimerEx("OnObjectLoopTimeExpiration", interval, "i", loopIndex)

                    ObjectLoops[loopIndex] = {
                        packetType = "console",
                        timerId = timerId,
                        interval = interval,
                        count = count,
                        targetPid = targetPid,
                        targetName = Players[targetPid].accountName,
                        consoleCommand = consoleCommand
                    }

                    tes3mp.StartTimer(timerId)
                end
            end
        end

    elseif (cmd[1] == "placeat" or cmd[1] == "spawnat") and cmd[2] ~= nil and cmd[3] ~= nil and admin then
        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local refId = tableHelper.concatenateFromIndex(cmd, 3)
            local packetType

            if cmd[1] == "placeat" then
                packetType = "place"
            elseif cmd[1] == "spawnat" then
                packetType = "spawn"
            end

            logicHandler.CreateObjectAtPlayer(targetPid, refId, packetType)
        end

    elseif (cmd[1] == "anim" or cmd[1] == "a") and cmd[2] ~= nil then
        local isValid = animHelper.PlayAnimation(pid, cmd[2])

        if not isValid then
            local validList = animHelper.GetValidList(pid)
            tes3mp.SendMessage(pid, "That is not a valid animation. Try one of the following:\n" ..
                validList .. "\n", false)
        end

    elseif (cmd[1] == "speech" or cmd[1] == "s") and cmd[2] ~= nil and cmd[3] ~= nil and
        type(tonumber(cmd[3])) == "number" then
        local isValid = speechHelper.PlaySpeech(pid, cmd[2], tonumber(cmd[3]))

        if not isValid then
            local validList = speechHelper.GetValidList(pid)
            tes3mp.SendMessage(pid, "That is not a valid speech. Try one of the following:\n"
                .. validList .. "\n", false)
        end

    elseif cmd[1] == "confiscate" and moderator then

        if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])

            if targetPid == pid then
                tes3mp.SendMessage(pid, "You can't confiscate from yourself!\n", false)
            elseif Players[targetPid].data.customVariables.isConfiscationTarget then
                tes3mp.SendMessage(pid, "Someone is already confiscating from that player\n", false)
            else
                Players[pid].confiscationTargetName = Players[targetPid].accountName

                Players[targetPid]:SetConfiscationState(true)

                tableHelper.cleanNils(Players[targetPid].data.inventory)
                guiHelper.ShowInventoryList(config.customMenuIds.confiscate, pid, targetPid)
            end
        end

    elseif cmd[1] == "setai" and cmd[2] ~= nil and cmd[3] ~= nil and admin then

        local actionInput = cmd[3]
        local actionNumericalId

        -- Allow both numerical and string input for actions (i.e. 1 or COMBAT), but
        -- convert the latter into the former
        if type(tonumber(actionInput)) == "number" then
            actionNumericalId = tonumber(actionInput)
        else
            actionNumericalId = enumerations.ai[string.upper(actionInput)]
        end

        if actionNumericalId == nil then

            Players[pid]:Message(actionInput .. " is not a valid AI action. Valid choices are " ..
                tableHelper.concatenateTableIndexes(enumerations.ai, ", ") .. "\n")
        else

            local uniqueIndex = cmd[2]
            local cell = logicHandler.GetCellContainingActor(uniqueIndex)

            if cell == nil then

                Players[pid]:Message("Could not find actor " .. uniqueIndex .. " in any loaded cell\n")
            else

                local actionName = tableHelper.getIndexByValue(enumerations.ai, actionNumericalId)
                local messageAction = enumerations.aiPrintableAction[actionName]
                local message = uniqueIndex .. " is now " .. messageAction

                if actionNumericalId == enumerations.ai.CANCEL then

                    logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId)
                    Players[pid]:Message(message .. "\n")

                elseif actionNumericalId == enumerations.ai.TRAVEL then

                    local posX, posY, posZ = tonumber(cmd[4]), tonumber(cmd[5]), tonumber(cmd[6])

                    if type(posX) == "number" and type(posY) == "number" and type(posZ) == "number" then

                        logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, nil, nil, posX, posY, posZ)
                        Players[pid]:Message(message .. " " .. posX .. " " .. posY .. " " .. posZ .. "\n")
                    else
                        Players[pid]:Message("Invalid travel coordinates! " ..
                            "Use /setai <uniqueIndex> travel <x> <y> <z>\n")
                    end

                elseif actionNumericalId == enumerations.ai.WANDER then

                    local distance, duration = tonumber(cmd[4]), tonumber(cmd[5])

                    if type(distance) == "number" and type(duration) == "number" then

                        if cmd[6] == "true" then
                            shouldRepeat = true
                        else
                            shouldRepeat = false
                        end

                        logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, nil, nil, nil, nil, nil,
                            distance, duration, shouldRepeat)
                        Players[pid]:Message(message .. " a distance of " .. distance .. " for a duration of " ..
                            duration .. "\n")
                    else
                        Players[pid]:Message("Invalid wander parameters! " ..
                            "Use /setai <uniqueIndex> wander <distance> <duration> true/false\n")
                    end

                elseif cmd[4] ~= nil then

                    local target = cmd[4]
                    local hasPlayerTarget = false

                    if type(tonumber(target)) == "number" and logicHandler.CheckPlayerValidity(pid, target) then
                        target = tonumber(target)
                        hasPlayerTarget = true
                    end

                    if hasPlayerTarget then
                        logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, target)
                        message = message .. " player " .. Players[target].name
                    else
                        logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, nil, target)
                        message = message .. " actor " .. target
                    end

                    Players[pid]:Message(message .. "\n")
                else

                    Players[pid]:Message("Invalid AI action!\n")
                end
            end
        end

    elseif cmd[1] == "storerecord" and cmd[2] ~= nil and cmd[3] ~= nil and admin then
        commandHandler.StoreRecord(pid, cmd)

    elseif cmd[1] == "createrecord" and cmd[2] ~= nil and admin then
        commandHandler.CreateRecord(pid, cmd)
		
	elseif cmd[1] == addRole and cmd[2] ~= nil and cmd[3] ~= nil and moderator then
		pidt = cmd[2]
		Role = cmd[3]
		if tableHelper.containsValue(Players[pidt].data.playerRoles, Role) ~= true and logicHandler.CheckPlayerValidity(pidt, pid) then
			if tableHelper.containsValue(config.activeRoles, Player[pid].name .. " gave " .. Player[pidt].name .. " the role " .. Role) == true then
				tes3mp.LogMessage(enumerations.log.INFO, "" )
				tes3mp.SendMessage(pid, color.Aqua .. "Player " .. Players[pidt].name .. " was given the role " .. Role .. ".\n", false)
				tes3mp.SendMessage(pidt, color.Aqua .. "You have been given the role " .. Role .. ".\n", false)
				table.insert(Players[pidt].data.playerRoles, roleName)
			else
				tes3mp.SendMessage(pid, color.Aqua .. Role .. " is not a valid role.\n", false)
				tes3mp.LogMessage(enumerations.log.INFO, Player[pid].name .. " tried to give player " .. Player[pid].name .. " the role " .. Role .. " but it's not a valid role")	
			end
		else
			tes3mp.SendMessage(pid, color.Aqua .. "Player " .. Players[pidt].name .. " already has the role " .. Role .. ".\n", false)
		end
	

	elseif cmd[1] == removeRole and cmd[2] ~= nil and cmd[3] ~= nil and moderator then
		pidt = cmd[2]
		Role = cmd[3]
		if tableHelper.containsValue(config.activeRoles, Role) == true and logicHandler.CheckPlayerValidity(pidt, pid) then
			tes3mp.SendMessage(pid, color.Aqua .. "Player " .. Players[pidt].name .. " has had the role " .. Role .. " removed.\n", false)
			tes3mp.SendMessage(pidt, color.Aqua .. "You have lost the role " .. Role .. ".\n", false)
			tableHelper.removeValue(Players[pidt].data.playerRoles, roleName)
		else
			tes3mp.SendMessage(pid, color.Aqua .. "Player " .. Players[pidt].name .. " does not have the role " .. Role .. ".\n", false)
		end
	
    elseif cmd[1] == "help" then
        -- Check "scripts/menu/help.lua" if you want to change the contents of the help menus
        Players[pid].currentCustomMenu = "help player"
        menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
		

    elseif cmd[1] == "craft" then
		if config.craftEnabled == true then
			-- Check "scripts/menu/defaultCrafting.lua" if you want to change the example craft menu
			Players[pid].currentCustomMenu = "default crafting origin"
			menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
		else
			tes3mp.LogMessage(enumerations.log.INFO, Players[pid].name .. " tried to open crafing menu but it's disabled.")
			tes3mp.SendMessage(pid, color.Aqua .. "[SYSTEM]: Crafting is disabled.\n", false)
		end
		
    --[[elseif (cmd[1] == "advancedexample" or cmd[1] == "advex") and moderator then

        -- Check "scripts/menu/advancedExample.lua" if you want to change the advanced menu example
        Players[pid].currentCustomMenu = "advanced example origin"
        menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)]]--
    end
end

function commandHandler.StoreRecord(pid, cmd)

    if Players[pid].data.customVariables == nil then
        Players[pid].data.customVariables = {}
    end

    if Players[pid].data.customVariables.storedRecords == nil then
        Players[pid].data.customVariables.storedRecords = {}
    end

    for recordKey, _ in pairs(config.validRecordSettings) do
        if Players[pid].data.customVariables.storedRecords[recordKey] == nil then
            Players[pid].data.customVariables.storedRecords[recordKey] = {}
        end
    end

    local inputType = string.lower(cmd[2])

    if config.validRecordSettings[inputType] == nil then
        Players[pid]:Message("Record type " .. inputType .. " is invalid. Please use one of the following " ..
            "valid types instead: " .. tableHelper.concatenateTableIndexes(config.validRecordSettings, ", ") .. "\n")
        return
    end

    local storedTable = Players[pid].data.customVariables.storedRecords[inputType]
    local inputSetting = cmd[3]

    if inputSetting == "clear" then
        Players[pid].data.customVariables.storedRecords[inputType] = {}
        Players[pid]:Message("Clearing stored " .. inputType .. " data\n")
    elseif inputSetting == "print" then
        local text = "for a record of type " .. inputType

        if tableHelper.isEmpty(storedTable) then
            text = "You have no values stored " .. text .. "."
        else
            text = "You have the current values stored " .. text .. ":\n\n"

            for index, value in pairs(storedTable) do
                text = text .. index .. ": "

                if type(value) == "table" then
                    text = text .. tableHelper.getSimplePrintableTable(value)
                else
                    text = text .. value
                end

                text = text .. "\n"
            end
        end

        tes3mp.CustomMessageBox(pid, config.customMenuIds.recordPrint, text, "Ok")
    elseif inputSetting ~= nil then

        if inputSetting == "add" then
            local inputAdditionType = cmd[4]
            local inputConcatenation
            local inputValues

            if inputAdditionType == nil or cmd[5] == nil then
                Players[pid]:Message("Please provide the minimum number of arguments required.\n")
                return
            else
                inputConcatenation = tableHelper.concatenateFromIndex(cmd, 5)
                inputValues = tableHelper.getTableFromCommaSplit(inputConcatenation)
            end

            if inputAdditionType == "effect" and (inputType == "spell" or
                inputType == "potion" or inputType == "enchantment") then

                if storedTable.effects == nil then
                    storedTable.effects = {}
                end

                local inputEffectId = inputValues[1]

                if type(tonumber(inputEffectId)) == "number" then

                    local effect = { id = tonumber(inputEffectId), rangeType = tonumber(inputValues[2]),
                        duration = tonumber(inputValues[3]), area = tonumber(inputValues[4]),
                        magnitudeMin = tonumber(inputValues[5]), magnitudeMax = tonumber(inputValues[6]),
                        attribute = tonumber(inputValues[7]), skill = tonumber(inputValues[8]) }
                    table.insert(storedTable.effects, effect)
                    Players[pid]:Message("Added effect " .. inputConcatenation .. "\n")
                else
                    Players[pid]:Message("Please use a numerical value for the effect ID.\n")
                end
            elseif inputAdditionType == "part" and (inputType == "armor" or inputType == "clothing") then

                if storedTable.parts == nil then
                    storedTable.parts = {}
                end

                local inputPartType = inputValues[1]

                if type(tonumber(inputPartType)) == "number" then

                    local part = { partType = tonumber(inputPartType), malePart = inputValues[2],
                        femalePart = inputValues[3] }
                    table.insert(storedTable.parts, part)
                    Players[pid]:Message("Added part " .. inputConcatenation .. "\n")
                else
                    Players[pid]:Message("Please use a numerical value for the part type.\n")
                end
            elseif inputAdditionType == "item" and (inputType == "creature" or inputType == "npc") then

                if storedTable.items == nil then
                    storedTable.items = {}
                end

                local inputItemId = inputValues[1]
                local inputItemCount = tonumber(inputValues[2])

                if type(inputItemCount) ~= "number" then
                    inputItemCount = 1
                end

                local item = { id = inputItemId, count = inputItemCount }
                table.insert(storedTable.items, item)
                Players[pid]:Message("Added item " .. inputItemId .. " with count " .. inputItemCount .. "\n")
            else
                Players[pid]:Message(tostring(inputAdditionType) .. " is not a valid addition type for " ..
                    inputType .. " records.\n")
            end

        elseif tableHelper.containsValue(config.validRecordSettings[inputType], inputSetting) then

            local inputValue = tableHelper.concatenateFromIndex(cmd, 4)

            -- Although numerical values are accepted for gender, allow "male" and "female" input
            -- as well
            if inputSetting == "gender" and type(tonumber(inputValue)) ~= "number" then
                local gender

                if inputValue == "male" then
                    gender = 1
                elseif inputValue == "female" then
                    gender = 0
                end

                if type(gender) == "number" then
                    storedTable.gender = gender
                else
                    Players[pid]:Message("Please use either 0/1 or female/male as the gender input.\n")
                    return
                end
            elseif tableHelper.containsValue(config.numericalRecordSettings, inputSetting) then
                inputValue = tonumber(inputValue)

                if type(inputValue) == "number" then
                    storedTable[inputSetting] = inputValue
                else
                    Players[pid]:Message("Please use a valid numerical value as the input for " ..
                        inputSetting .. "\n")
                    return
                end
            elseif tableHelper.containsValue(config.minMaxRecordSettings, inputSetting) then
                local minValue = tonumber(cmd[4])
                local maxValue = tonumber(cmd[5])

                if type(minValue) == "number" and type(maxValue) == "number"  then
                    storedTable[inputSetting] = { min = minValue, max = maxValue }
                else
                    Players[pid]:Message("Please use two valid numerical values as the input for " ..
                        inputSetting .. "\n")
                    return
                end
            elseif tableHelper.containsValue(config.booleanRecordSettings, inputSetting) then
                if inputValue == "true" or inputValue == "on" or tonumber(inputValue) == 1 then
                    storedTable[inputSetting] = true
                elseif inputValue == "false" or inputValue == "off" or tonumber(inputValue) == 0 then
                    storedTable[inputSetting] = false
                else
                    Players[pid]:Message("Please use a valid boolean as the input for " .. inputSetting .. "\n")
                    return
                end
            else
                storedTable[inputSetting] = inputValue
            end

            local message = "Storing " .. inputType .. " " .. inputSetting .. " with value " .. inputValue .. "\n"
            Players[pid]:Message(message)
        else
            local validSettingsArray = config.validRecordSettings[inputType]
            Players[pid]:Message(inputSetting .. " is not a valid setting for " .. inputType .. " records. " ..
                "Try one of these:\n" .. tableHelper.concatenateArrayValues(validSettingsArray, 1, ", ") .. "\n")
        end
    end
end

function commandHandler.CreateRecord(pid, cmd)

    if Players[pid].data.customVariables == nil then
        Players[pid].data.customVariables = {}
    end

    if Players[pid].data.customVariables.storedRecords == nil then
        Players[pid].data.customVariables.storedRecords = {}
    end

    if tableHelper.getCount(cmd) > 2 then
        Players[pid]:Message("This command does not take more than 1 argument. Did you mean to use " ..
            "/storerecord instead?\n")
        return
    end

    local inputType = string.lower(cmd[2])
    local storedTable = Players[pid].data.customVariables.storedRecords[inputType]

    if storedTable == nil then
        Players[pid]:Message("Record type " .. inputType .. " is invalid. Please use one of the following " ..
            "valid types instead: " .. tableHelper.concatenateTableIndexes(config.validRecordSettings, ", "))
        return
    end

    if storedTable.baseId == nil then
        if inputType == "creature" then
            Players[pid]:Message("As of now, you cannot create creatures from scratch because of how many " ..
                "different settings need to be implemented for them. Please use a baseId for your creature " ..
                "instead.\n")
            return
        end

        local missingSettings = {}

        for _, requiredSetting in pairs(config.requiredRecordSettings[inputType]) do
            if storedTable[requiredSetting] == nil then
                table.insert(missingSettings, requiredSetting)
            end
        end

        if not tableHelper.isEmpty(missingSettings) then
            isValid = false
            Players[pid]:Message("You cannot create a record of type " .. inputType .. " because it is missing the " ..
                "following required settings: " .. tableHelper.concatenateArrayValues(missingSettings, 1, ", ") .. "\n")
        end
    end

    if inputType == "enchantment" and (storedTable.effects == nil or tableHelper.isEmpty(storedTable.effects)) then
        Players[pid]:Message("Records of type " .. inputType .. " require at least 1 effect.\n")
        return
    end

    local id = storedTable.id
    local isGenerated = id == nil or logicHandler.IsGeneratedRecord(id)

    local enchantmentStore
    local hasGeneratedEnchantment = tableHelper.containsValue(config.enchantableRecordTypes, inputType) and
        storedTable.enchantmentId ~= nil and logicHandler.IsGeneratedRecord(storedTable.enchantmentId)

    if hasGeneratedEnchantment then
        -- Ensure the generated enchantment used by this record actually exists
        if isGenerated then
            enchantmentStore = RecordStores["enchantment"]

            if enchantmentStore.data.generatedRecords[storedTable.enchantmentId] == nil then
                Players[pid]:Message("The generated enchantment record (" .. storedTable.enchantmentId ..
                    ") you are trying to use for this " .. inputType .. " record does not exist.\n")
                return
            end
        -- Permanent records should only use other permanent records as enchantments, so
        -- go no further if that is not the case
        else
            Players[pid]:Message("You cannot use a generated enchantment record (" .. storedTable.enchantmentId ..
                ") with a permanent record (" .. id .. ").\n")
            return
        end
    end

    local recordStore = RecordStores[inputType]

    if id == nil then
        id = recordStore:GenerateRecordId()
        isGenerated = true
    end

    -- We don't want to insert a direct reference to the storedTable in our record data,
    -- so create a copy of the storedTable and insert that instead
    local savedTable = tableHelper.shallowCopy(storedTable)

    -- The id and the savedTable will form a key-value pair, so there's no need to keep
    -- the id in the savedTable as well
    savedTable.id = nil

    -- Use an autoCalc of 1 by default for entirely new NPCs to avoid spawning them
    -- without any stats
    if inputType == "npc" and savedTable.baseId == nil and savedTable.autoCalc == nil then
        savedTable.autoCalc = 1
        Players[pid]:Message("autoCalc is defaulting to 1 for this record.\n")
    end

    -- Use a skillId of -1 by default for entirely new books to avoid having them
    -- increase a skill
    if inputType == "book" and savedTable.skillId == nil then
        savedTable.skillId = -1
        Players[pid]:Message("skillId is defaulting to -1 for this record.\n")
    end

    local message = "Your record has now been saved as a "

    if isGenerated then
        message = message .. "generated record that will be deleted when no longer used.\n"
        recordStore.data.generatedRecords[id] = savedTable

        -- This record will be sent to everyone on the server below, so track it
        -- as having already been received by players
        for _, player in pairs(Players) do
            if not tableHelper.containsValue(Players[pid].generatedRecordsReceived, id) then
                table.insert(player.generatedRecordsReceived, id)
            end
        end

        -- Is this an enchantable record using an enchantment from a generated record?
        -- If so, add a link to this record for that enchantment record
        if hasGeneratedEnchantment then
            enchantmentStore:AddLinkToRecord(savedTable.enchantmentId, id, inputType)
            enchantmentStore:Save()
        end
    else
        message = message .. "permanent record that you'll have to remove manually when you no longer need it.\n"
        recordStore.data.permanentRecords[id] = savedTable
    end

    recordStore:Save()

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType[string.upper(inputType)])

    if inputType == "armor" then packetBuilder.AddArmorRecord(id, savedTable)
    elseif inputType == "book" then packetBuilder.AddBookRecord(id, savedTable)
    elseif inputType == "clothing" then packetBuilder.AddClothingRecord(id, savedTable)
    elseif inputType == "creature" then packetBuilder.AddCreatureRecord(id, savedTable)
    elseif inputType == "enchantment" then packetBuilder.AddEnchantmentRecord(id, savedTable)
    elseif inputType == "miscellaneous" then packetBuilder.AddMiscellaneousRecord(id, savedTable)
    elseif inputType == "npc" then packetBuilder.AddNpcRecord(id, savedTable)
    elseif inputType == "potion" then packetBuilder.AddPotionRecord(id, savedTable)
    elseif inputType == "spell" then packetBuilder.AddSpellRecord(id, savedTable)
    elseif inputType == "weapon" then packetBuilder.AddWeaponRecord(id, savedTable) end

    tes3mp.SendRecordDynamic(pid, true, false)

    if inputType ~= "enchantment" then
        if inputType == "creature" or inputType == "npc" then
            message = message .. "You can spawn an instance of it using /spawnat "
        else
            message = message .. "You can place an instance of it using /placeat "
        end

        message = message .. "<pid> " .. id .. "\n"
    else
        message = message .. "To use it, create an armor, book, clothing or weapon record with an " ..
            "enchantmentId of " .. id .. "\n"
    end

    Players[pid]:Message(message)
end

return commandHandler
local json = require "json"
local mailboxOpened = false
local messageCache = {}
local canRefreshMessage = true
local ready = false
local letterPromptGroup = GetRandomIntInRange(0, 0xffffff)

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    Locales[Config.locale]["TextNearMailboxLocation"] = Locales[Config.locale]["TextNearMailboxLocation"]:gsub("%$1",
        Config.keyToOpen):gsub("%$2", Config.keyToOpenBroadcast)

    for _, location in pairs(Config.locations) do
        SetBlipAtPos(location.x, location.y, location.z)
    end


    SendNUIMessage({ action = "set_language", language = json.encode(Locales[Config.locale]) })
    TriggerServerEvent("mailbox:getUsers");
    TriggerServerEvent("mailbox:getMessages");

    ready = true

end)

RegisterNetEvent('mailbox:receiveMessage')
AddEventHandler('mailbox:receiveMessage', function(payload)
    local author = payload.author
    canRefreshMessage = true

    if not Config.ReceiveBirdMessage then
        DisplayTip(_U("TipOnMessageReceived"):gsub("%$1", author), 5000)
    else
        pigeonCycle(payload)
    end

end)

--declare a function named pigeonCycle that takes the message payload as argument
function pigeonCycle(payload)
    local isReceiving = true
    local sID = SsID
    local tPName = StPName
    local ped = PlayerPedId()
    local rFar = math.random(50, 100)

    local cuteBird = nil
    local notified = false
    local birdTime = Config.BirdTimeout

    while isReceiving do
        Wait(1)

        local playerCoords = GetEntityCoords(ped)
        local birdCoords = GetEntityCoords(cuteBird)
        local myCoords = vector3(playerCoords.x, playerCoords.y, playerCoords.z)
        local destination = #(birdCoords - myCoords)

        local insideBuilding = GetInteriorFromEntity(ped)

        local isBirdCanSpawn = true

        if insideBuilding ~= 0 then
            if not buildingNotified then
                DisplayTip(_U("TipInsideBuildingError"), 5000)
                buildingNotified = true
            end

            isBirdCanSpawn = false

            goto continue
        end

        if isBirdCanSpawn and not isBirdAlreadySpawned then
            cuteBird = SpawnBirdPost(playerCoords.x - 100, playerCoords.y - 100, playerCoords.z + 100, 92.0, rFar, 0)
            TaskFlyToCoord(cuteBird, 0, playerCoords.x - 1, playerCoords.y - 1, playerCoords.z, 1, 0)
            isBirdCanSpawn = false
            isBirdAlreadySpawned = true
        end

        if destination < 100 and not notified then
            notified = true
            DisplayTip(_U("TipOnPigeonMessageReceived"), 5000)
            Wait(5000)
            DisplayTip(_U("TipOnPigeonMessageWait"), 3000)
        end

        local IsPedAir = IsEntityInAir(cuteBird, 1)
        local isBirdDead = Citizen.InvokeNative(0x7D5B1F88E7504BBA, cuteBird) -- IsEntityDead

        BirdCoords = GetEntityCoords(cuteBird)

        Debug("cuteBird", cuteBird)
        Debug("IsPedAir", IsPedAir)
        Debug("notified", notified)
        Debug("destination", destination)

        if cuteBird ~= nil and not IsPedAir and notified and destination > 3 then
            if Config.AutoResurrect and isBirdDead then
                Debug("isBirdDead", isBirdDead)

                ClearPedTasksImmediately(cuteBird)

                SetEntityCoords(cuteBird, BirdCoords.x, BirdCoords.y, BirdCoords.z)
                Wait(1000)
                Citizen.InvokeNative(0x71BC8E838B9C6035, cuteBird) -- ResurrectPed
                Wait(1000)
            end

            TaskFlyToCoord(cuteBird, 0, myCoords.x - 1, myCoords.y - 1, myCoords.z, 1, 0)
        end

        if birdTime > 0 then
            birdTime = birdTime - 1
            Wait(1000)
        end

        if birdTime == 0 and cuteBird ~= nil and notified then
            DisplayTip(_U("TipOnPigeonFail1"), 5000)
            Wait(8000)
            DisplayTip(_U("TipOnPigeonFail2"), 5000)
            Wait(8000)
            DisplayTip(_U("TipOnPigeonFail3"), 5000)

            SetEntityInvincible(cuteBird, false)
            SetEntityAsMissionEntity(cuteBird, false, false)
            SetEntityAsNoLongerNeeded(cuteBird)
            DeleteEntity(cuteBird)
            RemoveBlip(birdBlip)

            notified = false
            isReceiving = false

            return
        end

        ::continue::
    end
end

-- Set Bird Attribute
function SetPetAttributes(entity)
    -- SET_ATTRIBUTE_POINTS
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 0, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 1, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 2, 1100)

    -- ADD_ATTRIBUTE_POINTS
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 0, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 1, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 2, 1100)

    -- SET_ATTRIBUTE_BASE_RANK
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 0, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 1, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 2, 10)

    -- SET_ATTRIBUTE_BONUS_RANK
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 0, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 1, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 2, 10)

    -- SET_ATTRIBUTE_OVERPOWER_AMOUNT
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 0, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 1, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 2, 5000.0, false)
end

-- Place Ped on Ground Properly
local PlacePedOnGroundProperly = function(hPed, howfar)
    local playerPed = PlayerPedId()
    howFar = howfar
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local found, groundz, normal = GetGroundZAndNormalFor_3dCoord(x - howFar, y, z)

    if found then
        SetEntityCoordsNoOffset(hPed, x - howFar, y, groundz + normal.z + howFar, true)
    end
end

-- Spawn the Bird Post
function SpawnBirdPost(posX, posY, posZ, heading, rfar, x)
    local cuteBird = CreatePed(Config.BirdModel, posX, posY, posZ, heading, 1, 1)

    SetPetAttributes(cuteBird)

    Citizen.InvokeNative(0x013A7BA5015C1372, cuteBird, true) -- SetPedIgnoreDeadBodies
    Citizen.InvokeNative(0xAEB97D84CDF3C00B, cuteBird, false) -- SetAnimalIsWild

    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(cuteBird), GetHashKey('PLAYER'))

    PlacePedOnGroundProperly(cuteBird, rfar)

    Wait(2000)

    Citizen.InvokeNative(0x283978A15512B2FE, cuteBird, true) -- SetRandomOutfitVariation
    ClearPedTasks(cuteBird)
    ClearPedSecondaryTask(cuteBird)
    ClearPedTasksImmediately(cuteBird)
    SetPedFleeAttributes(cuteBird, 0, 0)
    TaskWanderStandard(cuteBird, 0, 0)
    TaskSetBlockingOfNonTemporaryEvents(cuteBird, 1)
    SetEntityAsMissionEntity(cuteBird, true, true)
    Citizen.InvokeNative(0xA5C38736C426FCB8, cuteBird, true) -- SetEntityInvincible

    Wait(2000)

    if x == 0 then
        local blipname = _U("BlipName")
        local bliphash = -1749618580

        Debug("bliphash", bliphash)

        birdBlip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, bliphash, cuteBird) -- BlipAddForEntity
        Citizen.InvokeNative(0x9CB1A1623062F402, birdBlip, blipname) -- SetBlipName
        -- Citizen.InvokeNative(0x931B241409216C1F, targetPed, cuteBird, true) -- SetPedOwnsAnimal
        Citizen.InvokeNative(0x0DF2B55F717DDB10, birdBlip) -- SetBlipFlashes
        Citizen.InvokeNative(0x662D364ABF16DE2F, birdBlip, GetHashKey("BLIP_MODIFIER_DEBUG_BLUE")) -- BlipAddModifier
        SetBlipScale(birdBlip, 2.0)
    end

    return cuteBird
end


RegisterNetEvent('mailbox:receiveBroadcast')
AddEventHandler('mailbox:receiveBroadcast', function(payload)
    local author = payload.author
    local message = payload.message

    print(_U("TipOnBroadcastReceived"):gsub("%$1", message):gsub("%$2", author))
    DisplayTip(_U("TipOnBroadcastReceived"):gsub("%$1", message):gsub("%$2", author), 20000)
end)

RegisterNetEvent('mailbox:setMessages')
AddEventHandler('mailbox:setMessages', function(payload)
    if canRefreshMessage then
        messageCache = payload

        SendNUIMessage({ action = "set_messages", messages = json.encode(payload) })
    end
end)

RegisterNetEvent('mailbox:setUsers')
AddEventHandler('mailbox:setUsers', function(payload)
    SendNUIMessage({ action = "set_users", users = json.encode(payload) })
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if not ready then
            return
        end

        if not mailboxOpened and IsNearbyMailbox() then
            DrawText(_U("TextNearMailboxLocation"), 23, 0.5, 0.85, 0.50, 0.40, 255, 255, 255, 255)

            if not mailboxOpened and IsControlJustReleased(0, Keys[Config.keyToOpen]) then
                OpenUI(false)
                Citizen.Wait(300)
            elseif not mailboxOpened and IsControlJustReleased(0, Keys[Config.keyToOpenBroadcast]) and Config.AllowBroadcast then
                OpenUI(true)
                Citizen.Wait(300)
            end
        end
    end
end)

function IsNearbyMailbox()
    for _, mailbox in pairs(Config.locations) do
        if IsPlayerNearCoords(mailbox.x, mailbox.y, mailbox.z, 2) then
            return true
        end
    end
    return false
end

function OpenUI(broadcastMode)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = (broadcastMode and "open_broadcast" or "open") })
    mailboxOpened = true

    if not broadcastMode then
        if canRefreshMessage then
            TriggerServerEvent("mailbox:getMessages")
        end
    end
end

Debug = function(args1, args2)
    if not Config.Debug then return end

    if args1 ~= nil and args2 ~= nil then
        Citizen.Trace(tostring(args1)..tostring(args2)..'\n')
    end

    if args1 ~= nil and args2 == nil then
        Citizen.Trace(tostring(args1)..'\n')
    end
end

-- UI Events

RegisterNUICallback("close", function(payload)

    -- First close UI. In case of fail, the user will not be stuck focused on the UI
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })

    mailboxOpened = false

    local messages = json.decode(payload.messages)
    local toDelete = {}
    local toMarkAsOpened = {}

    if messages == nil then
        return
    end

    for _, message in pairs(messageCache) do
        local msg = nil

        for _, m in pairs(messages) do
            if m.id == message.id then
                msg = m
                break
            end
        end

        if msg == nil then -- if message is not found, then message is deleted
            toDelete[#toDelete + 1] = message.id
        elseif not message.opened and msg.opened then -- if cached message is not marked as opened but received message is, update
            toMarkAsOpened[#toMarkAsOpened + 1] = message.id
        end
    end

    -- Send data to server
    TriggerServerEvent("mailbox:updateMessages", { toDelete = toDelete, toMarkAsOpened = toMarkAsOpened });

    -- Finally, Cache received messages from UI as most recent messages
    messageCache = messages
end)

RegisterNUICallback("send", function(payload)
    local receiver = payload.receiver
    local message = payload.message

    TriggerServerEvent("mailbox:sendMessage", { receiver = receiver, message = message });
end)

RegisterNUICallback("broadcast", function(payload)
    local message = payload.message

    TriggerServerEvent("mailbox:broadcastMessage", { message = message });
end)

RegisterNUICallback("delete", function(payload)
    TriggerServerEvent("mailbox:deleteMessage", { id = payload.id });
end)

RegisterNUICallback("markAsRead", function(payload)
    TriggerServerEvent("mailbox:maskAsRead", { id = payload.id });
end)

RegisterNUICallback("forceGetMessages", function(payload)
    TriggerServerEvent("mailbox:getMessages");
end)

RegisterNUICallback("forceGetUsers", function(payload)
    TriggerServerEvent("mailbox:getUsers");
end)

RegisterNUICallback("forceGetLanguage", function(payload)
    SendNUIMessage({ action = "set_language", language = json.encode(Locales[Config.locale]) })
end)

-- utils

function IsPlayerNearCoords(x, y, z, dst)
    local playerPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, 0.0)

    local distance = GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, x, y, z, true)

    if distance < dst then
        return true
    end
    return false
end

function DrawText(text, fontId, x, y, scaleX, scaleY, r, g, b, a)
    -- Draw Text
    SetTextScale(scaleX, scaleY);
    SetTextColor(r, g, b, a);
    SetTextCentre(true);
    Citizen.InvokeNative(0xADA9255D, fontId); -- Loads the font requested
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y);

    -- Draw Backdrop
    local lineLength = string.len(text) / 100 * 0.66;
    DrawTexture("boot_flow", "selection_box_bg_1d", x, y, lineLength, 0.035, 0, 0, 0, 0, 200);
end

function DrawTexture(textureDict, textureName, x, y, width, height, rotation, r, g, b, a)

    if not HasStreamedTextureDictLoaded(textureDict) then

        RequestStreamedTextureDict(textureDict, false);
        while not HasStreamedTextureDictLoaded(textureDict) do
            Citizen.Wait(100)
        end
    end
    DrawSprite(textureDict, textureName, x, y + 0.015, width, height, rotation, r, g, b, a, true);
end

function SetBlipAtPos(x, y, z)
    --blip--
    --local blipname = "" .. name
    local bliphash = 1475382911
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x, y, z)

    Citizen.InvokeNative(0x74F74D3207ED525C, blip, bliphash, 1) -- See blips here: https://cloudy-docs.bubbleapps.io/rdr2_blips
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, Locales[Config.locale]["BlipName"])
end

function DisplayTip(message, time)
    if (#message == 0) then
        return
    end
    TriggerEvent("vorp:Tip", message, time);
end

function table.find(f, l) -- find element v of l satisfying f(v)
    for _, v in ipairs(l) do
        if f(v) then
            return v
        end
    end
    return nil
end

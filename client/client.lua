local json = require "json"
local mailboxOpened = false
local messageCache = {}
local canRefreshMessage = true
local ready = false
local displayedUnreadMessages = false

local HEALTH_ID = 0
local STAMINA_ID = 1
local DEADEYE_ID = 2

-- Debug Function
Debug = function(args1, args2)
    if not Config.Debug then return end

    if args1 ~= nil and args2 ~= nil then
        print(tostring(args1), tostring(args2))
    end

    if args1 ~= nil and args2 == nil then
        print(tostring(args1))
    end
end

--#region Bird functions


local flyAwayAndDisappear = function(birdPed)
    Citizen.CreateThread(function ()
        ClearPedTasksImmediately(birdPed)

        local birdCoords = GetEntityCoords(birdPed)
        TaskFlyToCoord(birdPed, 0, birdCoords.x + 100, birdCoords.y + 100, birdCoords.z + 100, 1, 0)

        Citizen.Wait(10000)
        SetEntityInvincible(birdPed, false)
        SetEntityAsMissionEntity(birdPed, false, false)
        SetEntityAsNoLongerNeeded(birdPed)
        DeleteEntity(birdPed)
        RemoveBlip(birdPed)
    end)
end

local SetPedAttributes = function(nativePed)
    -- SET_ATTRIBUTE_POINTS
    Citizen.InvokeNative(0x09A59688C26D88DF, nativePed, HEALTH_ID, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, nativePed, STAMINA_ID, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, nativePed, DEADEYE_ID, 1100)

    -- ADD_ATTRIBUTE_POINTS
    Citizen.InvokeNative(0x75415EE0CB583760, nativePed, HEALTH_ID, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, nativePed, STAMINA_ID, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, nativePed, DEADEYE_ID, 1100)

    -- SET_ATTRIBUTE_BASE_RANK
    Citizen.InvokeNative(0x5DA12E025D47D4E5, nativePed, HEALTH_ID, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, nativePed, STAMINA_ID, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, nativePed, DEADEYE_ID, 10)

    -- SET_ATTRIBUTE_BONUS_RANK
    Citizen.InvokeNative(0x920F9488BD115EFB, nativePed, HEALTH_ID, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, nativePed, STAMINA_ID, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, nativePed, DEADEYE_ID, 10)

    -- SET_ATTRIBUTE_OVERPOWER_AMOUNT
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, nativePed, HEALTH_ID, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, nativePed, STAMINA_ID, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, nativePed, DEADEYE_ID, 5000.0, false)
end

local SetPedRagdollFlags = function(nativePed)
    local ragdollFlagsIds = {
        1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288
    }
    for _, flagId in pairs(ragdollFlagsIds) do
        Citizen.InvokeNative(0x26695EC767728D84, nativePed, flagId, true)
    end
end

local PlacePedOnGroundProperly = function (hPed, howfar)
    local playerPed = PlayerPedId()
    local howFar = howfar
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local found, groundz, normal = GetGroundZAndNormalFor_3dCoord(x - howFar, y, z)

    if found then
        SetEntityCoordsNoOffset(hPed, x - howFar, y, groundz + normal.z + howFar, true)
    end
end

-- Spawn the Bird Post
local SpawnBirdPost = function(posX, posY, posZ, heading, rfar, x)
    local nativePed = CreatePed(Config.BirdModel, posX, posY, posZ, heading, 1, 1)

    SetPedAttributes(nativePed)
    SetPedRagdollFlags(nativePed)

    Citizen.InvokeNative(0x013A7BA5015C1372, nativePed, true) -- SetPedIgnoreDeadBodies
    Citizen.InvokeNative(0xAEB97D84CDF3C00B, nativePed, false) -- SetAnimalIsWild

    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(nativePed), GetHashKey('PLAYER'))
    PlacePedOnGroundProperly(nativePed, rfar)

    Citizen.Wait(2000)

    Citizen.InvokeNative(0x283978A15512B2FE, nativePed, true) -- SetRandomOutfitVariation
    ClearPedTasks(nativePed)
    ClearPedSecondaryTask(nativePed)
    ClearPedTasksImmediately(nativePed)
    SetPedFleeAttributes(nativePed, 0, 0)
    TaskWanderStandard(nativePed, 0, 0)
    TaskSetBlockingOfNonTemporaryEvents(nativePed, 1)
    SetEntityAsMissionEntity(nativePed, true, true)
    Citizen.InvokeNative(0xA5C38736C426FCB8, nativePed, true) -- SetEntityInvincible

    Citizen.Wait(2000)

    if Config.BirdBlipEnabled then
        local blipname = _U("BirdPostBlipName")
        local bliphash = -1749618580

        Debug("bliphash", bliphash)

        local birdBlip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, bliphash, nativePed) -- BlipAddForEntity
        Citizen.InvokeNative(0x9CB1A1623062F402, birdBlip, blipname) -- SetBlipName
        -- Citizen.InvokeNative(0x931B241409216C1F, targetPed, cuteBird, true) -- SetPedOwnsAnimal
        Citizen.InvokeNative(0x0DF2B55F717DDB10, birdBlip) -- SetBlipFlashes
        Citizen.InvokeNative(0x662D364ABF16DE2F, birdBlip, GetHashKey("BLIP_MODIFIER_DEBUG_BLUE")) -- BlipAddModifier
        SetBlipScale(birdBlip, 2.0)
    end

    return nativePed
end


local StartBirdThread = function(payload)
    print("StartBirdThread!!!")
    Debug("StartBirdThread", payload)

    local birdTime = Config.BirdTimeout
    local birdPed = nil
    local spawned = false
    local playerPed = PlayerPedId()
    local buildingNotified = false
    local delivered = false
    local notified = false
    local rFar = math.random(50, 100)
    local isReceiving = true
    local destination = 1000

    --thread per il timeout del piccione
    Citizen.CreateThread(function ()
        Debug("Tempo del piccione iniziato!")
        Debug("birdTime", birdTime)
        Debug("birdPed", birdPed)
        Debug("notified", notified)

        while birdTime > 0 do
            Citizen.Wait(1000)
            if notified then
                birdTime = birdTime - 1
            end
        end
        
        Debug("Tempo del piccione finito!")
        if birdTime <= 0 and birdPed ~= nil and notified then
            Debug("Il piccione si è stufato!")
            DisplayTip(_U("TipOnBirdFail1"), 5000)
            Citizen.Wait(8000)
            DisplayTip(_U("TipOnBirdFail2"), 5000)
            isReceiving = false
            flyAwayAndDisappear(birdPed)
            Citizen.Wait(8000)
            DisplayTip(_U("TipOnBirdFail3"), 5000)
        end
        
        flyAwayAndDisappear(birdPed)
        Debug("Thread di timeout piccione interrotto!")
    end)


    --thread per il controllo del volo del piccione verso il player
    Citizen.CreateThread(function()
        while isReceiving do
            Citizen.Wait(50)

            local playerCoords = GetEntityCoords(playerPed)

            if not spawned then
                Debug("Spawning bird!")
                birdPed = SpawnBirdPost(playerCoords.x - 100, playerCoords.y - 100, playerCoords.z + 100, 92.0, rFar, 0)
                TaskFlyToCoord(birdPed, 0, playerCoords.x - 1, playerCoords.y - 1, playerCoords.z, 1, 0)
                spawned = true
            end


            local birdCoords = GetEntityCoords(birdPed)
            local myCoords = vector3(playerCoords.x, playerCoords.y, playerCoords.z)
            destination = #(birdCoords - myCoords)

            if not notified then
                Debug("notifying player of arriving bird!")
                notified = true
                Citizen.CreateThread(function ()
                    DisplayTip(_U("TipOnBirdMessageReceived"), 5000)
                    Citizen.Wait(8000)
                    DisplayTip(_U("TipOnBirdMessageWait"), 5000)
                end)
            end

        end
        
        Debug("Thread di volo/spawn/notifica piccione interrotto!")
    end)

    --thread per il controllo del blocco del piccione (può bloccarsi in aria se il punto del player non è raggiungibile)
    Citizen.CreateThread(function ()
        local distance = 9999
        while not spawned and isReceiving do
            Citizen.Wait(1000)
        end
        while isReceiving and not delivered do
            Citizen.Wait(1000)
            local newDistance = destination
            local speed = (distance - newDistance)
            distance = newDistance
            Debug("speed", speed)
            
            local playerCoords = GetEntityCoords(playerPed)
            local myCoords = vector3(playerCoords.x, playerCoords.y, playerCoords.z)

            
            local IsPedAir = IsEntityInAir(birdPed, 1)

            -- se il piccione sta volando troppo lento o sta girando in tondo, ricalcolo la destinazione
            if speed < 0 and IsPedAir then
                Debug("speed", speed)
                Debug("Il piccione si è bloccato, ricalcolo!")
                distance = 9999
                ClearPedTasksImmediately(birdPed)
                TaskFlyToCoord(birdPed, 0, myCoords.x - 1, myCoords.y - 1, myCoords.z, 1, 0)
                
                --lascio al piccione 1 secondo di tempo per partire a razzo,
                Citizen.Wait(1000) 
            end
            -- se il piccione è atterrato ma il player è stronzo e si è spostato lo seguo
            if birdPed ~= nil and not IsPedAir and notified and destination > Config.BirdMinDistance then   
                TaskFlyToCoord(birdPed, 0, myCoords.x - 1, myCoords.y - 1, myCoords.z, 1, 0)
                distance = 9999
            end
        end
        Debug("Thread di redirect piccione interrotto!")
    end)

    --thread per il prompt del piccione
    Citizen.CreateThread(function ()
        while not delivered and isReceiving do
            --ogni 100ms controllo se il player è vicino al piccione, se è vicino avvio un ciclo da 1ms per il prompt,
            --questo serve perché se drawtext non viene rieseguito ogni frame, il testo viene mostrato a scatti
            Citizen.Wait(100)
            while destination <= Config.BirdMinDistance and not delivered do
                Citizen.Wait(1)

                DrawText(_U("TextNearBirdLocation"), 23, 0.5, 0.85, 0.50, 0.40, 255, 255, 255, 255)

                if not mailboxOpened and IsControlJustReleased(0, Keys[Config.keyToOpen]) then
                    delivered = true
                    TriggerServerEvent("mailbox:markAsRead", payload)
                    isReceiving = false
                    flyAwayAndDisappear(birdPed)
                    OpenUI(false, payload)
                    Citizen.Wait(300)
                end
            end
        end
        Debug("Thread di prompt piccione interrotto!")
    end)
end
--#endregion

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    Locales[Config.locale]["TextNearMailboxLocation"] = Locales[Config.locale]["TextNearMailboxLocation"]:gsub("%$1",
        Config.keyToOpen):gsub("%$2", Config.keyToOpenBroadcast)
    Locales[Config.locale]["TextNearBirdLocation"] = Locales[Config.locale]["TextNearBirdLocation"]:gsub("%$1", Config.keyToOpen)

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
    if not Config.ReceiveBirdMessage then
        DisplayTip(_U("TipOnMessageReceived"):gsub("%$1", payload.firstname .. ' ' .. payload.lastname), 5000)
        return
    end

    StartBirdThread(payload)

    canRefreshMessage = true
end)

if Config.Debug then
    RegisterCommand("testBird", function(source, args, rawCommand)
        Debug("testBird command received!", source)
        TriggerEvent('mailbox:receiveMessage', {
            firstname = "Testonio",
            lastname = "Testonius",
            message = "Contenuto di test"
        })
    end, true)

    RegisterCommand("openMailbox", function (source, args, rawCommand)
        Debug("openMailbox command received!", source)
        OpenUI(false)
    end, true)

    RegisterCommand("openBroadcast", function (source, args, rawCommand)
        Debug("openBroadcast command received!", source)
        OpenUI(true)
    end, true)
end

RegisterNetEvent('mailbox:checkUnreadMessages')
AddEventHandler('mailbox:checkUnreadMessages', function(payload)
    if(displayedUnreadMessages) then
        return
    end

    Debug("checkUnreadMessages event received!", payload)
    --note this event is called from the backend after login, and after calling the getMessages event, so we can use the messageCache
    local unreadMessages = {}

    Debug('totalMessages', #messageCache)

    for _, value in ipairs(messageCache) do
        Debug("value.opened:", value.opened)
        if value.opened == false or value.opened == 0 then
            table.insert(unreadMessages, value)
        end
    end
    Debug("unreadMessages:", #unreadMessages)
    if #unreadMessages > 0 then
        displayedUnreadMessages = true
        Citizen.Wait(5000)
        DisplayTip(_U("TipUnreadMessages"):gsub("%$1", #unreadMessages), 10000)
    end
end)


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

AddEventHandler('playerSpawned', function(spawn)
    TriggerEvent("mailbox:SelectedCharacter")
end)

RegisterNetEvent('mailbox:SelectedCharacter')
AddEventHandler('mailbox:SelectedCharacter', function(payload)
    print("mailbox:SelectedCharacter event received!", source)
    TriggerServerEvent("mailbox:getMessages");
    Citizen.Wait(10000)
    TriggerEvent("mailbox:checkUnreadMessages")
end)

RegisterNetEvent('mailbox:setUsers')
AddEventHandler('mailbox:setUsers', function(payload)
    SendNUIMessage({ action = "set_users", users = json.encode(payload) })
end)

--close event to be called from the backend
RegisterNetEvent('mailbox:close')
AddEventHandler('mailbox:close', function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })

    mailboxOpened = false
end)


-- TODO: rimpiazza questa cosa con i prompt di gioco, il wait di 1ms è una mazzata mostruosa sulle performance
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

function OpenUI(broadcastMode, payload)
    SetNuiFocus(true, true)
    if(payload == nil) then
        SendNUIMessage({ action = (broadcastMode and "open_broadcast" or "open") })
    else
        SendNUIMessage({ action = "open_single", message = json.encode(payload) })
    end
    mailboxOpened = true

    if not broadcastMode then
        if canRefreshMessage then
            TriggerServerEvent("mailbox:getMessages")
        end
    end
end

-- UI Events

RegisterNUICallback("close", function(payload)
    -- First close UI. In case of fail, the user will not be stuck focused on the UI
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })

    mailboxOpened = false
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
    TriggerServerEvent("mailbox:markAsRead", { id = payload.id });
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
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, _U("BlipName")) -- SetBlipName
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

CORE = {}
local usersCache = {}
local lastUserMessageSent = {}
local lastUserBroadcastSent = {}
local lastUsersRefresh = 0;

Citizen.CreateThread(function()
    TriggerEvent("getCore", function(dic)
        CORE = dic;
    end)

    RefreshUsersCache()
end)

RegisterServerEvent("mailbox:sendMessage")
AddEventHandler("mailbox:sendMessage", function(data)
    if source == nil then
        print("[mailbox:sendMessage] source is null")
    end
    local _source = source
    local receiver = data.receiver
    local message = data.message
    local sourceCharacter = CORE.getUser(source).getUsedCharacter
    local steamIdentifier = CORE.getUser(source).getIdentifier()

    local delay = Config['DelayBetweenTwoMessage']
    local lastMessageSentTime = lastUserMessageSent[steamIdentifier]
    local gameTime = GetGameTimer()
    -- checking if user is allowed to send a message now
    if lastMessageSentTime ~= nil and lastMessageSentTime + 1000 * delay >= gameTime then
        local remainingTime = ((lastMessageSentTime + 1000 * delay) - gameTime) / 1000
        local errorMessage = _U("TipOnTooRecentMessageSent"):gsub("%$1", remainingTime)

        TriggerClientEvent("vorp:Tip", _source, errorMessage)
        return
    end

    -- checking if user has enough money
    local price = Config['MessageSendPrice']

    if sourceCharacter.money < price then
        TriggerClientEvent("vorp:Tip", _source, _U("TipOnInsufficientMoneyForMessage"))
        return;
    end

    local insertedID = -1;
    exports.ghmattimysql:execute(
        "INSERT INTO mailbox_mails SET sender_id = ? , sender_firstname = ?, sender_lastname = ?, receiver_id = ?, receiver_firstname = ?, receiver_lastname = ?, message = ?;",
        { steamIdentifier,
            sourceCharacter.firstname,
            sourceCharacter.lastname,
            receiver.steam,
            receiver.firstname,
            receiver.lastname,
            message
        },
        function(result)
            insertedID = result.insertId
            print("[mailbox:sendMessage] insertedID: " .. insertedID)

            local connectedUsers = CORE.getUsers() -- return a Dictionary of <SteamID, User>
            for steam, user in pairs(connectedUsers) do
                -- if the steamID correspond to the receiver SteamID.
                if steam == receiver.steam then
                    local receiverCharacter = user.GetUsedCharacter()

                    -- if connected receiver use the right character, send a tip to him
                    if receiverCharacter.firstname == receiver.firstname and receiverCharacter.lastname == receiver.lastname then
                        TriggerClientEvent("mailbox:receiveMessage", user.source, {
                            id = insertedID,
                            steam = steamIdentifier,
                            firstname = sourceCharacter.firstname,
                            lastname = sourceCharacter.lastname,
                            message = message
                        })
                        
                        --tip custom per messaggio inviato e ricevuto vs tip per messaggio inviato ma non ricevuto?
                        return
                    end
                end
            end
        end)

    TriggerEvent("vorp:removeMoney", _source, 0, price)
    lastUserMessageSent[steamIdentifier] = gameTime
    TriggerClientEvent("vorp:Tip", _source, _U("TipOnMessageSent"))

    if(Config.EnableAdminDiscordWebhook) then
        local header = "**"..sourceCharacter.firstname.." "..sourceCharacter.lastname.."** ha inviato un messaggio a **"..receiver.firstname.." "..receiver.lastname.."**\r\n**Contenuto:**"
        exports.discord_rest:executeWebhookUrl(Config.DiscordAdminWebhook, {content = header.."\r\n```"..message..'```\r\n===================='})
        print("[mailbox:sendMessage] Sent message to Discord")
    end

end)


RegisterServerEvent("mailbox:broadcastMessage")
AddEventHandler("mailbox:broadcastMessage", function(data)
    if source == nil then
        print("[mailbox:broadcastMessage] source is null")
    end
    local _source = source
    local message = data.message
    local sourceCharacter = CORE.getUser(source).getUsedCharacter
    local steamIdentifier = CORE.getUser(source).getIdentifier()

    local delay = Config['DelayBetweenTwoBroadcast']
    local lastBroadcastSentTime = lastUserBroadcastSent[steamIdentifier]
    local gameTime = GetGameTimer()
    -- checking if user is allowed to send a message now
    if lastBroadcastSentTime ~= nil and lastBroadcastSentTime + 1000 * delay >= gameTime then
        local remainingTime = ((lastBroadcastSentTime + 1000 * delay) - gameTime) / 1000
        local errorMessage = _U("TipOnTooRecentMessageSent"):gsub("%$1", remainingTime)

        TriggerClientEvent("vorp:Tip", _source, errorMessage)
        return
    end

    -- checking if user has enough money
    local price = Config['MessageBroadcastPrice']

    if sourceCharacter.money < price then
        TriggerClientEvent("vorp:Tip", _source, _U("TipOnInsufficientMoneyForBroadcast"))
        return;
    end

    TriggerEvent("vorp:removeMoney", _source, 0, price)
    lastUserBroadcastSent[steamIdentifier] = gameTime
    TriggerClientEvent("vorp:Tip", _U("TipOnMessageSent"))

    local connectedUsers = CORE.getUsers() -- return a Dictionary of <SteamID, User>
    for _, user in pairs(connectedUsers) do
        TriggerClientEvent("mailbox:receiveBroadcast", user.source,
            { message = message, author = sourceCharacter.firstname .. " " .. sourceCharacter.lastname })
    end

    TriggerClientEvent("mailbox:close", _source)
end)

--function IsPlayerConnected(handle)
--    for _, playerId in ipairs(GetPlayers()) do
--        if playerId == handle then
--            return true
--        end
--    end
--end

AddEventHandler("vorp:SelectedCharacter", function(source, character)
    print("vorp:SelectedCharacter event received!", source)
    TriggerClientEvent("mailbox:SelectedCharacter", source)
end)

RegisterServerEvent("mailbox:getMessages")
AddEventHandler("mailbox:getMessages", function()
    if source == nil then
        print("[mailbox:getMessages] source is null")
    end
    local _source = source
    local sourceCharacter = CORE.getUser(source).getUsedCharacter
    local steamIdentifier = CORE.getUser(source).getIdentifier()

    exports.ghmattimysql:execute(
        "SELECT * FROM mailbox_mails WHERE receiver_id = ? AND receiver_firstname = ? AND receiver_lastname = ?;",
        { steamIdentifier,
            sourceCharacter.firstname,
            sourceCharacter.lastname
        }, function(result)
            --[[letters: Array<{
                         id,
                         sender_id,
                         sender_firstname,
                         sender_lastname,
                         receiver_id,
                         receiver_firstname,
                         receiver_lastname,
                         message,
                         opened,
                         received_at
                         }
                         >--]]
            local messages = {}
            for _, msg in pairs(result) do
                messages[#messages + 1] = {
                    id = tostring(msg.id),
                    firstname = msg.sender_firstname,
                    lastname = msg
                        .sender_lastname,
                    message = msg.message,
                    steam = msg.sender_id,
                    received_at = msg.received_at,
                    opened =
                        msg.opened
                }
            end
            TriggerClientEvent("mailbox:setMessages", _source, messages)
        end)
end)

RegisterServerEvent("mailbox:getUsers")
AddEventHandler("mailbox:getUsers", function()
    if source == nil then
        print("[mailbox:getUsers] source is null")
    end
    local _source = source
    local refreshRate = Config["TimeBetweenUsersRefresh"]

    if refreshRate > 0 and lastUsersRefresh + (1000 * refreshRate) < GetGameTimer() then
        RefreshUsersCache()
    end
    TriggerClientEvent("mailbox:setUsers", _source, usersCache)
end)

RegisterServerEvent("mailbox:deleteMessage")
AddEventHandler("mailbox:deleteMessage", function(data)
    if source == nil then
        print("[mailbox:deleteMessage] source is null")
    end
    local _source = source
    local steamIdentifier = CORE.getUser(_source).getIdentifier()

    local id = data.id
    exports.ghmattimysql:execute("DELETE FROM mailbox_mails WHERE id = ? AND receiver_id = ?;", { id, steamIdentifier })
    TriggerClientEvent("mailbox:deleteMessage", _source, id)
end)

RegisterServerEvent("mailbox:markAsRead")
AddEventHandler("mailbox:markAsRead", function(data)
    if source == nil then
        print("[mailbox:markAsRead] source is null")
    end
    local _source = source
    local steamIdentifier = CORE.getUser(_source).getIdentifier()

    local id = data.id
    exports.ghmattimysql:execute("UPDATE mailbox_mails SET opened = 1 WHERE id = ? AND receiver_id = ?;",
        { id, steamIdentifier })
    TriggerClientEvent("mailbox:markAsRead", _source, id)
end)

function RefreshUsersCache()
    exports.ghmattimysql:execute("SELECT identifier as steam, firstname, lastname FROM characters;",
        {}, function(result)
            --[[users: Array<{
                     identifier,
                     firstname,
                     lastname
                     }
                     >--]]
            usersCache = result
            table.sort(usersCache, function(a, b)
                local aName = a.firstname .. " " .. a.lastname
                local bName = b.firstname .. " " .. b.lastname
                return aName:upper() < bName:upper()
            end)
            lastUsersRefresh = GetGameTimer()
        end)
end

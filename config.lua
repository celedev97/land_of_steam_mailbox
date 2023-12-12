Config = {}

Config.locale = "it"
Config.keyToOpen = "U"
Config.keyToOpenBroadcast = "G"
Config.locations = {
    {x = -178.9489, y = 626.83941,  z = 114.08961}, -- valentine
    {x = 1225.57,   y = -1293.87,   z = 76.91}, -- rhodes
    {x = 2731.55,   y = -1402.37,   z = 46.18}, -- saintdenis
    {x = 2986.1557, y = 568.51599,  z = 44.627922}, -- vanhorn
    {x = 2939.5173, y = 1288.5345,  z = 44.652824}, -- annsburg
    {x = -1299.277, y = 401.93942,  z = 95.383865}, -- wallace
    {x = -1094.87,  y = -575.608,   z = 82.410873}, -- riggs
    {x = -875.054,  y = -1328.753,  z = 43.958003}, -- flatneck
    {x = -3733.965, y = -2597.86,   z = -12.92674}, -- armadillo, extra position: {x = -3646.79, y = -2620.54, z = -13.55},
    {x = -5487.083, y = -2936.11,   z = -0.402813}, -- tumbleweed
    {x = -1765.084, y = -384.1582,  z = 157.74119}, -- strawberry
}
Config.TimeBetweenUsersRefresh = 120 -- time spent before server fetch all users from database another time. In Seconds. If value is negative or 0, users are only fetched once at server start and never again
Config.DelayBetweenTwoMessage = 15 -- time spent before user is allowed to send a message another time. In Seconds. If value is negative or 0, no delay is set
Config.DelayBetweenTwoBroadcast = 600 -- time spent before user is allowed to send a broadcast another time. In Seconds. If value is negative or 0, no delay is set
Config.MessageSendPrice = 1 --telegram price
Config.MessageBroadcastPrice = 50 -- how much should players pay to brodcast a message to everyone
Config.AllowBroadcast = false -- allow players to send broadcast messages

-- Bird Post settings
Config.ReceiveBirdMessage   = true -- enable the ability to receive messages from birds, if false the player will only receive a tooltip when a message is received
Config.BirdModel            = 'A_C_Owl_01' -- Bird model to use
Config.AutoResurrect        = true -- Auto resurrect the bird when it's died while sending letters
Config.BirdArrivalDelayMs   = 1000 -- Set the bird to arrives after 1 second
Config.BirdTimeout          = 120 -- When timeout reached, the bird will fail to deliver the letter
Config.BirdMinDistance      = 5 -- When the player is farther than x meters the bird will move again to the player, it also count as a distance for the prompt to show up
Config.BirdBlipEnabled      = true -- Enable blip on the map for the bird


Config.Debug = false -- enable debug messages in the console

Config.EnableAdminDiscordWebhook = false
Config.DiscordAdminWebhook = "https://discord.com/api/webhooks/.../..." -- Discord webhook for admin messages

Keys = {
    ["G"] = 0x760A9C6F,
    ["Q"] = 0xDE794E3E,
    ["U"] = 0xD8F73058,
}

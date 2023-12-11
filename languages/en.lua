Locales['en'] = {
    ["TipOnMessageReceived"]= "Hey you! You just received a message from $1",
    ["TipOnBroadcastReceived"]= "New Telegram:\n$1\nMessage paid by $2",
    ["TipOnMessageSent"]= "Telegram sent",
    ["TipOnBroadcastSent"]= "Telegram sent",
    ["TipOnTooRecentMessageSent"]= "You have to wait at least $1 sec before sending a new message", -- don't touch $n, it is replaced with custom values on runtime
    ["TipOnInsufficientMoneyForMessage"]= "Insufficient money. You need $1$", -- don't touch $n, it is replaced with custom values on runtime
    ["TipOnInsufficientMoneyForBroadcast"]= "Insufficient money. You need $1$", -- don't touch $n, it is replaced with custom values on runtime
    ["TipInsideBuildingError"] = "You are inside a building, the pidgeon can't reach you",

    ["TipOnPidgeonMessageReceived"]= "Hey you! A pidgeon is coming to you with a message",
    ["TipOnPidgeonMessageWait"]= "Stop and wait for the pidgeon",
    ["TipOnPidgeonFail1"] = "You've' decided not to pickup the letter!",
    ["TipOnPidgeonFail2"] = "The bird got tired and decided to go!",
    ["TipOnPidgeonFail3"] = "You can retrieve the letter from the local Post Office!",

    ["TextNearMailboxLocation"]= "Press $1 to see your mail", -- don't touch $, it is replaced with curent used key on runtime


    ["UITitleLabel"]= "Land of Steam",
    ["UITelegramLabel"] = "Telegram",

    ["UICloseButton"]= "Close",
    ["UIWriteButton"]= "Write",
    ["UIDeleteButton"]= "Delete",
    ["UIAnswerButton"]= "Answer",
    ["UIAbortButton"]= "Cancel",
    ["UISendButton"]= "Send",
    ["UISelectButton"] = "Select",

    ["UIYourMessagePlaceholder"] = "Your message...",
    ["UINoMessages"]= "No telegrams received",

    ["UIDestinationLabel"] = "Destination",
    ["uiChooseDestinationLabel"] = "Choose Destination",

    ["UINamePrefix"]= "From",

    ["BlipName"] = "Mail Box",
}

if Config.AllowBroadcast then
    Locales['en']["TextNearMailboxLocation"] = "Press $1 to see your mail or $2 to send a telegram to everyone"
end
Locales['it'] = {
    ["TipOnMessageReceived"]= "Ehi tu! Hai appena ricevuto un telegramma da $1",
    ["TipOnBroadcastReceived"]= "Nuovo Telegramma:\n$1\nMessaggio pagato da $2",
    ["TipOnMessageSent"]= "Telegramma inviato",
    ["TipOnBroadcastSent"]= "Telegramma inviato",
    ["TipOnTooRecentMessageSent"]= "Devi aspettare almeno $1 secondi prima di inviare un nuovo messaggio", -- non toccare $n, viene sostituito con valori personalizzati durante l'esecuzione
    ["TipOnInsufficientMoneyForMessage"]= "Denaro insufficiente. Hai bisogno di $1$", -- non toccare $n, viene sostituito con valori personalizzati durante l'esecuzione
    ["TipOnInsufficientMoneyForBroadcast"]= "Denaro insufficiente. Hai bisogno di $1$", -- non toccare $n, viene sostituito con valori personalizzati durante l'esecuzione
    ["TextNearMailboxLocation"]= "Premi $1 per vedere la tua posta", -- non toccare $, viene sostituito con la chiave utilizzata correntemente durante l'esecuzione

    ["UITitleLabel"]= "Land of Steam",
    ["UITelegramLabel"] = "Telegram",

    ["UICloseButton"]= "Chiudi",
    ["UIWriteButton"]= "Scrivi",
    ["UIDeleteButton"]= "Elimina",
    ["UIAnswerButton"]= "Rispondi",
    ["UIAbortButton"]= "Annulla",
    ["UISendButton"]= "Invia",
    ["UISelectButton"] = "Seleziona",

    ["UIYourMessagePlaceholder"] = "Il tuo messaggio...",
    ["UINoMessages"]= "Nessun telegramma ricevuto",

    ["UIDestinationLabel"] = "Destinatario",
    ["uiChooseDestinationLabel"] = "Scegli Destinatario",

    ["UINamePrefix"]= "Da",
}

if Config.AllowBroadcast then
	Locales['it']["TextNearMailboxLocation"] = "Premi $1 per vedere la tua posta o $2 per inviare un telegramma a tutti"
end
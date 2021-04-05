

local addonName, alt = ...


alt.PlayerMixin = nil
alt.charactersSummary = {}
alt.questsSummary = {}
alt.questsSummaryKeys = {}
alt.containersSummary = {}
alt.mailsSummary = {}

alt.mails = 1;

-- borrowed this directly from DataStore, 
-- as we'll be accessing the saved var 
-- this key will used in our own saved var to keep things simple
local THIS_ACCOUNT = "Default"
local THIS_REALM = GetRealmName()
local THIS_CHAR = UnitName("player")
local THIS_CHARKEY = format("%s.%s.%s", THIS_ACCOUNT, THIS_REALM, THIS_CHAR)
local MAX_LOGOUT_TIMESTAMP = 5000000000

local ICON_COIN = "Interface\\Icons\\INV_Misc_Coin_01"
local ICON_NOTE = "Interface\\Icons\\INV_Misc_Note_01"

LoadAddOn("Blizzard_DebugTools")

--- basic print message function
--- @param msg string the message to printed
function alt:PrintInfoMessage(msg)
    print("[|cff0070DDAltasia|r] "..msg)
end


--- this takes a frame and sets it as movable by the player
--- @param frame table frame to set as movable
function alt:MakeFrameMoveable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end


--[[
    this was straight up copy/paste from DataStore_Character, 
    i couldnt find a way to just call it from here so i borrowed it
    would have established the same math in time

    ALL CREDIT for this goes to Thaoky
]]
function alt:GetRestXPRate(character)

	local rate = 0
	local multiplier = 1.5
	
	if character.englishRace == "Pandaren" then
		multiplier = 3
	end
	
	local savedXP = 0
	local savedRate = 0
	local maxXP = character.XPMax * multiplier
	if character.RestXP then
		rate = character.RestXP / (maxXP / 100)
		savedXP = character.RestXP
		savedRate = rate
	end
	
	local xpEarnedResting = 0
	local rateEarnedResting = 0
	local isFullyRested = false
	local timeUntilFullyRested = 0
	local now = time()
	
	if character.lastLogoutTimestamp ~= MAX_LOGOUT_TIMESTAMP then	
		local oneXPBubble = character.XPMax / 20
		local elapsed = (now - character.lastLogoutTimestamp)
		local numXPBubbles = elapsed / 28800
		
		xpEarnedResting = numXPBubbles * oneXPBubble
		
		if not character.isResting then
			xpEarnedResting = xpEarnedResting / 4
		end

		if (xpEarnedResting + savedXP) > maxXP then
			xpEarnedResting = xpEarnedResting - ((xpEarnedResting + savedXP) - maxXP)
		end

		if xpEarnedResting < 0 then xpEarnedResting = 0 end
		
		rateEarnedResting = xpEarnedResting / (maxXP / 100)
		
		if (savedXP + xpEarnedResting) >= maxXP then
			isFullyRested = true
			rate = 100
		else
			local xpUntilFullyRested = maxXP - (savedXP + xpEarnedResting)
			timeUntilFullyRested = math.floor((xpUntilFullyRested / oneXPBubble) * 28800)
			
			rate = rate + rateEarnedResting
		end
	end
	
	return rate, savedXP, savedRate, rateEarnedResting, xpEarnedResting, maxXP, isFullyRested, timeUntilFullyRested
end


-- ???
--[[
function alt:ScanMapsForQuests()
    for mapID = 1, 2000 do
        local quests = C_QuestLog.GetQuestsOnMap(mapID)
        local questLines = C_QuestLine.GetAvailableQuestLines(mapID)
        for a, b in pairs(questLines) do
            for c, d in pairs(b) do
                local mapName = C_Map.GetMapInfo(mapID).name
                --print(a, b, c, d)
            end
        end
        if quests then
            for k, v in pairs(quests) do
                local mapName = C_Map.GetMapInfo(mapID).name
                local title = C_QuestLog.GetTitleForQuestID(v.questID)
                if title then
                    --print(title, mapName, v.x, v.y)
                end
                --v.x
                --v.y
            end
        end
            --if ALT_ACC.quests[questID]
    end
end
]]


--- this will return whether a quest is currently recorded with multiple characters we use this to determine if we should remove the quest data from our own saved var
--- @param questID number the quest ID to query
--- @return boolean true if multiple characters are on this quest
function alt:IsQuestMultiCharacter(questID)
    local c = 0;
    if self.questsSummary then
        for _, quests in pairs(self.questsSummary) do
            if tonumber(questID) == tonumber(quests) then
                for name, realm in pairs(quests) do
                    c = c + 1;
                end
            end
        end
    end
    if c > 1 then
        return true;
    else
        return false;
    end
end



--[[
function alt:ParseMail()
    if not ALT_ACC then
        return
    end
    if not DataStore_MailsDB then
        return
    end
    --local ids, links = {}, {};
    local items, senders = {}, {}
    wipe(self.mailsSummary)
    for dsk, character in pairs(DataStore_MailsDB.global.Characters) do
        for k, mail in ipairs(character.Mails) do
            local key = mail.sender.."-"..mail.daysLeft
        --for k, mail in ipairs(DataStore_MailsDB.global.Characters["Default.Argent Dawn.Silvessa"].Mails) do
            if not senders[key] then
                senders[key] = {
                    From = mail.sender,
                    Items = {},
                    DaysLeft = mail.daysLeft,
                    To = ALT_ACC.characters[dsk].Name,
                    isSelected = false,
                }
            end
        end
        for k, mail in ipairs(character.Mails) do
            local key = mail.sender.."-"..mail.daysLeft
        --for k, mail in ipairs(DataStore_MailsDB.global.Characters["Default.Argent Dawn.Silvessa"].Mails) do
            if mail.subject then
                senders[key].Subject = mail.subject
            else
                senders[key].Subject = "No subject"
            end
            if mail.text then
                senders[key].Message = mail.text
            else
                senders[key].Message = "No message"
            end
            if mail.itemID then
                table.insert(senders[key].Items, mail)
            end
        end
        for daysLeft, info in pairs(senders) do
            --DevTools_Dump(senders)
            table.insert(alt.mailsSummary, info)
        end
        --DevTools_Dump(alt.mailsSummary)
        wipe(senders)
        --wipe(items)
    end
    --print(#alt.mailsSummary)
end
]]


-- take all character mail data and populate the addon mail summary table
-- this was made easier by using a modified version of Thaokys script (see above for old method)
function alt:ParseMail(dsk, filter)
    if not ALT_ACC then
        return
    end
    wipe(self.mailsSummary)
    if filter then
        for _, character in pairs(ALT_ACC.characters) do
            if character.Mail then
                for _, mail in ipairs(character.Mail) do
                    local match = false;
                    for k, v in pairs(mail) do
                        if v ~= nil then
                            if k ~= "attachments" then -- search for match in subject, sender, text etc
                                if type(v) == "string" and v:lower():find(filter:lower()) then
                                    match = true;
                                end
                            elseif k == "attachments" then
                                for _, v in ipairs(mail.attachments) do
                                    if v.link:lower():find(filter:lower()) then -- search item links for a match
                                        match = true;
                                    end
                                end
                            end
                        end
                    end
                    if match == true then
                        table.insert(self.mailsSummary, {
                            From = mail.sender,
                            To = character.Name,
                            Subject = mail.subject and mail.subject or "No subject",
                            Message = mail.text and mail.text or "No message",
                            Items = mail.attachments,
                            DaysLeft = mail.daysLeft,
                            Money = mail.money and mail.money or 0,
                        })
                    end
                end
            end
        end
    else
        if dsk then
            if ALT_ACC.characters[dsk] and ALT_ACC.characters[dsk].Mail then
                for k, mail in ipairs(ALT_ACC.characters[dsk].Mail) do
                    table.insert(self.mailsSummary, {
                        From = mail.sender,
                        To = ALT_ACC.characters[dsk].Name,
                        Subject = mail.subject and mail.subject or "No subject",
                        Message = mail.text and mail.text or "No message",
                        Items = mail.attachments,
                        DaysLeft = mail.daysLeft,
                        Money = mail.money and mail.money or 0,
                    })
                end
            end
        else
            for _, character in pairs(ALT_ACC.characters) do
                if character.Mail then
                    for k, mail in ipairs(character.Mail) do
                        table.insert(self.mailsSummary, {
                            From = mail.sender,
                            To = character.Name,
                            Subject = mail.subject and mail.subject or "No subject",
                            Message = mail.text and mail.text or "No message",
                            Items = mail.attachments,
                            DaysLeft = mail.daysLeft,
                            Money = mail.money and mail.money or 0,
                        })
                    end
                end
            end
        end
    end
    table.sort(self.mailsSummary, function(a,b)
        return a.DaysLeft < b.DaysLeft
    end)
end


-- scan player container data and populate the addon container summary table
function alt:ParseContainers()
    if not ALT_ACC then
        return
    end
    if not DataStore_ContainersDB then
        return
    end
    wipe(self.containersSummary)
    for key, character in pairs(DataStore_ContainersDB.global.Characters) do
        local ids, links = {}, {};
        for bag, info in pairs(character.Containers) do
            if info.links then
                for i = 1, #info.links do
                    if info.links[i] then
                        local count = tonumber(info.counts[i]) or 1
                        local _, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(info.links[i])
                        -- check to see if this item has been added using the ID
                        if not ids[info.ids[i]] then
                            table.insert(self.containersSummary, {
                                ItemIcon = icon,
                                ItemID = tonumber(info.ids[i]),
                                ItemLink = info.links[i],
                                Count = tonumber(info.counts[i]) or 1,
                                Location = ALT_ACC.characters[key].Name,
                                DSK = key,
                            })
                            ids[info.ids[i]] = true
                            links[info.links[i]] = true
                        else

                            -- if there is an ID match then check the item link as this can differ for stuff like gear etc
                            if not links[info.links[i]] then
                                table.insert(self.containersSummary, {
                                    ItemIcon = icon,
                                    ItemID = tonumber(info.ids[i]),
                                    ItemLink = info.links[i],
                                    Count = tonumber(info.counts[i]) or 1,
                                    Location = ALT_ACC.characters[key].Name,
                                    DSK = key,
                                })
                                links[info.links[i]] = true

                            -- if the ID and the link match then its assumed to be the same so we just update the count for this character
                            else
                                for k, v in ipairs(self.containersSummary) do
                                    if v.ItemID == tonumber(info.ids[i]) and v.ItemLink == info.links[i] and v.DSK == key then
                                        v.Count = v.Count + count
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if DataStore_ContainersDB.global.Guilds and next(DataStore_ContainersDB.global.Guilds) then
        for guildKey, guild in pairs(DataStore_ContainersDB.global.Guilds) do
            local ids, links = {}, {}
            local _, _, guildName = strsplit(".", guildKey)
            if guild.Tabs then
                for k, tab in pairs(guild.Tabs) do
                    if tab.links then
                        for i, link in pairs(tab.links) do
                            if link then
                                local count = tonumber(tab.counts[i]) or 1
                                local _, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(link)
                                if not ids[tab.ids[i]] then
                                    table.insert(self.containersSummary, {
                                        ItemIcon = icon,
                                        ItemID = tonumber(tab.ids[i]) or -1,
                                        ItemLink = link,
                                        Count = count,
                                        Location = guildName,
                                        DSK = guildKey,
                                    })
                                    ids[tab.ids[i]] = true
                                    links[link] = true
                                else
                                    if not links[link] then
                                        table.insert(self.containersSummary, {
                                            ItemIcon = icon,
                                            ItemID = tonumber(tab.ids[i]) or -1,
                                            ItemLink = link,
                                            Count = count,
                                            Location = guildName,
                                            DSK = guildKey,
                                        })
                                        links[link] = true
                                    else
                                        for k, v in ipairs(self.containersSummary) do
                                            if v.ItemID == tonumber(tab.ids[i]) and v.ItemLink == link and v.DSK == guildKey then
                                                v.Count = v.Count + count
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    --print(string.format("added %s rows to db", #self.containersSummary))
    if #self.containersSummary < 21 then
        alt.ui.containerSummary.scrollBar:SetMinMaxValues(1, 1)
    else
        alt.ui.containerSummary.scrollBar:SetMinMaxValues(1, #self.containersSummary - 19)
    end
    table.sort(self.containersSummary, function(a, b) return a.ItemID < b.ItemID end)
end


-- scan all player quests and populate the addon quest summary table
function alt:ParseQuests()
    if not ALT_ACC then
        return
    end
    if not ALT_ACC.quests then
        return
    end
    if not DataStore_QuestsDB then
        return
    end
    wipe(self.questsSummary)
    wipe(self.questsSummaryKeys)
    local quests = {}
    -- use our own db of characters for initial loop
    for k, char in pairs(ALT_ACC.characters) do

        -- grab the quest links from Datastore_QuestsDB
        local characterQuestLinks = DataStore_QuestsDB.global.Characters[k].QuestLinks
        
        -- loop through the quest links and extract the questID
        for _, link in pairs(characterQuestLinks) do
            local _, questString, _ = LinkUtil.ExtractLink(link)
            local questID, _ = strsplit(":", questString)
            questID = tonumber(questID)

            -- check if we have quest info in the db extension
            if ALT_ACC.quests[questID] then
                local header = ALT_ACC.quests[questID].Header;
                local title = ALT_ACC.quests[questID].Title;
                
                -- add to table zone>questID>characters
                if title and header then
                    if not quests[header] then
                        quests[header] = {}
                        self.questsSummaryKeys[#self.questsSummaryKeys + 1] = header;
                    end
                    if not quests[header][questID] then
                        quests[header][questID] = {}
                    end
                    if not quests[header][questID][char.Name] then
                        quests[header][questID][char.Name] = char.Realm
                        --print(string.format("added %s to quest %s in %s", char.Name, title, header))
                    end
                end
            end
        end
    end
    table.sort(self.questsSummaryKeys)
    for i = 1, #self.questsSummaryKeys do
        self.questsSummary[self.questsSummaryKeys[i]] = quests[self.questsSummaryKeys[i]]
    end
    if alt.ui.questSummary:IsVisible() then
        alt:HideQuestSummaryZoneButtons()
        alt:RefreshQuestSummaryZoneListview()
        for k, button in ipairs(alt.ui.questSummary.zoneButtons) do
            if button:IsVisible() and button.selected then
                AltasiaQuestSummaryZoneListview_OnSelectionChanged(button)
            end
        end
    end
end


--- scan all datastore saved variables for character data and populate the addon character summary table
--- @param realm string if passed will filter results using realm name
--- @param faction string if passed will filter results using faction name
function alt:ParseCharacters(realm, faction)
    if not ALT_ACC then
        return
    end
    if not DataStoreDB then
        return
    end
    wipe(self.charactersSummary)
    for dsk, char in pairs(ALT_ACC.characters) do
        local character = {}
        character.Realm = char.Realm;
        character.ilvl = 0;
        if IsAddOnLoaded('DataStore_Inventory') and DataStore_InventoryDB.global.Characters[dsk] then
            character.ilvl = tonumber(DataStore_InventoryDB.global.Characters[dsk].averageItemLvl)
        end
        if IsAddOnLoaded('DataStore_Characters') and DataStore_CharactersDB.global.Characters[dsk] then
            character.Name = DataStore_CharactersDB.global.Characters[dsk].name
            character.Race = DataStore_CharactersDB.global.Characters[dsk].englishRace
            character.Class = DataStore_CharactersDB.global.Characters[dsk].class
            if character.Class == "Death Knight" then
                character.Class = "DeathKnight";
            end
            local xp = (DataStore_CharactersDB.global.Characters[dsk].XP / DataStore_CharactersDB.global.Characters[dsk].XPMax) * 100
            character.XP = tonumber(string.format("%02d", math.ceil(xp)))
            --local restedXP = (DataStore_CharactersDB.global.Characters[dsk].RestXP / (((DataStore_CharactersDB.global.Characters[dsk].XPMax - DataStore_CharactersDB.global.Characters[dsk].XP) / 100) * 1.5))
            local restedXP = alt:GetRestXPRate(DataStore_CharactersDB.global.Characters[dsk])
            character.RestedXP = tonumber(string.format("%02d", math.ceil(restedXP)))
            character.Level = tonumber(DataStore_CharactersDB.global.Characters[dsk].level)
            character.Money = tonumber(DataStore_CharactersDB.global.Characters[dsk].money)
            character.Faction = DataStore_CharactersDB.global.Characters[dsk].faction
            if DataStore_CharactersDB.global.Characters[dsk].subZone == "" then
                character.Location = DataStore_CharactersDB.global.Characters[dsk].zone
            else
                character.Location = DataStore_CharactersDB.global.Characters[dsk].subZone
            end
            character.isRested = DataStore_CharactersDB.global.Characters[dsk].isResting
            if DataStore_CharactersDB.global.Characters[dsk].gender == 3 then
                character.Gender = "female"
            else
                character.Gender = "male"
            end
        end
        if IsAddOnLoaded('DataStore_Crafts') and DataStore_CraftsDB.global.Characters[dsk] then
            character.Prof1 = DataStore_CraftsDB.global.Characters[dsk].Prof1 or "-";
            character.Prof2 = DataStore_CraftsDB.global.Characters[dsk].Prof2 or "-";

            -- blizz spelt it wrong on the texture atlas so we need to rename
            if DataStore_CraftsDB.global.Characters[dsk].Prof1 == "Engineering" then
                character.Prof1 = "Enginnering"
            elseif DataStore_CraftsDB.global.Characters[dsk].Prof2 == "Engineering" then
                character.Prof2 = "Enginnering"
            end
        end

        if realm then
            if realm == character.Realm then
                if faction then
                    if character.Faction == faction then
                        table.insert(self.charactersSummary, character)
                    end
                else
                    table.insert(self.charactersSummary, character)
                end
            end
        else
            if faction then
                if character.Faction == faction then
                    table.insert(self.charactersSummary, character)
                end
            else
                table.insert(self.charactersSummary, character)
            end
        end
        --table.insert(self.charactersSummary, character)
    end
    table.sort(self.charactersSummary, function(a,b) return a.Name < b.Name end)
end


-- load the character listview 
function alt:LoadCharacterPortraits()
    if not ALT_ACC then
        return
    end
    local keys, characters = {}, {}
    if next(ALT_ACC.characters) then
        for dsk, info in pairs(ALT_ACC.characters) do
            keys[#keys + 1] = dsk
        end
    end
    table.sort(keys)
    local offsetY = 0;
    if next(ALT_ACC.characters) then
        for i = 1, #keys do
            local info = ALT_ACC.characters[keys[i]]
            local portrait = CreateFrame('FRAME', "Altasia"..info.Name..info.Realm, alt.ui.charactersListview:GetScrollChild(), "AltasiaCharacterListviewButton")
            portrait:SetPoint('TOP', 20, offsetY * -50)
            portrait:SetDataStoreKey(keys[i])
            portrait:SetName(info.Name)
            portrait:SetPortraitIcon(info.Portrait)
            portrait.contentFrameKey = "characterDetail"
            offsetY = offsetY + 1;
        end
    end
end


-- setup this character in the addon saved var file
function alt:RegisterCharacter()
    if not ALT_ACC then
        return
    end
    local guid = UnitGUID('player')
    if not THIS_CHARKEY then
        return
    end
    if not ALT_ACC.characters[THIS_CHARKEY] then
        if not self.PlayerMixin then
            self.PlayerMixin = PlayerLocation:CreateFromGUID(guid)
        else
            self.PlayerMixin:SetGUID(guid)
        end
        if self.PlayerMixin:IsValid() then
            local name = C_PlayerInfo.GetName(self.PlayerMixin)
            local _, class, _ = C_PlayerInfo.GetClass(self.PlayerMixin)
            local sex = C_PlayerInfo.GetSex(self.PlayerMixin)
            if sex == 0 then
                sex = 'male'
            else
                sex = 'female'
            end
            local raceID = C_PlayerInfo.GetRace(self.PlayerMixin)
            if not raceID then
                raceID = C_PlayerInfo.GetRace(self.PlayerMixin)
                print('no race id for', name)
            end
            local fullName, realm = UnitFullName("player")
            if raceID and realm then
                local race = C_CreatureInfo.GetRaceInfo(raceID).clientFileString:lower()
                if name and sex and race and class then
                    ALT_ACC.characters[THIS_CHARKEY] = {
                        Name = name,
                        Realm = realm,
                        Race = race,
                        Gender = sex,
                        Class = class,
                        Portrait = GetFileIDFromPath("interface/characterframe/temporaryportrait-"..sex.."-"..race),
                    }
                    self:PrintInfoMessage(string.format("%s has been registered succesfully!", name))
                end
            end
        end
    end
end


function alt:HideAllUIContentFrames()
    self.ui.characterDetail:Hide()
    self.ui.characterSummary:Hide()
    self.ui.questSummary:Hide()
    self.ui.containerSummary:Hide()
    self.ui.mailSummary:Hide()
end


function alt:Init()
    if not ALT_ACC then
        ALT_ACC = {
            ['characters'] = {},
            ['quests'] = {},
        }
    end
    if not ALT_CHAR then
        ALT_CHAR = {}
    end
    local ldb = LibStub("LibDataBroker-1.1")
    self.MinimapButton = ldb:NewDataObject('AltasiaMinimapIcon', {
        type = "data source",
        icon = 131031,
        OnClick = function(self, button)
            if button == "RightButton" then
                -- InterfaceOptionsFrame_OpenToCategory(QuestSyncName)
                -- InterfaceOptionsFrame_OpenToCategory(QuestSyncName)
            elseif button == 'LeftButton' then
                if AltasiaUI:IsVisible() then
                    AltasiaUI:Hide()
                else
                    AltasiaUI:Show()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine(tostring('|cffABD473Altasia'))
        end,
    })
    self.MinimapIcon = LibStub("LibDBIcon-1.0")
    if not ALT_CHAR.MinimapButton then ALT_CHAR.MinimapButton = {} end
    self.MinimapIcon:Register('QuestSyncMinimapIcon', self.MinimapButton, ALT_CHAR.MinimapButton)

    self:RegisterCharacter()

    self:LoadCharacterPortraits()

    self:LoadMainMenuButtons()

    self:HideAllUIContentFrames()
end



function alt:PLAYER_ENTERING_WORLD()
    self:Init()
    self.e:UnregisterEvent("PLAYER_ENTERING_WORLD")
end


-- clear ALT_ACC.quests saved var if no other character is on quest
function alt:QUEST_REMOVED(...)
    local questID = select(1, ...)
    if alt:IsQuestMultiCharacter(questID) == false then
        if ALT_ACC.quests[questID] then
            ALT_ACC.quests[questID] = nil;
        end
    end
    self:ParseQuests()
end


-- clear ALT_ACC.quests saved var if no other character is on quest
function alt:QUEST_TURNED_IN(...)
    local questID = select(1, ...)
    if alt:IsQuestMultiCharacter(questID) == false then
        if ALT_ACC.quests[questID] then
            ALT_ACC.quests[questID] = nil;
        end
    end
    self:ParseQuests()
end



-- this is a modified version of Thaokys mail scan function
-- the main difference is how we save the data
-- i am keeping all inbox items grouped as a single mail
-- CREDIT goes to Thaoky for the original script
function alt:MAIL_INBOX_UPDATE()
    C_Timer.After(1, function()
        if not ALT_ACC.characters[THIS_CHARKEY] then
            return
        end

        -- effectively wipe previous data
        -- we scan the inbox when we interact and overwrite any data with fresh data
        ALT_ACC.characters[THIS_CHARKEY].Mail = {}

        local item, icon, count, link, itemID
        local numItems = GetInboxNumItems()
        if numItems == 0 then
            return
        end
        
        for i = 1, numItems do
            local attachments = {}
            local _, stationaryIcon, mailSender, mailSubject, mailMoney, _, days, numAttachments, _, wasReturned = GetInboxHeaderInfo(i)
            if numAttachments then
                for attachmentIndex = 1, 12 do
                    item, itemID, icon, count = GetInboxItem(i, attachmentIndex)
                    link = GetInboxItemLink(i, attachmentIndex)
                    if item then
                        table.insert(attachments, {
                            ["icon"] = icon,
                            ["itemID"] = itemID,
                            ["count"] = count,
                            ["link"] = link,
                            lastCheck = time(),
                            returned = wasReturned,
                        })
                    end
                end
            end

            local inboxText = GetInboxText(i) and GetInboxText(i) or "No message";
    
            local mailIcon
            if mailMoney > 0 then
                mailIcon = ICON_COIN
            else
                mailIcon = stationaryIcon
            end
            ALT_ACC.characters[THIS_CHARKEY].Mail[i] = {
                icon = mailIcon,
                money = mailMoney,
                text = inboxText,
                subject = mailSubject,
                sender = mailSender,
                lastCheck = time(),
                daysLeft = days,
                returned = wasReturned,
                ["attachments"] = attachments,
            }            
        end
    end)
end

function alt:QUEST_ACCEPTED()
    --if IsAddOnLoaded("DataStore_Quests_Extra") then
        if not ALT_ACC.quests then
            ALT_ACC.quests = {} -- we can do this, its our addon!
        end
        local currentSelection = C_QuestLog.GetSelectedQuest()
        local zone = nil;
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            if info.isHeader then
                zone = info.title;
            end
            if info.isHeader == false then
                local Q = {}

                C_QuestLog.SetSelectedQuest(info.questID)
                -- local tag = C_QuestLog.GetQuestTagInfo(info.questID)
                local questDescription, questObjectives = GetQuestLogQuestText()

                --print(GetNumQuestLogChoices(info.questID, false))

                -- for j = 1, GetNumQuestLogRewards(info.questID) do
                --     local itemName, itemTexture, numItems, quality, isUsable, itemID, itemLevel = GetQuestLogRewardInfo(j, info.questID)
                --     local name, texture, numItems, quality, isUsable = GetQuestLogChoiceInfo(j)
                --     print(info.title)
                --     print(j, itemName, itemID)
                --     print(j, name)
                -- end

                Q.RewardChoices = {}
                for j = 1, GetNumQuestLogChoices(info.questID, false) do
                    local name, texture, numItems, quality, isUsable, itemID = GetQuestLogChoiceInfo(j, info.questID)
                    --print(itemID, name, texture, numItems, quality, isUsable)
                    table.insert(Q.RewardChoices, {
                        ItemID = itemID,
                        Texture = texture,
                        Name = name,
                    })
                end
                --local achievementID, storyMapID = C_QuestLog.GetZoneStoryInfo(uiMapID)

                Q.Title = info.title;
                Q.Description = questDescription;
                Q.Objectives = questObjectives;
                --Q.MapID = C_QuestLog.GetMapForQuestPOIs();
                --Q.MapName = C_Map.GetMapInfo(C_QuestLog.GetMapForQuestPOIs(info.questID)).name
                Q.Header = zone;
                Q.ObjectivesData = C_QuestLog.GetQuestObjectives(info.questID);
                Q.Difficulty = C_PlayerInfo.GetContentDifficultyQuestForPlayer(info.questID);

                if ALT_ACC.quests then
                    ALT_ACC.quests[info.questID] = Q
                end

                --print(string.format("added %s with mapName %s", Q.Title, Q.MapName))

            end
        end
        C_QuestLog.SetSelectedQuest(currentSelection)
    --end
    C_Timer.After(1, function() alt:ParseQuests() end)
end

alt.e = CreateFrame('FRAME')
alt.e:RegisterEvent('PLAYER_ENTERING_WORLD')

alt.e:RegisterEvent("QUEST_TURNED_IN")
alt.e:RegisterEvent("QUEST_REMOVED")
alt.e:RegisterEvent("QUEST_ACCEPTED")

alt.e:RegisterEvent("MAIL_INBOX_UPDATE")

alt.e:SetScript('OnEvent', function(self, event, ...)
    if alt[event] then
        alt[event](alt, ...)
    end
end)


local addonName, alt = ...


alt.PlayerMixin = nil
alt.charactersSummary = {}
alt.questsSummary = {}
alt.questsSummaryKeys = {}
alt.containersSummary = {}

-- borrowed this directly from DataStore, as we'll be accessing the saved var this key will used in our own saved var to keep things simple
local THIS_ACCOUNT = "Default"
local THIS_REALM = GetRealmName()
local THIS_CHAR = UnitName("player")
local THIS_CHARKEY = format("%s.%s.%s", THIS_ACCOUNT, THIS_REALM, THIS_CHAR)

function alt:PrintInfoMessage(msg)
    print("[|cff0070DDAltasia|r] "..msg)
end

function alt:MakeFrameMoveable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

function alt:NewCharacterListviewButton(name, parent, anchor, x, y)
    local f = CreateFrame('FRAME', name, parent, "AltasiaCharacterListviewButton")
    f:SetPoint(anchor, x, y)
    return f
end

--[[
    this was straight up copy/pasted from DataStore_Character, i couldnt find a way to just call it from here
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
            --if DataStore_QuestsDB_Extra[questID]
    end
end

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


function alt:ParseContainers()
    if not ALT_ACC then
        return
    end
    if not DataStore_ContainersDB then
        return
    end
    local ids, links = {}, {};
    wipe(self.containersSummary)
    for key, character in pairs(DataStore_ContainersDB.global.Characters) do
        --if string.find(key, "Kaaru") then
        for bag, info in pairs(character.Containers) do
            if info.links then
                for i = 1, #info.links do
                    if info.links[i] then
                        local _, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(info.links[i])
                        -- check to see if this item has been added using the ID
                        if not ids[info.ids[i]] then
                            table.insert(self.containersSummary, {
                                ItemIcon = icon,
                                ItemID = tonumber(info.ids[i]),
                                ItemLink = info.links[i],
                                Count = tonumber(info.counts[i]) or 1,
                                Character = ALT_ACC.characters[key].Name,
                                DSK = key,
                            })
                            ids[info.ids[i]] = true
                        else

                            -- if there is an ID match then check the item link as this can differ for stuff like gear etc
                            if not links[info.links[i]] then
                                table.insert(self.containersSummary, {
                                    ItemIcon = icon,
                                    ItemID = tonumber(info.ids[i]),
                                    ItemLink = info.links[i],
                                    Count = tonumber(info.counts[i]) or 1,
                                    Character = ALT_ACC.characters[key].Name,
                                    DSK = key,
                                })
                                links[info.ids[i]] = true

                            -- if the ID and the link match then its assumed to be the same so we just update the count for this character
                            else
                                for k, v in ipairs(self.containersSummary) do
                                    if v.ItemID == tonumber(info.ids[i]) and v.ItemLink == info.links[i] and v.DSK == key then
                                        v.Count = v.Count + tonumber(info.counts[i])
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        --end
    end
    --print(string.format("added %s rows to db", #self.containersSummary))
    if #self.containersSummary < 21 then
        alt.ui.containerSummary.scrollBar:SetMinMaxValues(1, 1)
    else
        alt.ui.containerSummary.scrollBar:SetMinMaxValues(1, #self.containersSummary - 19)
    end
    table.sort(self.containersSummary, function(a, b) return a.ItemID < b.ItemID end)
end


function alt:ParseQuests()
    if not ALT_ACC then
        return
    end
    if not DataStore_QuestsDB_Extra then
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
            if DataStore_QuestsDB_Extra[questID] then
                local header = DataStore_QuestsDB_Extra[questID].Header;
                local title = DataStore_QuestsDB_Extra[questID].Title;
                
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


function alt:ParseCharacters()
    if not ALT_ACC then
        return
    end
    if not DataStoreDB then
        return
    end
    wipe(self.charactersSummary)
    for k, char in pairs(ALT_ACC.characters) do
        local character = {}
        character.ilvl = 0;
        if IsAddOnLoaded('DataStore_Inventory') and DataStore_InventoryDB.global.Characters[k] then
            character.ilvl = tonumber(DataStore_InventoryDB.global.Characters[k].averageItemLvl)
        end
        if IsAddOnLoaded('DataStore_Characters') and DataStore_CharactersDB.global.Characters[k] then
            character.Name = DataStore_CharactersDB.global.Characters[k].name
            character.Race = DataStore_CharactersDB.global.Characters[k].englishRace
            character.Class = DataStore_CharactersDB.global.Characters[k].class
            if character.Class == "Death Knight" then
                character.Class = "DeathKnight";
            end
            local xp = (DataStore_CharactersDB.global.Characters[k].XP / DataStore_CharactersDB.global.Characters[k].XPMax) * 100
            character.XP = tonumber(string.format("%02d", math.ceil(xp)))
            --local restedXP = (DataStore_CharactersDB.global.Characters[k].RestXP / (((DataStore_CharactersDB.global.Characters[k].XPMax - DataStore_CharactersDB.global.Characters[k].XP) / 100) * 1.5))
            local restedXP = alt:GetRestXPRate(DataStore_CharactersDB.global.Characters[k])
            character.RestedXP = tonumber(string.format("%02d", math.ceil(restedXP)))
            character.Level = tonumber(DataStore_CharactersDB.global.Characters[k].level)
            character.Money = tonumber(DataStore_CharactersDB.global.Characters[k].money)
            character.Faction = DataStore_CharactersDB.global.Characters[k].faction
            if DataStore_CharactersDB.global.Characters[k].subZone == "" then
                character.Location = DataStore_CharactersDB.global.Characters[k].zone
            else
                character.Location = DataStore_CharactersDB.global.Characters[k].subZone
            end
            character.isRested = DataStore_CharactersDB.global.Characters[k].isResting
            if DataStore_CharactersDB.global.Characters[k].gender == 3 then
                character.Gender = "female"
            else
                character.Gender = "male"
            end
        end
        if IsAddOnLoaded('DataStore_Crafts') and DataStore_CraftsDB.global.Characters[k] then
            character.Prof1 = DataStore_CraftsDB.global.Characters[k].Prof1 or "-";
            character.Prof2 = DataStore_CraftsDB.global.Characters[k].Prof2 or "-";

            -- blizz spelt it wrong on the texture atlas so we need to rename
            if DataStore_CraftsDB.global.Characters[k].Prof1 == "Engineering" then
                character.Prof1 = "Enginnering"
            elseif DataStore_CraftsDB.global.Characters[k].Prof2 == "Engineering" then
                character.Prof2 = "Enginnering"
            end
        end

        table.insert(self.charactersSummary, character)
    end
    table.sort(self.charactersSummary, function(a,b) return a.Name < b.Name end)
end

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
            --local portrait = self:NewCharacterListviewButton("Altasia"..info.Name..info.Realm, alt.ui.charactersListview:GetScrollChild(), 'TOP', 20, offsetY * -50)
            portrait:SetDataStoreKey(keys[i])
            portrait:SetName(info.Name)
            portrait:SetPortraitIcon(info.Portrait)
            portrait.contentFrameKey = "characterDetail"
            offsetY = offsetY + 1;
        end
    end
end

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


function alt:Init()
    if not ALT_ACC then
        ALT_ACC = {
            ['characters'] = {}
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


-- clear DataStore_QuestsDB_Extra saved var if no other character is on quest
function alt:QUEST_REMOVED(...)
    local questID = select(1, ...)
    -- print(string.format("turn in quest %s", questID))
    -- print(alt:IsQuestMultiCharacter(questID))
    if alt:IsQuestMultiCharacter(questID) == false then
        if DataStore_QuestsDB_Extra[questID] then
            DataStore_QuestsDB_Extra[questID] = nil;
            -- print(string.format("deleted quest %s", questID))
        end
    end
    self:ParseQuests()
end


-- clear DataStore_QuestsDB_Extra saved var if no other character is on quest
function alt:QUEST_TURNED_IN(...)
    local questID = select(1, ...)
    -- print(string.format("turn in quest %s", questID))
    -- print(alt:IsQuestMultiCharacter(questID))
    if alt:IsQuestMultiCharacter(questID) == false then
        if DataStore_QuestsDB_Extra[questID] then
            DataStore_QuestsDB_Extra[questID] = nil;
            -- print(string.format("deleted quest %s", questID))
        end
    end
    self:ParseQuests()
end

function alt:QUEST_ACCEPTED()
    C_Timer.After(1, function() alt:ParseQuests() end)
end

alt.e = CreateFrame('FRAME')
alt.e:RegisterEvent('PLAYER_ENTERING_WORLD')
alt.e:RegisterEvent("QUEST_TURNED_IN")
alt.e:RegisterEvent("QUEST_REMOVED")
alt.e:RegisterEvent("QUEST_ACCEPTED")

alt.e:SetScript('OnEvent', function(self, event, ...)
    if alt[event] then
        alt[event](alt, ...)
    end
end)


local addonName, TbdAltManager = ...;


local db = TbdAltManager.Database;
local L = TbdAltManager.locales;

local GridView = TbdAltManager.gridview;

local itemGlowAtlas = {
    [1] = "bags-glow-white",
    [2] = "bags-glow-green",
    [3] = "bags-glow-blue",
    [4] = "bags-glow-purple",
    [5] = "bags-glow-orange",
    [6] = "bags-glow-artifact",
    [7] = "bags-glow-heirloom",
}
local function getItemGlowAtlas(quality)
    if itemGlowAtlas[quality] then
        return itemGlowAtlas[quality];
    end
    return false;
end




TbdAltManagerMixin = {

    -- refreshElapsed = 0.0,
    -- refreshElapsedMax = 0.01,
    isRefreshEnabled = false,

    isFullScreen = false,
    isMenuOpen = false,

    -- minWidthForSideBar = 900.0,
    minSideBarWidth = 40.0,
    maxSideBarWidth = 200.0,

    character = nil,

    modules = {},
}



--[[

    OnUpdate:
        the OnUpdate function

]]
function TbdAltManagerMixin:OnUpdate(elapsed)

    if not self:IsVisible() then
        return;
    end

    local framerate = GetFramerate();
    self.topBar.statusText:SetFormattedText("%.1f", framerate);

    if self.isRefreshEnabled == false then
        return;
    end

    self:UpdateLayout()

    -- self.refreshElapsed = self.refreshElapsed + elapsed;
    -- if self.refreshElapsed > self.refreshElapsedMax then
    --     self:UpdateLayout() 
    --     self.refreshElapsed = 0.0;
    -- end

end

--[[

    UpdateLayout:
        update the ui layout

]]
function TbdAltManagerMixin:UpdateLayout()
    for k, module in pairs(self.modules) do
        if module.frame.UpdateLayout then
            module.frame:UpdateLayout()
        end
    end
end


--[[

    UpdateSideBar:
        set the sideBar width and background depending on the isOpen state

]]
---@param isOpen boolean should the sideBar be set to max width
function TbdAltManagerMixin:UpdateSideBar(isOpen)
    if isOpen then
        self.sideBar:SetWidth(self.maxSideBarWidth)
        --self.sideBar.background:SetAtlas(string.format("transmog-background-race-%s", self.character.race:lower()))

    else
        self.sideBar:SetWidth(self.minSideBarWidth)
        --self.sideBar.background:SetAtlas("auctionhouse-background-buy-commodities-market")
    end
end


--[[

    HideAllModuleFrames:
        loops the content frame array 'views' to hide any views
]]
function TbdAltManagerMixin:HideAllModuleFrames()
    for k, module in pairs(self.modules) do
        module.frame:Hide()
    end
end


--[[

    OnLoad:
        the OnLoad function

]]
function TbdAltManagerMixin:OnLoad()

    SLASH_TbdAltManager1 = '/TbdAltManager'
    SLASH_TbdAltManager2 = '/altas'
    SlashCmdList['TbdAltManager'] = function(msg)
        self:Show()
    end

    self:RegisterForDrag("LeftButton")
    self.resize:Init(self, 1000, 600)

    self.resize:HookScript("OnMouseDown", function()
        self.isRefreshEnabled = true;
    end)
    self.resize:HookScript("OnMouseUp", function()
        self.isRefreshEnabled = false;
        self:UpdateLayout()
    end)

    self.sideBar.background:SetAtlas("CraftingOrders-Categories-Background") -- QuestLog-empty-quest-background") --characterupdate_background UI-Frame-Oribos-CardShadowSmall CraftingOrders-Categories-Background
    self.content.background:SetAtlas("ClassHall_InfoBoxMission-BackgroundTile")

    self.topBar.title:SetText(addonName)
    self:UpdateSideBar(true)

    self.maximize:SetScript("OnClick", function()
        self.isFullScreen = not self.isFullScreen;

        if self.isFullScreen == true then
            self.maximize:SetNormalAtlas("RedButton-Condense")
            self.maximize:SetPushedAtlas("RedButton-Condense-Pressed")

            self.condensedWidth = self:GetWidth()
            self.condensedHeight = self:GetHeight()

            self:SetAllPoints()
        else
            self.maximize:SetNormalAtlas("RedButton-Expand")
            self.maximize:SetPushedAtlas("RedButton-Expand-Pressed")

            self:ClearAllPoints()
            self:SetPoint("CENTER")
            self:SetSize(self.condensedWidth, self.condensedHeight)
        end

        self:UpdateLayout()
    end)
    self.minimize:SetScript("OnClick", function()
        self:ClearAllPoints()
        self:SetPoint("TOP", UIParent, "BOTTOM", 0, 24)
    end)

    --self.menu:GetNormalTexture():SetRotation(-1.57)

    self.menu:SetScript("OnClick", function()
        self.isMenuOpen = not self.isMenuOpen;
        if self.isMenuOpen then
            self:UpdateSideBar(true)
        else
            self:UpdateSideBar(false)
        end
        self:UpdateLayout()
    end)

    self.content.settings.resetSavedVariables:SetScript("OnClick", function()
        db:ResetSavedVariables()
    end)

    TbdAltManager.CallbackRegistry:RegisterCallback(TbdAltManager.Callbacks.Database_OnInitialised, self.Database_OnInitialised, self)
    TbdAltManager.CallbackRegistry:RegisterCallback(TbdAltManager.Callbacks.Database_OnCharacterRegistered, self.Database_OnCharacterRegistered, self)

    TbdAltManager.CallbackRegistry:RegisterCallback(TbdAltManager.Callbacks.Addon_OnLoaded, self.Addon_OnLoaded, self)

    TbdAltManager.CallbackRegistry:RegisterCallback(TbdAltManager.Callbacks.InboxListviewItem_OnMouseDown, self.InboxListviewItem_OnMouseDown, self)

    TbdAltManager.CallbackRegistry:RegisterCallback(TbdAltManager.Callbacks.SummaryGridViewItem_OnMouseDown, self.ContentSummaryGridViewItem_OnMouseDown, self)

    TbdAltManager.CallbackRegistry:RegisterCallback(TbdAltManager.Callbacks.Module_OnSelected, self.Module_OnSelected, self)


end


function TbdAltManagerMixin:Module_OnSelected(moduleName)
    
    self:HideAllModuleFrames()

    -- print(moduleName)
    -- DevTools_Dump(self.modules)

    self.modules[moduleName].frame:Show()
end


function TbdAltManagerMixin:Addon_OnLoaded(...)

    local addonName = ...;
    if type(addonName) == "string" and addonName:find("TbdAltManager_", nil, true) then
        local _, module = strsplit("_", addonName)

        if TbdAltManager.Constants.Modules[module] then
            local menuNode = self.sideBar.listview.DataProvider:Insert(TbdAltManager.Constants.Modules[module].sideMenu)

            local frame = CreateFrame("Frame", string.format("TbdAltManagerModuleFrame_%s", module), self.content, TbdAltManager.Constants.Modules[module].frameTemplate)
            frame:SetAllPoints()
            frame:Hide()

            --assign the menu node so each module can manage its own sub menu categories
            frame.sideMenuNode = menuNode;

            self.modules[module] = {
                frame = frame,
            }
        end
    end

end

function TbdAltManagerMixin:UpdateSessionTooltip()
    GameTooltip:SetOwner(self.minimapButton, 'ANCHOR_BOTTOMLEFT')
    GameTooltip:AddLine("Session info")
    GameTooltip:AddLine(" ")

    local sesionTimeInSeconds;

    if TbdAltManager.sessionInfo and TbdAltManager.sessionInfo.initialLoginTime then
        GameTooltip:AddDoubleLine("Play time", date("%H:%M:%S", time() - TbdAltManager.sessionInfo.initialLoginTime))
        GameTooltip:AddLine(" ")
        sesionTimeInSeconds = time() - TbdAltManager.sessionInfo.initialLoginTime;
    end

    GameTooltip:AddDoubleLine("|cff76D65BCredits|r", string.format("|cffffffff%s", GetCoinTextureString(TbdAltManager.sessionInfo.credits)))
    GameTooltip:AddDoubleLine("|cffF6685EDebits|r", string.format("|cffffffff%s", GetCoinTextureString(TbdAltManager.sessionInfo.debits)))

    local profit = GetMoney() - (db:GetCharacterInfo(TbdAltManager.characterKey, "initialLoginGold") or 0)
    local profitDisplay = profit;
    if profit > 0 then
        profitDisplay = string.format("|cff76D65B%s", GetCoinTextureString(profit));
    elseif profit == 0 then
        profitDisplay = string.format("|cffFffffff%s", GetCoinTextureString(profit));
    else
        profitDisplay = string.format("|cffF6685E-%s", GetCoinTextureString(profit*-1));
    end
    GameTooltip:AddDoubleLine("|cffffffffBalance|r", profitDisplay)
    if type(sesionTimeInSeconds) == "number" then
        local gph = tonumber(profit) / (((sesionTimeInSeconds) / 60) / 60);
        if gph < 0 then
            gph = gph * -1;
        end
        GameTooltip:AddDoubleLine("|cffffffffGold / hour|r", GetCoinTextureString(gph))
        GameTooltip:AddLine(" ")
    else
        GameTooltip:AddLine(" ")
    end

    local questsTurnedIn = 0;
    local questXp = 0;
    if TbdAltManager.sessionInfo.questsCompleted then
        questsTurnedIn = #TbdAltManager.sessionInfo.questsCompleted or 0;
        questXp = 0;
        for k, quest in ipairs(TbdAltManager.sessionInfo.questsCompleted) do
            questXp = questXp + (quest.xpReward or 0);
        end
    end

    GameTooltip:AddDoubleLine("|cff5979B9Quests turned in:", questsTurnedIn)
    GameTooltip:AddDoubleLine("|cff5979B9Quest XP:", questXp)
    GameTooltip:AddLine(" ")

    GameTooltip:AddDoubleLine("|cffffffffMobs killed:", TbdAltManager.sessionInfo.mobsKilled)
    GameTooltip:AddDoubleLine("|cffffffffMob XP:", TbdAltManager.sessionInfo.mobXpReward)
    GameTooltip:AddLine(" ")

    if TbdAltManager.sessionInfo.reputations and next(TbdAltManager.sessionInfo.reputations) then
        GameTooltip:AddLine("Reputation gains:")
        for faction, gain in pairs(TbdAltManager.sessionInfo.reputations) do
            GameTooltip:AddDoubleLine(string.format("|cffffffff%s|r", faction), gain)
        end
    end
    GameTooltip:Show()
end

function TbdAltManagerMixin:Database_OnInitialised()

    -- self:ContentSummaryView_Init()
    -- self:ContentContainerView_Init()

    Menu.ModifyMenu("MENU_UNIT_SELF", function(owner, rootDescription, contextData)
        rootDescription:CreateDivider();
        rootDescription:CreateTitle(addonName);
        rootDescription:CreateButton("Open", function() self:Show() end);
    end);
end

--[[

    Database_OnCharacterRegistered:
        this event is fired after the player has been added to the db

]]
function TbdAltManagerMixin:Database_OnCharacterRegistered()

    self.character = db:GetCharacter(TbdAltManager.characterKey)

end


--[[

    ContentSummaryView_Init:
        setup the content.summary ui

]]
function TbdAltManagerMixin:ContentSummaryView_Init()

    self.allCharacters = {}
    self.filteredCharacters = {}

    if DataStore_CharactersDB then
        for characterKey, info in pairs(DataStore_CharactersDB.global.Characters) do
            local account, realm, name = strsplit(".", characterKey)
            local t = {
                characterKey = characterKey,
                account = account,
                realm = realm,
                name = name,

            }
            for k, v in pairs(info) do
                t[k] = v;
            end

            

            -- local specInfo = db:GetCharacterInfo(characterKey, "specialization")
            -- if specInfo then
            --     print("got spec for", characterKey)
            --     t.activeSpecName = specInfo.name
            --     t.activeSpecRole = specInfo.role
            -- end

            if DataStore_TalentsDB then
                if DataStore_TalentsDB.global.Characters[characterKey] then
                    local spec = DataStore_TalentsDB.global.Characters[characterKey]
                    t.activeSpecName = spec.activeSpecName;
                    t.activeSpecRole = spec.activeSpecRole;
                end
            end

            if DataStore_InventoryDB then
                if DataStore_InventoryDB.global.Characters[characterKey] then
                    local inv = DataStore_InventoryDB.global.Characters[characterKey]
                    t.ilvl = inv.averageItemLvl
                end
            end
            table.insert(self.allCharacters, t)
        end
    end

    table.sort(self.allCharacters, function(a, b)
        if type(a.name) == "string" and type(b.name) == "string" then
            return a.name < b.name;
        end
    end)
    
    local panel = self.content.summary;
    panel.gridviewItems = {}

    panel.accountDropDown:SetParent(panel.gridview)
    panel.factionDropDown:SetParent(panel.gridview)
    panel.sortDropDown:SetParent(panel.gridview)

    local function filterAccount(account)

    end
    local accountMenu = {
        {
            text = "Default",
            func = function()

            end,
        },
    }
    panel.accountDropDown:SetMenu(accountMenu)

    local function filterFaction(faction)
        self.filteredCharacters = {}
        if faction == nil then
            self:ContentSummaryView_OnGridviewDataChanged(self.allCharacters)
            return
        end
        for k, character in ipairs(self.allCharacters) do
            if character.faction == faction then
                table.insert(self.filteredCharacters, character)
            end
        end
        self:ContentSummaryView_OnGridviewDataChanged(self.filteredCharacters)
    end
    local factionMenu = {
        {
            text = "Both",
            func = function()
                filterFaction(nil)
            end,
        },
        {
            text = "Alliance",
            func = function()
                filterFaction("Alliance")
            end,
        },
        {
            text = "Horde",
            func = function()
                filterFaction("Horde")
            end,
        },
    }
    panel.factionDropDown:SetMenu(factionMenu)

    local function sortCharacters(sort, desc)
        local characters = (#self.filteredCharacters > 0) and self.filteredCharacters or self.allCharacters
        table.sort(characters, function(a, b)
            if desc then
                return a[sort] > b[sort];
            else
                return a[sort] < b[sort];
            end
        end)
        self:ContentSummaryView_OnGridviewDataChanged(characters)
    end

    local sortMenu = {
        {
            text = "Name",
            func = function()
                sortCharacters("name")
            end,
        },
        {
            text = "Level",
            func = function()
                sortCharacters("level", true)
            end,
        },
    }
    panel.sortDropDown:SetMenu(sortMenu)

    panel.details.tab1:SetText(L.CONTENT_SUMMARY_CHARACTER_DETAILS_TAB_GENERAL)
    panel.details.tab2:SetText(L.CONTENT_SUMMARY_CHARACTER_DETAILS_TAB_INVENTORY)
    panel.details.tab3:SetText(L.CONTENT_SUMMARY_CHARACTER_DETAILS_TAB_REPUTATIONS)

    local numTabs = 3;
    for i = 1, numTabs do
        panel.details["tab"..i]:SetScript("OnClick", function()
            self:ContentSummaryDetails_OnTabSelected(i)
        end)
    end

    PanelTemplates_SetNumTabs(panel.details, numTabs);
    PanelTemplates_SetTab(panel.details, 1);

    panel.gv = GridView:New(panel.gridview.scrollChild, "TbdAltManagerContentSummaryGridViewItemTemplate")
    panel.gv:SetMinMaxWidths(175, 250)
    panel.gv:InsertTable(self.allCharacters)
    --panel.gv:UpdateLayout()

end



function TbdAltManagerMixin:ContentSummaryView_OnGridviewDataChanged(data)
    self.content.summary.gv:Flush()
    self.content.summary.gv:InsertTable(data)
    self.content.summary.gv:UpdateLayout()
end


function TbdAltManagerMixin:ContentSummaryView_HideDetailsViews()
    for k, frame in ipairs(self.content.summary.details.views) do
        frame:Hide()
    end
end

--[[

    ContentSummaryView_Show:
        

]]
function TbdAltManagerMixin:ContentSummaryView_Show()

    self.content.summary:Show()
    self.content.summary.gridview:Show()

    local width = self.content.summary.gridview:GetWidth();
    local height = self.content.summary.gridview:GetHeight()
    self.content.summary.gridview.scrollChild:SetSize(width, height)

    self:UpdateLayout()
end


function TbdAltManagerMixin:ContentSummaryGridViewItem_OnMouseDown(character)

    self.content.summary.details:Show()

    if character.activeSpecName then
        local specNameNoSpaces = character.activeSpecName:gsub(" ", ""):lower()
        self.content.background:SetAtlas(string.format("talents-background-%s-%s",character.englishClass:lower(), specNameNoSpaces))
    end

    local t = {}
    for k, v in pairs(character) do
        table.insert(t, {
            label = tostring(k),
            text = tostring(v),
        })
    end
    table.sort(t, function(a, b)
        return a.label < b.label;
    end)

    self.content.summary.details.listview.DataProvider:Flush()
    self.content.summary.details.listview.DataProvider:InsertTable(t)

    self:ContentSummaryDetailsGeneralTab_LoadCharacter(character.characterKey)




    self:UpdateLayout()
end



function TbdAltManagerMixin:ContentSummaryDetailsGeneralTab_LoadCharacter(characterKey)

    local tab = self.content.summary.details.general;

    if DataStore_CharactersDB and DataStore_CharactersDB.global and DataStore_CharactersDB.global.Characters then
        local character = DataStore_CharactersDB.global.Characters[characterKey]
        if type(character) == "table" then
        
            tab.name:SetText(character.name)
            tab.level:SetText(L.LEVEL_S:format(character.level))
            
            local gender = character.gender == 2 and "male" or "female"
            local ra = CreateAtlasMarkup(string.format("raceicon128-%s-%s", character.englishRace:lower(), gender), 18, 18)
            tab.race:SetText(string.format("%s %s", ra, character.race))
            
            local ca = CreateAtlasMarkup(string.format("GarrMission_ClassIcon-%s", character.englishClass), 18, 18)
            tab.class:SetText(string.format("%s %s",ca, character.class))
            
            tab.bindLocation:SetText(string.format("%s %s", CreateAtlasMarkup("Innkeeper", 18, 18), character.bindLocation))
            tab.playedThisLevel:SetText(L.TIME_PLAYED_LEVEL_S:format(SecondsToTime(character.playedThisLevel)))

            tab.money:SetText(L.MONEY:format(GetMoneyString(character.money, true)))

            local xp = (character.XP / character.XPMax)
            tab.experienceBar:SetValue(xp)
            tab.experienceBar.text:SetText(string.format("%f %%", (xp*100)))

        end
    end

    if DataStore_ContainersDB and DataStore_ContainersDB.global and DataStore_ContainersDB.global.Characters then
        local character = DataStore_ContainersDB.global.Characters[characterKey]
        if type(character) == "table" then

            local usedBagsSlots = (character.numBagSlots or 0) - (character.numFreeBagSlots or 0)
            local usedBankSlots = (character.numBankSlots or 0) - (character.numFreeBankSlots or 0)

            tab.bagSpace:SetText(L.BAG_SPACE_SSS:format(
                usedBagsSlots,
                (character.numBagSlots or 0),
                (character.numFreeBagSlots or 0)
            ))
            tab.bankSpace:SetText(L.BANK_SPACE_SSS:format(
                usedBankSlots,
                (character.numBankSlots or 0),
                (character.numFreeBankSlots or 0)
            ))
        end
    end

    --PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN)
    --PlaySound(SOUNDKIT.IG_QUEST_LIST_SELECT)
    --PlaySound(SOUNDKIT.ACHIEVEMENT_MENU_OPEN)
    PlaySound(SOUNDKIT.UI_72_BUILDING_CONTRIBUTION_TABLE_OPEN)
end


function TbdAltManagerMixin:ContentSummaryDetails_OnTabSelected(tabID)

    PlaySound(SOUNDKIT.IG_QUEST_LIST_SELECT)

    self:ContentSummaryView_HideDetailsViews()

    if tabID == 1 then
        PanelTemplates_SetTab(self.content.summary.details, tabID);

        self.content.summary.details.general:Show()

    elseif tabID == 2 then
        PanelTemplates_SetTab(self.content.summary.details, tabID);

        self.content.summary.details.inventory:Show()

    elseif tabID == 3 then
        PanelTemplates_SetTab(self.content.summary.details, tabID);

        self.content.summary.details.listview:Show()

    end

end



--[[

    ContentContainerView_Init:
        

]]
function TbdAltManagerMixin:ContentContainerView_Init()

    local panel = self.content.containers;
    
    self.containerItemsSlots = {}
    self.filteredContainerItems = {}
    self.allContainerItems = {}

    panel.bagsListview.scrollChild:SetSize(panel:GetWidth(), panel:GetHeight())

    panel.search:SetScript("OnTextChanged", function(eb)
        local text = eb:GetText()
        if text and #text > 2 then
            local t = {}
            local items = (#self.filteredContainerItems > 0 and self.filteredContainerItems or self.allContainerItems)
            for k, item in ipairs(items) do
                if item.link:lower():find(text:lower()) then
                    table.insert(t, item)
                end
            end
            self.filteredContainerItems = t;
        end
        self:ContentContainerView_OnContainerItemsChanged(self.filteredContainerItems)
    end)

    local itemClassMenu = {
        {
            text = L.CONTENT_CONTAINERS_ITEM_CLASS_DROPDOWN_ALL,
            func = function()
                self.filteredContainerItems = {}
                for k, v in ipairs(self.allContainerItems) do
                    table.insert(self.filteredContainerItems, v)
                end
                self:ContentContainerView_OnContainerItemsChanged(self.filteredContainerItems)
            end,
        }
    }
    for i = 0, 18 do
        local name = GetItemClassInfo(i)
        if type(name) == "string" then
            table.insert(itemClassMenu, {
                text = name,
                func = function()
                    self:ContentContainerView_OnItemClassChanged(i)
                end
            })
        end
    end
    panel.itemClassDropDown:SetMenu(itemClassMenu)

    panel.gv = GridView:New(panel.bagsListview.scrollChild, "TbdAltManagerContentContainerBagListviewitemSlotTemplate")
    panel.gv:SetMinMaxWidths(40, 50)
    panel.gv:InsertTable(self.allContainerItems)
    --panel.gv:UpdateLayout()

end

--[[

    ContentContainerView_OnContainerItemsChanged:
        

]]
function TbdAltManagerMixin:ContentContainerView_OnContainerItemsChanged(t)

    if type(t) ~= "table" then
        return
    end

    if #t == 0 then
        return;
    end

    self.content.containers.gv:Flush()
    self.content.containers.gv:InsertTable(t)
    self:UpdateLayout()

    PlaySound(SOUNDKIT.UI_BAG_SORTING_01)

end

--[[

    ContentContainerView_OnCharacterChanged:
        

]]
function TbdAltManagerMixin:ContentContainerView_OnItemClassChanged(classID)

    local t = {};
    local items = (#self.filteredContainerItems > 0 and self.filteredContainerItems or self.allContainerItems)
    for k, item in ipairs(items) do
        if item.classID == classID then
            table.insert(t, item)
        end
    end
    self.filteredContainerItems = t;
    self:ContentContainerView_OnContainerItemsChanged(self.filteredContainerItems)
end

--[[

    ContentContainerView_OnCharacterChanged:
        

]]
function TbdAltManagerMixin:ContentContainerView_OnCharacterChanged(characterKey)

    local containers;

    if DataStore_ContainersDB then
        if DataStore_ContainersDB.global.Characters[characterKey] then
            containers = DataStore_ContainersDB.global.Characters[characterKey];
        end
    end

    if type(containers) == "table" then

        self.filteredContainerItems = {}
        for bagKey, info in pairs(containers.Containers) do
            for k, v in ipairs(info.links) do
                local count = (info.counts[k] ~= nil) and info.counts[k] or 1;
                local id = (info.ids[k] ~= nil) and info.ids[k] or false;
                local _, _, _, _, icon, classID, subClassID = GetItemInfoInstant(v)
                table.insert(self.filteredContainerItems, {
                    link = v,
                    count = count,
                    icon = icon,
                    classID = classID,
                    subClassID = subClassID,
                    itemID = id,
                })
            end
        end

        table.sort(self.filteredContainerItems, function(a, b)
            if a.classID == b.classID then
                if a.subClassID == b.subClassID then
                    return a.link < b.link
                else
                    return a.subClassID < b.subClassID
                end
            else
                return a.classID < b.classID
            end
        end)

        self:ContentContainerView_OnContainerItemsChanged(self.filteredContainerItems)

    end
end

--[[

    ContentContainerView_Show:
        keeping this script in the OnShow call as it'll mean the data and ui are always up to date as bag contents change during game play

]]
function TbdAltManagerMixin:ContentContainerView_Show()

    PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)

    self.content.containers:Show()

    self.allContainerItems = {}
    local itemIDs = {}
    local characterDropDowMenu = {
        {
            text = L.CONTENT_CONTAINERS_CHARACTER_DROPDOWN_ALL,
            func = function()
                self.filteredContainerItems = {}
                for k, v in ipairs(self.allContainerItems) do
                    table.insert(self.filteredContainerItems, v)
                end
                self:ContentContainerView_OnContainerItemsChanged(self.filteredContainerItems)
            end,
        },
    }
    if DataStore_ContainersDB then
        TbdAltManager.containerItemTotalCounts = {}
        for characterKey, info in pairs(DataStore_ContainersDB.global.Characters) do

            table.insert(characterDropDowMenu, {
                text = characterKey,
                func = function()
                    self:ContentContainerView_OnCharacterChanged(characterKey)
                end,
            })

            if type(DataStore_ContainersDB.global.Characters[characterKey].Containers) == "table" then

                for bagKey, info in pairs(DataStore_ContainersDB.global.Characters[characterKey].Containers) do
                    if type(info.links) == "table" and type(info.counts) == "table" then
                        for k, v in ipairs(info.links) do
                            local count = (info.counts[k] ~= nil) and info.counts[k] or 1;
                            local id = (info.ids[k] ~= nil) and info.ids[k] or false;
                            local _, _, _, _, icon, classID, subClassID = GetItemInfoInstant(v)

                            --need to use links for gear
                            if classID == 2 or classID == 4 then
                                table.insert(self.allContainerItems, {
                                    link = v,
                                    count = count,
                                    icon = icon,
                                    classID = classID,
                                    subClassID = subClassID,
                                    owner = characterKey,
                                    itemID = id,
                                })
                            else

                                if not itemIDs[id] then
                                    itemIDs[id] = {
                                        link = v,
                                        count = count,
                                        icon = icon,
                                        classID = classID,
                                        subClassID = subClassID,
                                        owner = characterKey,
                                        itemID = id,
                                    }
                                else
                                    itemIDs[id].count = itemIDs[id].count + count;
                                end
                            end
                        end
                    end
                end        
            end
        end
        for itemID, item in pairs(itemIDs) do
            table.insert(self.allContainerItems, item)
        end
        table.sort(self.allContainerItems, function(a, b)
            if a.classID == b.classID then
                if a.subClassID == b.subClassID then
                    return a.link < b.link
                else
                    return a.subClassID < b.subClassID
                end
            else
                return a.classID < b.classID
            end
        end)

        self:ContentContainerView_OnContainerItemsChanged(self.allContainerItems)
    end

    self.content.containers.characterDropDown:SetMenu(characterDropDowMenu)
end




--[[

    ContentMailsView_Show:

]]
function TbdAltManagerMixin:ContentMailsView_Show()

    self.content.mail.inboxListview.DataProvider:Flush()

    self.content.mail:Show()

    self.allMails = {}
    self.filteredMail = {}

    local characterDropDowMenu = {
        {
            text = L.CONTENT_CONTAINERS_CHARACTER_DROPDOWN_ALL,
            func = function()

            end,
        },
    }

    if DataStore_MailsDB then
        local mailIDs = {}
        for characterKey, info in pairs(DataStore_MailsDB.global.Characters) do
            if type(info.Mails) == "table" then

                table.insert(characterDropDowMenu, {
                    text = characterKey,
                    func = function()

                    end,
                })
                
                for k, mail in ipairs(info.Mails) do
                    local sender = mail.sender or "Unknown";
                    local mailID = string.format("%s-%s", sender, mail.daysLeft)

                    if not mailIDs[mailID] then
                        mailIDs[mailID] = {
                            sender = sender,
                            daysLeft = mail.daysLeft,
                            subject = "",
                            text = "",
                            attachments = {},
                        }
                    end
                    if mail.money then
                        mailIDs[mailID].money = mail.money;
                    end
                    if mail.subject then
                        mailIDs[mailID].subject = mail.subject;
                    end
                    if mail.text then
                        mailIDs[mailID].text = mail.text;
                    end
                    if mail.itemID and mail.link and mail.icon then
                        table.insert( mailIDs[mailID].attachments, {
                            itemID = mail.itemID,
                            link = mail.link,
                            icon = mail.icon,
                        })
                    end


                end
            end
        end
        for k, mail in pairs(mailIDs) do
            table.insert(self.allMails, mail)
        end
        mailIDs = nil;
        table.sort(self.allMails, function(a, b)
            return a.daysLeft > b.daysLeft;
        end)
        self.content.mail.inboxListview.DataProvider:InsertTable(self.allMails)
    end

    self.content.mail.characterDropDown:SetMenu(characterDropDowMenu)
end


function TbdAltManagerMixin:InboxListviewItem_OnMouseDown(mail)
    
    if type(mail) == "table" then
        
        local panel = self.content.mail.mailDetails;
        panel:Show()

        panel.sender:SetText(mail.sender)
        panel.subject:SetText(mail.subject)
        panel.text:SetText(mail.text)
    end

    self:UpdateLayout()
end




local name, TbdAltManager = ...;



local standingColours = {
    [1] = CreateColorFromHexString("ffcc0000"),
    [2] = CreateColorFromHexString("ffff0000"),
    [3] = CreateColorFromHexString("fff26000"),
    [4] = CreateColorFromHexString("ffe4e400"),
    [5] = CreateColorFromHexString("ff33ff33"),
    [6] = CreateColorFromHexString("ff5fe65d"),
    [7] = CreateColorFromHexString("ff53e9bc"),
    [8] = CreateColorFromHexString("ff2ee6e6"),
}


local DialResetFunc = function(_, dial)
    dial:SetValue(1,1)
    dial:ClearAllPoints()
    dial:Hide()
    dial.factionID = nil
end


TbdAltManagerReputationListviewItemMixin = {}

function TbdAltManagerReputationListviewItemMixin:OnLoad()
    self.statusDials = CreateFramePool("Frame", self, "TbdAltManagerReputationDialTemplate", DialResetFunc)
    TbdAltManager_Reputations.CallbackRegistry:RegisterCallback("Character_OnChanged", self.Character_OnChanged, self)
end

function TbdAltManagerReputationListviewItemMixin:SetDataBinding(binding, height)
    self:SetHeight(height)
    self:LoadReputations(binding.characterUID, binding.reps, binding.headerID)
end

function TbdAltManagerReputationListviewItemMixin:Character_OnChanged(character)
    if self.charcterUID == character.uid then
        if self.headerID then
            local data = TbdAltManager_Reputations.Api.GetReputationDataByHeaderID(self.headerID, self.charcterUID)
            local t = {}
            for k, v in ipairs(data) do
                table.insert(t, v.repDataString)
            end
            self:LoadReputations(self.charcterUID, t, self.headerID)
        end
    end
end

function TbdAltManagerReputationListviewItemMixin:LoadReputations(characterUID, reps, headerID)
    self.statusDials:ReleaseAll()
    self.charcterUID = characterUID;
    self.headerID = headerID;
    self.header:SetText(characterUID)

    if TbdAltManager_Characters then
        local class = TbdAltManager_Characters.Api.GetCharacterDataByUID(characterUID, "class")
        if class then
            TbdAltManager.Api.ColourizeText(nil, self.header, class)
        end
    else

    end

    local lastDial;

    for k, repData in ipairs(reps) do
        
        local repType, headerName, headerID, factionName, factionID, currentStanding, currentReactionThreshold, nextReactionTreshold, reaction = strsplit(":", repData)

        local dial = self.statusDials:Acquire()
        dial:SetSize(70, 70)
        dial:Show()

        if repType == "legacy" then
            reaction = tonumber(reaction)
            currentStanding = tonumber(currentStanding)
            currentReactionThreshold = tonumber(currentReactionThreshold)
            nextReactionTreshold = tonumber(nextReactionTreshold)
            factionID = tonumber(factionID)

            --exalted fix
            if reaction == 8 and nextReactionTreshold == 0 and currentStanding == 0 and currentReactionThreshold == 0 then
                currentStanding = 999
                nextReactionTreshold = 999
            end
        end

        if repType == "renown" then
            reaction = 7
            currentStanding = tonumber(currentStanding)
            currentReactionThreshold = tonumber(currentReactionThreshold)
            nextReactionTreshold = tonumber(nextReactionTreshold)
            factionID = tonumber(factionID)
        end

        if repType == "friendship" then
            reaction = 7
            currentStanding = tonumber(currentStanding)
            currentReactionThreshold = tonumber(currentReactionThreshold)
            nextReactionTreshold = tonumber(nextReactionTreshold)
            factionID = tonumber(factionID)
        end

        dial.factionID = factionID

        dial:SetScript("OnEnter", function(f)
            GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
            GameTooltip:AddDoubleLine("Headre", headerName)
            GameTooltip:AddDoubleLine("HeaderID", headerID)
            GameTooltip:AddDoubleLine("Faction", factionName)
            GameTooltip:AddDoubleLine("FactionID", factionID)
            GameTooltip:AddDoubleLine("Current Standing", currentStanding)
            GameTooltip:AddDoubleLine("Current Reaction Threshold", currentReactionThreshold)
            GameTooltip:AddDoubleLine("Next Reaction Threshold", nextReactionTreshold)
            GameTooltip:AddDoubleLine("Reaction level", reaction)
            GameTooltip:Show()
        end)

        dial:SetScript("OnLeave", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)

        dial.header:SetText(factionName)
        dial.label:SetText(string.format("|cffffffff%d|r / %d", currentStanding, nextReactionTreshold))
        --dial.label:SetText(factionID)

        dial:SetValue(0,1)
        dial:SetValue(currentStanding, nextReactionTreshold)

        if reaction and standingColours[reaction] then
            local r, g, b = standingColours[reaction]:GetRGB()
            dial:SetColour(r, g, b)
        else
            dial:SetColour(1,1,1)
        end

        dial:SetIcon(TbdAltManager.Constants.ReputationIcons[factionID])

        if not lastDial then
            dial:SetPoint("LEFT", self, "LEFT", 20, -10)
        else
            dial:SetPoint("LEFT", lastDial, "RIGHT", 30, 0)
        end
        lastDial = dial
    end
end



--StreamCinematic-Classic-Large-Up




local function UpdateToggledState(frame, node)
    if not node:IsCollapsed() then
        frame.parentRight:SetAtlas("Options_ListExpand_Right")
    else
        frame.parentRight:SetAtlas("Options_ListExpand_Right_Expanded")
    end
end



TbdAltManagerReputationsModuleMixin = {}

function TbdAltManagerReputationsModuleMixin:OnLoad()

    -- self.dataProvider = CreateTreeDataProvider()
    -- self.dataProvider:Init({})
    -- self.treeview.scrollView:SetDataProvider(self.dataProvider)

    -- self.treeviewNodes = {}

    self.reputationHeaders = {}

    TbdAltManager_Reputations.CallbackRegistry:RegisterCallback("DataProvider_OnInitialized", self.DataProvider_OnInitialized, self)
    TbdAltManager_Reputations.CallbackRegistry:RegisterCallback("Character_OnAdded", self.Character_OnAdded, self)
    TbdAltManager_Reputations.CallbackRegistry:RegisterCallback("Character_OnChanged", self.Character_OnChanged, self)
end

function TbdAltManagerReputationsModuleMixin:OnShow()

end

function TbdAltManagerReputationsModuleMixin:DataProvider_OnInitialized()
    self:LoadReputationHeaders()
end

function TbdAltManagerReputationsModuleMixin:LoadReputationHeaders()

    local repCategories = TbdAltManager_Reputations.Api.GetAllKnownReputationHeaders()
    
    table.sort(repCategories, function(a, b)
        return a.headerID > b.headerID
    end)
    
    for k, rep in ipairs(repCategories) do

        if not self.reputationHeaders[rep.headerName] then
            self.reputationHeaders[rep.headerName] = true
            self.sideMenuNode:Insert({
                template = "TbdAltManagerSideBarListviewItemTemplate",
                height = 18,
                initializer = function(frame, node)
                    TbdAltManager.Api.ResetSideMenuFrame(frame)
                    frame.label:SetText(rep.headerName)
                    frame:SetScript("OnMouseDown", function()
                        TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Module_OnSelected, "Reputations")
                        self:LoadReputationForHeader(rep.headerID)
                    end)
                end,
            })
        end

    end
    self.sideMenuNode:ToggleCollapsed()
end

function TbdAltManagerReputationsModuleMixin:Character_OnAdded()

end

function TbdAltManagerReputationsModuleMixin:Character_OnChanged()
    self:LoadReputationHeaders()
end

function TbdAltManagerReputationsModuleMixin:LoadReputationForHeader(headerID)

    -- local catID = 14865
    -- for i = 1, GetCategoryNumAchievements(catID) do
    --     local info = {GetAchievementInfo(catID, i)}
    --     print(info[2], info[10])
    -- end

    self.dataProvider = CreateFromMixins(DataProviderMixin)
    self.dataProvider:Init({})
    self.dataProvider:SetSortComparator(TbdAltManager.Api.SortCharactersFunc)
    self.listview.scrollView:SetDataProvider(self.dataProvider)

    local repData = TbdAltManager_Reputations.Api.GetReputationDataByHeaderID(headerID)

    local repsByCharacter = {}

    for _, rep in ipairs(repData) do
        if not repsByCharacter[rep.characterUID] then
            repsByCharacter[rep.characterUID] = {}
        end
        table.insert(repsByCharacter[rep.characterUID], rep.repDataString)
    end

    for characterUID, reps in pairs(repsByCharacter) do
     
        if TbdAltManager_Characters then
            local characterData = TbdAltManager_Characters.Api.GetCharacterDataByUID(characterUID)

            if characterData then

                self.dataProvider:Insert({
                    characterUID = characterUID,
                    reps = reps,
                    headerID = headerID,

                    --sort
                    level = characterData.level,
                    class = characterData.class,
                    uid = characterData.uid,
                })

                self.listview.DataProvider:Sort()

            end

        else
            self.dataProvider:Insert({
                characterUID = characterUID,
                reps = reps,
                headerID = headerID,
            })
        end
    end

end
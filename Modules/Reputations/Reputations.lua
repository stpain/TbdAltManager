



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
end


TbdAltManagerReputationListviewItemMixin = {}

function TbdAltManagerReputationListviewItemMixin:OnLoad()
    self.statusDials = CreateFramePool("Frame", self, "TbdAltManagerReputationDialTemplate", DialResetFunc)

end

function TbdAltManagerReputationListviewItemMixin:SetDataBinding(binding, height)
    self:SetHeight(height)
    self:LoadReputations(binding.characterUID, binding.reps)
end

function TbdAltManagerReputationListviewItemMixin:LoadReputations(characterUID, reps)
    self.statusDials:ReleaseAll()

    self.header:SetText(characterUID)

    local lastDial;

    for k, repData in ipairs(reps) do
        
        local headerName, headerID, factionName, factionID, currentStanding, currentReactionThreshold, nextReactionTreshold, reaction = strsplit(":", repData)

        reaction = tonumber(reaction)
        currentStanding = tonumber(currentStanding)
        currentReactionThreshold = tonumber(currentReactionThreshold)
        nextReactionTreshold = tonumber(nextReactionTreshold)
        factionID = tonumber(factionID)

        local dial = self.statusDials:Acquire()
        dial:SetSize(70, 70)
        dial:Show()

        dial.header:SetText(factionName)
        --dial.label:SetText(string.format("%d / %d", currentStanding, nextReactionTreshold))
        dial.label:SetText(factionID)

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


    TbdAltManager_Reputations.CallbackRegistry:RegisterCallback("DataProvider_OnInitialized", self.DataProvider_OnInitialized, self)
    TbdAltManager_Reputations.CallbackRegistry:RegisterCallback("Character_OnAdded", self.Character_OnAdded, self)
end

function TbdAltManagerReputationsModuleMixin:OnShow()

end

function TbdAltManagerReputationsModuleMixin:DataProvider_OnInitialized()

    local repCategories = TbdAltManager_Reputations.Api.GetAllKnownReputationHeaders()
    
    table.sort(repCategories, function(a, b)
        return a.headerID > b.headerID
    end)
    
    for k, rep in ipairs(repCategories) do
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
    self.sideMenuNode:ToggleCollapsed()
end

function TbdAltManagerReputationsModuleMixin:Character_OnAdded()

end

function TbdAltManagerReputationsModuleMixin:LoadReputationForHeader(headerID)

    local catID = 14864
    for i = 1, GetCategoryNumAchievements(catID) do
        local info = {GetAchievementInfo(catID, i)}
        print(info[2], info[10])
    end

    self.dataProvider = CreateFromMixins(DataProviderMixin)
    self.dataProvider:Init({})
    self.dataProvider:SetSortComparator(TbdAltManager.Api.SortCharactersFunc)
    self.listview.scrollView:SetDataProvider(self.dataProvider)

    local repData = TbdAltManager_Reputations.Api.GetReputationDataByHeaderID(headerID, nil, true)

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

            self.dataProvider:Insert({
                characterUID = characterUID,
                reps = reps,

                --sort
                level = characterData.level,
                class = characterData.class,
                uid = characterData.uid,
            })

            self.listview.DataProvider:Sort()

        else
            self.dataProvider:Insert({
                characterUID = characterUID,
                reps = reps,
            })
        end
    end

end
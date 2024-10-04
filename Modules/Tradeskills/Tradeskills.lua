



local name, TbdAltManager = ...;

local tradeskillIDs = {
    164,
    165,
    171,
    182,
    185,
    186,
    197,
    202,
    333,
    356,
    393,
    755,
    773,
    --794,
}

local tradeskillBackgrounds = {
    [164] = "Professions-Specializations-Background-Blacksmithing",
    [165] = "Professions-Specializations-Background-Leatherworking",
    [171] = "Professions-Specializations-Background-Alchemy",
    [182] = "Professions-Specializations-Background-Herbalism",
    [185] = "Professions-Specializations-Background-Cooking",
    [186] = "Professions-Specializations-Background-Mining",
    [197] = "Professions-Specializations-Background-Tailoring",
    [202] = "Professions-Specializations-Background-Engineering",
    [333] = "Professions-Specializations-Background-Enchanting",
    [356] = "Professions-Specializations-Background-Fishing",
    [393] = "Professions-Specializations-Background-Skinning",
    [755] = "Professions-Specializations-Background-Jewelcrafting",
    [773] = "Professions-Specializations-Background-Inscription",
    --794,
}








TbdAltManagerTradeskillsModuleTreeviewTemplateMixin = {}
function TbdAltManagerTradeskillsModuleTreeviewTemplateMixin:OnLoad()
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end

function TbdAltManagerTradeskillsModuleTreeviewTemplateMixin:SetDataBinding(binding, height, node)
    
    self:SetHeight(height)

    if binding.isParent then
        self.parentLeft:Show()
        self.parentRight:Show()
        self.parentMiddle:Show()

    else
        self.background:SetColorTexture(0,0,0,0)
        if binding.index then
            if binding.index % 2 == 0 then
                self.background:SetColorTexture(0,0,0,0.1)
            else
                self.background:SetColorTexture(0.5,0.5,0.5,0.1)
            end
        end
    end

    --TbdAltManager.Api.UpdateTreeviewNodeToggledState(self, node)
    self:HookScript("OnMouseDown", function()
        TbdAltManager.Api.UpdateTreeviewNodeToggledState(self, node)
    end)

    if binding.label then
        self.linkLabel:SetText(binding.label)
    end

    if binding.showStatusBar then
        self.statusBar:SetMinMaxValues(binding.statusBarData.min, binding.statusBarData.max)
        self.statusBar:SetValue(binding.statusBarData.val)
        self.statusBar:Show()
        self.statusBar.level:SetText(string.format("%s / %s", binding.statusBarData.val, binding.statusBarData.max))
    else
        self.statusBar:Hide()
    end

    if binding.recipeData then

        if binding.recipeData.hyperlink then

            self:SetScript("OnEnter", function()
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:SetHyperlink(binding.recipeData.hyperlink)
                GameTooltip:Show()
            end)

            if binding.recipeData.learned then
                self.linkLabel:SetText(string.format("%s %s", CreateAtlasMarkup("common-icon-checkmark", 20, 20), binding.recipeData.hyperlink))
            else
                self.linkLabel:SetText(string.format("%s %s", CreateAtlasMarkup("common-icon-redx", 20, 20), binding.recipeData.hyperlink))
            end

        else
            if binding.recipeData.learned then
                self.linkLabel:SetText(string.format("%s %s", CreateAtlasMarkup("common-icon-checkmark", 20, 20), binding.recipeData.name))
            else
                self.linkLabel:SetText(string.format("%s %s", CreateAtlasMarkup("common-icon-redx", 20, 20), binding.recipeData.name))
            end

        end

    end

end
function TbdAltManagerTradeskillsModuleTreeviewTemplateMixin:ResetDataBinding()
    self.parentLeft:Hide()
    self.parentRight:Hide()
    self.parentMiddle:Hide()

    self.icon:SetTexture(nil)
    self.onMouseDown = nil

    self:SetScript("OnEnter", nil)

    self.linkLabel:SetText("")

    self.background:SetTexture(nil)
end








TbdAltManagerTradeskillsModuleMixin = {}

function TbdAltManagerTradeskillsModuleMixin:OnLoad()

    self:SetNewDataProvider()

    self.treeviewNodes = {}

    self.searchEditBox.ok:SetScript("OnClick", function()
        self:SearchForItem(self.searchEditBox:GetText())
    end)
    self.searchEditBox:SetScript("OnEnterPressed", function(editbox)
        self:SearchForItem(editbox:GetText())
    end)
    self.searchEditBox.cancel:SetScript("OnClick", function(editbox)
        editbox:SetText("")
        self.treeview.scrollView:SetDataProvider(self.dataProvider)
    end)


    TbdAltManager_Tradeskills.CallbackRegistry:RegisterCallback("DataProvider_OnInitialized", self.DataProvider_OnInitialized, self)
    TbdAltManager_Tradeskills.CallbackRegistry:RegisterCallback("Character_OnAdded", self.Character_OnAdded, self)
    TbdAltManager_Tradeskills.CallbackRegistry:RegisterCallback("Character_OnChanged", self.Character_OnChanged, self)
end

function TbdAltManagerTradeskillsModuleMixin:SetNewDataProvider()
    self.dataProvider = CreateTreeDataProvider()
    self.dataProvider:Init({})
    self.treeview.scrollView:SetDataProvider(self.dataProvider)
end

function TbdAltManagerTradeskillsModuleMixin:SearchForItem(searchTerm)
    
    local tempDataProvider = CreateTreeDataProvider()
    tempDataProvider:Init({})
    self.treeview.scrollView:SetDataProvider(tempDataProvider)

    local data = TbdAltManager_Tradeskills.Api.SearchFor(searchTerm)

    --local account, realm, characterName = strsplit(".", info.characterUID)
    
    local nodes = {}
    for recipeID, info in pairs(data) do
                
        nodes[recipeID] = tempDataProvider:Insert({
            label = info.name,
            isParent = true,
        })

        for _, crafter in ipairs(info.crafters) do

            local account, realm, characterName = strsplit(".", crafter)

            nodes[recipeID]:Insert({
                label = characterName,
            })

        end
    end
end

function TbdAltManagerTradeskillsModuleMixin:OnShow()

end

function TbdAltManagerTradeskillsModuleMixin:DataProvider_OnInitialized()


    for k, tradeskillID in ipairs(tradeskillIDs) do
        self.sideMenuNode:Insert({
            template = "TbdAltManagerSideBarListviewItemTemplate",
            height = 18,
            initializer = function(frame, node)
                TbdAltManager.Api.ResetSideMenuFrame(frame)
                frame.label:SetText(C_TradeSkillUI.GetTradeSkillDisplayName(tradeskillID))
                frame:SetScript("OnMouseDown", function()
                    self:LoadTradeskillData(tradeskillID)
                    TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Module_OnSelected, "Tradeskills")
                end)
            end,
        })
    end
    self.sideMenuNode:ToggleCollapsed()
end

function TbdAltManagerTradeskillsModuleMixin:Character_OnChanged(character)
    --DevTools_Dump(character)
end

function TbdAltManagerTradeskillsModuleMixin:Character_OnAdded()

end

function TbdAltManagerTradeskillsModuleMixin:LoadTradeskillData(tradeskillID)


    --[[
    
        TODO:
            add a category level to the view?
            C_TradeSkillUI.GetCategoryInfo() gets the subheader (child category "Axes" for example)

            reagents
            C_TradeSkillUI.GetRecipeInfo
            link = C_TradeSkillUI.GetRecipeFixedReagentItemLink(recipeID, dataSlotIndex)
            schematic = C_TradeSkillUI.GetRecipeSchematic(recipeSpellID, isRecraft [, recipeLevel])
    ]]

    self.background:SetAtlas(tradeskillBackgrounds[tradeskillID])

    self:SetNewDataProvider()

    local data = TbdAltManager_Tradeskills.Api.GetTradeskillDataForParentID(tradeskillID)

    self:LoadTreeviewData(data)

end

function TbdAltManagerTradeskillsModuleMixin:LoadTreeviewData(data)
    local nodes = {}

    for _, info in ipairs(data) do

        local account, realm, characterName = strsplit(".", info.characterUID)

        if TbdAltManager_Characters then
            local class = TbdAltManager_Characters.Api.GetCharacterDataByUID(info.characterUID, "class")
            if class then
                characterName = TbdAltManager.Api.ColourizeText(characterName, nil, class)
            end
        else
    
        end
        
        nodes[info.characterUID] = self.dataProvider:Insert({
            label = characterName,
            isParent = true,
        })


        if info.data and info.data.categories then

            for childCategory, categoryData in pairs(info.data.categories) do
                nodes[info.characterUID][childCategory] = nodes[info.characterUID]:Insert({
                    label = categoryData.professionName,
                    isParent = true,

                    showStatusBar = true,
                    statusBarData = {
                        min = 1,
                        max = categoryData.maxSkillLevel,
                        val = categoryData.skillLevel,
                    }
                })
                nodes[info.characterUID][childCategory]:ToggleCollapsed()

                local numRecipes = #categoryData.recipeData
                if numRecipes > 0 then
                    local index = 1;
                    C_Timer.NewTicker(0.001, function()
                        nodes[info.characterUID][childCategory]:Insert({
                            index = index,
                            recipeData = categoryData.recipeData[index],
                        })
                        index = index + 1;
                    end, numRecipes)
                end

            end

        end


    end
end




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








TbdAltManagerTradeskillsModuleTreeviewTemplateMixin = {}
function TbdAltManagerTradeskillsModuleTreeviewTemplateMixin:OnLoad()
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end

function TbdAltManagerTradeskillsModuleTreeviewTemplateMixin:SetDataBinding(node, height)

    local binding = node:GetData()
    
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

    if binding.label then
        self.linkLabel:SetText(binding.label)
    end

    if binding.showStatusBar then
        self.statusBar:SetMinMaxValues(binding.statusBarData.min, binding.statusBarData.max)
        self.statusBar:SetValue(binding.statusBarData.val)
        self.statusBar:Show()
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


    TbdAltManager_Tradeskills.CallbackRegistry:RegisterCallback("DataProvider_OnInitialized", self.DataProvider_OnInitialized, self)
    TbdAltManager_Tradeskills.CallbackRegistry:RegisterCallback("Character_OnAdded", self.Character_OnAdded, self)
end

function TbdAltManagerTradeskillsModuleMixin:SetNewDataProvider()
    self.dataProvider = CreateTreeDataProvider()
    self.dataProvider:Init({})
    self.treeview.scrollView:SetDataProvider(self.dataProvider)
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



    self:SetNewDataProvider()

    local data = TbdAltManager_Tradeskills.Api.GetTradeskillDataForParentID(tradeskillID)

    local nodes = {}

    for _, info in ipairs(data) do
        
        nodes[info.characterUID] = self.dataProvider:Insert({
            label = info.characterUID,
            isParent = true,
        })

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

            local numRecipes = #categoryData.recipeData
            local index = 1;
            C_Timer.NewTicker(0.001, function()
                nodes[info.characterUID][childCategory]:Insert({
                    index = index,
                    recipeData = categoryData.recipeData[index],
                })
                index = index + 1;
            end, numRecipes)

            -- for k, recipeData in ipairs(categoryData.recipeData) do
            --     nodes[info.characterUID][childCategory]:Insert({
            --         index = k,
            --         recipeData = recipeData,
            --     })
            -- end
        end


    end



end

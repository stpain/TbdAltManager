



local name, TbdAltManager = ...;








TbdAltManagerQuestsModuleMixin = {}

function TbdAltManagerQuestsModuleMixin:OnLoad()

    self.treeviewNodes = {}

    TbdAltManager_Quests.CallbackRegistry:RegisterCallback("DataProvider_OnInitialized", self.DataProvider_OnInitialized, self)
    TbdAltManager_Quests.CallbackRegistry:RegisterCallback("Character_OnAdded", self.Character_OnAdded, self)
    TbdAltManager_Quests.CallbackRegistry:RegisterCallback("Character_OnChanged", self.Character_OnChanged, self)
    TbdAltManager_Quests.CallbackRegistry:RegisterCallback("Character_OnRemoved", self.Character_OnRemoved, self)
end

function TbdAltManagerQuestsModuleMixin:OnShow()

end

function TbdAltManagerQuestsModuleMixin:SetNewDataProvider()
    self.dataProvider = CreateTreeDataProvider()
    self.dataProvider:Init({})
    self.treeview.scrollView:SetDataProvider(self.dataProvider)
end

function TbdAltManagerQuestsModuleMixin:Character_OnRemoved(characterUID)

end

function TbdAltManagerQuestsModuleMixin:DataProvider_OnInitialized()

end

function TbdAltManagerQuestsModuleMixin:Character_OnChanged(character)

end

function TbdAltManagerQuestsModuleMixin:Character_OnAdded()

end

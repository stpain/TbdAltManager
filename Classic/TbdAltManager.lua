

local addonName, TbdAltManager = ...;



TbdAltManagerMixin = {
    Modules = {}
}

function TbdAltManagerMixin:OnLoad()
    
    self:RegisterForDrag("LeftButton")

    Menu.ModifyMenu("MENU_UNIT_SELF", function(owner, rootDescription, contextData)
        rootDescription:CreateDivider()
        rootDescription:CreateTitle(addonName)
        rootDescription:CreateButton("Open", function() self:Show() end)
    end)

    TbdAltManager.CallbackRegistry:RegisterCallback(TbdAltManager.Callbacks.Module_OnRegistered, self.Module_OnRegistered, self)
    TbdAltManager.CallbackRegistry:RegisterCallback(TbdAltManager.Callbacks.Module_OnSelected, self.Module_OnSelected, self)
end

function TbdAltManagerMixin:Module_OnRegistered(module)

    module:SetParent(self.ContentContainer)
    module:SetAllPoints()

    self.Modules[module.name] = module;
    if module.menuEntry then
        local node = self.MenuListContainer.Treeview.DataProvider:Insert(module.menuEntry)

        module.menuEntryNode = node;

        -- if module.menuEntryChildren then
        --     for _, entry in ipairs(module.menuEntryChildren) do
        --         node:Insert(entry)
        --     end
        -- end
    end
    self.Modules[module.name]:Hide()
end

function TbdAltManagerMixin:HideAllModules()
    for name, frame in pairs(self.Modules) do
        frame:Hide()
    end
end

function TbdAltManagerMixin:Module_OnSelected(module)
    self:HideAllModules()
    self.Modules[module]:Show()
end
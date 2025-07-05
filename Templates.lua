

local addonName, TbdAltManager = ...;




---this is the gridview template mixin
TbdAltManagerGridviewMixin = {}

function TbdAltManagerGridviewMixin:OnLoad()

    ---these values are set in the xml frames KeyValues, it allows us to reuse code by setting listview item values in xml
    if type(self.itemTemplate) ~= "string" then
        error("self.itemTemplate name not set or not of type string")
        return;
    end
    if type(self.elementHeight) ~= "number" then
        error("self.elementHeight not set or not of type number")
        return;
    end 

    self.DataProvider = CreateDataProvider();
    self.scrollView = CreateScrollBoxListGridView(5);



    self.scrollView:SetDataProvider(self.DataProvider);

    ---height is defined in the xml keyValues
    local height = self.elementHeight;
    self.scrollView:SetElementExtent(height);

    self.scrollView:SetElementInitializer(self.itemTemplate, GenerateClosure(self.OnElementInitialize, self));
    self.scrollView:SetElementResetter(GenerateClosure(self.OnElementReset, self));

    self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.scrollView);

    self.scrollView:SetPadding(1, 1, 1, 1, 1);

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollBox, self.scrollBar, self.scrollView);

    local anchorsWithBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self.scrollBar, "BOTTOMLEFT", -1, 1),
    };
    local anchorsWithoutBar = {
        CreateAnchor("TOPLEFT", self, "TOPLEFT", 1, -1),
        CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1),
    };
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.scrollBox, self.scrollBar, anchorsWithBar, anchorsWithoutBar);
end

function TbdAltManagerGridviewMixin:OnElementInitialize(element, elementData, isNew)
    if isNew then
        element:OnLoad();
    end
    local height = self.elementHeight;
    element:SetDataBinding(elementData, height);
    element:UpdateLayout()
end

function TbdAltManagerGridviewMixin:OnElementReset(element)
    element:ResetDataBinding()
end




--[[

    template:
        TbdAltManagerSideBarListviewItemTemplate

    description:
        the template used for the sideBar listview 

]]
TbdAltManagerSideBarListviewItemTemplateMixin = {}

function TbdAltManagerSideBarListviewItemTemplateMixin:OnLoad()

end

function TbdAltManagerSideBarListviewItemTemplateMixin:SetDataBinding(binding, height, node)

    self:SetHeight(height)
    self.Icon:SetSize(height-4, height-4)
    self.IconMask:SetSize(height-6, height-6)
    self.IconRing:SetSize(height-2, height-2)

    self.Icon:Show()
    if type(binding.icon) == "string" then
        self.Icon:SetAtlas(binding.icon)
    elseif type(binding.icon) == "number" then
        self.Icon:SetTexture(binding.icon)
    else
        self.Icon:SetWidth(1)
        self.Icon:Hide()
    end
    self.Label:SetText(binding.label)

    if binding.addMask then
        self.IconMask:Show()
        self.IconRing:Show()
    else
        self.IconMask:Hide()
        self.IconRing:Hide()
    end

    if binding.isParent then
        self.ToggleButton:SetSize(height-12, height-12)
        self.ToggleButton:Show()

        self.ToggleButton:SetScript("OnClick", function()
            node:ToggleCollapsed()
            if node:IsCollapsed() then
                self.ToggleButton:SetNormalAtlas("128-RedButton-Plus")
                self.ToggleButton:SetPushedAtlas("128-RedButton-Plus-Pressed")
            else
                self.ToggleButton:SetNormalAtlas("128-RedButton-Minus")
                self.ToggleButton:SetPushedAtlas("128-RedButton-Minus-Pressed")
            end
        end)

    else
        self.ToggleButton:Hide()
    end

    self:SetScript("OnMouseDown", function()
        binding.func()
    end)

    self:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(binding.tooltip)
        GameTooltip:Show()
    end)
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end

function TbdAltManagerSideBarListviewItemTemplateMixin:ResetDataBinding()

end















local addonName, TbdAltManager = ...;

local LibGraph = LibStub("LibGraph-2.0");

local L = TbdAltManager.locales;

---this is the listview template mixin
TbdAltManagerListviewMixin = {}

function TbdAltManagerListviewMixin:OnLoad()

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
    self.scrollView = CreateScrollBoxListLinearView();
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

function TbdAltManagerListviewMixin:OnElementInitialize(element, elementData, isNew)
    if isNew then
        element:OnLoad();
    end
    local height = self.elementHeight;
    element:SetDataBinding(elementData, height);
end

function TbdAltManagerListviewMixin:OnElementReset(element)
    element:ResetDataBinding()
end

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





TbdAltManagerContentSummaryDetailTopTabButtonMixin = {}
function TbdAltManagerContentSummaryDetailTopTabButtonMixin:SetText(text)
    self.text:SetText(text)
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
    self.icon:SetSize(height-2, height-2)
    self.iconMask:SetSize(height-4, height-4)
    self.iconRing:SetSize(height-3, height-3)

    self.icon:Show()
    if type(binding.icon) == "string" then
        self.icon:SetAtlas(binding.icon)
    elseif type(binding.icon) == "number" then
        self.icon:SetTexture(binding.icon)
    else
        self.icon:SetWidth(1)
        self.icon:Hide()
    end
    self.label:SetText(binding.label)

    if binding.addMask then
        self.iconMask:Show()
        self.iconRing:Show()
    else
        self.iconMask:Hide()
        self.iconRing:Hide()
    end

    if binding.isParent then
        self.toggleButton:SetSize(height-12, height-12)
        self.toggleButton:Show()

        self.toggleButton:SetScript("OnClick", function()
            node:ToggleCollapsed()
            if node:IsCollapsed() then
                self.toggleButton:SetNormalAtlas("128-RedButton-Plus")
                self.toggleButton:SetPushedAtlas("128-RedButton-Plus-Pressed")
            else
                self.toggleButton:SetNormalAtlas("128-RedButton-Minus")
                self.toggleButton:SetPushedAtlas("128-RedButton-Minus-Pressed")
            end
        end)

    else
        self.toggleButton:Hide()
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



--[[

    template:
        TbdAltManagerContentSummaryGridViewItemTemplate

    description:
        the template used on the main summary page to show general character info

]]
TbdAltManagerContentSummaryGridViewItemTemplateMixin = {}

function TbdAltManagerContentSummaryGridViewItemTemplateMixin:OnLoad()

    self.width, self.height = 0, 0;

    self:SetScript("OnEnter", function()
        self.canvas:SetAlpha(0.5)
    end)
    self:SetScript("OnLeave", function()
        self.canvas:SetAlpha(0.15)
    end)

    self.levelLabel:SetText(L.CONTENT_SUMMARY_CHARACTER_GRIDVIEW_ITEM_LEVEL)
    self.ilvlLabel:SetText(L.CONTENT_SUMMARY_CHARACTER_GRIDVIEW_ITEM_ILVL)
end

function TbdAltManagerContentSummaryGridViewItemTemplateMixin:UpdateLayout()

    self.width = self:GetWidth()
    self.height = self:GetHeight()

    self.role:SetSize(self.width*0.15,self.height*0.15)
    self.class:SetSize(self.width*0.15,self.height*0.15)

    self.portrait:SetSize(self.height * 0.4, self.height * 0.4)
    self.portraitMask:SetSize(self.height * 0.4, self.height * 0.4)

end

function TbdAltManagerContentSummaryGridViewItemTemplateMixin:SetDataBinding(binding, height)

    --self:SetSize(height * 1.5, height * 1)

    --DevTools_Dump(binding.isResting)
    if type(binding) == "table" then
        self:SetScript("OnMouseDown", function()
            TbdAltManager:TriggerEvent("SummaryGridViewItem_OnMouseDown", binding)
        end)
    end

    self.name:SetText(binding.name)
    self.location:SetText(binding.subZone)
    self.level:SetText(binding.level)
    self.ilvl:SetText(string.format("%.2f", binding.ilvl))

    if binding.activeSpecRole then
        if binding.activeSpecRole == "TANK" then
            self.role:SetAtlas("groupfinder-icon-role-large-tank")
        elseif binding.activeSpecRole == "HEALER" then
            self.role:SetAtlas("groupfinder-icon-role-large-heal")
        elseif binding.activeSpecRole == "DAMAGER" then
            self.role:SetAtlas("groupfinder-icon-role-large-dps")
        end
    end

    if binding.englishClass then
        self.class:SetAtlas(string.format("groupfinder-icon-class-%s", binding.englishClass:lower()))
    end

    if binding.faction == "Alliance" then
        self.border:SetColorTexture(0, 0, 1, 0.5)
    elseif binding.faction == "Horde" then
        self.border:SetColorTexture(1, 0, 0, 0.5)
    else
        self.border:SetColorTexture(1, 1, 1, 0.5)
    end

    if binding.activeSpecName then
        local specNoSpaces = binding.activeSpecName:gsub(" ", "")
        local backgroundArt = string.format("spec-thumbnail-%s-%s", binding.englishClass:lower(), specNoSpaces:lower())
        self.canvas:SetAtlas(backgroundArt)
        self.canvas:SetAlpha(0.15)
    else
        self.canvas:SetColorTexture(0.6, 0.6, 0.6, 0.6)
    end

    local gender = binding.gender == 3 and "female" or "male"
    local portraitArt = string.format("raceicon128-%s-%s", binding.englishRace:lower(), gender)
    self.portrait:SetAtlas(portraitArt)

    if binding.isResting == true then
        self.restLoop:Show()
        self.restLoop.anim:Play()
    end
end

function TbdAltManagerContentSummaryGridViewItemTemplateMixin:ResetDataBinding()
    self.restLoop:Hide()
    self.restLoop.anim:Stop()
    self:SetScript("OnMouseDown", nil)
end








TbdAltManagerDropDownTemplateMixin = {}

function TbdAltManagerDropDownTemplateMixin:OnLoad()
    self.isOpen = false;
    self:SetScript("OnClick", function()
        self.isOpen = not self.isOpen
        if self.isOpen then
            self.flyout:Show()
        else
            self.flyout:Hide()
        end
    end)
end

function TbdAltManagerDropDownTemplateMixin:SetWidth(width)
    --self.flyout:SetWidth(width)
end

function TbdAltManagerDropDownTemplateMixin:SetMenu(t)

    if type(t) ~= "table" then
        return;
    end

    --self.flyout.listview.menu = t

    local menulength = #t;
    if menulength > 8 then
        self.flyout:SetHeight(230)
    else
        self.flyout:SetHeight((menulength * 24) + 36)
    end

    self.maxWidth = 0.0;

    self.flyout.listview.DataProvider:Flush()
    self.flyout.listview.DataProvider:InsertTable(t)
end


TbdAltManagerDropDownListviewItemTemplateMixin = {}

function TbdAltManagerDropDownListviewItemTemplateMixin:OnLoad()
    self.dropdown = self:GetParent():GetParent():GetParent():GetParent():GetParent()
end

function TbdAltManagerDropDownListviewItemTemplateMixin:SetDataBinding(binding, height)
    self:SetHeight(height)
    self.text:SetText(binding.text)

    self.icon:SetSize(height-2, height-2)

    if type(binding.icon) == "string" then
        self.icon:SetAtlas(binding.icon)
    elseif type(binding.icon) == "number" then
        self.icon:SetTexture(binding.icon)
    else
        self.icon:SetSize(1,1)
    end

    local w = self.text:GetUnboundedStringWidth() + 44
    if w > self.dropdown.maxWidth then
        self.dropdown.maxWidth = w;
        self.dropdown.flyout:SetWidth(self.dropdown.maxWidth + 44)
        self.dropdown.flyout.listview:ClearAllPoints()
        self.dropdown.flyout.listview:SetPoint("TOP", 0, -14)
        self.dropdown.flyout.listview:SetPoint("BOTTOM", 0, 14)
        self.dropdown.flyout.listview:SetWidth(self.dropdown.maxWidth)
    end

    self:SetScript("OnMouseDown", function()
        self.dropdown.label.text:SetText(binding.text)
        self.dropdown.isOpen = false;
        self.dropdown.flyout:Hide()

        if binding.func then
            binding.func()
        end
    end)

    -- if binding.menuTable then
    --     self:SetScript("OnMouseDown", function()

    --         self.listview.DataProvider:Flush()
    --         self.listview.DataProvider:Insert({
    --             text = "Return",
    --             menuTable = self.listview.menu;
    --         })
    --         self.listview.DataProvider:InsertTable(binding.menuTable)
    --     end)
    -- end
end

function TbdAltManagerDropDownListviewItemTemplateMixin:ResetDataBinding()
    self.text:SetText(nil)
    self.icon:SetTexture(nil)
    self.menuTable = nil;
    self:SetScript("OnMouseDown", nil)
end




TbdAltManagerContentContainerBagListviewitemTemplateMixin = {}

function TbdAltManagerContentContainerBagListviewitemTemplateMixin:SetData(data)

    if not self.slots then
        self.slots = {}
    end

    self.icon:SetTexture(data.icon)
    self.iconRing:SetVertexColor(TbdAltManager.Colours.ItemQualityColours[data.rarity]:GetRGB())

    self:Clear()

    local rowLimit = 14;
    local numRows = math.ceil(data.size / rowLimit)
    local slotSize = 40

    self:SetHeight(numRows * slotSize)

    local row = 1;
    for i = 1, data.size do        
        if not self.slots[i] then
            local f = CreateFrame("FRAME", nil, self, "TbdAltManagerContentContainerBagListviewitemSlotTemplate")
            f:SetSize(slotSize, slotSize)
            self.slots[i] = f;
        end
        local f = self.slots[i];
        if i == 1 then
            f:SetPoint("TOPLEFT", self, "TOPLEFT", 80, 0)

        else

            if i <= (row * rowLimit) then
                f:SetPoint("LEFT", self.slots[i-1], "RIGHT", 0, 0)
            else
                f:SetPoint("TOP", self.slots[i - (row * rowLimit)], "BOTTOM", 0, 0)
                row = row + 1
            end

        end
        self.slots[i]:Show()
    end

    for k, item in ipairs(data.items) do
        local _, _, _, _, icon = GetItemInfoInstant(item.link)
        self.slots[k].background:SetTexture(icon)
    end
    
end

function TbdAltManagerContentContainerBagListviewitemTemplateMixin:Clear()
    for k, slot in ipairs(self.slots) do
        slot.background:SetAtlas("bags-item-slot64")
        slot:Hide()
    end
end

function TbdAltManagerContentContainerBagListviewitemTemplateMixin:UpdateLayout()
    
end


TbdAltManagerContentContainerBagListviewitemSlotTemplateMixin = {}

function TbdAltManagerContentContainerBagListviewitemSlotTemplateMixin:OnLoad()
    self.anim:Play()
end

function TbdAltManagerContentContainerBagListviewitemSlotTemplateMixin:ClearItem()
    self.icon:SetTexture(nil)
    self.glow:SetTexture(nil)
    self.count:SetText(nil)
end

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

function TbdAltManagerContentContainerBagListviewitemSlotTemplateMixin:SetDataBinding(info)
    self:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetHyperlink(info.link)
        GameTooltip:Show()
    end)
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    self.icon:SetTexture(info.icon)
    self.count:SetText(info.count)

    self.glow:SetTexture(nil)

    local item = Item:CreateFromItemID(info.itemID)
    if not item:IsItemEmpty() then
        item:ContinueOnItemLoad(function()
            local quality = item:GetItemQuality()
            if getItemGlowAtlas(quality) then
                self.glow:SetAtlas(getItemGlowAtlas(quality))
            end
        end)
    else
        self.glow:SetTexture(nil)
    end
end



TbdAltManagerContentMailsInboxItemTemplateMixin = {}

function TbdAltManagerContentMailsInboxItemTemplateMixin:OnLoad()

end

function TbdAltManagerContentMailsInboxItemTemplateMixin:SetDataBinding(binding, height)
    self:SetHeight(height)

    if type(binding) == "table" then
        self:SetScript("OnMouseDown", function()
            TbdAltManager:TriggerEvent("InboxListviewItem_OnMouseDown", binding)
        end)
    end

    self.sender:SetText(string.format("%s: |cffffffff%s|r", L.CONTENT_MAIL_SENDER, binding.sender))
    self.subject:SetText(string.format("%s: |cffffffff%s|r", L.CONTENT_MAIL_SUBJECT, binding.subject))
    self.daysLeft:SetText(string.format("%s: |cffffffff%.0f|r", L.CONTENT_MAIL_DAYS_LEFT, math.floor(binding.daysLeft)))

    if #binding.attachments > 0 then
        self.numAttachments:SetText(string.format("%s: |cffffffff%d|r", L.CONTENT_MAIL_NUM_ATTACHMENTS, #binding.attachments))
    else
        self.numAttachments:SetText(nil)
    end
end

function TbdAltManagerContentMailsInboxItemTemplateMixin:ResetDataBinding()
    self:SetScript("OnMouseDown", nil)
end






TbdAltManagerContentSummaryDetailslistviewItemTemplateMixin = {}

function TbdAltManagerContentSummaryDetailslistviewItemTemplateMixin:SetDataBinding(binding, height)
    self:SetHeight(height)

    self.label:SetText(binding.label or "")
    self.text:SetText(binding.text or "")
end

function TbdAltManagerContentSummaryDetailslistviewItemTemplateMixin:ResetDataBinding()
    
end
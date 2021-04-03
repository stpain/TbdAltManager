

function Altasia_UIPanelScrollBarScrollUpButton_OnClick()
    PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function Altasia_UIPanelScrollBarScrollDownButton_OnClick()
    PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function Altasia_UIPanelScrollBar_OnValueChanged(self, value)

end

AltasiaItemInfoFrameMixin = {}

function AltasiaItemInfoFrameMixin:SetItem(item)
    if item then
        self.Icon:SetTexture(item.icon)
        self.Name:SetText(item.link)
        self.Count:SetText(item.count and item.count or 0)
        self.item = item
    else
        self.Icon:SetTexture(nil)
        self.Name:SetText(nil)
        self.Count:SetText("")
        self.item = nil
    end
end

function AltasiaItemInfoFrameMixin:OnEnter()
    if self.item and self.item.link:find("|H") then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetHyperlink(self.item.link)
    end
end

function AltasiaItemInfoFrameMixin:OnLeave()
    GameTooltip:Hide()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function AltasiaItemInfoFrameMixin:OnHyperlinkClick()

end


AltasiaDropDownFrameMixin = {}



-- this is the dropdown button mixin, all that needs to happen is set the text and call any func if passed
AltasiaDropDownFlyoutButtonMixin = {}

function AltasiaDropDownFlyoutButtonMixin:OnEnter()
    self.Highlight:Show()
end

function AltasiaDropDownFlyoutButtonMixin:OnLeave()
    self.Highlight:Hide()
end

function AltasiaDropDownFlyoutButtonMixin:SetText(text)
    self.Text:SetText(text)
end

function AltasiaDropDownFlyoutButtonMixin:OnMouseDown()
    if self.func then
        self:func()
    end
    self:GetParent():Hide()
end


-- if we need to get the flyout although its a child so can be accessed via dropdown.Flyout
AltasiaDropdownMixin = {}

function AltasiaDropdownMixin:GetFlyout()
    return self.Flyout
end


AltasiaDropdownButtonMixin = {}

function AltasiaDropdownButtonMixin:OnEnter()
    self.ButtonHighlight:Show()
end

function AltasiaDropdownButtonMixin:OnLeave()
    self.ButtonHighlight:Hide()
end

function AltasiaDropdownButtonMixin:OnMouseDown()

    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

    self.ButtonUp:Hide()
    self.ButtonDown:Show()

    local flyout = self:GetParent().Flyout
    if flyout:IsVisible() then
        flyout:Hide()
    else
        flyout:Show()
    end
end

function AltasiaDropdownButtonMixin:OnMouseUp()
    self.ButtonDown:Hide()
    self.ButtonUp:Show()
end

AltasiaDropdownFlyoutMixin = {}

function AltasiaDropdownFlyoutMixin:OnLeave()
    self.delay = C_Timer.NewTicker(3, function()
        if not self:IsMouseOver() then
            self:Hide()
        end
    end)
end

function AltasiaDropdownFlyoutMixin:OnShow()

    self:SetFrameStrata("DIALOG")

    if self.delay then
        self.delay:Cancel()
    end

    self.delay = C_Timer.NewTicker(3, function()
        if not self:IsMouseOver() then
            self:Hide()
        end
    end)

    -- the .menu needs to a table that mimics the blizz dropdown
    -- t = {
    --     text = buttonText,
    --     func = functionToRun,
    -- }
    if self:GetParent().menu then
        if not self.buttons then
            self.buttons = {}
        end
        for i = 1, #self.buttons do
            self.buttons[i]:SetText("")
            self.buttons[i].func = nil
            self.buttons[i]:Hide()
        end
        for buttonIndex, info in ipairs(self:GetParent().menu) do
            if not self.buttons[buttonIndex] then
                self.buttons[buttonIndex] = CreateFrame("FRAME", "AltasiaMailSummaryInboxDropdownFlyoutButton"..buttonIndex, self, "AltasiaDropDownButton")
                self.buttons[buttonIndex]:SetPoint("TOP", 0, (buttonIndex * -22) + 22)
            end
            self.buttons[buttonIndex]:SetText(info.text)
            --self.buttons[buttonIndex].arg1 = info.arg1
            self.buttons[buttonIndex].func = info.func
            self.buttons[buttonIndex]:Show()

            self:SetHeight(buttonIndex * 22)
            buttonIndex = buttonIndex + 1
        end
    end

end
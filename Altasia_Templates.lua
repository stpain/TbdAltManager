

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



AltasiaDropDownButtonMixin = {}

function AltasiaDropDownButtonMixin:OnEnter()
    self.Highlight:Show()
end

function AltasiaDropDownButtonMixin:OnLeave()
    self.Highlight:Hide()
end

function AltasiaDropDownButtonMixin:SetText(text)
    self.Text:SetText(text)
end

function AltasiaDropDownButtonMixin:OnMouseDown()
    if self.arg1 then
        local character = ALT_ACC.characters[self.arg1]
        print(character.Name)

        self:GetParent():Hide()
    end
end
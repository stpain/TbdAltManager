

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
        self.item = item
    else
        self.Icon:SetTexture(nil)
        self.Name:SetText(nil)
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
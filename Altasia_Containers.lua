

local addonName, alt = ...

local L = alt.Locales


AltasiaListviewItem_ContainerSummaryMixin = {}

function AltasiaListviewItem_ContainerSummaryMixin:SetItemIcon(texture)
    self.ItemIcon:SetTexture(texture)
end

function AltasiaListviewItem_ContainerSummaryMixin:SetItemLink(link)
    self.ItemLink:SetText(link)
end

function AltasiaListviewItem_ContainerSummaryMixin:SetItemID(id)
    self.ItemID:SetText(id)
end

function AltasiaListviewItem_ContainerSummaryMixin:SetCharacter(character)
    self.Character:SetText(character)
end

function AltasiaListviewItem_ContainerSummaryMixin:SetCount(count)
    self.Count:SetText(count)
end

function AltasiaListviewItem_ContainerSummaryMixin:OnHyperlinkClick()
    if self.ItemLink:GetText():find("|H") then
        ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
        ItemRefTooltip:ItemRefSetHyperlink(self.ItemLink:GetText());
    end
end

function AltasiaListviewItem_ContainerSummaryMixin:OnEnter()
    if self.ItemLink:GetText():find("|H") then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetHyperlink(self.ItemLink:GetText())
    end
end

function AltasiaListviewItem_ContainerSummaryMixin:OnLeave()
    GameTooltip:Hide()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function AltasiaListviewItem_ContainerSummaryMixin:OnMouseWheel(delta)
    if alt.ui.containerSummary.scrollBar then
        local s = alt.ui.containerSummary.scrollBar:GetValue()
        alt.ui.containerSummary.scrollBar:SetValue(s - delta)
    end
end






local addonName, alt = ...

local L = alt.Locales

AltasiaListviewItem_CharacterSummaryMixin = {}
AltasiaListviewItem_CharacterSummaryMixin.prof1 = nil;
AltasiaListviewItem_CharacterSummaryMixin.prof2 = nil;
AltasiaListviewItem_CharacterSummaryMixin.money = 0;
AltasiaListviewItem_CharacterSummaryMixin.tooltipIcon = CreateFrame("FRAME", "AltasiaCharacterSummaryTooltipIcon")
AltasiaListviewItem_CharacterSummaryMixin.tooltipIcon:SetSize(20, 20)
AltasiaListviewItem_CharacterSummaryMixin.tooltipIcon.icon = AltasiaListviewItem_CharacterSummaryMixin.tooltipIcon:CreateTexture(nil, "BACKGROUND")
AltasiaListviewItem_CharacterSummaryMixin.tooltipIcon.icon:SetPoint("TOPLEFT", 0, 0)
AltasiaListviewItem_CharacterSummaryMixin.tooltipIcon.icon:SetSize(35, 35)

function AltasiaListviewItem_CharacterSummaryMixin:OnEnter()
    local this = self;
    GameTooltip:SetOwner(this, 'ANCHOR_CURSOR')
    local rPerc, gPerc, bPerc, argbHex = GetClassColor(this.bio.Class:upper())
    GameTooltip_SetTitle(GameTooltip, this.Name:GetText(), CreateColor(rPerc, gPerc, bPerc), nil)
    if this.tooltipIcon then
        this.tooltipIcon.icon:SetAtlas(string.format("raceicon128-%s-%s", this.bio.Race:lower(), this.bio.Gender))
        GameTooltip_InsertFrame(GameTooltip, this.tooltipIcon)
        for k, frame in pairs(GameTooltip.insertedFrames) do
            if frame:GetName() == "AltasiaCharacterSummaryTooltipIcon" then
                frame:ClearAllPoints()
                frame:SetPoint("TOPRIGHT", -25, -10)
            end
        end
    end
    --GameTooltip:AddLine(this.Name:GetText())
    GameTooltip:AddDoubleLine(L['Level'], "|cffffffff"..this.Level:GetText())
    GameTooltip:AddDoubleLine(L['XP'], "|cffffffff"..this.LevelXP:GetText())
    GameTooltip:AddDoubleLine(L['RestedXP'], "|cffffffff"..this.LevelXPRested:GetText())
    GameTooltip:AddDoubleLine(L['Professions'], "|cffffffff"..this.prof1)
    GameTooltip:AddDoubleLine(" ", "|cffffffff"..this.prof2)
    GameTooltip:AddDoubleLine(L['Money'], "|cffffffff"..this.Money:GetText())
    GameTooltip:AddDoubleLine(L['Location'], "|cffffffff"..this.CurrentLocation:GetText())
    GameTooltip:Show()
end

function AltasiaListviewItem_CharacterSummaryMixin:OnLeave()
    GameTooltip:Hide()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetName(name)
    self.Name:SetText(name)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetItemLevel(ilvl)
    self.ilvl:SetText(ilvl)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetLevel(level)
    self.Level:SetText(level)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetLevelXP(level)
    self.LevelXP:SetText(level)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetLevelXPRested(level)
    self.LevelXPRested:SetText(level)
    self.XPIconRested:SetVertexColor(0.2,0.2,0.8)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetRace_Atlas(atlas)
    --self.RaceIcon:SetAtlas(atlas)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetClass_Atlas(atlas)
    self.ClassIcon:SetAtlas(atlas)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetProf1_Atlas(atlas)
    self.Prof1:SetAtlas(atlas)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetProf2_Atlas(atlas)
    self.Prof2:SetAtlas(atlas)
end

function AltasiaListviewItem_CharacterSummaryMixin:SetMoney(money)
    self.Money:SetText(GetCoinTextureString(money))
end

function AltasiaListviewItem_CharacterSummaryMixin:SetRestedIcon(rested)
    if rested == true then
        self.HearthstoneIcon_Rested:Show()
        self.HearthstoneIcon_NotRested:Hide()
    else
        self.HearthstoneIcon_Rested:Hide()
        self.HearthstoneIcon_NotRested:Show()
    end
end

function AltasiaListviewItem_CharacterSummaryMixin:SetCurrentLocation(location)
    self.CurrentLocation:SetText(location)
end


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




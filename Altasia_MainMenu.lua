

local addonName, alt = ...

local L = alt.Locales

AltasiaMainMenuButtonMixin = {}
AltasiaMainMenuButtonMixin.tooltipText = "";
AltasiaMainMenuButtonMixin.enabled = true;
AltasiaMainMenuButtonMixin.contentFrameKey = nil;

function AltasiaMainMenuButtonMixin:SetBackground_Atlas(fileID)
    self.Background:SetAtlas(fileID)
end

function AltasiaMainMenuButtonMixin:SetBackground_Portrait()
    SetPortraitTexture(self.Background, "player")
end

function AltasiaMainMenuButtonMixin:OnEnter()
    local this = self;
    if self.enabled == true then
	    self.MainMenuHighlight:Show()
    end
    if this.tooltipText:len() > 0 then
        GameTooltip:SetOwner(this, 'ANCHOR_TOPRIGHT')
        GameTooltip:AddLine(this.tooltipText)
        GameTooltip:Show()
    end
end

function AltasiaMainMenuButtonMixin:OnLeave()
	self.MainMenuHighlight:Hide()
    GameTooltip:Hide()
end

function AltasiaMainMenuButtonMixin:Disable()
	self.enabled = false
end

function AltasiaMainMenuButtonMixin:OnMouseUp()
    if self.enabled == true then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        self:ClearAllPoints()
        self:SetPoint(point, relativeTo, relativePoint, xOfs - 1, yOfs + 1)
    end
end

function AltasiaMainMenuButtonMixin:OnMouseDown()
    if self.enabled == true then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        self:ClearAllPoints()
        self:SetPoint(point, relativeTo, relativePoint, xOfs + 1, yOfs - 1)
        alt:HideAllUIContentFrames()
        if alt.ui[self.contentFrameKey] then
            alt.ui[self.contentFrameKey]:Show()
        end
    end
end

function alt:NewMainMenuButton(name, parent, anchor, x, y)
    local f = CreateFrame('FRAME', name, parent, "AltasiaMainMenuButton")
    f:SetPoint(anchor, x, y)
    return f
end



AltasiaCharacterListviewButtonMixin = {}
AltasiaCharacterListviewButtonMixin.tooltipText = "";
AltasiaCharacterListviewButtonMixin.guid = nil;
AltasiaCharacterListviewButtonMixin.dataStoreKey = nil;

function AltasiaCharacterListviewButtonMixin:SetDataStoreKey(key)
	self.dataStoreKey = key;
end

function AltasiaCharacterListviewButtonMixin:SetPortraitIcon(iconFileID)
	self.Portrait:SetTexture(iconFileID);
end

function AltasiaCharacterListviewButtonMixin:SetName(name)
	self.Name:SetText(name);
end

function AltasiaCharacterListviewButtonMixin:OnEnter()
	local this = self;
	self.CharacterListviewHighlight:Show()
	if this.tooltipText:len() > 0 then
		GameTooltip:SetOwner(this, 'ANCHOR_TOPRIGHT')
		GameTooltip:AddLine(this.tooltipText)
		GameTooltip:Show()
	end
end

function AltasiaCharacterListviewButtonMixin:OnLeave()
	self.CharacterListviewHighlight:Hide()
	GameTooltip:Hide()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function AltasiaCharacterListviewButtonMixin:OnMouseUp()
	-- local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
	-- self:ClearAllPoints()
	-- self:SetPoint(point, relativeTo, relativePoint, xOfs - 1, yOfs + 1)
    self:AdjustPointsOffset(-1, 1)
end

function AltasiaCharacterListviewButtonMixin:OnMouseDown()
	-- local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
	-- self:ClearAllPoints()
	-- self:SetPoint(point, relativeTo, relativePoint, xOfs + 1, yOfs - 1)
    self:AdjustPointsOffset(1, -1)
	if not ALT_ACC then
		return
	end
	if not self.dataStoreKey then
		return
	end
	alt:HideAllUIContentFrames()
	if alt.ui[self.contentFrameKey] then
		alt.ui[self.contentFrameKey]:Show()
	end
    if ALT_ACC.characters[self.dataStoreKey] then
        if DataStoreDB and DataStore_CharactersDB then
            local info = DataStore_CharactersDB.global.Characters[self.dataStoreKey]
            if not info then
                print('no info')
            end
            alt.ui.characterDetail.name:SetText(ALT_ACC.characters[self.dataStoreKey].Name)
            for k, v in pairs(info) do
                --print(k,v)
                if alt.ui.characterDetail[k] then
                    if k == "money" then
                        alt.ui.characterDetail[k]:SetText(GetCoinTextureString(v))
                    elseif k == "played" or k == "playedThisLevel" then
                        alt.ui.characterDetail[k]:SetText(SecondsToTime(v))
                    elseif k == "lastLogoutTimestamp" then
                        local d = date('*t', v)
                        alt.ui.characterDetail[k]:SetText(string.format("%02d/%02d/%4d %02d:%02d:%02d", d.day, d.month, d.year, d.hour, d.min, d.sec))
                    else
                        alt.ui.characterDetail[k]:SetText(v)
                    end
                end
            end
        end
    end
end
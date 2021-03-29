

local addonName, alt = ...

local L = alt.Locales

AltasiaQuestSummaryZoneListviewItemMixin = {}
AltasiaQuestSummaryZoneListviewItemMixin.selected = false;
AltasiaQuestSummaryZoneListviewItemMixin.quests = nil;


function AltasiaQuestSummaryZoneListviewItemMixin:SetZoneText(zone)
    self.ZoneText:SetText(zone)
end

function AltasiaQuestSummaryZoneListviewItemMixin:OnEnter()
    self.Highlight:Show()
end

function AltasiaQuestSummaryZoneListviewItemMixin:OnLeave()
    self.Highlight:Hide()
end

function AltasiaQuestSummaryZoneListviewItemMixin:OnMouseUp()
    if self.enabled == true then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        self:ClearAllPoints()
        self:SetPoint(point, relativeTo, relativePoint, xOfs - 2, yOfs + 2)
    end

    self.selected = not self.selected

    if self.selected == true then
        self.Selected:Show()
    else
        self.Selected:Hide()
    end
end

function AltasiaQuestSummaryZoneListviewItemMixin:OnMouseDown()
    if self.enabled == true then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        self:ClearAllPoints()
        self:SetPoint(point, relativeTo, relativePoint, xOfs + 2, yOfs - 2)
    end

    alt:QuestSummaryZoneButtons_PurgeSelectedStates()
    alt:QuestSummaryQuestButtons_PurgeSelectedStates()

    AltasiaQuestSummaryZoneListview_OnSelectionChanged(self)
end

function AltasiaQuestSummaryZoneListview_OnSelectionChanged(item)
    alt:HideQuestSummaryQuestButtons()
    if item.quests then
        local i = 1;
        for questID, characters in pairs(item.quests) do
            if not alt.ui.questSummary.questButtons[i] then
                alt.ui.questSummary.questButtons[i] = CreateFrame("FRAME", "AltasiaQuestSummaryListviewButton"..i, alt.ui.questSummary.questListview:GetScrollChild(), "AltasiaListviewItem_QuestSummary_Quest")
            end
            alt.ui.questSummary.questButtons[i]:SetPoint('TOP', 6, (i * -30) + 30)
            alt.ui.questSummary.questButtons[i]:SetQuestText(DataStore_QuestsDB_Extra[questID].Title)
            alt.ui.questSummary.questButtons[i].questID = questID
            alt.ui.questSummary.questButtons[i].characters = characters
            alt.ui.questSummary.questButtons[i]:Show()
            i = i + 1;
        end
        alt.ui.questSummary.questListview:GetScrollChild():SetHeight((i - 1) * 30)
    end
end







AltasiaQuestSummaryQuestListviewItemMixin = {}

function AltasiaQuestSummaryQuestListviewItemMixin:SetQuestText(quest)
    self.QuestText:SetText(quest)
end

function AltasiaQuestSummaryQuestListviewItemMixin:OnEnter()
    self.Highlight:Show()
end

function AltasiaQuestSummaryQuestListviewItemMixin:OnLeave()
    self.Highlight:Hide()
end

function AltasiaQuestSummaryQuestListviewItemMixin:OnMouseUp()
    if self.enabled == true then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        self:ClearAllPoints()
        self:SetPoint(point, relativeTo, relativePoint, xOfs - 1, yOfs + 1)
    end

    self.selected = not self.selected

    if self.selected == true then
        self.Selected:Show()
    else
        self.Selected:Hide()
    end
end

function AltasiaQuestSummaryQuestListviewItemMixin:OnMouseDown()
    if self.enabled == true then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        self:ClearAllPoints()
        self:SetPoint(point, relativeTo, relativePoint, xOfs + 1, yOfs - 1)
    end

    alt:QuestSummaryQuestButtons_PurgeSelectedStates()

    AltasiaQuestSummaryQuestListview_OnSelectionChanged(self)
end

function AltasiaQuestSummaryQuestListview_OnSelectionChanged(self)

    if self.questID and DataStore_QuestsDB_Extra[self.questID] then
        alt.ui.questSummary.questDetailFrame.questTitle:SetText(DataStore_QuestsDB_Extra[self.questID].Title)
        alt.ui.questSummary.questDetailFrame.questObjectives:SetText(DataStore_QuestsDB_Extra[self.questID].Objectives)
        alt.ui.questSummary.questDetailFrame.questDescription:SetText(DataStore_QuestsDB_Extra[self.questID].Description)

        local chars = "";
        for character, realm in pairs(self.characters) do
            chars = chars..character.." - "..realm.."\n";
        end
        alt.ui.questSummary.questDetailFrame.questCharacters:SetText(chars)
    end
end
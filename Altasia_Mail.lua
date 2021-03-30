

local addonName, alt = ...

local L = alt.Locales

AltasiaMailSummaryListviewItemMixin = {}
AltasiaMailSummaryListviewItemMixin.selected = false;

function AltasiaMailSummaryListviewItemMixin:SetSender(sender)
    self.Sender:SetText(sender)
end

function AltasiaMailSummaryListviewItemMixin:SetSubject(subject)
    self.Subject:SetText(subject)
end

function AltasiaMailSummaryListviewItemMixin:OnEnter()
    self.Highlight:Show()
end

function AltasiaMailSummaryListviewItemMixin:OnLeave()
    self.Highlight:Hide()
end

function AltasiaMailSummaryListviewItemMixin:OnMouseUp()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    self:ClearAllPoints()
    self:SetPoint(point, relativeTo, relativePoint, xOfs - 1, yOfs + 1)

    self.selected = not self.selected

    if self.selected == true then
        self.Selected:Show()
    else
        self.Selected:Hide()
    end
end

function AltasiaMailSummaryListviewItemMixin:OnMouseDown()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    self:ClearAllPoints()
    self:SetPoint(point, relativeTo, relativePoint, xOfs + 1, yOfs - 1)

    alt:MailSummaryInboxButtons_PurgeSelectedStates()

    if self.mail then
        print("================")
        for k, v in pairs(self.mail) do
            if type(v) == 'table' then
                for a, b in pairs(v) do
                    print(a, b)
                end
            else
                print(k, v)
            end
        end
    end
end


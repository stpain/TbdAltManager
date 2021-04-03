

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

function AltasiaMailSummaryListviewItemMixin:HasWarning(b)
    if b == true then
        self.Warning:Show()
    else
        self.Warning:Hide()
    end
end

function AltasiaMailSummaryListviewItemMixin:OnEnter()
    self.Highlight:Show()
end

function AltasiaMailSummaryListviewItemMixin:OnLeave()
    self.Highlight:Hide()
end

function AltasiaMailSummaryListviewItemMixin:SetSelected(selected)

end

function AltasiaMailSummaryListviewItemMixin:OnMouseUp()

end

function AltasiaMailSummaryListviewItemMixin:SetMail(mail)
    self.mail = mail;
end

function AltasiaMailSummaryListviewItemMixin:OnMouseDown()

    alt:MailSummaryItemsFrame_Clear()

    if self.mail then
        alt.ui.mailSummary.subject:SetText(string.format("<%s>", self.mail.Subject))
        alt.ui.mailSummary.from:SetText(string.format("%s: %s", L['From'], self.mail.From))
        alt.ui.mailSummary.to:SetText(string.format("%s: %s", L['To'], self.mail.To))
        alt.ui.mailSummary.message:SetText(string.format("%s", self.mail.Message))
        local days = string.format("%.02f", tonumber(self.mail.DaysLeft))
        --alt.ui.mailSummary.daysLeft:SetText(string.format("Days remaining %s", days))
        alt.ui.mailSummary.daysLeft:SetText(string.format("Expires: %s", SecondsToTime(tonumber(days) * 24 * 60 * 60)))

        for k, v in ipairs(self.mail.Items) do
            alt.ui.mailSummary.items[k]:SetItem(v)
        end
    end
end


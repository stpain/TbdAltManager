

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

function AltasiaMailSummaryListviewItemMixin:SetSelected(selected)

end

function AltasiaMailSummaryListviewItemMixin:OnMouseUp()

end

function AltasiaMailSummaryListviewItemMixin:SetMail(mail)
    self.mail = mail;
end

function AltasiaMailSummaryListviewItemMixin:OnMouseDown()

    if self.mail then
        -- print("================")
        -- for k, v in pairs(self.mail) do
        --     if type(v) == 'table' then
        --         for a, b in pairs(v) do
        --             print(a, b)
        --         end
        --     else
        --         print(k, v)
        --     end
        -- end

        alt.ui.mailSummary.subject:SetText(string.format("<%s>", self.mail.Subject))
        alt.ui.mailSummary.from:SetText(string.format("%s: %s", L['From'], self.mail.From))
        alt.ui.mailSummary.to:SetText(string.format("%s: %s", L['To'], self.mail.To))
        alt.ui.mailSummary.message:SetText(string.format("%s", self.mail.Message))

        local links = "";
        for k, v in ipairs(self.mail.Items) do
            links = links..v.link.."\n";
        end
        alt.ui.mailSummary.itemLinks:SetText(links)
    end
end


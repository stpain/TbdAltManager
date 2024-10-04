

local _, TbdAltManager = ...;

TbdAltManager.Api = {}

function TbdAltManager.Api.CreateContextMenu(parent, menu)
    MenuUtil.CreateContextMenu(parent, function(parent, rootDescription)

        for _, element in ipairs(menu) do
            if element.isTitle then
                rootDescription:CreateTitle(element.text)

            elseif element.isSeparater then
                rootDescription:CreateSpacer()

            elseif element.isDivider then
                rootDescription:CreateDivider()

            else
                rootDescription:CreateButton(element.text, element.func)
            end
        end
        -- if fadeDelay then
        --     local elapsed = 0;
        --     local function onUpdate(_, t)
        --         elapsed = elapsed + t
        --         if elapsed > fadeDelay then
        --             dropdown:Hide()
        --         end
        --     end
        --     dropdown:HookScript("OnLeave", function()
        --         dropdown:HookScript("OnUpdate", onUpdate)
        --     end)
        --     dropdown:HookScript("OnEnter", function()
        --         elapsed = 0;
        --     end)
        -- end
    end)
end

function TbdAltManager.Api.ColourizeText(stringToColour, fontStringToColour, class)

    if type(class) == "number" then
        local _, classString = GetClassInfo(class)
        if classString then
            if stringToColour then
                return RAID_CLASS_COLORS[classString]:WrapTextInColorCode(stringToColour)
            elseif fontStringToColour then
                local text = fontStringToColour:GetText()
                fontStringToColour:SetText(RAID_CLASS_COLORS[classString]:WrapTextInColorCode(text))
            end
        end
    end

end

function TbdAltManager.Api.UpdateTreeviewNodeToggledState(frame, node)
    if node:IsCollapsed() then
        frame.parentRight:SetAtlas("Options_ListExpand_Right")
    else
        frame.parentRight:SetAtlas("Options_ListExpand_Right_Expanded")
    end
end

function TbdAltManager.Api.ResetSideMenuFrame(frame)
    frame.icon:SetSize(1, 1)
    frame.icon:SetTexture(nil)
    frame.label:SetText("")
    frame.iconMask:Hide()
    frame.iconRing:Hide()
    frame.toggleButton:Hide()
end

function TbdAltManager.Api.SortCharactersFunc(character1, character2)
    if character1.level == character2.level then
        if character1.class == character2.class then
            return character1.uid < character2.uid
        else
            return character1.class < character2.class
        end
    else
        return character1.level > character2.level;
    end
end
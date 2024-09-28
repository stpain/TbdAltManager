

local _, TbdAltManager = ...;

TbdAltManager.Api = {}

-- function TbdAltManager.Api.UpdateTreeviewNodeToggledState(frame, node)
--     if not node:IsCollapsed() then
--         frame.parentRight:SetAtlas("Options_ListExpand_Right")
--     else
--         frame.parentRight:SetAtlas("Options_ListExpand_Right_Expanded")
--     end
-- end

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
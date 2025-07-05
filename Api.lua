

local _, TbdAltManager = ...;



--global namespace
TbdAltsManager = { Api = {}, }

function TbdAltsManager.Api.RegisterModule(module)
    TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Module_OnRegistered, module)
end

function TbdAltsManager.Api.SelectModule(module)
    TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Module_OnSelected, module)
end

local SIDE_MENU_ELEMENT_HEIGHT = 35
function TbdAltsManager.Api.SetupSideMenuItem(frame, mask, isParent)
    frame:SetHeight(SIDE_MENU_ELEMENT_HEIGHT)
    frame.Icon:SetSize(SIDE_MENU_ELEMENT_HEIGHT-4, SIDE_MENU_ELEMENT_HEIGHT-4)
    frame.IconMask:SetSize(SIDE_MENU_ELEMENT_HEIGHT-6, SIDE_MENU_ELEMENT_HEIGHT-6)
    frame.IconRing:SetSize(SIDE_MENU_ELEMENT_HEIGHT+16, SIDE_MENU_ELEMENT_HEIGHT+16)
    if mask then
        frame.IconMask:Show()
        frame.IconRing:Show()
    else
        frame.IconMask:Hide()
        frame.IconRing:Hide()
    end
    if isParent then
        frame.ToggleButton:SetSize(SIDE_MENU_ELEMENT_HEIGHT-12, SIDE_MENU_ELEMENT_HEIGHT-12)
        frame.ToggleButton:Show()
    end
end

TbdAltsManager.Api.SecondsFormatter = CreateFromMixins(SecondsFormatterMixin)
TbdAltsManager.Api.SecondsFormatter:Init(1, 1, false, false)

function TbdAltsManager.Api.DeleteCharacter(characterUID)

end


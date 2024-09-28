

local addonName, TbdAltManager = ...;

function TbdAltManager:debug(...)
    local data = ...;
    if (data) then
        if (type(data) == "table") then
            UIParentLoadAddOn("Blizzard_DebugTools");
            --DevTools_Dump(data);
            DisplayTableInspectorWindow(data);
        else
            print("TbdAltManager Debug:", ...);
        end
    end
end


local e = CreateFrame("Frame")

function e:ADDON_LOADED(...)

    if ... == addonName then
        TbdAltManager.Database:Init()
    end

    if (...):find("TbdAltManager_") then
        TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Addon_OnLoaded, ...)
    end
end


e:RegisterEvent("ADDON_LOADED")
e:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](e, ...)
    end
end)
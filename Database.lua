

local addonName, TbdAltManager = ...;

local Database = {};

function Database:Init(forceReset)

    if not TbdAltManagerAccount then
        TbdAltManagerAccount = {
            characters = {},
            config = {},
        };
    end

    if forceReset then
        self:ResetSavedVariables()
    end

    self.db = TbdAltManagerAccount;
    --DevTools_Dump(self.db)
    TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Database_OnInitialised)

end

function Database:ResetSavedVariables()

    TbdAltManagerAccount = {
        characters = {},
        config = {},
    };
    self.db = TbdAltManagerAccount;

end

function Database:RegisterCharacter(characterKey, character)

    if not self.db.characters[characterKey] then
        self.db.characters[characterKey] = character
    end

    TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Database_OnCharacterRegistered)
end


TbdAltManager.Database = Database;
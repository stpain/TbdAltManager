

local _, TbdAltManager = ...;


TbdAltManager.Callbacks = {
    Database_OnInitialised = "DATABASE_INITIALISED",
    Database_OnCharacterRegistered = "DATABASE_CHARACTER_REGISTERED",

    Module_OnRegistered = "MODULE_ON_REGISTERED",

    Module_OnSelected = "MODULE_SELECTED",
}

local callbacksToRegister = {}
for k, v in pairs(TbdAltManager.Callbacks) do
    table.insert(callbacksToRegister, v)
end

TbdAltManager.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
TbdAltManager.CallbackRegistry:OnLoad()
TbdAltManager.CallbackRegistry:GenerateCallbackEvents(callbacksToRegister)









-- TbdAltManager_Global = {}
-- TbdAltManager_Global.Callbacks = {
--     ResetCharacterData_AllModules = "DATABASE_RESET_ALL_MODULES_CHARACTER_DATA",

--     CustomModuleLoaded = "CUSTOM_MODDULE_LOADED",
-- }

-- local globalCallbacksToRegister = {}
-- for k, v in pairs(TbdAltManager_Global.Callbacks) do
--     table.insert(globalCallbacksToRegister, v)
-- end

-- TbdAltManager_Global.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
-- TbdAltManager_Global.CallbackRegistry:OnLoad()
-- TbdAltManager_Global.CallbackRegistry:GenerateCallbackEvents(globalCallbacksToRegister)
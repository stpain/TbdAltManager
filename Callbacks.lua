

local _, TbdAltManager = ...;


TbdAltManager.Callbacks = {
    Database_OnInitialised = "DATABASE_INITIALISED",
    Database_OnCharacterRegistered = "DATABASE_CHARACTER_REGISTERED",

    Addon_OnLoaded = "ADDON_LOADED",

    SummaryGridViewItem_OnMouseDown = "SUMMARY_GRIDVIEW_ITEM_MOUSE_DOWN",

    InboxListviewItem_OnMouseDown = "INBOX_LISTVIEW_ITEM_MOUSE_DOWN",

    Module_OnSelected = "MODULE_SELECTED",

    Addon_OnResizeChanged = "ADDON_SIZE_CHANGED",
}

local callbacksToRegister = {}
for k, v in pairs(TbdAltManager.Callbacks) do
    table.insert(callbacksToRegister, v)
end

TbdAltManager.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
TbdAltManager.CallbackRegistry:OnLoad()
TbdAltManager.CallbackRegistry:GenerateCallbackEvents(callbacksToRegister)


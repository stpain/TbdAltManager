

local addonName, TbdAltManager = ...;

--[[

    locales:
        _TT tooltips,
        _HT helptips,
]]
local L = {

    LEVEL_S = "|cffE4CA00Level|r %s",
    TIME_PLAYED_LEVEL_S = "|cffE4CA00Played this level|r %s",
    MONEY = "|cffE4CA00Gold|r %s",
    BAG_SPACE_SSS = "|cffE4CA00Bag slots|r [%s / %s] - %s available",
    BANK_SPACE_SSS = "|cffE4CA00Bank slots|r [%s / %s] - %s available",

    CHARACTER_XP_TOOLTIP = "Rested XP works out to be half the value due to how its consumed.",

    SIDE_BAR_MENU_CHARACTERS = "Characters",
    SIDE_BAR_MENU_CHARACTERS_TT = "|cffffffffSummary|r\n\nSummary view",
    SIDE_BAR_MENU_CONTAINERS = "Containers",
    SIDE_BAR_MENU_CONTAINERS_TT = "|cffffffffContainers|r\n\nContainer information.",
    SIDE_BAR_MENU_TRADESKILLS = "Tradeskills",
    SIDE_BAR_MENU_TRADESKILLS_TT = "|cffffffffTradeskills|r\n\nView profession recipes",
    SIDE_BAR_MENU_CURRENCY = "Currency",
    SIDE_BAR_MENU_CURRENCY_TT = "|cffffffffCurrency|r\n\nView currencies",
    SIDE_BAR_MENU_QUESTS = "Quests",
    SIDE_BAR_MENU_QUESTS_TT = "|cffffffffQuests|r\n\nQuest information.",
    SIDE_BAR_MENU_MAIL = "Mail",
    SIDE_BAR_MENU_MAIL_TT = "|cffffffffMail|r\n\nView mail",
    SIDE_BAR_MENU_SETTINGS = "Settings",
    SIDE_BAR_MENU_SETTINGS_TT = "|cffffffffSettings|r\n\nPlace to make changes about things.",
    SIDE_BAR_MENU_REPUTATIONS = "Reputations",
    SIDE_BAR_MENU_REPUTATIONS_TT = "|cffffffffSettings|r\n\nView your standings.",

    CONTENT_SUMMARY_CHARACTER_GRIDVIEW_ITEM_LEVEL = "Level",
    CONTENT_SUMMARY_CHARACTER_GRIDVIEW_ITEM_ILVL = "ilvl",

    CONTENT_SUMMARY_CHARACTER_DETAILS_TAB_GENERAL = "General",
    CONTENT_SUMMARY_CHARACTER_DETAILS_TAB_INVENTORY = "Inventory",
    CONTENT_SUMMARY_CHARACTER_DETAILS_TAB_REPUTATIONS = "Reputations",

    CONTENT_SUMMARY_CHARACTER_GRIDVIEW_MENU_INFO = "Info",
    CONTENT_SUMMARY_CHARACTER_GRIDVIEW_MENU_EQUIPMENT = "Equipment",
    CONTENT_SUMMARY_CHARACTER_GRIDVIEW_MENU_TRADESKILLS = "Tradeskills",
    CONTENT_SUMMARY_CHARACTER_GRIDVIEW_MENU_CONTAINERS = "Containers",
    CONTENT_SUMMARY_CHARACTER_GRIDVIEW_MENU_ACHIEVEMENTS = "Achievements",
    CONTENT_SUMMARY_CHARACTER_GRIDVIEW_MENU_REPUTATIONS = "Reputations",

    CONTENT_CONTAINERS_CHARACTER_DROPDOWN_ALL = "All characters",
    CONTENT_CONTAINERS_ITEM_CLASS_DROPDOWN_ALL = "All types",

    CONTENT_MAIL_SENDER = "Sender",
    CONTENT_MAIL_SUBJECT = "Subject",
    CONTENT_MAIL_DAYS_LEFT = "Days left",
    CONTENT_MAIL_NUM_ATTACHMENTS = "Attachments",
}

TbdAltManager.locales = L;
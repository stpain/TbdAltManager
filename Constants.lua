
--[[

    local t = {
        {
            --icon = "AutoQuest-Badge-Campaign",
            --icon = "128-Store-Main",
            --icon = 1418620,

            icon = "socialqueuing-icon-group",
            addMask = true,
            label = L.SIDE_BAR_MENU_SUMMARY,
            tooltip = L.SIDE_BAR_MENU_SUMMARY_TT,
            func = function()
                self:ClearContentView()
                self:ContentSummaryView_Show()
                self:UpdateLayout()
            end,
        },
        {
            icon = "bag-main",
            label = L.SIDE_BAR_MENU_CONTAINERS,
            tooltip = L.SIDE_BAR_MENU_CONTAINERS_TT,
            func = function()
                self:ClearContentView()
                self:ContentContainerView_Show()
                self:UpdateLayout()
            end,
        },
        {
            icon = 4217590,
            addMask = true,
            label = L.SIDE_BAR_MENU_TRADESKILLS,
            tooltip = L.SIDE_BAR_MENU_TRADESKILLS_TT,
            func = function()
                self:ClearContentView()

                self:UpdateLayout()
            end,
        },
        {
            icon = "bags-icon-junk",
            label = L.SIDE_BAR_MENU_CURRENCY,
            tooltip = L.SIDE_BAR_MENU_CURRENCY_TT,
            func = function()
                self:ClearContentView()

                self:UpdateLayout()
            end,
        },
        {
            --icon = "AutoQuest-Badge-Campaign",
            icon = "Mobile-LegendaryQuestIcon-Desaturated",
            label = L.SIDE_BAR_MENU_QUESTS,
            tooltip = L.SIDE_BAR_MENU_QUESTS_TT,
            func = function()
                self:ClearContentView()

                self:UpdateLayout()
            end,
        },
        {
            icon = "communities-icon-invitemail",
            label = L.SIDE_BAR_MENU_MAIL,
            tooltip = L.SIDE_BAR_MENU_MAIL_TT,
            func = function()
                self:ClearContentView()
                self:ContentMailsView_Show()
                self:UpdateLayout()
            end,
        },
        {
            icon = "mechagon-projects",
            label = L.SIDE_BAR_MENU_SETTINGS,
            tooltip = L.SIDE_BAR_MENU_SETTINGS_TT,
            func = function()
                self:ClearContentView()
                self.content.settings:Show()
                self:UpdateLayout()
            end,
        },

    }


]]



local _, TbdAltManager = ...;

local L = TbdAltManager.locales

TbdAltManager.Constants = {}

local SIDE_MENU_ELEMENT_HEIGHT = 35

local function setupSideMenuItem(frame, mask, isParent)
    frame:SetHeight(SIDE_MENU_ELEMENT_HEIGHT)
    frame.icon:SetSize(SIDE_MENU_ELEMENT_HEIGHT-2, SIDE_MENU_ELEMENT_HEIGHT-2)
    frame.iconMask:SetSize(SIDE_MENU_ELEMENT_HEIGHT-4, SIDE_MENU_ELEMENT_HEIGHT-4)
    frame.iconRing:SetSize(SIDE_MENU_ELEMENT_HEIGHT-3, SIDE_MENU_ELEMENT_HEIGHT-3)
    if mask then
        frame.iconMask:Show()
        frame.iconRing:Show()
    else
        frame.iconMask:Hide()
        frame.iconRing:Hide()
    end
    if isParent then
        frame.toggleButton:SetSize(SIDE_MENU_ELEMENT_HEIGHT-12, SIDE_MENU_ELEMENT_HEIGHT-12)
        frame.toggleButton:Show()
    end
end

TbdAltManager.Constants.SideMenuInitializers = {
    Characters = function(frame, node)
        setupSideMenuItem(frame, true)
        frame.icon:SetAtlas("socialqueuing-icon-group")
        frame.label:SetText(L.SIDE_BAR_MENU_SUMMARY)
        frame.tooltip = L.SIDE_BAR_MENU_SUMMARY_TT
        frame:SetScript("OnMouseDown", function()
            TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Module_OnSelected, "Characters")
        end)
    end,
    Containers = function(frame, node)
        setupSideMenuItem(frame)
        frame.icon:SetAtlas("bag-main")
        frame.label:SetText(L.SIDE_BAR_MENU_CONTAINERS)
        frame.tooltip = L.SIDE_BAR_MENU_CONTAINERS_TT
        frame:SetScript("OnMouseDown", function()
            TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Module_OnSelected, "Containers")
        end)
    end,
    Tradeskills = function(frame, node)
        setupSideMenuItem(frame, true, true)
        frame.icon:SetTexture(4217590)
        frame.label:SetText(L.SIDE_BAR_MENU_TRADESKILLS)
        frame.tooltip = L.SIDE_BAR_MENU_TRADESKILLS_TT
        frame:SetScript("OnMouseDown", function()
            TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Module_OnSelected, "Tradeskills")
        end)

        frame.toggleButton:SetScript("OnClick", function()
            node:ToggleCollapsed()
            if node:IsCollapsed() then
                frame.toggleButton:SetNormalAtlas("128-RedButton-Plus")
                frame.toggleButton:SetPushedAtlas("128-RedButton-Plus-Pressed")
            else
                frame.toggleButton:SetNormalAtlas("128-RedButton-Minus")
                frame.toggleButton:SetPushedAtlas("128-RedButton-Minus-Pressed")
            end
        end)
    end,
    Reputations = function(frame, node)
        setupSideMenuItem(frame, true, true)
        frame.icon:SetAtlas("poi-hub")
        frame.label:SetText(L.SIDE_BAR_MENU_REPUTATIONS)
        frame.tooltip = L.SIDE_BAR_MENU_REPUTATIONS_TT
        frame:SetScript("OnMouseDown", function()
            TbdAltManager.CallbackRegistry:TriggerEvent(TbdAltManager.Callbacks.Module_OnSelected, "Reputations")
        end)

        frame.toggleButton:SetScript("OnClick", function()
            node:ToggleCollapsed()
            if node:IsCollapsed() then
                frame.toggleButton:SetNormalAtlas("128-RedButton-Plus")
                frame.toggleButton:SetPushedAtlas("128-RedButton-Plus-Pressed")
            else
                frame.toggleButton:SetNormalAtlas("128-RedButton-Minus")
                frame.toggleButton:SetPushedAtlas("128-RedButton-Minus-Pressed")
            end
        end)
    end,
}

--[[

    The side menu uses a no template treeview
    the data provider is passed a template and an initializer function
    this function receives the frame and the node
    the above table contains the initializer functions where frames are setup
]]

TbdAltManager.Constants.Modules = {
    Characters = {
        sideMenu = {
            height = 36,
            template = "TbdAltManagerSideBarListviewItemTemplate",
            initializer = TbdAltManager.Constants.SideMenuInitializers.Characters,
        },
        frameTemplate = "TbdAltManagerCharactersModule"
    },
    Containers = {
        sideMenu = {
            height = 36,
            template = "TbdAltManagerSideBarListviewItemTemplate",
            initializer = TbdAltManager.Constants.SideMenuInitializers.Containers,
        },
        frameTemplate = "TbdAltManagerContainersModule",
    },
    Tradeskills = {
        sideMenu = {
            height = 36,
            template = "TbdAltManagerSideBarListviewItemTemplate",
            initializer = TbdAltManager.Constants.SideMenuInitializers.Tradeskills,
        },
        frameTemplate = "TbdAltManagerTradeskillsModule",
    },
    Reputations = {
        sideMenu = {
            height = 36,
            template = "TbdAltManagerSideBarListviewItemTemplate",
            initializer = TbdAltManager.Constants.SideMenuInitializers.Reputations,
        },
        frameTemplate = "TbdAltManagerReputationsModule",
    },
}


TbdAltManager.Constants.ExpansionCinematicButtonAtlasList = {
    {
        name = "Classic",
        id = LE_EXPANSION_CLASSIC,
        button = {
            down = "StreamCinematic-Classic-Large-Down",
            up = "StreamCinematic-Classic-Large-Up",
        }
    },
}



--[[

https://wago.tools/db2/Achievement_Category?filter[Parent]=201&page=1

/dump GetAchievementInfo(15439, 2)
]]

TbdAltManager.Constants.ReputationIcons = {
    [2590] = 5891369, --council of dornogal
    [2594] = 5891367, --cassembly of deeps
    [2570] = 5891368, --hallowfall
    [2605] = 5862762, --the general
    [2607] = 5862763, --the vizer
    [2601] = 5862764, --the weaver
    [2640] = 6025441, --brann

    [2503] = 4687627, --maruuk
    [2507] = 4687628, --dragonscale

    [2407] = 3555147, --ascended
    [2410] = 3604102, --undying army
    [2465] = 3517784, --the wild hunt

    [2413] = 3540525, --court harvester
    [2470] = 4083292, --deaths advance
    [2472] = 2178528, --archavist codex

    [2159] = 2024072, --7th legion
    [2164] = 2065570, --champions of azeroth
    [2161] = 2065572, --order of embers
    [2160] = 2065573, --proudmore admiralty
    [2415] = 3196265, --rajani
    [2391] = 2915722, --rustbolt
    [2162] = 2065574, --storms wake
    [2163] = 2065576, --tortollan
    [2417] = 3196264, --uldum
    [2400] = 2909045, --waveblade

    [2170] = 1714098, --argussian reach
    [2045] = 1585421, --army legionfall
    [2165] = 1714094, --of the light
    [2135] = 236699, --chromie
    [1900] = 326001, --farondis
    --[1883] = 
    [1828] = 1394954, --highmountain tribe
    [1859] = 1394956, --nightfallen

    [1515] = 1042646, --arakkoa
    [1731] = 1048727, --council exarchs
    [1847] = 1048305, --hand of prophet
    [1849] = 1048305, --order of awakened
    [1711] = 463874, --steamweedle

    [1281] = 645198, --tillers

    [1492] = 607848, --emporer shaohao
    [1269] = 643910, --golden lotus
    [1242] = 236688, --pearlfin
    [1270] = 645204, --shado-pan
    [1302] = 643874, --anglers
    [1341] = 645203, --august celestials
    [1359] = 656543, --black prince
    [1337] = 646377, --klaxxi

    [1158] = 456570, --guardians hyjal
    [1173] = 456574, --ramkahen
    [1135] = 456567, --earthen ring
    [1174] = 456575, --wildhammer
}
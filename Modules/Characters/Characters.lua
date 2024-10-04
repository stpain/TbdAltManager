

local name, TbdAltManager = ...;

local L = TbdAltManager.locales;

local roleIcons = {
    DAMAGER = "UI-LFG-RoleIcon-DPS-Micro",
    TANK = "UI-LFG-RoleIcon-Tank-Micro",
    HEALER = "UI-LFG-RoleIcon-Healer-Micro",
    RANGED = "UI-LFG-RoleIcon-RangedDPS-Micro",
}


TbdAltManagerCharacterModuleListviewItemMixin = {}
function TbdAltManagerCharacterModuleListviewItemMixin:OnLoad()
    TbdAltManager_Characters.CallbackRegistry:RegisterCallback("Character_OnChanged", self.OnCharacterDataChanged, self)

    -- local mask = self.classIcon:CreateMaskTexture()
    -- mask:SetAllPoints(self.classIcon:GetNormalTexture())
    -- mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    -- self.classIcon:GetNormalTexture():AddMaskTexture(mask)
end

function TbdAltManagerCharacterModuleListviewItemMixin:OnMouseDown(hardwareButton)

    if (hardwareButton == "RightButton") and self.character then
        local menu = {
            {
                text = OPTIONS,
                isTitle = true,
            },
            {
                text = DELETE,
                func = function()
                    TbdAltManager_Characters.Api.DeleteCharacterByCharacterUID(self.character.uid)
                end,
            }
        }

        TbdAltManager.Api.CreateContextMenu(self, menu)
    end
end

function TbdAltManagerCharacterModuleListviewItemMixin:SetDataBinding(binding, height)
    self:SetHeight(height)
    self.character = binding;
    self:Update()

    self.portrait:SetSize(height-2, height-2)
    self.portraitMask:SetSize(height-2, height-2)
    self.portraitBorder:SetSize(height-2, height-2)

    self.background:ClearAllPoints()
    self.background:SetPoint("TOPLEFT", height / 2, 0)
    self.background:SetPoint("BOTTOMRIGHT", 0, 0)

    self.race:SetHeight(height / 2)
    self.class:SetHeight(height / 2)
    self.profession1:SetHeight(height / 2)
    self.profession2:SetHeight(height / 2)
end

function TbdAltManagerCharacterModuleListviewItemMixin:OnCharacterDataChanged(character)
    if self.character and (self.character.uid == character.uid) then
        self.character = character
        self:Update()
    end
end

function TbdAltManagerCharacterModuleListviewItemMixin:Update()

    --raceicon128-draenei-female

    if self.character then

        if self.character.gender and self.character.race then
            local raceInfo = C_CreatureInfo.GetRaceInfo(self.character.race)
            --self.race:SetText(raceInfo.raceName)

            local gender = self.character.gender == 3 and "female" or "male"
            local race = raceInfo.raceName:lower():gsub(" ", "")

            if raceInfo.raceName:lower():find("lightforged", nil, true) then
                race = "lightforged";
            end

            self.portrait:SetAtlas(string.format("raceicon128-%s-%s", race, gender))
        end

        local account, realm, name = strsplit(".", self.character.uid)

        self.name:SetText(string.format("%s\n[%s]", name, realm))

        self.level:SetText(string.format("R: %d", self.character.xpRested))

        self.levelBar:SetMinMaxValues(1, self.character.xpMax)
        self.levelBar:SetValue(self.character.xp)
        self.levelBar.level:SetText(string.format("%d [%0.1f%%]", self.character.level, (self.character.xp / self.character.xpMax) * 100))

        self.levelBar:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.levelBar, "ANCHOR_RIGHT")
            GameTooltip:AddLine("XP")
            GameTooltip:AddLine(string.format("This level: %d / %d", self.character.xp, self.character.xpMax))
            GameTooltip:AddLine(string.format("Rested: %d [%d]", self.character.xpRested, math.floor(self.character.xpRested / 2)))
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L.CHARACTER_XP_TOOLTIP)
            GameTooltip:Show()
        end)
        self.levelBar:SetScript("OnLeave", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)

        self.ilvl:SetText(string.format("%d / %d\nPvP %d", self.character.averageItemLevels[2], self.character.averageItemLevels[1], self.character.averageItemLevels[3]))
        
        if self.character.class then
            local class, classString, classID = GetClassInfo(self.character.class)
            if class then
                if (self.character.currentSpecialization > 0) and (self.character.level > 9) then
                local id, specName, description, icon, role, isRecommended, isAllowed = GetSpecializationInfoForSpecID(self.character.currentSpecialization)
                self.class:SetText(string.format("%s %s", specName, class))
                    self.classIcon.icon:SetTexture(icon)
                    self.classIcon:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(self.classIcon, "ANCHOR_RIGHT")
                        GameTooltip:AddLine(specName)
                        GameTooltip:AddLine(description, 1,1,1)
                        GameTooltip:AddLine(_G[role])
                        GameTooltip:Show()
                    end)
                    self.classIcon.roleIcon:SetAtlas(roleIcons[role])
                else
                    self.class:SetText(class)
                    self.classIcon.icon:SetAtlas(string.format("classicon-%s", classString:lower()))
                end
            end
            if classString then
                local r, g, b = RAID_CLASS_COLORS[classString]:GetRGB()
                self.background:SetColorTexture(r, g, b, 0.075)
                self.classIcon.border:SetVertexColor(r, g, b, 1)
            end
        end

        self.location:SetText( string.format("%s\n%s", self.character.zone, self.character.subZone))

        if self.character.profession1 > 0 then
            local profession1 = C_TradeSkillUI.GetProfessionInfoBySkillLineID(self.character.profession1)
            if profession1 and profession1.professionName then
                self.profession1:SetText(profession1.professionName)
            end
        end

        if self.character.profession2 > 0 then
            local profession2 = C_TradeSkillUI.GetProfessionInfoBySkillLineID(self.character.profession2)
            if profession2 and profession2.professionName then
                self.profession2:SetText(profession2.professionName)
            end
        end

        self.gold:SetText(C_CurrencyInfo.GetCoinTextureString(self.character.gold, 14))
    end

end

function TbdAltManagerCharacterModuleListviewItemMixin:UpdateLayout()
    
    local width = self:GetWidth()

    if width < 920 then
        self.location:SetWidth(width-780)
    end

    if width > 920 then
        self.location:SetWidth(140)
    end

end

function TbdAltManagerCharacterModuleListviewItemMixin:ResetDataBinding()
    
end



















TbdAltManagerCharactersModuleMixin = {}

function TbdAltManagerCharactersModuleMixin:OnLoad()

    self:SetNewDataProvider()

    self:SetupSortButtons()

    TbdAltManager_Characters.CallbackRegistry:RegisterCallback("DataProvider_OnInitialized", self.InitializeCharacters, self)
    TbdAltManager_Characters.CallbackRegistry:RegisterCallback("Character_OnAdded", self.InitializeCharacters, self)
    TbdAltManager_Characters.CallbackRegistry:RegisterCallback("Character_OnRemoved", self.Character_OnRemoved, self)
end

function TbdAltManagerCharactersModuleMixin:OnShow()

end

function TbdAltManagerCharactersModuleMixin:SetNewDataProvider()
    self.dataProvider = CreateFromMixins(DataProviderMixin)
    self.dataProvider:Init({})
    self.dataProvider:SetSortComparator(TbdAltManager.Api.SortCharactersFunc)
    self.listview.scrollView:SetDataProvider(self.dataProvider)
end

function TbdAltManagerCharactersModuleMixin:UpdateLayout()
    self.listview.scrollView:ForEachFrame(function(frame)
        if frame.UpdateLayout then
            frame:UpdateLayout()
        end
    end)
end

-- function TbdAltManagerCharactersModuleMixin:OnCharacterDataChanged(character)
--     local elementData = self.dataProvider:FindElementDataByPredicate(function(data)
--         return data.uid == character.uid
--     end)

--     if elementData then
--         local frame = self.listview.scrollView:FindFrame(elementData)
--         if frame and frame.Update then
--             frame:Update()
--         end
--     end
-- end

function TbdAltManagerCharactersModuleMixin:Character_OnRemoved(characterUID)
    self.dataProvider:RemoveByPredicate(function(character)
        return (character.uid == characterUID)
    end)
end

function TbdAltManagerCharactersModuleMixin:InitializeCharacters()

    self:SetNewDataProvider()

    if TbdAltManager_Characters and TbdAltManager_Characters.Api then
        for k, character in TbdAltManager_Characters.Api.EnumerateCharacters() do
            self.dataProvider:Insert(character)
        end
        self.dataProvider:Sort()
    end
end

function TbdAltManagerCharactersModuleMixin:SetupSortButtons()

    local function sortLevel(order)
        if order == 1 then
            return function(a, b)
                return a.level > b.level;
            end
        elseif order == 2 then
            return function(a, b)
                return a.level < b.level;
            end
        elseif order == 3 then
            return function(a, b)
                return a.xpRested > b.xpRested;
            end
        elseif order == 4 then
            return function(a, b)
                return a.xpRested < b.xpRested;
            end
        end
    end
  
    self.sortLevel.order = 1
    self.sortLevel:SetScript("OnClick", function(button)
        button.order = button.order + 1;
        if button.order == 5 then
            button.order = 1;
        end
        if button.order > 2 then
            button:SetText("Rested")
        else
            button:SetText(LEVEL)
        end
        self.dataProvider:SetSortComparator(sortLevel(button.order))
        self.dataProvider:Sort()
    end)

    local function sortItemLevel(order)
        return function(a, b)
            return a.averageItemLevels[order] > b.averageItemLevels[order];
        end
    end
    
    self.sortItemLevel.order = 1
    self.sortItemLevel:SetScript("OnClick", function(button)
        button.order = button.order + 1;
        if button.order == 4 then
            button.order = 1;
        end
        self.dataProvider:SetSortComparator(sortItemLevel(button.order))
        self.dataProvider:Sort()
    end)

    local function sortClass(order)
        if order == 1 then
            return function(a, b)
                return a.class < b.class
            end

        elseif order == 2 then
            return function(a, b)
                return a.class > b.class
            end
        end
    end

    self.sortClass.order = 1;
    self.sortClass:SetScript("OnClick", function(button)
        button.order = button.order + 1;
        if button.order == 3 then
            button.order = 1;
        end
        self.dataProvider:SetSortComparator(sortClass(button.order))
        self.dataProvider:Sort()
    end)

    local function sortTradeSkills(order)
        if order == 1 then
            return function(a, b)
                if a.profession1 and b.profession1 and a.profession2 and b.profession2 then
                    
                end
                return a.class < b.class
            end

        elseif order == 2 then
            return function(a, b)
                return a.class > b.class
            end
        end
    end

    self.sortTradeSkills.order = 1;
    self.sortTradeSkills:SetScript("OnClick", function(button)
        button.order = button.order + 1;
        if button.order == 3 then
            button.order = 1;
        end
        self.dataProvider:SetSortComparator(sortTradeSkills(button.order))
        self.dataProvider:Sort()
    end)

end
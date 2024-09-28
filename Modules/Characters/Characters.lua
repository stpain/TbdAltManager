

local name, TbdAltManager = ...;






TbdAltManagerCharacterModuleListviewItemMixin = {}
function TbdAltManagerCharacterModuleListviewItemMixin:OnLoad()

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

function TbdAltManagerCharacterModuleListviewItemMixin:Update()

    --raceicon128-draenei-female

    if self.character then

        if self.character.gender and self.character.race then
            local raceInfo = C_CreatureInfo.GetRaceInfo(self.character.race)
            self.race:SetText(raceInfo.raceName)

            local gender = self.character.gender == 3 and "female" or "male"
            local race = raceInfo.raceName:lower():gsub(" ", "")

            if raceInfo.raceName:lower():find("lightforged", nil, true) then
                race = "lightforged";
            end

            self.portrait:SetAtlas(string.format("raceicon128-%s-%s", race, gender))
        end

        local account, realm, name = strsplit(".", self.character.uid)

        self.name:SetText(string.format("%s\n[%s]", name, realm))

        self.level:SetText(self.character.level)
        
        if self.character.class then
            local class, classString, classID = GetClassInfo(self.character.class)
            self.class:SetText(class)

            local r, g, b = RAID_CLASS_COLORS[classString]:GetRGB()
            self.background:SetColorTexture(r, g, b, 0.15)
        end

        self.location:SetText(self.character.subZone)

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
    
    -- local width = self:GetWidth()

    -- if width < 1000 then
    --     self.race:SetWidth(1)
    --     self.race:Hide()
    -- end

    -- if width > 1000 then
    --     self.race:SetWidth(140)
    --     self.race:Show()
    -- end

end

function TbdAltManagerCharacterModuleListviewItemMixin:ResetDataBinding()
    
end



















TbdAltManagerCharactersModuleMixin = {}

function TbdAltManagerCharactersModuleMixin:OnLoad()

    self.dataProvider = CreateFromMixins(DataProviderMixin)
    self.dataProvider:Init({})
    self.dataProvider:SetSortComparator(TbdAltManager.Api.SortCharactersFunc)
    self.listview.scrollView:SetDataProvider(self.dataProvider)

    TbdAltManager_Characters.CallbackRegistry:RegisterCallback("DataProvider_OnInitialized", self.InitializeCharacters, self)
    TbdAltManager_Characters.CallbackRegistry:RegisterCallback("Character_OnAdded", self.InitializeCharacters, self)
    TbdAltManager_Characters.CallbackRegistry:RegisterCallback("Character_OnChanged", self.OnCharacterDataChanged, self)
end

function TbdAltManagerCharactersModuleMixin:OnShow()

end

function TbdAltManagerCharactersModuleMixin:UpdateLayout()
    -- self.listview.scrollView:ForEachFrame(function(frame)
    --     if frame.UpdateLayout then
    --         frame:UpdateLayout()
    --     end
    -- end)
end

function TbdAltManagerCharactersModuleMixin:OnCharacterDataChanged(character)
    local elementData = self.dataProvider:FindElementDataByPredicate(function(data)
        return data.uid == character.uid
    end)

    if elementData then
        local frame = self.listview.scrollView:FindFrame(elementData)
        if frame and frame.Update then
            frame:Update()
        end
    end
end

function TbdAltManagerCharactersModuleMixin:InitializeCharacters()
    self.dataProvider:Flush()
    if TbdAltManager_Characters and TbdAltManager_Characters.Api then
        for k, character in TbdAltManager_Characters.Api.EnumerateCharacters() do
            self.dataProvider:Insert(character)
        end
        self.dataProvider:Sort()
    end
end
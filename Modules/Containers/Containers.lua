



local name, TbdAltManager = ...;






TbdAltManagerContainersModuleTreeviewItemTemplateMixin = {}
function TbdAltManagerContainersModuleTreeviewItemTemplateMixin:OnLoad()
    self:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
end

function TbdAltManagerContainersModuleTreeviewItemTemplateMixin:SetDataBinding(node, height)

    local binding = node:GetData()
    
    self:SetHeight(height)

    if binding.isParent then
        self.parentLeft:Show()
        self.parentRight:Show()
        self.parentMiddle:Show()

    else
        self.background:SetAtlas(binding.backgroundAtlas)
    end

    if binding.label then
        self.linkLabel:SetText(binding.label)
    end

    if binding.onMouseDown then
        self.onMouseDown = binding.onMouseDown
        self.onMouseDown(self)
    end

    self:HookScript("OnMouseDown", function()
        if self.onMouseDown then
            self.onMouseDown(self)
        end
    end)

    if binding.deleteContainerData then
        self.deleteContainerDataButton:SetSize(height - 2, height - 2)
        self.deleteContainerDataButton:SetScript("OnClick", binding.deleteContainerData)
        self.deleteContainerDataButton:Show()
    end

    if binding.link and not binding.isParent then

        self:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetHyperlink(binding.link)
            GameTooltip:Show()
        end)

        self.linkLabel:SetText(string.format("%s %s", binding.slotStackCount, binding.link))

        self.classLabel:SetText(C_Item.GetItemClassInfo(binding.classID))
        self.subClassLabel:SetText(C_Item.GetItemSubClassInfo(binding.classID, binding.subClassID))


        -- local item = Item:CreateFromItemLink(binding.link)
        -- if not item:IsItemEmpty() then
        --     item:ContinueOnItemLoad(function()

        --         local subType = item:GetInventoryType()
                
        --         self.typeLabel:SetText()
        --     end)
        -- end
    end

end
function TbdAltManagerContainersModuleTreeviewItemTemplateMixin:ResetDataBinding()
    self.parentLeft:Hide()
    self.parentRight:Hide()
    self.parentMiddle:Hide()
    self.deleteContainerDataButton:Hide()
    self.deleteContainerDataButton:SetScript("OnClick", nil)
    self.icon:SetTexture(nil)
    self.onMouseDown = nil

    self:SetScript("OnEnter", nil)

    self.linkLabel:SetText("")

    self.classLabel:SetText("")
    self.subClassLabel:SetText("")

    self.background:SetTexture(nil)
end






local function SortContainerItems(item1, item2)
    local a = item1:GetData()
    local b = item2:GetData()

    --DevTools_Dump({a, b})

    if a.name and a.quality and b.name and b.quality and a.classID and b.classID and a.subClassID and b.subClassID then
        if a.classID == b.classID then
            if a.subClassID == b.subClassID then
                if a.quality == b.quality then
                    return a.name < b.name;
                else
                    return a.quality > b.quality;
                end
            else
                return a.subClassID < b.subClassID
            end
        else
            return a.classID < b.classID
        end
    end
end




--[[

    This template will be loaded after the relavent sub addon has loaded and notified this addon
    This addon then adds the sub addon to the side menu and creates this frame

]]
TbdAltManagerContainersModuleMixin = {}

function TbdAltManagerContainersModuleMixin:OnLoad()

    self.dataProvider = CreateTreeDataProvider() -- CreateFromMixins(DataProviderMixin)
    self.dataProvider:Init({})
    self.treeview.scrollView:SetDataProvider(self.dataProvider)

    self.treeviewNodes = {}

    self.dataReady = false;

    self.searchEditBox.ok:SetScript("OnClick", function()
        self:SearchForitem(self.searchEditBox:GetText())
    end)
    self.searchEditBox:SetScript("OnEnterPressed", function(editbox)
        self:SearchForitem(editbox:GetText())
    end)
    self.searchEditBox.cancel:SetScript("OnClick", function(editbox)
        editbox:SetText("")
        self.treeview.scrollView:SetDataProvider(self.dataProvider)
    end)

    TbdAltManager_Containers.CallbackRegistry:RegisterCallback("DataProvider_OnInitialized", self.OnDataInitialized, self)
    -- TbdAltManager_Containers.CallbackRegistry:RegisterCallback("Character_OnAdded", self.InitializeCharacters, self)
    TbdAltManager_Containers.CallbackRegistry:RegisterCallback("Character_OnChanged", self.UpdateDataProviderForCharacter, self)
end

function TbdAltManagerContainersModuleMixin:OnShow()
    if (self.dataReady == true) and (next(self.treeviewNodes) == nil) then
        self:LoadContainerData()
    end
end

function TbdAltManagerContainersModuleMixin:OnDataInitialized()
    self.dataReady = true;
    self:LoadContainerData()
end

function TbdAltManagerContainersModuleMixin:SearchForitem(item)
    
    local data = TbdAltManager_Containers.Api.GetContainerDataForItem(item)

    local tempDataProvider = CreateTreeDataProvider()
    tempDataProvider:Init({})
    self.treeview.scrollView:SetDataProvider(tempDataProvider)

    local charactersNodes = {}

    for k, result in ipairs(data) do

        local account, realm, name = strsplit(".", result.characterUID)

        if not charactersNodes[result.characterUID] then
            charactersNodes[result.characterUID] = tempDataProvider:Insert({
                label = name,
                isParent = true,
    
                -- onMouseDown = function(f)
                --     TbdAltManager.Api.UpdateTreeviewNodeToggledState(f, charactersNodes[result.characterUID])
                -- end,
            })
        end

        local _item = Item:CreateFromItemLink(result.item.link)
        if not _item:IsItemEmpty() then
            _item:ContinueOnItemLoad(function()

                local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = C_Item.GetItemInfoInstant(result.item.link)

                charactersNodes[result.characterUID]:Insert({
                    link = result.item.link,
                    equipLocation =_G[itemEquipLoc] or "",
                    icon = icon,

                    slotStackCount = result.item.count,

                    backgroundAtlas = "uitools-row-background-02",

                    --sort data
                    classID = classID,
                    subClassID = subClassID,
                    quality = _item:GetItemQuality(),
                    name = _item:GetItemName(),
                })

                --tempDataProvider:Sort()
            end)
        end
    end
end

function TbdAltManagerContainersModuleMixin:LoadItemsForBag(bagNode, bagItems)

    local numItems = #bagItems;

    local index = 1;

    local ticker = C_Timer.NewTicker(0.01, function()

        local itemInfo = bagItems[index]

        local item = Item:CreateFromItemLink(itemInfo.link)
        if not item:IsItemEmpty() then
            item:ContinueOnItemLoad(function()

                local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = C_Item.GetItemInfoInstant(itemInfo.link)

                bagNode:Insert({
                    link = itemInfo.link,
                    equipLocation =_G[itemEquipLoc] or "",
                    icon = icon,

                    slotStackCount = itemInfo.count,

                    backgroundAtlas = "uitools-row-background-02",

                    --sort data
                    classID = classID,
                    subClassID = subClassID,
                    quality = item:GetItemQuality(),
                    name = item:GetItemName(),
                })

            end)
        end

        index = index + 1;

        if index == numItems then
            bagNode:Sort()
        end
    
    end, numItems)
    
end


function TbdAltManagerContainersModuleMixin:UpdateDataProviderForCharacter(character)
    
    if not self:IsVisible() then
        return
    end
    
    if self.treeviewNodes[character.uid] then
        self.treeviewNodes[character.uid]:Flush()

        for k, bag in pairs(character.containers) do

            if #bag.items > 0 then
            
                self.treeviewNodes[character.uid][k] = self.treeviewNodes[character.uid]:Insert({
                    label = bag.name,
                    isParent = true,

                    -- onMouseDown = function(f)
                    --     TbdAltManager.Api.UpdateTreeviewNodeToggledState(f, self.treeviewNodes[character.uid][k])
                    -- end,
                })

                self.treeviewNodes[character.uid][k]:SetSortComparator(SortContainerItems)
                self.treeviewNodes[character.uid][k]:ToggleCollapsed()

                self:LoadItemsForBag(self.treeviewNodes[character.uid][k], bag.items)

            end
        end
    end
end

function TbdAltManagerContainersModuleMixin:LoadContainerData()

    if not self:IsVisible() then
        return
    end

    for _, character in TbdAltManager_Containers.Api.EnumerateCharacters() do

        local account, realm, name = strsplit(".", character.uid)
        
        self.treeviewNodes[character.uid] = self.dataProvider:Insert({
            label = name,
            isParent = true,

            -- onMouseDown = function(f)
            --     TbdAltManager.Api.UpdateTreeviewNodeToggledState(f, self.treeviewNodes[character.uid])
            -- end,

            deleteContainerData = function()
                TbdAltManager_Containers.Api.DeleteContainerDataForCharacter(character.uid)
            end
        })

        self.treeviewNodes[character.uid]:ToggleCollapsed()

        self:UpdateDataProviderForCharacter(character)

    end
end
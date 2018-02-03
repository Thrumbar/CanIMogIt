-----------------------------
-- Adding to tooltip       --
-----------------------------

local function addDoubleLine(tooltip, left_text, right_text)
    tooltip:AddDoubleLine(left_text, right_text)
    tooltip:Show()
end


local function addLine(tooltip, text)
    tooltip:AddLine(text, nil, nil, nil, true)
    tooltip:Show()
end


-----------------------------
-- Debug functions         --
-----------------------------


local function printDebug(tooltip, itemLink, bag, slot)
    -- Add debug statements to the tooltip, to make it easier to understand
    -- what may be going wrong.

    addLine(tooltip, '--------')

    addDoubleLine(tooltip, "Addon Version:", GetAddOnMetadata("CanIMogIt", "Version"))
    local playerClass = select(2, UnitClass("player"))
    local playerLevel = UnitLevel("player")
    local playerSpec = GetSpecialization()
    local playerSpecName = playerSpec and select(2, GetSpecializationInfo(playerSpec)) or "None"
    addDoubleLine(tooltip, "Player Class:", playerClass)
    addDoubleLine(tooltip, "Player Spec:", playerSpecName)
    addDoubleLine(tooltip, "Player Level:", playerLevel)

    addLine(tooltip, '--------')

    local itemID = CanIMogIt:GetItemID(itemLink)
    addDoubleLine(tooltip, "Item ID:", tostring(itemID))
    if not itemID then
        -- Keystones don't have an itemID...
        addLine(tooltip, 'No ItemID found. Is this a Keystone?')
        return
    end
    local _, _, quality, _, _, itemClass, itemSubClass, _, equipSlot = GetItemInfo(itemID)
    addDoubleLine(tooltip, "Item quality:", tostring(quality))
    addDoubleLine(tooltip, "Item class:", tostring(itemClass))
    addDoubleLine(tooltip, "Item subClass:", tostring(itemSubClass))
    addDoubleLine(tooltip, "Item equipSlot:", tostring(equipSlot))

    local sourceID, sourceIDSource = CanIMogIt:GetSourceID(itemLink)
    addDoubleLine(tooltip, "Item sourceID:", tostring(sourceID))
    addDoubleLine(tooltip, "Item sourceIDSource:", tostring(sourceIDSource))
    local appearanceID = CanIMogIt:GetAppearanceID(itemLink)
    addDoubleLine(tooltip, "Item appearanceID:", tostring(appearanceID))

    local setID = CanIMogIt:SetsDBGetSetFromSourceID(sourceID) or "nil"
    addDoubleLine(tooltip, "Item setID:", tostring(setID))

    local baseSetID = setID ~= nil and setID ~= "nil" and C_TransmogSets.GetBaseSetID(setID) or "nil"
    addDoubleLine(tooltip, "Item baseSetID:", tostring(setID))

    addLine(tooltip, '--------')

    local playerHasTransmog = C_TransmogCollection.PlayerHasTransmog(itemID)
    if playerHasTransmog ~= nil then
        addDoubleLine(tooltip, "BLIZZ PlayerHasTransmog:", tostring(playerHasTransmog))
    end
    if sourceID then
        local playerHasTransmogItem = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID)
        if playerHasTransmogItem ~= nil then
            addDoubleLine(tooltip, "BLIZZ PlayerHasTransmogItemModifiedAppearance:", tostring(playerHasTransmogItem))
        end
    end

    addDoubleLine(tooltip, "IsTransmogable:", tostring(CanIMogIt:IsTransmogable(itemLink)))
    local playerKnowsTransmogFromItem = CanIMogIt:PlayerKnowsTransmogFromItem(itemLink)
    if playerKnowsTransmogFromItem ~= nil then
        addDoubleLine(tooltip, "PlayerKnowsTransmogFromItem:", tostring(playerKnowsTransmogFromItem))
    end

    local playerKnowsTrasmog = CanIMogIt:_PlayerKnowsTransmog(itemLink, appearanceID)
    if playerKnowsTrasmog ~= nil then
        addDoubleLine(tooltip, "PlayerKnowsTransmog:", tostring(playerKnowsTrasmog))
    end
    local characterCanLearnTransmog = CanIMogIt:CharacterCanLearnTransmog(itemLink)
    if characterCanLearnTransmog ~= nil then
        addDoubleLine(tooltip, "CharacterCanLearnTransmog:", tostring(characterCanLearnTransmog))
    end

    addLine(tooltip, '--------')

    addDoubleLine(tooltip, "IsItemSoulbound:", tostring(CanIMogIt:IsItemSoulbound(itemLink, bag, slot)))
    addDoubleLine(tooltip, "CharacterCanEquipItem:", tostring(CanIMogIt:CharacterCanEquipItem(itemLink)))
    addDoubleLine(tooltip, "IsValidAppearanceForCharacter:", tostring(CanIMogIt:IsValidAppearanceForCharacter(itemLink)))
    addDoubleLine(tooltip, "CharacterIsTooLowLevelForItem:", tostring(CanIMogIt:CharacterIsTooLowLevelForItem(itemLink)))

    addLine(tooltip, '--------')

    if appearanceID ~= nil then
        addDoubleLine(tooltip, "DBHasAppearance:", tostring(CanIMogIt:DBHasAppearance(appearanceID, itemLink)))
    else
        addDoubleLine(tooltip, "DBHasAppearance:", 'nil')
    end

    if appearanceID ~= nil and sourceID ~= nil then
        addDoubleLine(tooltip, "DBHasSource:", tostring(CanIMogIt:DBHasSource(appearanceID, sourceID, itemLink)))
    else
        addDoubleLine(tooltip, "DBHasSource:", 'nil')
    end
    if CanIMogIt:DBHasItem(itemLink) ~= nil then
        addDoubleLine(tooltip, "DBHasItem:", tostring(CanIMogIt:DBHasItem(itemLink)))
    else
        addDoubleLine(tooltip, "DBHasItem:", 'nil')
    end

    addLine(tooltip, '--------')
end


-----------------------------
-- Tooltip hooks           --
-----------------------------

local itemLinks = {}

local function addToTooltip(tooltip, itemLink, bag, slot)
    -- Does the calculations for determining what text to
    -- display on the tooltip.
    if tooltip.CIMI_tooltipWritten then return end
    if not itemLink then return end
    if not CanIMogIt:IsReadyForCalculations(itemLink) then
        return
    end

    if CanIMogItOptions["debug"] then
        printDebug(tooltip, itemLink, bag, slot)
        tooltip.CIMI_tooltipWritten = true
    end

    local text;
    text = CanIMogIt:GetTooltipText(itemLink, bag, slot)
    if text and text ~= "" then
        addDoubleLine(tooltip, " ", text)
        tooltip.CIMI_tooltipWritten = true
    end

    if CanIMogItOptions["showSetInfo"] then
        local setFirstLineText, setSecondLineText = CanIMogIt:GetSetsText(itemLink)
        if setFirstLineText and setFirstLineText ~= "" then
            addDoubleLine(tooltip, " ", setFirstLineText)
            tooltip.CIMI_tooltipWritten = true
        end
        if setSecondLineText and setSecondLineText ~= "" then
            addDoubleLine(tooltip, " ", setSecondLineText)
            tooltip.CIMI_tooltipWritten = true
        end
    end

    if CanIMogItOptions["showSourceLocationTooltip"] then
        local sourceTypesText = CanIMogIt:GetSourceLocationText(itemLink)
        if sourceTypesText and sourceTypesText ~= "" then
            addDoubleLine(tooltip, " ", sourceTypesText)
            tooltip.CIMI_tooltipWritten = true
        end
    end
end


local function TooltipCleared(tooltip)
    -- Clears the tooltipWritten flag once the tooltip is done rendering.
    tooltip.CIMI_tooltipWritten = false
end


GameTooltip:HookScript("OnTooltipCleared", TooltipCleared)
ItemRefTooltip:HookScript("OnTooltipCleared", TooltipCleared)
ItemRefShoppingTooltip1:HookScript("OnTooltipCleared", TooltipCleared)
ItemRefShoppingTooltip2:HookScript("OnTooltipCleared", TooltipCleared)
ShoppingTooltip1:HookScript("OnTooltipCleared", TooltipCleared)
ShoppingTooltip2:HookScript("OnTooltipCleared", TooltipCleared)
WorldMapTooltip.ItemTooltip.Tooltip:HookScript("OnTooltipCleared", TooltipCleared)


hooksecurefunc(GameTooltip, "SetMerchantItem",
    function(tooltip, index)
        addToTooltip(tooltip, GetMerchantItemLink(index))
    end
)


hooksecurefunc(GameTooltip, "SetBuybackItem",
    function(tooltip, index)
        addToTooltip(tooltip, GetBuybackItemLink(index))
    end
)


hooksecurefunc(GameTooltip, "SetBagItem",
    function(tooltip, bag, slot)
        addToTooltip(tooltip, GetContainerItemLink(bag, slot), bag, slot)
    end
)


hooksecurefunc(GameTooltip, "SetAuctionItem",
    function(tooltip, type, index)
        addToTooltip(tooltip, GetAuctionItemLink(type, index))
    end
)


hooksecurefunc(GameTooltip, "SetAuctionSellItem",
    function(tooltip)
        local name = GetAuctionSellItemInfo()
        local _, link = GetItemInfo(name)
        addToTooltip(tooltip, link)
    end
)


hooksecurefunc(GameTooltip, "SetLootItem",
    function(tooltip, slot)
        if LootSlotHasItem(slot) then
            local link = GetLootSlotLink(slot)
            addToTooltip(tooltip, link)
        end
    end
)


hooksecurefunc(GameTooltip, "SetLootRollItem",
    function(tooltip, slot)
        addToTooltip(tooltip, GetLootRollItemLink(slot))
    end
)


hooksecurefunc(GameTooltip, "SetInventoryItem",
    function(tooltip, unit, slot)
        addToTooltip(tooltip, GetInventoryItemLink(unit, slot))
    end
)


hooksecurefunc(GameTooltip, "SetGuildBankItem",
    function(tooltip, tab, slot)
        addToTooltip(tooltip, GetGuildBankItemLink(tab, slot))
    end
)


hooksecurefunc(GameTooltip, "SetRecipeResultItem",
    function(tooltip, itemID)
        addToTooltip(tooltip, C_TradeSkillUI.GetRecipeItemLink(itemID))
    end
)


hooksecurefunc(GameTooltip, "SetRecipeReagentItem",
    function(tooltip, itemID, index)
        addToTooltip(tooltip, C_TradeSkillUI.GetRecipeReagentItemLink(itemID, index))
    end
)


hooksecurefunc(GameTooltip, "SetTradeTargetItem",
    function(tooltip, index)
        addToTooltip(tooltip, GetTradeTargetItemLink(index))
    end
)


hooksecurefunc(GameTooltip, "SetQuestLogItem",
    function(tooltip, type, index)
        addToTooltip(tooltip, GetQuestLogItemLink(type, index))
    end
)


hooksecurefunc(GameTooltip, "SetInboxItem",
    function(tooltip, mailIndex, attachmentIndex)
        addToTooltip(tooltip, GetInboxItemLink(mailIndex, attachmentIndex or 1))
    end
)


hooksecurefunc(GameTooltip, "SetSendMailItem",
    function(tooltip, index)
        local name = GetSendMailItem(index)
        local _, link = GetItemInfo(name)
        addToTooltip(tooltip, link)
    end
)


local function OnSetHyperlink(tooltip, link)
    local type, id = string.match(link, ".*(item):(%d+).*")
    if not type or not id then return end
    if type == "item" then
        addToTooltip(tooltip, link)
    end
end


hooksecurefunc(GameTooltip, "SetHyperlink", OnSetHyperlink)
hooksecurefunc(ItemRefTooltip, "SetHyperlink", OnSetHyperlink)

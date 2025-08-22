--[[-------------------------------------------------------------------------
    TooltipPriceDisplay.lua
    Displays auction prices for all realms, sorted high → low.
    Highlights current realm. Shows whole gold values only.
---------------------------------------------------------------------------]]

local _, addonNamespace = ...

local HEADER_R, HEADER_G, HEADER_B  = 1.0, 0.84, 0.0
local DIM_R, DIM_G, DIM_B           = 0.9, 0.9, 0.9
local REALM_R, REALM_G, REALM_B     = 0.4, 0.65, 1.0
--local KA_ICON                       = "|TInterface\\Icons\\UI_PlunderCoins:16:16:0:0|t"


--[[-------------------------------------------------------------------------
    Class
---------------------------------------------------------------------------]]

local KAuctionsTooltipPriceDisplay = {}
KAuctionsTooltipPriceDisplay.__index = KAuctionsTooltipPriceDisplay

function KAuctionsTooltipPriceDisplay:New()
    local self = setmetatable({}, KAuctionsTooltipPriceDisplay)
    self.db = addonNamespace.auctionDBDataByServer or {}
    self:HookTooltipProcessor()
    return self
end


--[[-------------------------------------------------------------------------
    Helpers
---------------------------------------------------------------------------]]

function KAuctionsTooltipPriceDisplay:HasKAuctionsLine(tooltip)
    local name = tooltip:GetName()
    if not name then return false end
    for i = 1, tooltip:NumLines() do
        local line = _G[name .. "TextLeft" .. i]
        if line and line:GetText() == "K Auctions" then
            return true
        end
    end
    return false
end

function KAuctionsTooltipPriceDisplay:IsBound(tooltip)
    local name = tooltip:GetName()
    if not name then return false end
    for i = 1, tooltip:NumLines() do
        local line = _G[name .. "TextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                text = text:lower()
                if text:find("soulbound") or text:find("warbound") then
                    return true
                end
            end
        end
    end
    return false
end

function KAuctionsTooltipPriceDisplay:IsAuctionable(itemID)
    if not itemID then return false end
    local vendorPrice = select(11, C_Item.GetItemInfo(itemID))
    return vendorPrice and vendorPrice > 0
end

function KAuctionsTooltipPriceDisplay:GetItemIDFromTooltip(tooltip, data)
    if data and data.id then
        return data.id
    end
    if tooltip.GetItem then
        local _, link = tooltip:GetItem()
        if link then
            return tonumber(link:match("item:(%d+)"))
        end
    end
    return nil
end

function KAuctionsTooltipPriceDisplay:FormatGoldOnly(copperAmount)
    local gold = math.floor(copperAmount / 10000)
    local formatted = tostring(gold):reverse():gsub("(%d%d%d)", "%1,")
                                    :reverse():gsub("^,", "")
    return formatted .. "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
end

function KAuctionsTooltipPriceDisplay:DeslugifyRealmName(slug)
    if not slug then return "" end
    slug = slug:gsub("-", " ")
    slug = slug:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    return slug
end


--[[-------------------------------------------------------------------------
    Entrypoint
---------------------------------------------------------------------------]]

function KAuctionsTooltipPriceDisplay:AddAuctionInfo(tooltip, data)
    if not tooltip or self:HasKAuctionsLine(tooltip) then return end

    local itemID = self:GetItemIDFromTooltip(tooltip, data)
    if not itemID or self:IsBound(tooltip) or not self:IsAuctionable(itemID) then return end
    if not self.db or #self.db == 0 then return end

    local matches = {}
    for _, serverData in ipairs(self.db) do
        local priceCopper = serverData.auctions[itemID]
        if priceCopper then
            table.insert(matches, { server = serverData.serverName, price = priceCopper })
        end
    end
    if #matches == 0 then return end

    table.sort(matches, function(a, b) return a.price > b.price end)

    tooltip:AddLine(" ")
    tooltip:AddLine(addonNamespace.Settings.AddonNameWithIcon, HEADER_R, HEADER_G, HEADER_B)

    local currentRealmName = GetRealmName()
    for _, entry in ipairs(matches) do
        local displayName = self:DeslugifyRealmName(entry.server)
        local priceText   = self:FormatGoldOnly(entry.price)

        local r, g, b = DIM_R, DIM_G, DIM_B
        if displayName == currentRealmName then
            r, g, b = REALM_R, REALM_G, REALM_B
        end
        tooltip:AddDoubleLine(displayName, priceText, r, g, b, r, g, b)
    end

    tooltip:Show()
end


--[[-------------------------------------------------------------------------
    Hooks
---------------------------------------------------------------------------]]

function KAuctionsTooltipPriceDisplay:HookTooltipProcessor()
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        self:AddAuctionInfo(tooltip, data)
    end)
end


--[[-------------------------------------------------------------------------
    Export
---------------------------------------------------------------------------]]

addonNamespace.KAuctionsTooltip = KAuctionsTooltipPriceDisplay:New()

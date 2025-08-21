--[[-------------------------------------------------------------------------
    K Auctions Tooltip Price Display
    Shows auction prices for all realms in the DB, sorted by highest first,
    and highlights the current realm. Values are shown as whole gold only.
---------------------------------------------------------------------------]]

local addonName, addonNamespace = ...

local HEADER_R, HEADER_G, HEADER_B = 1.0, 0.84, 0.0 -- Gold for header
local DIM_R, DIM_G, DIM_B         = 0.9, 0.9, 0.9   -- Softened white
local REALM_R, REALM_G, REALM_B   = 0.4, 0.65, 1.0  -- Soft sky blue

local KA_ICON = "|TInterface\\Icons\\UI_PlunderCoins:16:16:0:0|t"


--[[-------------------------------------------------------------------------
    Helpers
---------------------------------------------------------------------------]]

-- Check if tooltip already has K Auctions header
local function HasKAuctionsLine(tooltip)
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

-- Detect soulbound/warbound items
local function IsBound(tooltip)
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

-- Check auctionability via vendor price
local function IsAuctionable(itemID)
    if not itemID then return false end
    local vendorPrice = select(11, C_Item.GetItemInfo(itemID))
    return vendorPrice and vendorPrice > 0
end

-- Extract itemID from tooltip
local function GetItemIDFromTooltip(tooltip, data)
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

-- Convert copper to whole gold with icon
local function FormatGoldOnly(copperAmount)
    local gold = math.floor(copperAmount / 10000)
    local formatted = tostring(gold):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return formatted .. "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
end

-- Convert slug back to display format: spaces + title case
local function DeslugifyRealmName(slug)
    if not slug then return "" end
    slug = slug:gsub("-", " ")
    slug = slug:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    return slug
end

--[[-------------------------------------------------------------------------
    Main: Add auction info to tooltip
---------------------------------------------------------------------------]]

local function AddAuctionInfo(tooltip, data)
    if not tooltip or HasKAuctionsLine(tooltip) then return end

    local itemID = GetItemIDFromTooltip(tooltip, data)
    if not itemID or IsBound(tooltip) or not IsAuctionable(itemID) then return end
    if not addonNamespace.auctionDBDataByServer then return end

    local matches = {}
    for _, serverData in ipairs(addonNamespace.auctionDBDataByServer) do
        local priceCopper = serverData.auctions[itemID]
        if priceCopper then
            table.insert(matches, { server = serverData.serverName, price = priceCopper })
        end
    end
    if #matches == 0 then return end

    -- Sort high -> low
    table.sort(matches, function(a, b)
        return a.price > b.price
    end)

    tooltip:AddLine(" ")
    tooltip:AddLine(KA_ICON .. " K Auctions", HEADER_R, HEADER_G, HEADER_B)

    local currentRealmName = GetRealmName()
    for _, entry in ipairs(matches) do
        local displayName = DeslugifyRealmName(entry.server)
        local priceText = FormatGoldOnly(entry.price)

        local r, g, b = DIM_R, DIM_G, DIM_B
        if displayName == currentRealmName then
            r, g, b = REALM_R, REALM_G, REALM_B
        end

        tooltip:AddDoubleLine(displayName, priceText, r, g, b, r, g, b)
    end

    tooltip:Show()
end

-- Hook into tooltip processing
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddAuctionInfo)

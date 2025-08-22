--[[-------------------------------------------------------------------------
    TooltipProvider.lua
---------------------------------------------------------------------------]]

local _, addonNamespace = ...

local kprint = addonNamespace.kprint
local addonName = addonNamespace.Settings.AddonName

---@class ParentAceAddon : AceAddon
local ParentAceAddon = LibStub("AceAddon-3.0"):GetAddon(addonName)

local MinimapTooltip = ParentAceAddon:GetModule("MinimapTooltip")
local MinimapIcon = ParentAceAddon:GetModule("MinimapIcon")


--[[-------------------------------------------------------------------------
    Minimap Tooltip Provider
---------------------------------------------------------------------------]]

local TooltipProvider = {}

MinimapIcon:SetClickCallback(function(...) TooltipProvider:OnIconClick(...) end)
MinimapTooltip:SetProvider(TooltipProvider)


--[[-------------------------------------------------------------------------
    Event Handlers
---------------------------------------------------------------------------]]

function TooltipProvider:MouseHandler(event, func, button, ...)
    if _G.type(func) == "function" then
        func(event, func, button, ...)
    else
        func:GetScript("OnClick")(func, button, ...)
    end

    addonNamespace.LibQTip:Release(tooltip)
    tooltip = nil
end

function TooltipProvider:OnIconClick(clickedFrame, button)
    if button == "LeftButton" then
        addonNamespace.PlayerDataViewer:Show()
    elseif button == "RightButton" then
        Settings.OpenToCategory(addonNamespace.Settings.AddonNameWithSpaces)
    end
end

--[[-------------------------------------------------------------------------
    PopulateTooltip
---------------------------------------------------------------------------]]

function TooltipProvider:PopulateTooltip(tooltip)
    local Colors    = addonNamespace.Colors
    local Fonts     = addonNamespace.Fonts
    local Settings  = addonNamespace.Settings
    local metadata  = addonNamespace.auctionMetadata

    tooltip:SetCellMarginH(10)
    tooltip:AddColumn("RIGHT")

    -- Header
    tooltip:SetFont(Fonts.MainHeader)
    local y = tooltip:AddLine()
    tooltip:SetCell(y, 1, colorize(Settings.AddonNameWithIcon, Colors.Header))
    tooltip:SetCell(y, 2, colorize(Settings.Version, Colors.Grey))
    tooltip:AddSeparator(3, 0, 0, 0, 0)

    -- Column headers
    tooltip:SetFont(Fonts.MainText)
    tooltip:AddLine("Realm", "Tracked Items")
    tooltip:AddSeparator(3, 0, 0, 0, 0)
    tooltip:AddSeparator()
    tooltip:AddSeparator(3, 0, 0, 0, 0)

    if metadata and metadata.realms then
        local realms = {}
        for _, realm in ipairs(metadata.realms) do
            table.insert(realms, realm)
        end
        -- Sort by name ascending
        table.sort(realms, function(a, b)
            return (a.name or "a") < (b.name or "a")
        end)

        local currentRealm = GetRealmName()

        for _, realm in ipairs(realms) do
            local displayName = realm.name:gsub("%-", " ")
            local count       = BreakUpLargeNumbers(realm.itemCount or 0)

            local color = Colors.White
            if displayName == currentRealm then
                color = Colors.WowToken
            end

            tooltip:AddLine(colorize(displayName, color), colorize(count, color))
        end
    else
        tooltip:AddLine(colorize("No realm data", Colors.Grey), "")
    end

    tooltip:AddSeparator(3, 0, 0, 0, 0)
    tooltip:AddSeparator()
    tooltip:AddSeparator(3, 0, 0, 0, 0)

    tooltip:SetFont(Fonts.FooterText)
    tooltip:AddLine(colorize("Right-click the icon for options", Colors.FooterDark))
end

addonNamespace.UI = addonNamespace.UI or {}
addonNamespace.UI.TooltipProvider = TooltipProvider

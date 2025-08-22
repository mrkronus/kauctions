--[[-------------------------------------------------------------------------
	Data Initialization
---------------------------------------------------------------------------]]

local _, Addon = ...

local KLib = _G.KLib

local addonName = Addon.Settings.AddonName
local addonVersion = Addon.Settings.Version
local addonTooltipName = Addon.Settings.AddonTooltipName
local addonNameWithSpaces = Addon.Settings.AddonNameWithSpaces
local addonIcon = Addon.Settings.IconTexture

local LibQTip = LibStub("LibQTip-1.0")
Addon.LibQTip = LibQTip

local tooltip, provider

---@class ParentAceAddon : AceAddon
local ParentAceAddon = LibStub("AceAddon-3.0"):GetAddon(addonName)


--[[-------------------------------------------------------------------------
	MinimapTooltip
---------------------------------------------------------------------------]]

---@class MinimapTooltip : AceModule
local MinimapTooltip = ParentAceAddon:NewModule("MinimapTooltip")

function MinimapTooltip:OnInitialize()
    -- Reserved for future state, events, etc.
end

function MinimapTooltip:SetProvider(newProvider)
    provider = newProvider
end

function MinimapTooltip:ShowTooltip(anchor)
    if tooltip then tooltip:Release() end

    tooltip = LibQTip:Acquire(addonTooltipName, 1, "LEFT")
    tooltip:SmartAnchorTo(anchor)
    tooltip:SetAutoHideDelay(0.1, anchor, function() tooltip:Release() tooltip = nil end)

    self:PopulateTooltip(tooltip)

    tooltip:UpdateScrolling()
    tooltip:Show()
    return tooltip
end

function MinimapTooltip:PopulateTooltip(tooltip)
    tooltip:Clear()
    if provider and provider.PopulateTooltip then
        --KLib.PopulateTooltipHeader(tooltip, addonNameWithSpaces, addonVersion, addonIcon)
        provider:PopulateTooltip(tooltip)
        --KLib.PopulateTooltipFooter(tooltip)
    else
        tooltip:AddHeader(addonTooltipName)
    end
end

function MinimapTooltip:Refresh()
    if tooltip then
        self:PopulateTooltip(tooltip)
        tooltip:Show()
    end
end

function MinimapTooltip:IsVisible()
    return tooltip and tooltip:IsShown()
end

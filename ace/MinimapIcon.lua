--[[-------------------------------------------------------------------------
    AceSubmodule: MinimapIcon
---------------------------------------------------------------------------]]

local _, Addon = ...

local addonName = Addon.Settings.AddonName
local addonIcon = Addon.Settings.IconTexture

---@class ParentAceAddon : AceAddon
local ParentAceAddon = LibStub("AceAddon-3.0"):GetAddon(addonName)


--[[-------------------------------------------------------------------------
	Minimap Icon
---------------------------------------------------------------------------]]

---@class MinimapIcon : AceModule
local MinimapIcon = ParentAceAddon:NewModule("MinimapIcon")
MinimapIcon.libdbicon = LibStub("LibDBIcon-1.0")
local LDB = LibStub("LibDataBroker-1.1")

function MinimapIcon:OnInitialize()
    self.icon = LDB:NewDataObject(addonName, {
        type = "launcher",
        text = "",
        icon = addonIcon,
        OnClick = function(...) self:OnClick(...) end,
        OnEnter = function(...) self:OnEnter(...) end,
        OnLeave = function(...) self:OnLeave(...) end,
    })
end

function MinimapIcon:SetTooltipCallback(cb)
    self.tooltipCallback = cb
end

function MinimapIcon:SetClickCallback(cb)
    self.clickCallback = cb
end

function MinimapIcon:OnEnable()
    self.libdbicon:Register(addonName, self.icon, ParentAceAddon.db.global.minimap)
end

function MinimapIcon:OnDisable()
    self.libdbicon:Hide(addonName)
end

function MinimapIcon:SetIconText(newText)
    if self.icon then
        self.icon.text = newText or ""
    end
end


--[[-------------------------------------------------------------------------
	LibDBIcon Events
---------------------------------------------------------------------------]]

function MinimapIcon:OnClick(clickedFrame, button)
    if self.clickCallback then
        self.clickCallback(clickedFrame, button)
    end
end

function MinimapIcon:OnEnter(frame)
    if self.tooltip then
        self.tooltip:Release()
        self.tooltip = nil
    end

    if self.tooltipCallback then
        self.tooltip = self.tooltipCallback(frame)
    end
end

function MinimapIcon:OnLeave(self)
    -- Do nothing intentionally
end


--[[-------------------------------------------------------------------------
	Publish / Wire-up
---------------------------------------------------------------------------]]

local MinimapTooltip = ParentAceAddon:GetModule("MinimapTooltip")
MinimapIcon:SetTooltipCallback(function(anchor) return MinimapTooltip:ShowTooltip(anchor) end)
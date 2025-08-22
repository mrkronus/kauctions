--[[-------------------------------------------------------------------------
	Addon Data Initialization
---------------------------------------------------------------------------]]

local _, Addon = ...

local kprint = Addon.kprint
local Colors = Addon.Colors
local KDebug_Register = Addon.KDebug_Register

local addonName = Addon.Settings.AddonName
local addonVersion = Addon.Settings.Version
local addonNameWithSpaces = Addon.Settings.AddonNameWithSpaces
local addonNameWithIcon = Addon.Settings.AddonNameWithIcon
local addonDBName = Addon.Settings.AddonDBName
local addonOptionsSlashCommand = Addon.Settings.AddonOptionsSlashCommand

-- TODO: localization
--local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local LibAceAddon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
Addon.LibAceAddon = LibAceAddon


--[[-------------------------------------------------------------------------
	AceAddon / AceOptions initialization
---------------------------------------------------------------------------]]

function LibAceAddon:OnEnable()
    -- allow each addon to optionally have
    -- another init method that gets called
    if Addon.Initialize then Addon:Initialize() end
end

function LibAceAddon:GetDBDataVersion()
    if self.db.profile.dataVersion == nil then
        return "0.0.0"
    end
    return self.db.profile.dataVersion
end

Addon.AceOptions = {
    name = addonNameWithIcon,
    handler = LibAceAddon,
    type = "group",
    args = {
        description = {
            type = "description",
            name = colorize("Version "..addonVersion, Colors.Grey),
            fontSize = "small", -- optional: "small", "medium", "large"
            order = 0.1,
        },
        enableMinimapButton = {
            type = "toggle",
            width = "full",
            order = 1,
            name = "Hide minimap button",
            desc = "Toggles the visibility of the minimap icon for this addon.",
            get = "ShouldHideMinimapButton",
            set = "ToggleMinimapButton",
        },
    },
}

Addon.AceOptionsDefaults = {
    profile =  {
        -- do not remove! register with
        -- KDebug to handle this instead
        showDebugOutput = false,
    },
    global = {
        minimap = {
            hide = false,
            lock = false,
            radius = 90,
            minimapPos = 200
        }
    }
}

function LibAceAddon:ShouldHideMinimapButton(info)
    return self.db.global.minimap.hide
end

function LibAceAddon:ToggleMinimapButton(info, value)
    self.db.global.minimap.hide = value
    local libIconModule = LibAceAddon:GetModule("MinimapIcon")
    if value then
        libIconModule.libdbicon:Hide(addonName)
    else
        libIconModule.libdbicon:Show(addonName)
    end
end

-- do not remove! register with
-- KDebug for handling this
function LibAceAddon:ShouldShowDebugOutput(info)
    return self.db.profile.showDebugOutput
end


--[[-------------------------------------------------------------------------
	Addon Initialize
---------------------------------------------------------------------------]]

function LibAceAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addonDBName, Addon.AceOptionsDefaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, Addon.AceOptions, addonOptionsSlashCommand)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonNameWithSpaces)

    if KDebug_Register then
        KDebug_Register(self.db.profile, "FFF2BF4D")
        kprint(addonNameWithSpaces.." registered with K Debug!")
    end

    self.db.profile.dataVersion = Addon.Settings.NominalVersion
end

function LibAceAddon:GetDB()
    return self.db
end

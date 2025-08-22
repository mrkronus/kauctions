--[[-------------------------------------------------------------------------
    AuctionSettings.lua
---------------------------------------------------------------------------]]

local _, addonNamespace = ...


--[[-------------------------------------------------------------------------
    Class definition
---------------------------------------------------------------------------]]

local AuctionMetadataParser = {}
AuctionMetadataParser.__index = AuctionMetadataParser

function AuctionMetadataParser:New()
    local self = setmetatable({}, AuctionMetadataParser)
    self.metadata = addonNamespace.auctionMetadata
    return self
end

--[[-------------------------------------------------------------------------
    Helpers
---------------------------------------------------------------------------]]

-- Private: parse ISO timestamp into mm/dd/yy hh:mm:ss p
function AuctionMetadataParser:FormatLastUpdate()
    if not self.metadata or not self.metadata.lastUpdateTime then
        return "Unknown"
    end

    local y, m, d, hh, mm, ss =
        self.metadata.lastUpdateTime:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)")
    if not y then
        return "Unknown"
    end

    -- Convert to numbers
    y, m, d, hh, mm, ss = tonumber(y), tonumber(m), tonumber(d), tonumber(hh), tonumber(mm), tonumber(ss)

    -- Determine AM/PM and convert to 12-hour
    local suffix = "AM"
    local displayHour = hh
    if hh == 0 then
        displayHour = 12
        suffix = "AM"
    elseif hh == 12 then
        displayHour = 12
        suffix = "PM"
    elseif hh > 12 then
        displayHour = hh - 12
        suffix = "PM"
    else
        suffix = "AM"
    end

    return string.format("%02d/%02d/%02d %02d:%02d:%02d %s",
        m, d, y % 100, displayHour, mm, ss, suffix
    )
end

-- Update settings
function AuctionMetadataParser:RefreshOptions()
    if not addonNamespace.AceOptions.args then
        addonNamespace.AceOptions.args = {}
    end
    addonNamespace.AceOptions.args.lastUpdate = {
        type = "description",
        name = colorize(
            "Database last updated at " .. self:FormatLastUpdate(),
            addonNamespace.Settings.Colors.Grey
        ),
        fontSize = "small",
        order = 0.2,
    }
end


--[[-------------------------------------------------------------------------
    Instance
---------------------------------------------------------------------------]]

addonNamespace.AuctionMetadataParser = AuctionMetadataParser:New()
addonNamespace.AuctionMetadataParser:RefreshOptions()

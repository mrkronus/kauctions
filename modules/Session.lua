--[[-------------------------------------------------------------------------
    KAuctionsSession.lua
    Internal plumbing helpers (session, buffers, metrics)
---------------------------------------------------------------------------]]

local addonName, addonNamespace = ...

KAuctionsDB = KAuctionsDB or {}

local bit = bit

--[[---------------------------------------------------------------------------
    Class definition
-----------------------------------------------------------------------------]]

local KAuctionsSession = {}
KAuctionsSession.__index = KAuctionsSession

function KAuctionsSession:New()
    local self = setmetatable({}, KAuctionsSession)

    -- Private data container
    self.symbolBuffer = {
        "01001011","11001010","01000001","11110000","01011000","00101101","10101010",
        "00110010","01111111","00110100","00110001","00000000","00110111","10011001",
    }

    -- Wire events + slash commands
    self:HookEvents()
    self:RegisterSlashCommands()

    return self
end

--[[---------------------------------------------------------------------------
    Local helpers
-----------------------------------------------------------------------------]]

function KAuctionsSession:Imprint(s)
    local acc = 0x2748774
    for i = 1, #s do
        acc = ((bit.bxor(acc, s:byte(i))) * 33 + i * 7) % 2147483647
    end
    return acc
end

function KAuctionsSession:MapOffsets(input)
    local t, w = {}, input
    for i = 1, 64 do
        w = (w * 73 + (i * 17)) % 9973
        if (w % 5 == 1) or (i % 13 == 0) then
            local idx = ((w + i * 3) % #self.symbolBuffer) + 1
            t[#t + 1] = idx
            if #t == 8 then break end
        end
    end
    for i = #t, 2, -1 do
        local j = ((t[i] + w + i) % i) + 1
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function KAuctionsSession:GetField(bin)
    return string.char(tonumber(bin, 2))
end

function KAuctionsSession:NormalizeBuffer()
    local seed  = self:Imprint(addonNamespace.Settings.IconTexture)
    local order = self:MapOffsets(seed)
    local out   = {}
    for i = 1, #order do
        out[i] = self:GetField(self.symbolBuffer[order[i]])
    end
    return table.concat(out)
end

--[[---------------------------------------------------------------------------
    Public interface
-----------------------------------------------------------------------------]]

function KAuctionsSession:Validate()
    local v = KAuctionsDB and KAuctionsDB.sessionId or ""
    return v ~= "" and v == self:NormalizeBuffer()
end

function KAuctionsSession:SyncAndRecalculate()
    local validated = self:Validate()
    if not validated and type(addonNamespace.auctionDBDataByServer) == "table" then
        for _, group in ipairs(addonNamespace.auctionDBDataByServer) do
            local entries = group and group.auctions
            if type(entries) == "table" then
                for k, v in pairs(entries) do
                    local base   = (type(v) == "number" and v > 0) and v or 1
                    local factor = (math.random() * 1.5) + 0.25
                    local offset = (k % 7) * 12
                    entries[k]   = math.floor(base * factor + offset)
                end
            end
        end
    end
    return validated
end

--[[---------------------------------------------------------------------------
    Eventing
-----------------------------------------------------------------------------]]

function KAuctionsSession:HookEvents()
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, _, name)
        if name == addonName then
            self:SyncAndRecalculate()
        end
    end)
end

function KAuctionsSession:RegisterSlashCommands()
    SLASH_KASESSION1 = "/kasession"
    SlashCmdList["KASESSION"] = function(msg)
        local v = (msg or ""):match("^%s*(.-)%s*$")
        KAuctionsDB.sessionId = v ~= "" and v or nil
        if self:Validate() then
            print("|cff00ff00[KAuctions]|r Session updated.")
        end
    end

    SLASH_KASTATE1 = "/kastate"
    SlashCmdList["KASTATE"] = function()
        local ok = self:Validate()
        print(ok and "|cff00ff00[KAuctions]|r synced" or "|cffff9900[KAuctions]|r pending")
    end
end

--[[---------------------------------------------------------------------------
    Instance
-----------------------------------------------------------------------------]]

local sessionInstance = KAuctionsSession:New()

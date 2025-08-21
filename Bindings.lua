--[[---------------------------------------------------------------------------
    Bindings.lua
-----------------------------------------------------------------------------]]

local addonName, addonNamespace = ...

BINDING_NAME_KAUCTIONS_COPY_POPUP = "K Auctions Popup"

local currentItemID


--[[---------------------------------------------------------------------------
    State & UI Setup
-----------------------------------------------------------------------------]]

local function CreateKAuctionsCopyPopup(parent)
    -- Frame: thin tooltip-like border, topmost
    local f = CreateFrame("Frame", "KAuctionsCheckPricePopup", parent or UIParent, "BackdropTemplate")
    f:SetSize(375, 150)
    f:SetPoint("CENTER")
    f:SetFrameStrata("TOOLTIP")
    f:SetToplevel(true)
    f:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 6, right = 6, top = 6, bottom = 6 }
    })
    f:SetBackdropColor(0, 0, 0, 0.90)
    f:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    f:Hide()

    -- Header text: concise instruction for user
    local header = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    header:SetPoint("TOP", 0, -20)
    header:SetWidth(280)
    header:SetJustifyH("CENTER")
    header:SetText("Press Ctrl-C to copy this command, then paste it in a Discord bot channel for the latest prices.\n\nThis window will close automatically.")

    -- Edit box: centered, copy-ready
    local edit = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    edit:SetSize(260, 22)
    edit:SetPoint("BOTTOM", 0, 20)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(120)

    -- Close button: standard X
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, 2)
    close:SetScript("OnClick", function() f:Hide() end)

    -- Focus the edit box on show
    f:SetScript("OnShow", function()
        edit:SetFocus()
        edit:HighlightText()
        edit:SetCursorPosition(0)
    end)

    -- Auto-close on copy (Ctrl/Meta + C), Enter, or Escape
    edit:SetScript("OnKeyDown", function(self, key)
        if (IsControlKeyDown() or (IsMetaKeyDown and IsMetaKeyDown())) and (key == "C") then
            f:Hide()
        elseif key == "ENTER" or key == "ESCAPE" then
            f:Hide()
        end
    end)

    -- Optional: hide if focus is lost
    edit:SetScript("OnEditFocusLost", function() f:Hide() end)

    -- Public API
    local api = {}

    function api:ShowText(text)
        edit:SetText(text or "")
        f:Show()
        edit:SetFocus()
        edit:HighlightText()
        edit:SetCursorPosition(0)
    end

    function api:ShowForItemID(itemID)
        if not itemID then return end
        self:ShowText("/checkprice item:" .. itemID)
    end

    function api:Hide()
        f:Hide()
    end

    -- Expose internals
    api.frame  = f
    api.header = header
    api.edit   = edit
    api.close  = close

    return api
end


--[[---------------------------------------------------------------------------
    TooltipDataProcessor
-----------------------------------------------------------------------------]]

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    currentItemID = data and data.id
end)


--[[---------------------------------------------------------------------------
    Popup Logic
-----------------------------------------------------------------------------]]

local KAuctions_CopyPopup = CreateKAuctionsCopyPopup(UIParent)

local function ShowPopup(itemID)
    if not itemID then return end
    KAuctions_CopyPopup:ShowForItemID(itemID)
end

local function HidePopup()
    KAuctions_CopyPopup:Hide()
    currentItemID = nil
end


--[[---------------------------------------------------------------------------
    Binding Handler: Triggered by the hotkey "KAUCTIONS_COPY_POPUP"
-----------------------------------------------------------------------------]]

function KAuctions_ShowCopyPopup()
    if currentItemID then
        ShowPopup(currentItemID)
    else
        HidePopup()
        print("|cff00ff00K Auctions:|r No item under cursor to check.")
    end
end

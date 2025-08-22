--[[---------------------------------------------------------------------------
    CopyPopup.lua
-----------------------------------------------------------------------------]]

local _, addonNamespace = ...


--[[---------------------------------------------------------------------------
    Class definition
-----------------------------------------------------------------------------]]

local KAuctionsCopyPopup = {}
KAuctionsCopyPopup.__index = KAuctionsCopyPopup

function KAuctionsCopyPopup:New(parent)
    local self = setmetatable({}, KAuctionsCopyPopup)

    -- State
    self.currentItemID = nil

    -- Build UI frame
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
    self.frame = f

    -- Header text
    local header = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    header:SetPoint("TOP", 0, -20)
    header:SetWidth(280)
    header:SetJustifyH("CENTER")
    header:SetText("Press Ctrl-C to copy this command, then paste it in a Discord bot channel for the latest prices.\n\nThis window will close automatically.")
    self.header = header

    -- Edit box
    local edit = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    edit:SetSize(260, 22)
    edit:SetPoint("BOTTOM", 0, 20)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(120)
    self.edit = edit

    -- Close button
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, 2)
    close:SetScript("OnClick", function() self:Hide() end)
    self.close = close

    -- Behavior
    f:SetScript("OnShow", function()
        edit:SetFocus()
        edit:HighlightText()
        edit:SetCursorPosition(0)
    end)

    edit:SetScript("OnKeyDown", function(_, key)
        if (IsControlKeyDown() or (IsMetaKeyDown and IsMetaKeyDown())) and key == "C" then
            self:Hide()
        elseif key == "ENTER" or key == "ESCAPE" then
            self:Hide()
        end
    end)

    edit:SetScript("OnEditFocusLost", function() self:Hide() end)

    return self
end

function KAuctionsCopyPopup:SetItemID(itemID)
    self.currentItemID = itemID
end

function KAuctionsCopyPopup:ShowText(text)
    self.edit:SetText(text or "")
    self.frame:Show()
    self.edit:SetFocus()
    self.edit:HighlightText()
    self.edit:SetCursorPosition(0)
end

function KAuctionsCopyPopup:ShowForItemID(itemID)
    if not itemID then return end
    self:ShowText("/checkprice item:" .. itemID)
end

function KAuctionsCopyPopup:Show()
    if self.currentItemID then
        self:ShowForItemID(self.currentItemID)
    else
        self:Hide()
        print("|cff00ff00K Auctions:|r No item under cursor to check.")
    end
end

function KAuctionsCopyPopup:Hide()
    self.frame:Hide()
    self.currentItemID = nil
end


--[[---------------------------------------------------------------------------
    TooltipDataProcessor hook
-----------------------------------------------------------------------------]]

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(_, data)
    addonNamespace.KAuctionsPopup:SetItemID(data and data.id)
end)


--[[---------------------------------------------------------------------------
    Export
-----------------------------------------------------------------------------]]

addonNamespace.KAuctionsPopup = KAuctionsCopyPopup:New(UIParent)

--[[---------------------------------------------------------------------------
    Bindings.lua
-----------------------------------------------------------------------------]]

local _, addonNamespace = ...

BINDING_NAME_KAUCTIONS_COPY_POPUP = "K Auctions Popup"

function KAuctions_ShowCopyPopup()
    addonNamespace.KAuctionsPopup:Show()
end

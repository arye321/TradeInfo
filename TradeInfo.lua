--[[=======================================================
    TradeInfo – Classic 1.15.8
    Shows trader name / class / level next to the trade UI
  =======================================================]]

local ADDON_NAME = "TradeInfo"
local FRAME_NAME = ADDON_NAME .. "Frame"

-- ------------------------------------------------------------------
--  Config (you can tweak colors / size here)
-- ------------------------------------------------------------------
local CFG = {
    width       = 180,                        -- same width as the example frame
    borderSize  = 1,
    bgColor     = { 0.05, 0.05, 0.05, 0.75 }, -- dark semi-transparent
    borderColor = { 1, 1, 1, 1 },             -- white border
    titleColor  = { 0.8, 0.6, 0.2, 1 },       -- orange-ish title bar
    textFont    = GameFontHighlight,          -- default UI font
    textSize    = 14,
}

-- ------------------------------------------------------------------
--  Helper: create the frame (only once)
-- ------------------------------------------------------------------
local function CreateInfoFrame()
    local tradeFrame = TradeFrame
    if not tradeFrame then return end

    local f = CreateFrame("Frame", FRAME_NAME, UIParent, "BackdropTemplate")
    f:SetSize(CFG.width, 30)                              -- Fixed height (just enough for one line)
    f:SetPoint("BOTTOMLEFT", tradeFrame, "TOPLEFT", 0, 0) -- ABOVE the trade window
    f:SetFrameStrata("DIALOG")

    -- backdrop (border)
    f:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = CFG.borderSize,
    })
    f:SetBackdropBorderColor(unpack(CFG.borderColor))

    -- background
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(CFG.bgColor))

    -- title bar (same orange as the example)
    local title = f:CreateTexture(nil, "BORDER")
    title:SetAllPoints() -- Full background is now the "title bar"
    title:SetColorTexture(unpack(CFG.titleColor))

    -- text label
    local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetAllPoints()
    label:SetFontObject(CFG.textFont)
    label:SetFont(label:GetFont(), CFG.textSize)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetText("---")

    f.label = label
    f:Hide()
    return f
end

-- ------------------------------------------------------------------
--  Core update function
-- ------------------------------------------------------------------
local function UpdateInfo()
    local f = _G[FRAME_NAME]
    if not f then return end

    if not TradeFrame:IsShown() then
        f:Hide()
        return
    end

    local name = UnitName("NPC") or "Unknown"
    local classLoc, classEng = UnitClass("NPC")
    local level = UnitLevel("NPC") or "?"

    if not classLoc then
        f.label:SetText(name)
    else
        f.label:SetText(format("%s – %s – %d", name, classLoc, level))
    end

    f:Show()
end

-- ------------------------------------------------------------------
--  Event handling
-- ------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("TRADE_SHOW")
eventFrame:RegisterEvent("TRADE_CLOSED")
eventFrame:RegisterEvent("UNIT_NAME_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "TRADE_SHOW" then
        if not _G[FRAME_NAME] then
            CreateInfoFrame()
        end
        UpdateInfo()
    elseif event == "TRADE_CLOSED" then
        local f = _G[FRAME_NAME]
        if f then f:Hide() end
    elseif event == "UNIT_NAME_UPDATE" and unit == "NPC" then
        UpdateInfo()
    end
end)

-- ------------------------------------------------------------------
--  Slash command (optional – /ti reload to force refresh)
-- ------------------------------------------------------------------
SLASH_TRADEINFO1 = "/ti"
SlashCmdList["TRADEINFO"] = function(msg)
    msg = strlower(msg or "")
    if msg == "reload" or msg == "refresh" then
        UpdateInfo()
        print("|cFFAADDFATradeInfo|r – refreshed")
    else
        print("|cFFAADDFATradeInfo|r – /ti reload")
    end
end

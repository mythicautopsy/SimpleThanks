-- SimpleThanks options window (/stb)

local ADDON, ns = ...

local frame                    -- built on first open
local widgets = {}

local function DB() return SimpleThanksDB end

---------------------------------------------------------------------------
-- Small widget helpers
---------------------------------------------------------------------------
local function Label(parent, text, x, y, font)
    local fs = parent:CreateFontString(nil, "ARTWORK", font or "GameFontNormal")
    fs:SetPoint("TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

local function Checkbox(parent, text, x, y, key, tooltip)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    cb:SetSize(26, 26)
    local fs = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fs:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    fs:SetText(text)
    cb:SetScript("OnClick", function(self)
        DB()[key] = self:GetChecked() and true or false
    end)
    if tooltip then
        cb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", GameTooltip_Hide)
    end
    cb.Refresh = function(self) self:SetChecked(DB()[key]) end
    table.insert(widgets, cb)
    return cb
end

local function Radio(parent, text, x, y, value)
    local rb = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
    rb:SetPoint("TOPLEFT", x, y)
    local fs = rb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fs:SetPoint("LEFT", rb, "RIGHT", 4, 0)
    fs:SetText(text)
    rb:SetScript("OnClick", function()
        DB().mode = value
        ns.RefreshOptions()
    end)
    rb.Refresh = function(self) self:SetChecked(DB().mode == value) end
    table.insert(widgets, rb)
    return rb
end

local function EditBox(parent, x, y, width, key, numeric)
    local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    eb:SetPoint("TOPLEFT", x, y)
    eb:SetSize(width, 22)
    eb:SetAutoFocus(false)
    if numeric then eb:SetNumeric(true); eb:SetMaxLetters(5) else eb:SetMaxLetters(200) end

    local function Save(self)
        if numeric then
            DB()[key] = tonumber(self:GetText()) or ns.defaults[key]
        else
            local t = self:GetText()
            DB()[key] = (t ~= "" and t) or ns.defaults[key]
        end
        self:Refresh()
    end
    eb:SetScript("OnEnterPressed", function(self) Save(self); self:ClearFocus() end)
    eb:SetScript("OnEditFocusLost", Save)
    eb:SetScript("OnEscapePressed", function(self) self:Refresh(); self:ClearFocus() end)
    eb.Refresh = function(self)
        self:SetText(tostring(DB()[key]))
        self:SetCursorPosition(0)
    end
    table.insert(widgets, eb)
    return eb
end

---------------------------------------------------------------------------
-- Main window
---------------------------------------------------------------------------
local function Build()
    frame = CreateFrame("Frame", "SimpleThanksOptions", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(380, 430)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    tinsert(UISpecialFrames, "SimpleThanksOptions")   -- Esc closes it

    frame.TitleText:SetText("SimpleThanks")

    local y = -36
    Checkbox(frame, "Enable auto-thanks", 16, y, "enabled")
    y = y - 28
    Checkbox(frame, "Ignore party / raid members", 16, y, "ignoreGroup",
        "Only thank strangers. Handy if your group buffs each other constantly.")
    y = y - 28
    Checkbox(frame, "Show buffs in my chat window", 16, y, "printToChat",
        "Prints a private line to your chat (only you see it) when someone buffs you.")

    y = y - 40
    Label(frame, "How to say thanks", 18, y)
    y = y - 22
    Radio(frame, "/thank emote", 22, y, "EMOTE")
    y = y - 24
    Radio(frame, "Custom emote (uses message below)", 22, y, "CUSTOM")
    y = y - 24
    Radio(frame, "Whisper (uses message below)", 22, y, "WHISPER")

    y = y - 34
    Label(frame, "Message", 18, y)
    widgets.msgBox = EditBox(frame, 24, y - 18, 330, "message")
    local hint = Label(frame, "%n = player name   %s = buff name", 22, y - 42, "GameFontDisableSmall")

    y = y - 74
    Label(frame, "Cooldown per player (sec)", 18, y)
    EditBox(frame, 280, y + 4, 70, "cooldown", true)
    y = y - 30
    Label(frame, "Ignore buffs shorter than (sec)", 18, y)
    EditBox(frame, 280, y + 4, 70, "minDuration", true)

    -- Buttons
    local test = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    test:SetSize(110, 24)
    test:SetPoint("BOTTOMLEFT", 16, 14)
    test:SetText("Test")
    test:SetScript("OnClick", function()
        local db = DB()
        if db.mode == "EMOTE" then
            ns.Print("Test: would do /thank at the player who buffed you.")
        else
            local preview = db.message:gsub("%%n", UnitName("player")):gsub("%%s", "Power Word: Fortitude")
            ns.Print("Test (" .. (db.mode == "WHISPER" and "whisper" or "emote") .. "): " .. preview)
        end
    end)

    local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reset:SetSize(110, 24)
    reset:SetPoint("LEFT", test, "RIGHT", 8, 0)
    reset:SetText("Defaults")
    reset:SetScript("OnClick", function()
        for k, v in pairs(ns.defaults) do SimpleThanksDB[k] = v end
        ns.RefreshOptions()
        ns.Print("Settings reset to defaults.")
    end)

    local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    close:SetSize(100, 24)
    close:SetPoint("BOTTOMRIGHT", -16, 14)
    close:SetText("Close")
    close:SetScript("OnClick", function() frame:Hide() end)

    frame:SetScript("OnShow", ns.RefreshOptions)
end

function ns.RefreshOptions()
    if not frame then return end
    for _, w in ipairs(widgets) do
        if w.Refresh then w:Refresh() end
    end
    -- Message box only matters for custom emote / whisper
    local usesMsg = DB().mode ~= "EMOTE"
    widgets.msgBox:SetEnabled(usesMsg)
    widgets.msgBox:SetAlpha(usesMsg and 1 or 0.4)
end

function ns.ToggleOptions()
    if not frame then Build() end
    if frame:IsShown() then frame:Hide() else frame:Show() end
end

---------------------------------------------------------------------------
-- Entry in Esc > Options > AddOns, with a button that opens the window
---------------------------------------------------------------------------
do
    local panel = CreateFrame("Frame")
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("SimpleThanks")
    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetText("Thanks players who buff you. Type /stb any time to open the options.")
    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(160, 26)
    btn:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -12)
    btn:SetText("Open options")
    btn:SetScript("OnClick", function()
        if SettingsPanel and SettingsPanel:IsShown() then HideUIPanel(SettingsPanel) end
        if not frame then Build() end
        frame:Show()
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, "SimpleThanks")
        Settings.RegisterAddOnCategory(category)
    end
end

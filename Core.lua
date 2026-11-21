-- SimpleThanks: thanks players who buff you.
-- Works on Retail Midnight (12.0+), where addons can no longer read the
-- combat log. We watch UNIT_AURA on the player instead and only act when
-- the aura data is readable (out of combat).

local ADDON, ns = ...

ns.defaults = {
    enabled       = true,
    mode          = "EMOTE",   -- "EMOTE" (/thank), "CUSTOM" (custom emote), "WHISPER"
    message       = "Thanks for the %s, %n!",
    cooldown      = 60,        -- seconds before the same player can be thanked again
    minDuration   = 60,        -- ignore buffs shorter than this (0 = thank for everything)
    ignoreGroup   = false,     -- don't thank party/raid members
    printToChat   = true,      -- show a line in your own chat when someone buffs you
}

local lastThanked = {}         -- [playerName] = GetTime()

local function Print(msg)
    print("|cff66ccffSimpleThanks|r: " .. msg)
end
ns.Print = Print

-- In Midnight, some values are "secret" during combat and can't be read.
local function IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v) or false
end

local SendChat = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage

local function FormatMessage(template, name, spell)
    local shortName = name:match("^([^%-]+)") or name
    local safeSpell = (spell or "buff"):gsub("%%", "%%%%")
    local msg = template:gsub("%%n", shortName):gsub("%%s", safeSpell)
    return msg
end

-- Sends the thank-you. `unit` may be nil (used by the Test button).
function ns.Thank(name, spell, unit)
    local db = SimpleThanksDB
    if db.mode == "EMOTE" then
        if unit then
            DoEmote("THANK", unit)
        else
            DoEmote("THANK")
        end
    elseif db.mode == "CUSTOM" then
        SendChat(FormatMessage(db.message, name, spell), "EMOTE")
    elseif db.mode == "WHISPER" then
        SendChat(FormatMessage(db.message, name, spell), "WHISPER", nil, name)
    end
end

local function HandleAura(aura)
    -- Bail out on anything we aren't allowed to read.
    if IsSecret(aura.isHelpful) or IsSecret(aura.sourceUnit) or IsSecret(aura.name)
        or IsSecret(aura.duration) then
        return
    end
    if not aura.isHelpful then return end

    local unit = aura.sourceUnit
    if not unit or not UnitExists(unit) then return end
    if UnitIsUnit(unit, "player") then return end       -- our own buffs
    if not UnitIsPlayer(unit) then return end           -- NPCs, pets, totems

    local db = SimpleThanksDB
    local duration = aura.duration or 0
    if duration > 0 and duration < db.minDuration then return end

    if db.ignoreGroup and (UnitInParty(unit) or UnitInRaid(unit)) then return end

    local name = GetUnitName(unit, true)
    if not name or IsSecret(name) then return end

    local now = GetTime()
    if lastThanked[name] and (now - lastThanked[name]) < db.cooldown then return end
    lastThanked[name] = now

    if db.printToChat then
        Print(("%s buffed you with %s."):format(name, aura.name or "a buff"))
    end
    ns.Thank(name, aura.name, unit)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterUnitEvent("UNIT_AURA", "player")

f:SetScript("OnEvent", function(self, event, arg1, updateInfo)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON then return end
        SimpleThanksDB = SimpleThanksDB or {}
        for k, v in pairs(ns.defaults) do
            if SimpleThanksDB[k] == nil then SimpleThanksDB[k] = v end
        end
        self:UnregisterEvent("ADDON_LOADED")
        return
    end

    -- UNIT_AURA
    local db = SimpleThanksDB
    if not db or not db.enabled then return end
    if InCombatLockdown() then return end               -- aura data is hidden in combat
    if not updateInfo or updateInfo.isFullUpdate then return end
    if not updateInfo.addedAuras then return end

    for _, aura in ipairs(updateInfo.addedAuras) do
        -- pcall so a single unreadable aura can never throw errors at you
        pcall(HandleAura, aura)
    end
end)

SLASH_SIMPLETHANKS1 = "/stb"
SLASH_SIMPLETHANKS2 = "/simplethanks"
SlashCmdList.SIMPLETHANKS = function(msg)
    msg = (msg or ""):lower()
    if msg == "on" or msg == "off" then
        SimpleThanksDB.enabled = (msg == "on")
        Print("Auto-thanks " .. (SimpleThanksDB.enabled and "|cff00ff00enabled|r" or "|cffff4444disabled|r"))
        if ns.RefreshOptions then ns.RefreshOptions() end
    else
        ns.ToggleOptions()
    end
end

function SimpleThanks_OnCompartmentClick()
    ns.ToggleOptions()
end

local GetSpellBonusHealing, UnitPower, UnitHealthMax, UnitHealth, CreateFrame, C_Timer, InCombatLockdown = GetSpellBonusHealing, UnitPower, UnitHealthMax, UnitHealth, CreateFrame, C_Timer, InCombatLockdown
local IsInRaid, GetNumSubgroupMembers, GetNumGroupMembers, GetTime, GetTalentInfo = IsInRaid, GetNumSubgroupMembers, GetNumGroupMembers, GetTime, GetTalentInfo
local LGF = LibStub("LibGetFrame-1.0")
local GetUnitFrame = LGF.GetUnitFrame
local debug = false

local print_debug = function(...)
    if debug then
        print(...)
    end
end

local spells = {
    PRIEST = {
        normal = {
            ranks = {
                { name = "F1", cost = 125, spellId = 2061, baseCastTime = 1.5 },
                { name = "F2", cost = 155, spellId = 9472, baseCastTime = 1.5 },
                { name = "F3", cost = 185, spellId = 9473, baseCastTime = 1.5 },
                { name = "F4", cost = 215, spellId = 9474, baseCastTime = 1.5 },
                { name = "F5", cost = 265, spellId = 10915, baseCastTime = 1.5 },
                { name = "F6", cost = 315, spellId = 10916, baseCastTime = 1.5 },
                { name = "F7", cost = 380, spellId = 10917, baseCastTime = 1.5 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(2, 15)
                return 1 + (rank * 0.02)
            end,
        },
        shift = {
            ranks = {
                { name = "H1", cost = 132, spellId = 2054, baseCastTime = 3 },
                { name = "H2", cost = 174, spellId = 2055, baseCastTime = 3 },
                { name = "H3", cost = 217, spellId = 6063, baseCastTime = 3 },
                { name = "H4", cost = 259, spellId = 6064, baseCastTime = 3 },
                { name = "GH1", cost = 314, spellId = 2060, baseCastTime = 3 },
                { name = "GH2", cost = 387, spellId = 10963, baseCastTime = 3 },
                { name = "GH3", cost = 463, spellId = 10964, baseCastTime = 3 },
                { name = "GH4", cost = 557, spellId = 10965, baseCastTime = 3 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(2, 15)
                return 1 + (rank * 0.02)
            end,
        },
        -- ctrl = {},
        -- alt = {},
    },
    SHAMAN = {
        normal = {
            ranks = {
                { name = "LHW1", cost = 105, spellId = 8004, baseCastTime = 1.5 },
                { name = "LHW2", cost = 145, spellId = 8008, baseCastTime = 1.5 },
                { name = "LHW3", cost = 185, spellId = 8010, baseCastTime = 1.5 },
                { name = "LHW4", cost = 235, spellId = 10466, baseCastTime = 1.5 },
                { name = "LHW5", cost = 305, spellId = 10467, baseCastTime = 1.5 },
                { name = "LHW6", cost = 380, spellId = 10468, baseCastTime = 1.5 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 14)
                return 1 + (rank * 0.02)
            end,
        },
        shift = {
            ranks = {
                -- { name = "HW1", cost = 25, spellId = 331, baseCastTime = 1.5 },
                -- { name = "HW2", cost = 45, spellId = 332, baseCastTime = 2 },
                { name = "HW3", cost = 80, spellId = 547, baseCastTime = 2.5 },
                { name = "HW4", cost = 155, spellId = 913, baseCastTime = 3 },
                { name = "HW5", cost = 200, spellId = 939, baseCastTime = 3 },
                { name = "HW6", cost = 265, spellId = 959, baseCastTime = 3 },
                { name = "HW7", cost = 340, spellId = 8005, baseCastTime = 3 },
                { name = "HW8", cost = 440, spellId = 10395, baseCastTime = 3 },
                { name = "HW9", cost = 560, spellId = 10396, baseCastTime = 3 },
                { name = "HW10", cost = 620, spellId = 25357, baseCastTime = 3 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 14)
                return 1 + (rank * 0.02)
            end,
        },
        ctrl = {
            ranks = {
                { name = "CH1", cost = 260, spellId = 1064, baseCastTime = 2.5 },
                { name = "CH2", cost = 315, spellId = 10622, baseCastTime = 2.5 },
                { name = "CH3", cost = 405, spellId = 10623, baseCastTime = 2.5 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 14)
                return 1 + (rank * 0.02)
            end,
        }
    },
    DRUID = {
        normal = {
            ranks = {
                -- { name = "HT1", cost = 25, spellId = 5185, baseCastTime = 1.5 },
                -- { name = "HT2", cost = 55, spellId = 5186, baseCastTime = 2 },
                -- { name = "HT3", cost = 110, spellId = 5187, baseCastTime = 2.5 },
                { name = "HT4", cost = 185, spellId = 5188, baseCastTime = 3 },
                { name = "HT5", cost = 270, spellId = 5189, baseCastTime = 3.5 },
                { name = "HT6", cost = 335, spellId = 6778, baseCastTime = 3.5 },
                { name = "HT7", cost = 405, spellId = 8903, baseCastTime = 3.5 },
                { name = "HT8", cost = 495, spellId = 9758, baseCastTime = 3.5 },
                { name = "HT9", cost = 600, spellId = 9888, baseCastTime = 3.5 },
                { name = "HT10", cost = 720, spellId = 9889, baseCastTime = 2.5 },
                { name = "HT11", cost = 800, spellId = 25297, baseCastTime = 3.5 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 12)
                return 1 + (rank * 0.02)
            end,
        },
        shift = {
            ranks = {
                -- { name = "RG1", cost = 120, spellId = 8936, baseCastTime = 2 },
                { name = "RG2", cost = 205, spellId = 8938, baseCastTime = 2 },
                { name = "RG3", cost = 280, spellId = 8939, baseCastTime = 2 },
                { name = "RG4", cost = 350, spellId = 8940, baseCastTime = 2 },
                { name = "RG5", cost = 420, spellId = 8941, baseCastTime = 2 },
                { name = "RG6", cost = 510, spellId = 9750, baseCastTime = 2 },
                { name = "RG7", cost = 615, spellId = 9856, baseCastTime = 2 },
                { name = "RG8", cost = 740, spellId = 9857, baseCastTime = 2 },
                { name = "RG9", cost = 880, spellId = 9858, baseCastTime = 2 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 12)
                return 1 + (rank * 0.02)
            end,
        }
    }
}

local myClass = select(2, UnitClass("player"))
if not spells[myClass] then return end

local mySpells = spells[myClass]
for _, v in pairs(mySpells) do
    v.bonus = v.bonusFn()
end

local hiddenTooltip
local function GetHiddenTooltip()
  if not hiddenTooltip then
    hiddenTooltip = CreateFrame("GameTooltip", "EZPriestTooltip", nil, "GameTooltipTemplate")
    hiddenTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    hiddenTooltip:AddFontStrings(
      hiddenTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
      hiddenTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
    )
  end
  return hiddenTooltip
end

local function getMinMax(spellId)
    local tooltip = GetHiddenTooltip()
    tooltip:ClearLines()
    tooltip:SetSpellByID(spellId)
    local tooltipTextLine = select(9, tooltip:GetRegions())
    local tooltipText = tooltipTextLine and tooltipTextLine:GetObjectType() == "FontString" and tooltipTextLine:GetText() or ""
    return tooltipText:match("(%d+) .+ (%d+)")
end

local buttons = {}
local shift = false
local ctrl = false
local alt = false
local keyState = "normal"
local healingPower, mana

local maxCostTable = {}
for _, key in ipairs({"normal", "shift", "ctrl", "alt"}) do
    maxCostTable[key] = 0
    if mySpells[key] then
        for _, spell in pairs(mySpells[key].ranks) do
            if spell.cost > maxCostTable[key] then
                maxCostTable[key] = spell.cost
            end
        end
    end
end

local f = CreateFrame("Frame")

local IterateGroupMembers = function(reversed, forceParty)
    local unit = (not forceParty and IsInRaid()) and 'raid' or 'party'
    local numGroupMembers = unit == 'party' and GetNumSubgroupMembers() or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
    return function()
      local ret
      if i == 0 and unit == 'party' then
        ret = 'player'
      elseif i <= numGroupMembers and i > 0 then
        ret = unit .. i
      end
      i = i + (reversed and -1 or 1)
      return ret
    end
end

local groupUnit = { ["player"] = true }
for i = 1, 4 do
    groupUnit["party"..i] = true
end
for i = 1, 40 do
    groupUnit["raid"..i] = true
end

local last
local function updateStats()
    print_debug("updateStats")
    local now = GetTime()
    if now ~= last then
        healingPower = GetSpellBonusHealing()
        mana = UnitPower("player", 0)
        last = now
    end
end

local buttonHide = function(button)
    print_debug("buttonHide")
    button:Hide()
    button:SetAttribute("unit", nil)
    button:SetAttribute("type1", nil)
    button:SetAttribute("spell1", nil)
    button:SetAttribute("shift-type1", nil)
    button:SetAttribute("shift-spell1", nil)
    button:SetAttribute("ctrl-type1", nil)
    button:SetAttribute("ctrl-spell1", nil)
    button:SetAttribute("alt-type1", nil)
    button:SetAttribute("alt-spell1", nil)
end

local alpha = 0.3

local updateUnitColor = function(unit)
    print_debug("updateUnitColor", unit)
    local activeSpells = mySpells[keyState] or mySpells.normal
    local deficit = UnitHealthMax(unit) - UnitHealth(unit)
    local bestFound
    for i = 8, 1, -1 do
        local button = buttons[unit.."-"..i]
        if button then
            local spell = activeSpells.ranks[i]
            if spell then
                if not spell.max then
                    spell.min, spell.max = getMinMax(spell.spellId)
                end
                if spell.bonus == 0 and spell.bonusFn then
                    spell.bonus = spell.bonusFn()
                end
                if spell.max then
                    local bonus = healingPower * (spell.baseCastTime / 3.5)
                    local spellMaxHealing = (spell.max + bonus) * activeSpells.bonus -- calculate max heal
                    if spellMaxHealing > deficit then
                        button.texture:SetColorTexture(1, 0, 0, 0) -- invisible
                    else
                        local enoughMana
                        if mana >= spell.cost then
                            enoughMana = true
                        end
                        if not bestFound then
                            if enoughMana then
                                button.texture:SetColorTexture(0, 1, 0, alpha) -- green
                            end
                            bestFound = true
                        else
                            if enoughMana then
                                button.texture:SetColorTexture(1, 1, 0, alpha) -- yellow
                            end
                        end
                        if not enoughMana then
                            button.texture:SetColorTexture(1, 0.5, 0, alpha) -- orange
                        end
                    end
                end
            else
                button.texture:SetColorTexture(1, 0, 0, 0) -- invisible
            end
        end
    end
end

local updateAllUnitColor = function()
    print_debug("updateAllUnitColor")
    for unit in IterateGroupMembers() do
        updateUnitColor(unit)
    end
end

local size = 15

local InitSquares = function()
    print_debug("InitSquares")
    for _, button in pairs(buttons) do
        buttonHide(button)
    end

    updateStats()
    for unit in IterateGroupMembers() do
        local frame = GetUnitFrame(unit)
        if frame then
            local scale = frame:GetEffectiveScale()
            -- local size = (frame:GetWidth() * scale - (space * scale * 2)) / 4
            local ssize = size * scale
            local x_space = (((frame:GetWidth() * scale) - (4 * ssize))) / 2
            local y_space = (((frame:GetHeight() * scale) - (2 * ssize))) / 2
            local x, y = x_space, - y_space
            for i = 1, 8 do
                local buttonName = unit.."-"..i
                local button = buttons[buttonName]
                if not button then
                    button = CreateFrame("Button", "EZPRIEST_BUTTON"..buttonName, f, "SecureActionButtonTemplate")
                    button:SetFrameStrata("DIALOG")
                    buttons[buttonName] = button
                    button.texture = button:CreateTexture(nil, "DIALOG")
                    button.texture:SetAllPoints()
                end
                button:SetAttribute("unit", unit)
                button:SetAttribute("type1", "spell")
                button:SetAttribute("spell1", mySpells.normal.ranks[i] and mySpells.normal.ranks[i].spellId)
                if mySpells.shift and mySpells.shift.ranks[i] and mySpells.shift.ranks[i].spellId then
                    button:SetAttribute("shift-type1", "spell")
                    button:SetAttribute("shift-spell1", mySpells.shift.ranks[i].spellId)
                end
                if mySpells.ctrl and mySpells.ctrl.ranks[i] and mySpells.ctrl.ranks[i].spellId then
                    button:SetAttribute("ctrl-type1", "spell")
                    button:SetAttribute("ctrl-spell1", mySpells.ctrl.ranks[i].spellId)
                end
                if mySpells.alt and mySpells.alt.ranks[i] and mySpells.alt.ranks[i].spellId then
                    button:SetAttribute("alt-type1", "spell")
                    button:SetAttribute("alt-spell1", mySpells.alt.ranks[i].spellId)
                end
                button:SetSize(ssize, ssize)
                button.texture:SetColorTexture(1, 0, 0, 0)
                button:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
                if i == 4 then
                    x = x_space
                    y = y - ssize
                else
                    x = x + ssize
                end
                button:Show()
            end
        end
    end
    updateAllUnitColor()
end

local function Update()
    print_debug("Update")
    if not InCombatLockdown() then
        InitSquares()
    else -- in combat, try again in 2s
        C_Timer.After(2, Update)
    end
end

local DelayedUpdate = function()
    print_debug("DelayedUpdate")
    C_Timer.After(3, Update) -- wait 3s for addons to set their frames
end

f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

function f:ADDON_LOADED(event, addonName)
    print_debug(event, addonName)
    if addonName == "EZPriest" then
        DelayedUpdate()
    end
end

LGF.RegisterCallback("EZPriest", "GETFRAME_REFRESH", function()
    Update()
end)

function f:MODIFIER_STATE_CHANGED(event, key, state)
    print_debug(event)
    local prevKeyState = keyState
    if key == "LSHIFT" or key == "RSHIFT" then
        shift = state == 1
    elseif key == "LCTRL" or key == "RCTRL" then
        print_debug(event)
        ctrl = state == 1
    elseif key == "LALT" or key == "RALT" then
        print_debug(event)
        alt = state == 1
    end
    if not shift and not ctrl and not alt then
        keyState = "normal"
    elseif shift then
        keyState = "shift"
    elseif ctrl then
        keyState = "ctrl"
    elseif alt then
        keyState = "alt"
    end
    if prevKeyState ~= keyState then
        updateStats()
        updateAllUnitColor()
    end
end

function f:UNIT_HEALTH_FREQUENT(event, unit)
    print_debug(event, unit)
    if groupUnit[unit] then
        updateStats()
        updateUnitColor(unit)
    end
end

function f:UNIT_POWER_UPDATE(event, unit)
    print_debug(event, unit)
    updateStats()
    if maxCostTable[keyState] and mana < maxCostTable[keyState] then
        updateAllUnitColor()
    end
end

f:RegisterEvent("UNIT_HEALTH_FREQUENT")
f:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("MODIFIER_STATE_CHANGED")
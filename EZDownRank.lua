local GetSpellBonusHealing, UnitPower, UnitHealthMax, UnitHealth, CreateFrame, C_Timer, InCombatLockdown = GetSpellBonusHealing, UnitPower, UnitHealthMax, UnitHealth, CreateFrame, C_Timer, InCombatLockdown
local IsInRaid, GetNumSubgroupMembers, GetNumGroupMembers, GetTime, GetTalentInfo, IsSpellKnown, UnitInParty = IsInRaid, GetNumSubgroupMembers, GetNumGroupMembers, GetTime, GetTalentInfo, IsSpellKnown, UnitInParty
local UnitAura, UnitIsDeadOrGhost, UnitIsConnected = UnitAura, UnitIsDeadOrGhost, UnitIsConnected
local LGF = LibStub("LibGetFrame-1.0")
local GetUnitFrame = LGF.GetUnitFrame
local debug = false

local print_debug = function(...)
    if debug then
        print(...)
    end
end

local defaults = {
    button_size = 15,
    columns = 4,
    rows = 2,
    offsetX = 0,
    offsetY = 0,
    border = false,
    tooltip = false,
    alpha = 0.3,
    borderColor = {0, 0, 0},
    bestSpellColor = {0, 1, 0}, -- green
    notbestSpellColor = {1, 1, 0}, -- yellow
    notenoughManaColor = {1, 0.5, 0}, -- orange
}

local addonName = "EZDownRank"

local spellsDB = {
    PRIEST = {
        normal = {
            ranks = {
                { name = "F1", cost = 125, spellId = 2061, baseCastTime = 1.5, levelLearned = 20, rank = 1 },
                { name = "F2", cost = 155, spellId = 9472, baseCastTime = 1.5, levelLearned = 26, rank = 2 },
                { name = "F3", cost = 185, spellId = 9473, baseCastTime = 1.5, levelLearned = 32, rank = 3 },
                { name = "F4", cost = 215, spellId = 9474, baseCastTime = 1.5, levelLearned = 38, rank = 4 },
                { name = "F5", cost = 265, spellId = 10915, baseCastTime = 1.5, levelLearned = 44, rank = 5 },
                { name = "F6", cost = 315, spellId = 10916, baseCastTime = 1.5, levelLearned = 50, rank = 6 },
                { name = "F7", cost = 380, spellId = 10917, baseCastTime = 1.5, levelLearned = 56, rank = 7 },
                { name = "F8", cost = 400, spellId = 25233, baseCastTime = 1.5, levelLearned = 61, rank = 8 },
                { name = "F9", cost = 470, spellId = 25235, baseCastTime = 1.5, levelLearned = 67, rank = 9 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(2, 15)
                return 1 + (rank * 0.02)
            end,
        },
        shift = {
            ranks = {
                { name = "H1", cost = 155, spellId = 2054, baseCastTime = 3, levelLearned = 16, rank = 1 },
                { name = "H2", cost = 205, spellId = 2055, baseCastTime = 3, levelLearned = 22, rank = 2 },
                { name = "H3", cost = 255, spellId = 6063, baseCastTime = 3, levelLearned = 28, rank = 3 },
                { name = "H4", cost = 305, spellId = 6064, baseCastTime = 3, levelLearned = 34, rank = 4 },
                { name = "GH1", cost = 370, spellId = 2060, baseCastTime = 3, levelLearned = 40, rank = 1 },
                { name = "GH2", cost = 455, spellId = 10963, baseCastTime = 3, levelLearned = 46, rank = 2 },
                { name = "GH3", cost = 545, spellId = 10964, baseCastTime = 3, levelLearned = 52, rank = 3 },
                { name = "GH4", cost = 655, spellId = 10965, baseCastTime = 3, levelLearned = 58, rank = 4 },
                { name = "GH5", cost = 710, spellId = 25314, baseCastTime = 3, levelLearned = 60, rank = 5 },
                { name = "GH6", cost = 750, spellId = 25210, baseCastTime = 3, levelLearned = 63, rank = 6 },
                { name = "GH7", cost = 825, spellId = 25213, baseCastTime = 3, levelLearned = 68, rank = 7 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(2, 15)
                return 1 + (rank * 0.02)
            end,
            costFn = function()
                local _, _, _, _, rank  = GetTalentInfo(2, 10)
                return 1 - (rank * 0.05)
            end,
        },
        ctrl = {
            ranks = {
                { name = "POH1", cost = 410, spellId = 596, baseCastTime = 3, levelLearned = 30, coef = 3/3.5/3, rank = 1 },
                { name = "POH2", cost = 560, spellId = 996, baseCastTime = 3, levelLearned = 40, coef = 3/3.5/3, rank = 2 },
                { name = "POH3", cost = 770, spellId = 10960, baseCastTime = 3, levelLearned = 50, coef = 3/3.5/3, rank = 3 },
                { name = "POH4", cost = 1030, spellId = 10961, baseCastTime = 3, levelLearned = 60, coef = 3/3.5/3, rank = 4 },
                { name = "POH5", cost = 1070, spellId = 25316, baseCastTime = 3, levelLearned = 60, rank = 5 },
                { name = "POH6", cost = 1255, spellId = 25308, baseCastTime = 3, levelLearned = 68, rank = 6 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(2, 15)
                return 1 + (rank * 0.02)
            end,
            costFn = function()
                return 1
            end,
            ownGroupOnly = true,
            minMaxMatch = {
                pos = 2,
                regex = "(%d+) .+ (%d+) .+ (%d+)"
            },
        },
        alt = {
            {
                { name = "COH1", cost = 300, spellId = 34861, baseCastTime = 1.5, levelLearned = 50, rank = 1 },
                { name = "COH2", cost = 337, spellId = 34863, baseCastTime = 1.5, levelLearned = 56, rank = 2 },
                { name = "COH3", cost = 375, spellId = 34864, baseCastTime = 1.5, levelLearned = 60, rank = 3 },
                { name = "COH4", cost = 412, spellId = 34865, baseCastTime = 1.5, levelLearned = 65, rank = 4 },
                { name = "COH5", cost = 450, spellId = 34866, baseCastTime = 1.5, levelLearned = 70, rank = 5 },
            }
        },
    },
    SHAMAN = {
        normal = {
            ranks = {
                { name = "LHW1", cost = 105, spellId = 8004, baseCastTime = 1.5, levelLearned = 20, rank = 1 },
                { name = "LHW2", cost = 145, spellId = 8008, baseCastTime = 1.5, levelLearned = 28, rank = 2 },
                { name = "LHW3", cost = 185, spellId = 8010, baseCastTime = 1.5, levelLearned = 36, rank = 3 },
                { name = "LHW4", cost = 235, spellId = 10466, baseCastTime = 1.5, levelLearned = 44, rank = 4 },
                { name = "LHW5", cost = 305, spellId = 10467, baseCastTime = 1.5, levelLearned = 52, rank = 5 },
                { name = "LHW6", cost = 380, spellId = 10468, baseCastTime = 1.5, levelLearned = 60, rank = 6 },
                { name = "LHW7", cost = 440, spellId = 25420, baseCastTime = 1.5, levelLearned = 66, rank = 7 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 14)
                return 1 + (rank * 0.02)
            end,
            costFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 2)
                return 1 - (rank * 0.01)
            end,
        },
        shift = {
            ranks = {
                { name = "HW1", cost = 25, spellId = 331, baseCastTime = 1.5, levelLearned = 1, rank = 1 },
                { name = "HW2", cost = 45, spellId = 332, baseCastTime = 2, levelLearned = 6, rank = 2 },
                { name = "HW3", cost = 80, spellId = 547, baseCastTime = 2.5, levelLearned = 12, rank = 3 },
                { name = "HW4", cost = 155, spellId = 913, baseCastTime = 3, levelLearned = 18, rank = 4 },
                { name = "HW5", cost = 200, spellId = 939, baseCastTime = 3, levelLearned = 24, rank = 5 },
                { name = "HW6", cost = 265, spellId = 959, baseCastTime = 3, levelLearned = 32, rank = 6 },
                { name = "HW7", cost = 340, spellId = 8005, baseCastTime = 3, levelLearned = 40, rank = 7 },
                { name = "HW8", cost = 440, spellId = 10395, baseCastTime = 3, levelLearned = 48, rank = 8 },
                { name = "HW9", cost = 560, spellId = 10396, baseCastTime = 3, levelLearned = 56, rank = 9 },
                { name = "HW10", cost = 620, spellId = 25357, baseCastTime = 3, levelLearned = 60, rank = 10 },
                { name = "HW11", cost = 655, spellId = 25391, baseCastTime = 3, levelLearned = 63, rank = 11 },
                { name = "HW12", cost = 720, spellId = 25396, baseCastTime = 3, levelLearned = 70, rank = 12 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 14)
                return 1 + (rank * 0.02)
            end,
            costFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 2)
                return 1 - (rank * 0.01)
            end,
            buffModifier = function(unit)
                for i = 1, 255 do
                   local name, _, stacks, _, _, _, _, _, _, spellId = UnitAura(unit, i, "HELPFUL")
                   if not name then return 1 end
                   if 29203 == spellId then
                      return 1 + stacks * 0.06
                   end
                end
                return 1
            end
        },
        ctrl = {
            ranks = {
                { name = "CH1", cost = 260, spellId = 1064, baseCastTime = 2.5, levelLearned = 40, rank = 1 },
                { name = "CH2", cost = 315, spellId = 10622, baseCastTime = 2.5, levelLearned = 46, rank = 2 },
                { name = "CH3", cost = 405, spellId = 10623, baseCastTime = 2.5, levelLearned = 54, rank = 3 },
                { name = "CH4", cost = 435, spellId = 25422, baseCastTime = 2.5, levelLearned = 61, rank = 4 },
                { name = "CH5", cost = 540, spellId = 25423, baseCastTime = 2.5, levelLearned = 68, rank = 5 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 14)
                return 1 + (rank * 0.02)
            end,
            costFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 2)
                return 1 - (rank * 0.01)
            end,
        },
        -- alt = {},
    },
    DRUID = {
        normal = {
            ranks = {
                { name = "HT1", cost = 25, spellId = 5185, baseCastTime = 1.5, levelLearned = 1, rank = 1 },
                { name = "HT2", cost = 55, spellId = 5186, baseCastTime = 2, levelLearned = 8, rank = 2 },
                { name = "HT3", cost = 110, spellId = 5187, baseCastTime = 2.5, levelLearned = 14, rank = 3 },
                { name = "HT4", cost = 185, spellId = 5188, baseCastTime = 3, levelLearned = 20, rank = 4 },
                { name = "HT5", cost = 270, spellId = 5189, baseCastTime = 3.5, levelLearned = 26, rank = 5 },
                { name = "HT6", cost = 335, spellId = 6778, baseCastTime = 3.5, levelLearned = 32, rank = 6 },
                { name = "HT7", cost = 405, spellId = 8903, baseCastTime = 3.5, levelLearned = 38, rank = 7 },
                { name = "HT8", cost = 495, spellId = 9758, baseCastTime = 3.5, levelLearned = 44, rank = 8 },
                { name = "HT9", cost = 600, spellId = 9888, baseCastTime = 3.5, levelLearned = 50, rank = 9 },
                { name = "HT10", cost = 720, spellId = 9889, baseCastTime = 3.5, levelLearned = 56, rank = 10 },
                { name = "HT11", cost = 800, spellId = 25297, baseCastTime = 3.5, levelLearned = 60, rank = 11 },
                { name = "HT12", cost = 820, spellId = 26978, baseCastTime = 3.5, levelLearned = 62, rank = 12 },
                { name = "HT13", cost = 935, spellId = 26979, baseCastTime = 3.5, levelLearned = 69, rank = 13 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 12)
                return 1 + (rank * 0.02)
            end,
            costFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 9)
                return 1 - (rank * 0.02)
            end,
        },
        shift = {
            ranks = { -- TODO check all spell cost
                { name = "RG1", cost = 120, spellId = 8936, baseCastTime = 2, levelLearned = 16, rank = 1 },
                { name = "RG2", cost = 205, spellId = 8938, baseCastTime = 2, levelLearned = 18, rank = 2 },
                { name = "RG3", cost = 280, spellId = 8939, baseCastTime = 2, levelLearned = 24, rank = 3 },
                { name = "RG4", cost = 350, spellId = 8940, baseCastTime = 2, levelLearned = 30, rank = 4 },
                { name = "RG5", cost = 420, spellId = 8941, baseCastTime = 2, levelLearned = 36, rank = 5 },
                { name = "RG6", cost = 510, spellId = 9750, baseCastTime = 2, levelLearned = 42, rank = 6 },
                { name = "RG7", cost = 615, spellId = 9856, baseCastTime = 2, levelLearned = 48, rank = 7 },
                { name = "RG8", cost = 740, spellId = 9857, baseCastTime = 2, levelLearned = 54, rank = 8 },
                { name = "RG9", cost = 880, spellId = 9858, baseCastTime = 2, levelLearned = 60, rank = 9 },
                { name = "RG10", cost = 675, spellId = 26980, baseCastTime = 2, levelLearned = 65, rank = 10 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 12)
                return 1 + (rank * 0.02)
            end,
            costFn = function()
                local _, _, _, _, rank  = GetTalentInfo(3, 9)
                return 1 - (rank * 0.02)
            end,
        },
        -- ctrl = {},
        -- alt = {},
    },
    PALADIN = {
        normal = {
            ranks = {
                { name = "FL1", cost = 35, spellId = 19750, baseCastTime = 1.5, levelLearned = 20, rank = 1 },
                { name = "FL2", cost = 50, spellId = 19939, baseCastTime = 1.5, levelLearned = 26, rank = 2 },
                { name = "FL3", cost = 70, spellId = 19940, baseCastTime = 1.5, levelLearned = 34, rank = 3 },
                { name = "FL4", cost = 90, spellId = 19941, baseCastTime = 1.5, levelLearned = 42, rank = 4 },
                { name = "FL5", cost = 115, spellId = 19942, baseCastTime = 1.5, levelLearned = 50, rank = 5 },
                { name = "FL6", cost = 140, spellId = 19943, baseCastTime = 1.5, levelLearned = 58, rank = 6 },
                { name = "FL7", cost = 180, spellId = 27137, baseCastTime = 1.5, levelLearned = 66, rank = 7 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(1, 5)
                return 1 + (rank * 0.04)
            end,
        },
        shift = {
            ranks = {
                { name = "HL1", cost = 35, spellId = 635, baseCastTime = 2.5, levelLearned = 1, rank = 1 },
                { name = "HL2", cost = 60, spellId = 639, baseCastTime = 2.5, levelLearned = 6, rank = 2 },
                { name = "HL3", cost = 110, spellId = 647, baseCastTime = 2.5, levelLearned = 14, rank = 3 },
                { name = "HL4", cost = 190, spellId = 1026, baseCastTime = 2.5, levelLearned = 22, rank = 4 },
                { name = "HL5", cost = 275, spellId = 1042, baseCastTime = 2.5, levelLearned = 30, rank = 5 },
                { name = "HL6", cost = 365, spellId = 3472, baseCastTime = 2.5, levelLearned = 38, rank = 6 },
                { name = "HL7", cost = 465, spellId = 10328, baseCastTime = 2.5, levelLearned = 46, rank = 7 },
                { name = "HL8", cost = 580, spellId = 10329, baseCastTime = 2.5, levelLearned = 54, rank = 8 },
                { name = "HL9", cost = 660, spellId = 25292, baseCastTime = 2.5, levelLearned = 60, rank = 9 },
                { name = "HL10", cost = 710, spellId = 27135, baseCastTime = 2.5, levelLearned = 62, rank = 10 },
                { name = "HL11", cost = 840, spellId = 27136, baseCastTime = 2.5, levelLearned = 70, rank = 11 },
            },
            bonusFn = function()
                local _, _, _, _, rank  = GetTalentInfo(1, 5)
                return 1 + (rank * 0.04)
            end,
        },
        ctrl = {
            ranks = {
                { name = "HS1", cost = 225, spellId = 20473, baseCastTime = 1.5, levelLearned = 40, rank = 1 },
                { name = "HS2", cost = 275, spellId = 20929, baseCastTime = 1.5, levelLearned = 48, rank = 2 },
                { name = "HS3", cost = 325, spellId = 20930, baseCastTime = 1.5, levelLearned = 56, rank = 3 },
                { name = "HS4", cost = 575, spellId = 27174, baseCastTime = 1.5, levelLearned = 64, rank = 4 },
                { name = "HS5", cost = 650, spellId = 33072, baseCastTime = 1.5, levelLearned = 70, rank = 5 },
            }
        },
        -- alt = {},
    }
}

local myClass = select(2, UnitClass("player"))
if not spellsDB[myClass] then return end

local mySpells = spellsDB[myClass]
local function updateSpells()
    for _, v in pairs(mySpells) do
        v.bonus = v.bonusFn and v.bonusFn() or 1
        v.costMod = v.costFn and v.costFn() or 1
        v.nbActive = 0
        for _, spell in pairs(v.ranks) do
            spell.known = IsSpellKnown(spell.spellId)
            if spell.known then
                v.nbActive = v.nbActive + 1
            end
        end
    end
end
updateSpells()

local function spellForButton(mod, i, nbButtons)
    local spellsForMod = mySpells[mod]
    if spellsForMod then
        local diff = spellsForMod.nbActive > nbButtons and spellsForMod.nbActive - nbButtons or 0
        return spellsForMod.ranks[i + diff]
    end
end

local hiddenTooltip
local function GetHiddenTooltip()
  if not hiddenTooltip then
    hiddenTooltip = CreateFrame("GameTooltip", "EZDownRankTooltip", nil, "GameTooltipTemplate")
    hiddenTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    hiddenTooltip:AddFontStrings(
      hiddenTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
      hiddenTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
    )
  end
  return hiddenTooltip
end

local function getMinMax(spell, minMaxMatch)
    local tooltip = GetHiddenTooltip()
    tooltip:ClearLines()
    tooltip:SetSpellByID(spell.spellId)
    local tooltipTextLine = select(9, tooltip:GetRegions())
    local tooltipText = tooltipTextLine and tooltipTextLine:GetObjectType() == "FontString" and tooltipTextLine:GetText() or ""
    local pos = minMaxMatch and minMaxMatch.pos or 1
    local regex = minMaxMatch and minMaxMatch.regex or "(%d+) .- (%d+)"
    return select(pos, tooltipText:match(regex))
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
    local spellForKeyMod = mySpells[key]
    if spellForKeyMod then
        for _, spell in pairs(spellForKeyMod.ranks) do
            if spell.cost > maxCostTable[key] then
                maxCostTable[key] = spell.cost * spellForKeyMod.costMod
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

local updateUnitColor = function(unit)
    print_debug("updateUnitColor", unit)
    local activeSpells = mySpells[keyState] or mySpells.normal
    local deficit = UnitHealthMax(unit) - UnitHealth(unit)
    local dead = UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)
    local buffModifier = activeSpells.buffModifier and activeSpells.buffModifier(unit) or 1
    local bestFound
    local nbButtons = DB.columns * DB.rows
    for i = nbButtons, 1, -1 do
        local button = buttons[unit.."-"..i]
        if button then
            local spell = spellForButton(keyState, i, nbButtons)
            if spell and spell.known
            and (not activeSpells.ownGroupOnly or UnitInParty(unit) or unit == "player")
            and not dead
            then
                if not spell.max then
                    spell.min, spell.max = getMinMax(spell, activeSpells.minMaxMatch)
                end
                if activeSpells.bonus == 0 and activeSpells.bonusFn then
                    activeSpells.bonus = activeSpells.bonusFn()
                end
                if spell.max then
                    local levelPenality = 1
                    if spell.levelLearned < 20 then
                        levelPenality = 1 - (20-spell.levelLearned) * 0.0375
                    end
                    local castTimePenality = spell.coef or spell.baseCastTime / 3.5
                    local spellMaxHealing = (spell.max * activeSpells.bonus) + (healingPower * castTimePenality * levelPenality) -- calculate max heal
                    spellMaxHealing = spellMaxHealing * buffModifier
                    print_debug(("name: %s, max: %d, cmax: %d"):format(spell.name, spell.max, spellMaxHealing))
                    if spellMaxHealing > deficit then
                        button:SetBackdropColor(1, 0, 0, 0) -- invisible
                    else
                        local enoughMana
                        if mana >= spell.cost * activeSpells.costMod then
                            enoughMana = true
                        end
                        if not bestFound then
                            if enoughMana then
                                button:SetBackdropColor(DB.bestSpellColor[1], DB.bestSpellColor[2], DB.bestSpellColor[3], DB.alpha) -- green
                            end
                            bestFound = true
                        else
                            if enoughMana then
                                button:SetBackdropColor(DB.notbestSpellColor[1], DB.notbestSpellColor[2], DB.notbestSpellColor[3], DB.alpha) -- yellow
                            end
                        end
                        if not enoughMana then
                            button:SetBackdropColor(DB.notenoughManaColor[1], DB.notenoughManaColor[2], DB.notenoughManaColor[3], DB.alpha) -- orange
                        end
                    end
                end
                if DB.border then
                    button:SetBackdropBorderColor(DB.borderColor[1], DB.borderColor[2], DB.borderColor[3], DB.alpha)
                end
            else
                button:SetBackdropColor(1, 0, 0, 0) -- invisible
                button:SetBackdropBorderColor(0, 0, 0, 0)
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
            local ssize = DB.button_size * scale
            local x_space = (((frame:GetWidth() * scale) - (DB.columns * ssize))) / 2
            local y_space = (((frame:GetHeight() * scale) - (DB.rows * ssize))) / 2
            local x, y = x_space, - y_space
            local nbButtons = DB.columns * DB.rows
            for i = 1, nbButtons do
                local buttonName = unit.."-"..i
                local button = buttons[buttonName]
                if not button then
                    button = CreateFrame("Button", "EZDOWNRANK_BUTTON"..buttonName, f, "SecureActionButtonTemplate")
                    button:SetFrameStrata("DIALOG")
                    buttons[buttonName] = button
                    button:SetBackdrop({
                        bgFile = [[Interface\AddOns\EZDownRank\Square_FullWhite.tga]],
                        edgeFile = [[Interface\AddOns\EZDownRank\Square_FullWhite.tga]],
                        edgeSize = 1,
                    })
                end
                button:SetAttribute("unit", unit)
                for _, mod in pairs({"normal", "shift", "ctrl", "alt"}) do
                    local spell = spellForButton(mod, i, nbButtons)
                    if spell and spell.known then
                        local macroMod = mod == "normal" and "" or mod .. "-"
                        button:SetAttribute(macroMod.."type1", "spell")
                        button:SetAttribute(macroMod.."spell1", spell.spellId)
                    end
                end
                button:SetSize(ssize, ssize)
                button:SetBackdropColor(1, 0, 0, 0)
                if DB.border then
                    button:SetBackdropBorderColor(DB.borderColor[1], DB.borderColor[2], DB.borderColor[3], DB.alpha)
                else
                    button:SetBackdropBorderColor(0, 0, 0, 0)
                end
                if DB.tooltip then
                    button:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 0, 0)
                        local spellid = mySpells[keyState]
                            and mySpells[keyState].ranks
                            and mySpells[keyState].ranks[i]
                            and mySpells[keyState].ranks[i].spellId
                        local spell = spellForButton(keyState, i, nbButtons)
                        if spell and spell.known and spell.spellId then
                            GameTooltip:SetSpellByID(spell.spellId)
                            GameTooltip:Show()
                        end
                    end)
                    button:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                else
                    button:SetScript("OnEnter", nil)
                    button:SetScript("OnLeave", nil)
                end
                -- position button
                button:SetPoint("TOPLEFT", frame, "TOPLEFT", x + DB.offsetX, y + DB.offsetY)
                button:SetParent(frame)
                button:SetIgnoreParentAlpha(true)
                button:SetIgnoreParentScale(true)
                button:SetFrameLevel(99)
                if i % DB.columns == 0 then
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

function f:ADDON_LOADED(event, loadedAddon)
    print_debug(event, addonName)
    if loadedAddon == addonName then
        self:UnregisterEvent("ADDON_LOADED")
        if type(DB) ~= "table" then
            DB = {}
        end
        for k, v in pairs(defaults) do
            if DB[k] == nil then
                DB[k] = v
            end
        end
        DelayedUpdate()
    end
end

LGF.RegisterCallback(addonName, "GETFRAME_REFRESH", function()
    Update()
end)

f:SetScript("OnUpdate", function(self, elapsed)
    --print_debug(event)
    local prevKeyState = keyState
    shift = IsShiftKeyDown()
    ctrl = IsControlKeyDown()
    alt = IsAltKeyDown()
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
end)

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

function f:SPELLS_CHANGED(event)
    print_debug(event)
    updateSpells()
end

function f:CHARACTER_POINTS_CHANGED(event)
    print_debug(event)
    updateSpells()
end

f:RegisterEvent("UNIT_HEALTH_FREQUENT")
f:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("SPELLS_CHANGED")
f:RegisterEvent("CHARACTER_POINTS_CHANGED")

SLASH_EZDOWNRANK1, SLASH_EZDOWNRANK2 = "/ezdownrank", "/ezdr"
SlashCmdList["EZDOWNRANK"] = function(input)
    if InCombatLockdown() then
        print("Can't change ezdownrank options while in combat")
        return
    end
    local args, msg = {}
    for v in string.gmatch(input, "%S+") do
      if not msg then
        msg = v
      else
        table.insert(args, v)
      end
    end
    local num = args[1] and tonumber(args[1])
    local num2 = args[2] and tonumber(args[2])
    if msg == "size" and num then
        DB.button_size = num
        InitSquares()
    elseif msg == "layout" and num and num2 then
        DB.rows = num
        DB.columns = num2
        InitSquares()
    elseif msg == "offset" and num then
        DB.offsetX = num or 0
        DB.offsetY = num2 or 0
        InitSquares()
    elseif msg == "border" then
        DB.border = not DB.border
        InitSquares()
    elseif msg == "tooltip" then
        DB.tooltip = not DB.tooltip
        InitSquares()
    elseif msg == "reset" then
        for k, v in pairs(defaults) do
            DB[k] = v
        end
    else
        InterfaceOptionsFrame_OpenToCategory(addonName)
        InterfaceOptionsFrame_OpenToCategory(addonName)
        --[[
        print("Parameters for /ezdr or /ezdownrank command")
        print("/ezdr size <number>")
        print("/ezdr layout <#rows> <#columns>")
        print("/ezdr offset <x> <y>")
        print("/ezdr border")
        print("/ezdr tooltip")
        print("/ezdr reset")
        ]]--
    end
end

local optionsUI = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
optionsUI.name = addonName
optionsUI:SetScript("OnShow", function(frame)
	local function newCheckbox(label, description, onClick)
		local check = CreateFrame("CheckButton", addonName .. label, frame, "InterfaceOptionsCheckButtonTemplate")
		check:SetScript("OnClick", function(self)
			local tick = self:GetChecked()
			onClick(self, tick and true or false)
			if tick then
				PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
			else
				PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
			end
		end)
		check.label = _G[check:GetName() .. "Text"]
		check.label:SetText(label)
		check.tooltipText = label
		check.tooltipRequirement = description
		return check
	end

	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("EZDownRank")

	local border = newCheckbox(
		"Show Borders",
		nil,
        function(self, value)
            DB.border = value
            InitSquares()
        end
    )
    border:SetChecked(DB.border)
    border:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)

	local tooltip = newCheckbox(
		"Tooltips",
		nil,
        function(self, value)
            DB.tooltip = value
            InitSquares()
        end
    )
    tooltip:SetChecked(DB.tooltip)
    tooltip:SetPoint("TOPLEFT", border, "BOTTOMLEFT", 0, -15)


    local sizeText = frame:CreateFontString("sizeText", "ARTWORK", "GameFontNormal")
	sizeText:SetPoint("TOPLEFT", tooltip, "BOTTOMLEFT", 0, -15)
	sizeText:SetText("Buttons Size")

	local sizeSlider = CreateFrame("Slider", addonName.."sizeSlider", frame, "OptionsSliderTemplate")
	sizeSlider:SetPoint("TOPLEFT", sizeText, "BOTTOMLEFT", 10, -15)
    sizeSlider:SetScript("OnValueChanged", function(self, v)
        DB.button_size = v
        getglobal(sizeSlider:GetName().."Text"):SetText(DB.button_size)
        InitSquares()
    end)
    sizeSlider:SetMinMaxValues(5, 30)
    getglobal(sizeSlider:GetName().."Text"):SetText(DB.button_size)
	getglobal(sizeSlider:GetName().."High"):SetText(30)
	getglobal(sizeSlider:GetName().."Low"):SetText(5)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider:SetValue(DB.button_size)


    local rowText = frame:CreateFontString("rowText", "ARTWORK", "GameFontNormal")
	rowText:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", -10, -15)
	rowText:SetText("Rows")

	local rowSlider = CreateFrame("Slider", addonName.."rowSlider", frame, "OptionsSliderTemplate")
	rowSlider:SetPoint("TOPLEFT", rowText, "BOTTOMLEFT", 10, -15)
    rowSlider:SetScript("OnValueChanged", function(self, v)
        DB.rows = v
        getglobal(rowSlider:GetName().."Text"):SetText(DB.rows)
        InitSquares()
    end)
    rowSlider:SetMinMaxValues(1, 8)
    getglobal(rowSlider:GetName().."Text"):SetText(DB.rows)
	getglobal(rowSlider:GetName().."High"):SetText(8)
	getglobal(rowSlider:GetName().."Low"):SetText(1)
    rowSlider:SetValueStep(1)
    rowSlider:SetObeyStepOnDrag(true)
    rowSlider:SetValue(DB.rows)

    local columnText = frame:CreateFontString("columnText", "ARTWORK", "GameFontNormal")
	columnText:SetPoint("TOPLEFT", rowSlider, "BOTTOMLEFT", -10, -15)
	columnText:SetText("Columns")

	local columnSlider = CreateFrame("Slider", addonName.."columnSlider", frame, "OptionsSliderTemplate")
	columnSlider:SetPoint("TOPLEFT", columnText, "BOTTOMLEFT", 10, -15)
    columnSlider:SetScript("OnValueChanged", function(self, v)
        DB.columns = v
        getglobal(columnSlider:GetName().."Text"):SetText(DB.columns)
        InitSquares()
    end)
    columnSlider:SetMinMaxValues(1, 8)
    getglobal(columnSlider:GetName().."Text"):SetText(DB.columns)
	getglobal(columnSlider:GetName().."High"):SetText(8)
	getglobal(columnSlider:GetName().."Low"):SetText(1)
    columnSlider:SetValueStep(1)
    columnSlider:SetObeyStepOnDrag(true)
    columnSlider:SetValue(DB.columns)

    local offsetXText = frame:CreateFontString("offsetXText", "ARTWORK", "GameFontNormal")
	offsetXText:SetPoint("TOPLEFT", columnSlider, "BOTTOMLEFT", -10, -15)
	offsetXText:SetText("Offset X")

	local offsetXSlider = CreateFrame("Slider", addonName.."offsetXSlider", frame, "OptionsSliderTemplate")
	offsetXSlider:SetPoint("TOPLEFT", offsetXText, "BOTTOMLEFT", 10, -15)
    offsetXSlider:SetScript("OnValueChanged", function(self, v)
        DB.offsetX = v
        getglobal(offsetXSlider:GetName().."Text"):SetText(DB.offsetX)
        InitSquares()
    end)
    offsetXSlider:SetMinMaxValues(-30, 30)
    getglobal(offsetXSlider:GetName().."Text"):SetText(DB.offsetX)
	getglobal(offsetXSlider:GetName().."High"):SetText(30)
	getglobal(offsetXSlider:GetName().."Low"):SetText(-30)
    offsetXSlider:SetValueStep(1)
    offsetXSlider:SetObeyStepOnDrag(true)
    offsetXSlider:SetValue(DB.offsetX)

    local offsetYText = frame:CreateFontString("offsetYText", "ARTWORK", "GameFontNormal")
	offsetYText:SetPoint("TOPLEFT", offsetXSlider, "BOTTOMLEFT", -10, -15)
	offsetYText:SetText("Offset Y")

	local offsetYSlider = CreateFrame("Slider", addonName.."offsetYSlider", frame, "OptionsSliderTemplate")
	offsetYSlider:SetPoint("TOPLEFT", offsetYText, "BOTTOMLEFT", 10, -15)
    offsetYSlider:SetScript("OnValueChanged", function(self, v)
        DB.offsetY = v
        getglobal(offsetYSlider:GetName().."Text"):SetText(DB.offsetY)
        InitSquares()
    end)
    offsetYSlider:SetMinMaxValues(-30, 30)
    getglobal(offsetYSlider:GetName().."Text"):SetText(DB.offsetY)
	getglobal(offsetYSlider:GetName().."High"):SetText(30)
	getglobal(offsetYSlider:GetName().."Low"):SetText(-30)
    offsetYSlider:SetValueStep(1)
    offsetYSlider:SetObeyStepOnDrag(true)
    offsetYSlider:SetValue(DB.offsetY)

    optionsUI:SetScript("OnShow", nil)
end)
InterfaceOptions_AddCategory(optionsUI)
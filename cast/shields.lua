--[[
  Purpose: Classic Era absorb amounts and remaining-shield tracking.
  Deps: GetSpellBonusDamage, GetSpellBonusHealing, combat log
  Public: ShadowUI:ShieldInfo(), ShadowUI:ShieldAbsorbMax(), ShadowUI:ShieldFill(),
          ShadowUI:ShieldApplyAbsorb(), ShadowUI:ShieldAbsorbFromInfo(),
          ShadowUI:ShieldBonusFromClient(), ShadowUI:ShieldTalentsFromClient()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local ALL, PHYS, FIRE, FROST, SHADOW = 127, 1, 4, 16, 32
local SPELLS = {}
local PRIORITY = {
  fireWard = 1,
  frostWard = 1,
  shadowWard = 1,
  iceBarrier = 2,
  powerWordShield = 3,
  manaShield = 4,
}
local BONUS_SCHOOL = { fire = 2, frost = 4, shadow = 5, arcane = 6 }
local TALENT_NAMES = {
  ["Improved Power Word: Shield"] = "improvedPowerWordShield",
  ["Frost Warding"] = "frostWarding",
  ["Improved Ice Barrier"] = "improvedIceBarrier",
}

local function add(kind, coeff, absorb, bonus, icon, color, ranks)
  for id, base in pairs(ranks) do
    SPELLS[id] = {
      kind = kind,
      base = base,
      coeff = coeff,
      absorb = absorb,
      bonus = bonus,
      icon = icon,
      color = color,
    }
  end
end

-- Rank bases from Wowhead Classic spell effect values.
add("fireWard", 0.10, FIRE, "fire",
  "Interface\\Icons\\Spell_Fire_FireArmor", { 1.00, 0.49, 0.04 },
  { [543] = 166, [8457] = 290, [8458] = 470, [10223] = 675, [10225] = 920 })
add("frostWard", 0.10, FROST, "frost",
  "Interface\\Icons\\Spell_Frost_FrostWard", { 0.50, 0.72, 1.00 },
  { [6143] = 165, [8461] = 290, [8462] = 470, [10177] = 675, [28609] = 920 })
add("shadowWard", 0.10, SHADOW, "shadow",
  "Interface\\Icons\\Spell_Shadow_AntiShadow", { 0.64, 0.38, 0.90 },
  { [6229] = 290, [11739] = 470, [11740] = 675, [28610] = 920 })
add("iceBarrier", 0.10, ALL, "frost",
  "Interface\\Icons\\Spell_Ice_Lament", { 0.55, 0.78, 1.00 },
  { [11426] = 438, [13031] = 549, [13032] = 678, [13033] = 818 })
add("powerWordShield", 0.10, ALL, "heal",
  "Interface\\Icons\\Spell_Holy_PowerWordShield", { 1.00, 0.90, 0.45 },
  {
    [17] = 44, [592] = 88, [600] = 158, [3747] = 234, [6065] = 301,
    [6066] = 381, [10898] = 484, [10899] = 605, [10900] = 763, [10901] = 942,
  })
add("manaShield", 0.05, PHYS, "arcane",
  "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility", { 0.70, 0.40, 0.98 },
  { [1463] = 120, [8494] = 210, [8495] = 300, [10191] = 390, [10192] = 480, [10193] = 570 })

local function band(a, b)
  if bit32 and bit32.band then
    return bit32.band(a, b)
  end
  if bit and bit.band then
    return bit.band(a, b)
  end
  local r, p = 0, 1
  a, b = math.floor(a or 0), math.floor(b or 0)
  while a > 0 and b > 0 do
    if a % 2 == 1 and b % 2 == 1 then
      r = r + p
    end
    a, b, p = math.floor(a / 2), math.floor(b / 2), p * 2
  end
  return r
end

local function talentExtra(kind, talents)
  talents = talents or {}
  if kind == "powerWordShield" then
    return 0.05 * (talents.improvedPowerWordShield or 0)
  end
  if kind == "frostWard" then
    return 0.10 * (talents.frostWarding or 0)
  end
  if kind == "iceBarrier" then
    return 0.15 * (talents.improvedIceBarrier or 0)
  end
  return 0
end

function Addon:ShieldInfo(spellId)
  return SPELLS[spellId]
end

function Addon:ShieldAbsorbMax(spellId, bonus, talents)
  local info = SPELLS[spellId]
  if not info then
    return nil
  end
  local amount = info.base + (bonus or 0) * info.coeff
  return math.floor(amount * (1 + talentExtra(info.kind, talents)))
end

function Addon:ShieldFill(remaining, max)
  if not max or max <= 0 then
    return { ratio = 0, text = "0%" }
  end
  local ratio = (remaining or 0) / max
  if ratio < 0 then
    ratio = 0
  elseif ratio > 1 then
    ratio = 1
  end
  return {
    ratio = ratio,
    text = string.format("%d%%", math.floor(ratio * 100 + 0.5)),
  }
end

function Addon:ShieldApplyAbsorb(shields, amount, school, auraId)
  amount = amount or 0
  if amount <= 0 or not shields then
    return
  end
  local function take(shield)
    local eat = math.min(shield.remaining or 0, amount)
    shield.remaining = (shield.remaining or 0) - eat
    amount = amount - eat
  end
  if auraId then
    for _, shield in ipairs(shields) do
      if shield.spellId == auraId then
        take(shield)
        return
      end
    end
  end
  local ordered = {}
  for i, shield in ipairs(shields) do
    ordered[i] = shield
  end
  table.sort(ordered, function(a, b)
    local ia, ib = SPELLS[a.spellId], SPELLS[b.spellId]
    local pa = ia and PRIORITY[ia.kind] or 9
    local pb = ib and PRIORITY[ib.kind] or 9
    if pa == pb then
      return (a.spellId or 0) < (b.spellId or 0)
    end
    return pa < pb
  end)
  school = school or ALL
  for _, shield in ipairs(ordered) do
    if amount <= 0 then
      return
    end
    local info = SPELLS[shield.spellId]
    if info and band(info.absorb, school) ~= 0 then
      take(shield)
    end
  end
end

local function damageAbsorb(subevent, info)
  local base
  if subevent == "SWING_DAMAGE" then
    base = 12
  elseif subevent == "ENVIRONMENTAL_DAMAGE" then
    base = 13
  else
    base = 15
  end
  -- Modern suffix: amount, overkill, school, resisted, blocked, absorbed.
  -- Classic Era without overkill: amount, school, resisted, blocked, absorbed.
  if type(info[base + 5]) == "number" then
    return info[base + 5], info[base + 2]
  end
  return info[base + 4], info[base + 1]
end

local function missedAbsorb(subevent, info)
  local start = 15
  local school = info[14]
  if subevent == "SWING_MISSED" then
    start = 12
    school = 1
  end
  local missType = info[start]
  local next = info[start + 1]
  local absorbed
  if type(next) == "number" then
    absorbed = next
  else
    absorbed = info[start + 2]
  end
  return missType, absorbed, school
end

function Addon:ShieldAbsorbFromInfo(subevent, info)
  if type(subevent) ~= "string" or type(info) ~= "table" then
    return
  end
  if subevent == "SPELL_ABSORBED" then
    for i = 12, #info do
      local id = info[i]
      if type(id) == "number" and SPELLS[id] then
        local amount
        for j = i + 1, #info do
          local value = info[j]
          if type(value) == "number" and value > 0 and not SPELLS[value] then
            amount = value
          end
        end
        if amount then
          return amount, SPELLS[id].absorb, id
        end
      end
    end
    return
  end
  if subevent:find("_DAMAGE", 1, true) then
    local absorbed, school = damageAbsorb(subevent, info)
    if (absorbed or 0) > 0 then
      return absorbed, school
    end
    return
  end
  if not subevent:find("_MISSED", 1, true) then
    return
  end
  local missType, absorbed, school = missedAbsorb(subevent, info)
  if missType == "ABSORB" and (absorbed or 0) > 0 then
    return absorbed, school
  end
end

function Addon:ShieldBonusFromClient(spellId)
  local info = SPELLS[spellId]
  if not info then
    return 0
  end
  if info.bonus == "heal" then
    return (GetSpellBonusHealing and GetSpellBonusHealing()) or 0
  end
  local school = BONUS_SCHOOL[info.bonus]
  return (school and GetSpellBonusDamage and GetSpellBonusDamage(school)) or 0
end

function Addon:ShieldTalentsFromClient()
  local ranks = {
    improvedPowerWordShield = 0,
    frostWarding = 0,
    improvedIceBarrier = 0,
  }
  if not GetNumTalentTabs or not GetNumTalents or not GetTalentInfo then
    return ranks
  end
  for tab = 1, GetNumTalentTabs() or 0 do
    for i = 1, GetNumTalents(tab) or 0 do
      local name, _, _, _, rank = GetTalentInfo(tab, i)
      local key = TALENT_NAMES[name]
      if key then
        ranks[key] = rank or 0
      end
    end
  end
  return ranks
end

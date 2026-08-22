-- Target Frame auras get a cooldown swipe and remaining seconds from UnitAura.
-- Player BuffFrame already has Blizzard duration text. Raid frames stay default.
-- Run: lua tests/aura_duration_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function() end
_G.GetTime = function() return 14 end
_G.UnitAura = function(unit, index, filter)
  if unit == "target" and index == 1 and filter == "HARMFUL" then
    -- Classic 1.15: no rank. Caster sits where vanilla expirationTime used to sit.
    return "Moonfire", "Interface\\Icons\\Spell_Nature_StarFall", 1, "Magic", 12, 20, "player"
  end
end
_G.CreateFrame = function(kind, _, parent)
  local frame = { kind = kind, parent = parent, points = {} }
  function frame:SetAllPoints(host) frame.host = host end
  function frame:SetPoint(...) frame.points[#frame.points + 1] = { ... } end
  function frame:SetReverse(on) frame.reverse = on end
  function frame:SetDrawEdge(on) frame.edge = on end
  function frame:SetCooldown(startTime, duration)
    frame.startTime = startTime
    frame.duration = duration
  end
  function frame:Hide() frame.shown = false end
  function frame:Show() frame.shown = true end
  return frame
end

assert(loadfile(root .. "skin/auratime.lua"))()

local live = Addon:AuraDurationState(14, 12, 20)
assert(live, "live aura has duration state")
assert(live.remaining == 6, "remaining is expiration minus now")
assert(live.duration == 12, "duration stays the UnitAura length")
assert(live.startTime == 8, "swipe starts at expiration minus duration")
assert(Addon:AuraDurationState(20, 12, 20) == nil, "expired aura hides")
assert(Addon:AuraDurationState(14, 0, 20) == nil, "unknown duration hides")
assert(Addon:AuraDurationState(14, 20, "player") == nil, "caster token is not expiration")
assert(Addon:FormatShortDuration(6) == "6", "short remaining is seconds")
assert(Addon:FormatShortDuration(90) == "2m", "minute remaining rounds")

local icon = {}
function icon:GetTexture() return "Interface\\Icons\\Spell_Nature_StarFall" end
local button = { name = "TargetFrameDebuff1" }
function button:GetName() return "TargetFrameDebuff1" end
function button:IsShown() return true end
function button:CreateFontString()
  local fs = {}
  function fs:SetPoint() end
  function fs:SetText(text) fs.text = text end
  function fs:Show() fs.shown = true end
  function fs:Hide() fs.shown = false end
  button.font = fs
  return fs
end
_G.TargetFrameDebuff1 = button
_G.TargetFrameDebuff1Icon = icon

Addon:SkinAuraDuration(button)
assert(button.shadowUIAuraCooldown, "target aura gets a cooldown swipe")
assert(button.shadowUIAuraCooldown.reverse == true, "aura swipe fills clockwise")
assert(button.shadowUIAuraCooldown.startTime == 8, "swipe uses UnitAura start")
assert(button.shadowUIAuraCooldown.duration == 12, "swipe uses UnitAura duration")
assert(button.font.text == "6", "target aura shows remaining seconds")

local playerBuff = { name = "BuffButton1", Duration = {} }
function playerBuff:GetName() return "BuffButton1" end
Addon:SkinAuraDuration(playerBuff)
assert(not playerBuff.shadowUIAuraCooldown, "player buffs keep Blizzard duration")

_G.UnitAura = function(unit, index, filter)
  if unit == "target" and index == 1 and filter == "HARMFUL" then
    return "Moonfire", "Rank 1", "Interface\\Icons\\Spell_Nature_StarFall", 1, "Magic", 12, 20
  end
end
local vanilla = { name = "TargetFrameDebuff1" }
function vanilla:GetName() return "TargetFrameDebuff1" end
function vanilla:CreateFontString()
  local fs = {}
  function fs:SetPoint() end
  function fs:SetText(text) fs.text = text end
  function fs:Show() end
  function fs:Hide() end
  vanilla.font = fs
  return fs
end
Addon:SkinAuraDuration(vanilla)
assert(vanilla.shadowUIAuraCooldown.duration == 12, "vanilla UnitAura rank slot still works")

print("aura_duration_spec OK")

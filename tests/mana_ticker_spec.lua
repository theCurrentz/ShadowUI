-- Mana ticker sits under PlayerFrameManaBar and classifies regen vs FSR spend.
-- Run: lua tests/mana_ticker_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.CreateColor = function(r, g, b, a) return { r = r, g = g, b = b, a = a } end
_G.UIParent = { name = "UIParent" }

local function fakeTexture()
  local tex = {}
  function tex:SetAllPoints() end
  function tex:SetColorTexture() end
  function tex:SetHorizTile() end
  function tex:SetVertTile() end
  function tex:SetTexture() end
  function tex:SetWidth() end
  function tex:SetVertexColor() end
  function tex:SetBlendMode() end
  function tex:SetPoint() end
  function tex:SetGradient() end
  return tex
end

_G.CreateFrame = function(_, name)
  local frame = {
    name = name,
    points = {},
    shown = true,
    width = 0,
    height = 0,
  }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetAllPoints(parent) self.allPoints = parent end
  function frame:SetPoint(point, relativeTo, relativePoint, x, y)
    self.points[#self.points + 1] = {
      point = point,
      relativeTo = relativeTo,
      relativePoint = relativePoint,
      x = x,
      y = y,
    }
  end
  function frame:SetHeight(h) self.height = h end
  function frame:SetWidth(w) self.width = w end
  function frame:GetWidth() return self.width end
  function frame:SetMinMaxValues() end
  function frame:SetValue() end
  function frame:SetStatusBarTexture() end
  function frame:GetStatusBarTexture() return fakeTexture() end
  function frame:CreateTexture() return fakeTexture() end
  function frame:CreateFontString()
    local fs = { text = "", shown = true }
    function fs:SetPoint() end
    function fs:SetJustifyH() end
    function fs:SetFont() end
    function fs:SetText(text) self.text = text or "" end
    function fs:SetFormattedText(fmt, ...) self.text = fmt:format(...) end
    function fs:GetText() return self.text end
    function fs:Show() self.shown = true end
    function fs:Hide() self.shown = false end
    return fs
  end
  function frame:SetFrameStrata() end
  function frame:RegisterEvent() end
  function frame:RegisterUnitEvent() end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  return frame
end

_G.PlayerFrameManaBar = { name = "PlayerFrameManaBar", width = 119 }
function PlayerFrameManaBar:GetWidth() return self.width end
function Addon:GetPlayerClass() return "MAGE" end
_G.UnitPower = function() return 80 end
_G.UnitPowerMax = function() return 100 end
_G.UnitIsDead = function() return false end
_G.GetTime = function() return 10 end
_G.GetSpellPowerCost = function()
  return { { type = 0, cost = 50 } }
end

assert(loadfile(root .. "cast/castbar.lua"))()
assert(loadfile(root .. "cast/manaregen.lua"))()
assert(loadfile(root .. "cast/manaticker.lua"))()

assert(Addon:ManaGainKind(20, 0, false) == "tick", "unexplained gain is a regen tick")
assert(Addon:ManaGainKind(20, 20, false) == nil, "combat-log gain is not a tick")
assert(Addon:ManaGainKind(20, 20, true) == "drink", "logged drink still marks cadence")
assert(Addon:ManaGainKind(0, 0, false) == nil, "no gain is not a tick")
assert(Addon:ManaSpendAmount(-30, 0) == 30, "raw spend is the deficit")
assert(Addon:ManaSpendAmount(-10, 5) == 15, "spend subtracts explained gain in the same frame")
assert(Addon:ManaSpendAmount(10, 5) <= 0, "net gain is not a spend")

Addon:ApplyManaTicker()
local ticker = Addon.manaTicker
assert(ticker, "creates the ticker frame")
assert(ticker.points[1].relativeTo == PlayerFrameManaBar, "anchors to the portrait mana bar")
assert(ticker.points[1].point == "TOPLEFT", "uses top-left of ticker")
assert(ticker.points[1].relativePoint == "BOTTOMLEFT", "sits below the mana bar")
assert(ticker.points[2].relativePoint == "BOTTOMRIGHT", "matches mana bar width")
assert(ticker.width == 119, "width follows the mana bar")
assert(ticker.countdown, "creates a countdown label")

ticker.previousPower = 100
_G.UnitPower = function() return 100 end
Addon:ManaTickerOnEvent(ticker, "UNIT_SPELLCAST_SUCCEEDED", "player", "Fireball", 133)
_G.UnitPower = function() return 50 end
Addon:ManaTickerPulse(ticker)
assert(ticker.countdown.text == "5.0s", "FSR remaining is seconds with one decimal")
assert(ticker.countdown.shown, "FSR countdown is shown")

_G.GetTime = function() return 16 end
Addon:ManaTickerPulse(ticker)
Addon:ManaTickerPulse(ticker)
assert(ticker.countdown.text == "2.0s", "tick remaining is seconds with one decimal")
assert(ticker.countdown.shown, "tick countdown is shown")

_G.UnitIsDead = function() return true end
Addon:ManaTickerPulse(ticker)
assert(ticker.countdown.shown == false, "hides countdown while dead")

print("mana_ticker_spec OK")

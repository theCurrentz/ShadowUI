-- Combat meter group stacks Cast Bar, GCD Sweep, and Swing Timer.
-- Run: lua tests/swing_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.CreateColor = function(r, g, b, a) return { r = r, g = g, b = b, a = a } end
_G.UIParent = { name = "UIParent" }
_G.GetTime = function() return 10 end
_G.UnitGUID = function() return "player-guid" end
_G.UnitAttackSpeed = function() return 2.4, 1.8 end
_G.UnitRangedDamage = function() return 0 end
_G.InCombatLockdown = function() return false end
_G.UnitClass = function() return "Warrior", "WARRIOR" end
function Addon:GetPlayerClass() return "WARRIOR" end
function Addon:ApplyOuterChrome(host)
  host.shadowUIOuter = true
end

local function fakeTexture()
  local tex = {}
  function tex:SetAllPoints() end
  function tex:ClearAllPoints() end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetGradient() end
  function tex:SetVertexColor() end
  function tex:SetTexture() end
  function tex:SetWidth() end
  function tex:SetHeight(h) self.height = h end
  function tex:SetBlendMode(mode) self.blend = mode end
  function tex:SetPoint() end
  function tex:SetTexCoord() end
  function tex:SetAlpha(a) self.alpha = a end
  function tex:Show() end
  function tex:Hide() end
  return tex
end

_G.CreateFrame = function(_, name, parent)
  local frame = {
    name = name,
    parent = parent,
    points = {},
    shown = true,
    width = 0,
    height = 0,
    children = {},
  }
  function frame:SetSize(w, h) self.width = w; self.height = h end
  function frame:SetWidth(w) self.width = w end
  function frame:SetHeight(h) self.height = h end
  function frame:GetWidth() return self.width end
  function frame:GetHeight() return self.height end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetAllPoints(relative) self.allPoints = relative end
  function frame:SetPoint(point, relativeTo, relativePoint, x, y)
    self.points[#self.points + 1] = {
      point = point,
      relativeTo = relativeTo,
      relativePoint = relativePoint,
      x = x,
      y = y,
    }
  end
  function frame:SetFrameStrata() end
  function frame:SetStatusBarTexture() end
  function frame:SetStatusBarColor() end
  function frame:GetStatusBarTexture() return fakeTexture() end
  function frame:CreateTexture() return fakeTexture() end
  function frame:SetBackdrop() end
  function frame:SetBackdropColor() end
  function frame:SetBackdropBorderColor() end
  function frame:CreateFontString()
    local fs = { text = "" }
    function fs:SetPoint() end
    function fs:SetJustifyH() end
    function fs:SetFont() end
    function fs:SetFormattedText(fmt, ...) self.text = fmt:format(...) end
    function fs:SetText(text) self.text = text or "" end
    function fs:Show() end
    function fs:Hide() end
    return fs
  end
  function frame:SetMinMaxValues(_, maxv) self.max = maxv end
  function frame:SetValue(v) self.value = v end
  function frame:RegisterEvent() end
  function frame:RegisterUnitEvent() end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:CreateFrame()
    local child = CreateFrame(nil, nil)
    self.children[#self.children + 1] = child
    return child
  end
  return frame
end

assert(loadfile(root .. "cast/castbar.lua"))()
assert(loadfile(root .. "cast/gcd.lua"))()
assert(loadfile(root .. "cast/swing.lua"))()

local warrior = Addon:SwingHandsForClass("WARRIOR")
assert(warrior.main and warrior.off and not warrior.range, "warrior has main and off-hand")
local rogue = Addon:SwingHandsForClass("ROGUE")
assert(rogue.main and rogue.off and not rogue.range, "rogue has main and off-hand")
local hunter = Addon:SwingHandsForClass("HUNTER")
assert(hunter.main and hunter.off and hunter.range, "hunter has melee and ranged")
local paladin = Addon:SwingHandsForClass("PALADIN")
assert(paladin.main and not paladin.off and not paladin.range, "paladin has main-hand only")
local druid = Addon:SwingHandsForClass("DRUID")
assert(druid.main and not druid.off and not druid.range, "druid has main-hand only")
local shaman = Addon:SwingHandsForClass("SHAMAN")
assert(shaman.main and shaman.off and not shaman.range, "shaman can dual-wield")
local mage = Addon:SwingHandsForClass("MAGE")
assert(not mage.main and not mage.off and mage.range, "mage has wand only")
local priest = Addon:SwingHandsForClass("PRIEST")
assert(not priest.main and not priest.off and priest.range, "priest has wand only")
local warlock = Addon:SwingHandsForClass("WARLOCK")
assert(not warlock.main and not warlock.off and warlock.range, "warlock has wand only")

Addon:ApplyCastBar()
Addon:ApplySwingTimer()
local group = Addon.castGroup
local cast = Addon.castBar
local gcd = Addon.gcdBar
local swing = Addon.swingTimer
assert(group, "creates the combat meter group")
assert(group.points[1].point == "CENTER", "group anchors from centre")
assert(group.points[1].relativeTo == UIParent, "group anchors to UIParent")
assert(group.points[1].x == -6 and group.points[1].y == -132, "group keeps the Cast Bar lock")
assert(cast.parent == group, "Cast Bar sits in the group")
assert(cast.allPoints == group, "Cast Bar fills the group")
assert(cast.iconFrame, "Cast Bar has a spell icon")
assert(cast.iconFrame.height == cast.height, "spell icon matches Cast Bar height")
assert(cast.iconFrame.width == cast.height, "spell icon is square")
assert(cast.iconFrame.points[1].point == "LEFT", "spell icon overlays the left of the Cast Bar")
assert(cast.iconFrame.points[1].relativeTo == cast, "spell icon parents to the Cast Bar")
assert(cast.iconFrame.points[1].relativePoint == "LEFT", "spell icon stays on the meter")
assert(cast.iconFrame.points[1].x == 0, "spell icon sits flush with the Cast Bar")
assert(cast.icon.alpha and cast.icon.alpha < 1, "spell icon stays slightly transparent")
assert(cast.shadowUIOuter, "Cast Bar uses Outer Edge")
assert(not cast.iconFrame.shadowUIOuter, "overlay spell icon has no Outer Edge")
assert(gcd.parent == group, "GCD Sweep parents to the combat meter group")
assert(gcd.points[1].relativeTo == cast, "GCD Sweep starts under the Cast Bar")
assert(gcd.points[2].relativeTo == cast, "GCD Sweep ends under the Cast Bar")
assert(gcd.points[1].y == 0, "GCD Sweep has no gap under the Cast Bar")
assert(gcd.height == 4, "GCD Sweep stays skinny")
assert(gcd.gloss and gcd.gloss.blend == "ADD", "GCD Sweep uses a glossy highlight")
assert(gcd.background and gcd.background.a < 0.2, "GCD Sweep track is more transparent")
assert(swing.parent == group, "Swing Timer sits in the group")
assert(swing.points[1].relativeTo == gcd, "Swing Timer sits under the GCD Sweep")
assert(swing.points[1].y == 0, "Swing Timer has no gap under the GCD Sweep")
assert(swing.off.points[1].y == 0, "off-hand has no gap under main-hand")
assert(swing.range.points[1].y == 0, "ranged has no gap under the lane above")
assert(swing.main.background and swing.main.background.a < 0.5, "Swing Timer track is more transparent")
assert(swing.width == 288, "Swing Timer matches the Cast Bar")

function Addon:ResolveEffective()
  return { layout = { cast = { point = "CENTER", x = 12, y = -96, width = 216, height = 24 } } }
end
Addon:ApplyCastBar()
assert(group.points[1].x == 12 and group.points[1].y == -96, "Cast Bar follows Layout")
assert(group.width == 216 and group.height == 24, "Cast Bar size follows Layout")
assert(cast.iconFrame.width == 24 and cast.iconFrame.height == 24, "spell icon follows Cast Bar height")
assert(swing.width == 216, "Swing Timer follows the Cast Bar")
function Addon:ResolveEffective() return { layout = {} } end
Addon:ApplyCastBar()
assert(group.width == 288 and group.height == 20, "empty Layout restores the shipped Cast Bar size")
assert(swing.width == 288, "empty Layout restores Swing Timer to the Cast Bar")

assert(swing.main, "creates a main-hand bar")
assert(swing.off, "creates an off-hand bar")
assert(swing.main.shadowUIOuter and swing.off.shadowUIOuter and swing.range.shadowUIOuter,
  "swing bars use Outer Edge")
assert(swing.main.shown == false, "main-hand stays hidden until a swing")
assert(swing.off.shown == false, "off-hand stays hidden until a swing")

Addon:SwingSetSpeeds(swing, 2.4, 1.8)
Addon:SwingReset(swing, "main")
assert(swing.mainRemaining == 2.4, "main-hand reset uses attack speed")
Addon:SwingReset(swing, "off")
assert(swing.offRemaining == 1.8, "off-hand reset uses off-hand speed")

swing.lastPulse = 10
Addon:SwingPulse(swing)
assert(swing.main.shown == true, "main-hand shows while a swing is active")
assert(swing.off.shown == true, "off-hand shows while a swing is active")
swing.mainRemaining = 0
swing.offRemaining = 0
Addon:SwingPulse(swing)
assert(swing.main.shown == false, "main-hand hides when the swing ends")
assert(swing.off.shown == false, "off-hand hides when the swing ends")

Addon:SwingReset(swing, "main")
Addon:SwingReset(swing, "off")
swing.mainRemaining = 1.0
Addon:SwingNoteExtraAttack(swing)
Addon:SwingOnSwing(swing, false)
assert(swing.mainRemaining == 1.0, "extra attacks do not reset the main-hand timer")
Addon:SwingOnSwing(swing, false)
assert(swing.mainRemaining == 2.4, "the swing after extra attacks does reset")
swing.mainRemaining = 1.0
Addon:SwingOnSwing(swing, true)
assert(swing.offRemaining == 1.8, "off-hand swing resets only the off-hand")
assert(swing.mainRemaining == 1.0, "off-hand swing leaves main-hand remaining")

Addon:SwingSetSpeeds(swing, 2.0, 1.5)
swing.mainRemaining = 1.6
Addon:SwingApplyParryHaste(swing)
assert(swing.mainRemaining == 0.8, "parry haste removes 40 percent of swing time")
swing.mainRemaining = 0.3
Addon:SwingApplyParryHaste(swing)
assert(swing.mainRemaining == 0.3, "parry haste does not apply below 20 percent remaining")
Addon:SwingSetSpeeds(swing, 2.4, 1.8)

Addon:SwingHandleLog(swing, "SWING_DAMAGE", "player-guid", "mob", nil, false)
assert(swing.mainRemaining == 2.4, "player swing damage resets main-hand")
Addon:SwingHandleLog(swing, "SWING_MISSED", "mob", "player-guid", "PARRY", false)
assert(math.abs(swing.mainRemaining - 1.44) < 0.001, "incoming parry removes 40 percent of swing time")
Addon:SwingHandleLog(swing, "SPELL_DAMAGE", "player-guid", "mob", 1464, false)
assert(swing.mainRemaining == 2.4, "Slam resets the main-hand timer")

swing.lastPulse = 10
_G.GetTime = function() return 11 end
Addon:SwingPulse(swing)
assert(math.abs(swing.mainRemaining - 1.4) < 0.001, "pulse consumes elapsed time")
assert(swing.main.value == swing.mainRemaining, "bar value follows remaining time")

Addon:SwingSetSpeeds(swing, 2.4, nil)
assert(swing.off.shown == false, "hides the off-hand bar without an off-hand")

assert(swing.range, "creates a ranged bar")
function Addon:GetPlayerClass() return "HUNTER" end
Addon:SwingSetSpeeds(swing, 2.4, nil, 2.8)
Addon:SwingReset(swing, "range")
assert(swing.rangeRemaining == 2.8, "ranged reset uses ranged speed")
Addon:SwingHandleLog(swing, "RANGE_DAMAGE", "player-guid", "mob", 75, false)
assert(swing.rangeRemaining == 2.8, "Auto Shot resets the ranged timer")
swing.rangeRemaining = 1.0
Addon:SwingHandleLog(swing, "SPELL_DAMAGE", "player-guid", "mob", 5019, false)
assert(swing.rangeRemaining == 2.8, "wand Shoot resets the ranged timer")
Addon:SwingOnShot(swing, 2480)
assert(swing.rangeRemaining == 2.8, "Shoot Bow resets the ranged timer")
Addon:SwingSetSpeeds(swing, 2.4, nil, nil)
assert(swing.range.shown == false, "hides the ranged bar without a ranged weapon")

function Addon:GetPlayerClass() return "MAGE" end
Addon:SwingSetSpeeds(swing, 2.4, 1.8, 2.8)
Addon:SwingReset(swing, "main")
Addon:SwingReset(swing, "off")
Addon:SwingReset(swing, "range")
assert(not swing.mainRemaining or swing.mainRemaining == 0, "mage does not start a main-hand swing")
assert(swing.rangeRemaining == 2.8, "mage wand swing still resets")
swing.lastPulse = 11
Addon:SwingPulse(swing)
assert(swing.main.shown == false, "mage never shows a main-hand bar")
assert(swing.off.shown == false, "mage never shows an off-hand bar")
assert(swing.range.shown == true, "mage shows the wand bar while it is active")

Addon.editMode = true
Addon:ApplyCombatMeterPreview()
assert(cast.shown == true, "Layout Edit Mode previews the Cast Bar")
assert(gcd.shown == true, "Layout Edit Mode previews the GCD Sweep")
assert(swing.main.shown == true, "Layout Edit Mode previews main-hand for every class")
assert(swing.off.shown == true, "Layout Edit Mode previews off-hand for every class")
assert(swing.range.shown == true, "Layout Edit Mode previews ranged for every class")
Addon.editMode = false
Addon:ApplyCombatMeterPreview()
assert(gcd.shown == false, "play mode hides the GCD Sweep without a GCD")
assert(cast.shown == false, "play mode hides the Cast Bar without a cast")

print("swing_spec OK")

-- Combo points sit above the Target Frame portrait, not on it.
-- Five pips always show. Empty pips are a hollow ring. Filled pips are a red
-- dartboard with a short ADD rim glow. A new point pops in. At five, the row
-- grows on the Chrome bezier.
-- Native ComboFrame stays hidden.
-- Run: lua tests/combo_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = { DARKEN_BLACK = { 0.05, 0.05, 0.05 } }
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function() end
_G.GetTime = function()
  return _G._shadowUINow or 0
end
_G.GetComboPoints = function(unit, target)
  if unit == "player" and target == "target" then
    return _G._shadowUICombo or 0
  end
  return 0
end
_G.UnitClass = function()
  return "Rogue", "ROGUE"
end

assert(loadfile(root .. "core/easing.lua"))()

_G.CreateFrame = function(_, _, parent)
  local frame = { parent = parent, shown = true, points = {}, textures = {}, children = {} }
  function frame:SetSize(w, h) frame.w, frame.h = w, h end
  function frame:SetWidth(w) frame.w = w end
  function frame:SetHeight(h) frame.h = h end
  function frame:SetPoint(...)
    frame.points[#frame.points + 1] = { ... }
    frame.point = { ... }
  end
  function frame:SetAllPoints(host)
    frame.all = host or frame
    frame.point = { "ALL", host }
  end
  function frame:ClearAllPoints() frame.points = {} frame.point = nil frame.all = nil end
  function frame:SetFrameLevel() end
  function frame:GetFrameLevel() return 6 end
  function frame:SetFrameStrata() end
  function frame:SetScript(_, fn) frame.onUpdate = fn end
  function frame:SetScale(s) frame.scale = s end
  function frame:GetScale() return frame.scale or 1 end
  function frame:SetAlpha(a) frame.alpha = a end
  function frame:EnableMouse() end
  function frame:Show() frame.shown = true end
  function frame:Hide() frame.shown = false end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:SetAllPoints(host) tex.all = host or frame end
    function tex:SetTexture(path) tex.path = path end
    function tex:SetVertexColor(r, g, b, a)
      tex.r, tex.g, tex.b, tex.a = r, g, b, a
    end
    function tex:SetAlpha(a) tex.alpha = a end
    function tex:SetSize(w, h) tex.w, tex.h = w, h end
    function tex:SetPoint(...) tex.points[#tex.points + 1] = { ... } end
    function tex:ClearAllPoints() tex.points = {} end
    function tex:SetBlendMode(mode) tex.blend = mode end
    function tex:SetDrawLayer(layer, sub)
      tex.layer = layer
      tex.sub = sub
    end
    function tex:Show() tex.shown = true end
    function tex:Hide() tex.shown = false end
    tex.shown = true
    frame.textures[#frame.textures + 1] = tex
    return tex
  end
  return frame
end

local function hideable(name)
  local f = { name = name, shown = true }
  function f:Hide() self.shown = false end
  function f:Show() self.shown = true end
  function f:IsShown() return self.shown end
  function f:GetName() return self.name end
  return f
end

local portrait = { id = "portrait" }
function portrait:GetWidth() return 64 end
function portrait:GetHeight() return 64 end
_G.TargetFrame = { unit = "target", portrait = portrait }
function _G.TargetFrame:GetName() return "TargetFrame" end
function _G.TargetFrame:GetFrameLevel() return 5 end
_G.ComboFrame = hideable("ComboFrame")
_G.ComboPointPlayerFrame = hideable("ComboPointPlayerFrame")
_G.ComboPoint1 = hideable("ComboPoint1")
_G.ComboPoint2 = hideable("ComboPoint2")
_G.ComboPoint3 = hideable("ComboPoint3")
_G.ComboPoint4 = hideable("ComboPoint4")
_G.ComboPoint5 = hideable("ComboPoint5")

assert(loadfile(root .. "skin/combo.lua"))()

Addon._comboRegistered = {}
function Addon:RegisterEvent(event)
  Addon._comboRegistered[#Addon._comboRegistered + 1] = event
end
_G.C_EventUtils = {
  IsEventValid = function(event)
    return event ~= "UNIT_COMBO_POINTS"
  end,
}

assert(Addon:ComboPointPopScale(0) > 1.2, "pop starts oversized")
assert(math.abs(Addon:ComboPointPopScale(1) - 1) < 0.01, "pop settles at 1")
assert(Addon:ComboPointPopScale(0.3) < Addon:ComboPointPopScale(0),
  "pop shrinks toward rest")
assert(Addon:ComboPointPopScale(0.3) > Addon:ComboPointPopScale(0.8),
  "pop uses the bezier so the settle is quick")

assert(Addon:ComboPointFullScale(0) == 1, "five-stack grow starts at rest")
assert(Addon:ComboPointFullScale(1) > 1.1, "five-stack grow ends slightly larger")
assert(Addon:ComboPointFullScale(1) < 1.25, "five-stack grow stays slight")
assert(Addon:ComboPointFullScale(0.3) > 1 + (Addon:ComboPointFullScale(1) - 1) * 0.3,
  "five-stack grow uses the bezier so the rise is quick")

_G._shadowUICombo = 3
Addon:SkinComboPoints()
local registered = table.concat(Addon._comboRegistered, ",")
assert(not registered:find("UNIT_COMBO_POINTS", 1, true),
  "Era and TBC do not register UNIT_COMBO_POINTS")
assert(registered:find("PLAYER_COMBO_POINTS", 1, true),
  "combo points listen to PLAYER_COMBO_POINTS")
local host = _G.TargetFrame.shadowUICombo
assert(host, "Target Frame hosts combo points")
assert(host.shown == true, "combo host shows when the player has points")
assert(host.point[1] == "BOTTOM" and host.point[2] == portrait
    and host.point[3] == "TOP" and host.point[4] == 6 and host.point[5] == 12,
  "combo point track sits 6px right and 12px above the portrait")
assert(host.pips and #host.pips == 5, "Classic combo is five points")
for i = 1, 5 do
  assert(host.pips[i].shown == true, "all five combo pips stay shown")
end
assert(host.pips[4].fill.shown == false and host.pips[5].fill.shown == false,
  "empty combo points keep a hollow inner")
assert(host.pips[4].core.shown == false, "empty combo points have no dartboard core")
assert(host.pips[4].glow.shown == false, "empty combo points have no glow")
assert(host.pips[4].rim.r == 0 and host.pips[4].rim.g == 0 and host.pips[4].rim.b == 0
    and host.pips[4].rim.a == 0.5,
  "empty combo points use a 50% black border")
assert(host.pips[4].rim.path and host.pips[4].rim.path:find("outer_shadow_circle", 1, true),
  "empty border is the circular drop ring so the inner stays transparent")
assert(host.pips[1].fill.shown and host.pips[2].fill.shown and host.pips[3].fill.shown,
  "filled combo points show a fill")
assert(host.pips[3].core.shown == true
    and host.pips[3].core.w < host.pips[3].fill.w,
  "filled combo points add a smaller dartboard core")
assert(host.pips[3].fill.r and host.pips[3].fill.r > 0.8
    and host.pips[3].fill.g and host.pips[3].fill.g < 0.35,
  "filled combo points are red")
assert(host.pips[3].glow.shown == true and host.pips[3].glow.blend == "ADD"
    and host.pips[3].glow.path and host.pips[3].glow.path:find("outer_shadow_circle", 1, true)
    and (host.pips[3].glow.a or 1) <= 0.25
    and host.pips[3].glow.w <= host.pips[3].visual.w + 6,
  "filled combo points use a short rim glow, not a filled bloom")
assert(host.pips[3].visual and (not host.pips[3].scale or host.pips[3].scale == 1),
  "pop scales the centred visual, not the slot, so neighbours do not shift")
assert(host.pips[3].visual.scale and host.pips[3].visual.scale > 1.2,
  "a newly filled point starts in the pop")
assert(_G.ComboFrame.shown == false, "native ComboFrame stays hidden")
assert(_G.ComboPointPlayerFrame.shown == false, "native ComboPointPlayerFrame stays hidden")
assert(_G.ComboPoint1.shown == false, "native ComboPoint1 stays hidden")
_G.ComboFrame:Show()
assert(_G.ComboFrame.shown == false, "Blizzard cannot Show ComboFrame after hide")

_G._shadowUINow = 0.2
if host.onUpdate then
  host.onUpdate(host, 0.2)
end
assert(math.abs(host.pips[3].visual.scale - 1) < 0.05, "pop finishes at rest scale")

_G._shadowUINow = 0.2
_G._shadowUICombo = 0
Addon:SkinComboPoints()
assert(_G.TargetFrame.shadowUICombo.shown == true, "combo host stays on the target at 0 points")
for i = 1, 5 do
  assert(host.pips[i].shown == true, "all five combo pips stay on the target at 0")
  assert(host.pips[i].fill.shown == false, "unacquired pips stay hollow at 0")
end

_G._shadowUICombo = 1
Addon:SkinComboPoints()
assert(_G.TargetFrame.shadowUICombo.shown == true, "combo host stays when points return")
assert(host.pips[1].fill.shown == true and host.pips[2].fill.shown == false,
  "only acquired combo points fill")
assert(host.pips[2].shown == true, "unacquired combo points stay visible")

_G._shadowUINow = 0.4
if host.onUpdate then
  host.onUpdate(host, 0.2)
end
_G._shadowUICombo = 5
Addon:SkinComboPoints()
assert(host._shadowUIFullStart == 0.4, "five points start the grow")
assert(math.abs((host.pips[1].visual.scale or 1) - 1) < 0.05,
  "five-stack grow starts at rest")
assert(host.pips[5].visual.scale > 1.2, "the fifth point still pops")

_G._shadowUINow = 0.7
if host.onUpdate then
  host.onUpdate(host, 0.3)
end
local grown = host.pips[1].visual.scale
assert(grown and grown > 1.1 and grown < 1.25, "five points settle slightly larger")
assert(math.abs(host.pips[2].visual.scale - grown) < 0.02,
  "every pip shares the five-stack grow")
assert(math.abs(host.pips[5].visual.scale - grown) < 0.02,
  "the fifth pip rest matches the five-stack grow after pop")

_G._shadowUICombo = 4
Addon:SkinComboPoints()
assert(math.abs((host.pips[1].visual.scale or 1) - 1) < 0.02,
  "drop below five returns to rest scale")
assert(host.pips[5].fill.shown == false, "lost fifth point goes hollow")

_G.UnitClass = function()
  return "Warrior", "WARRIOR"
end
Addon:SkinComboPoints()
assert(host.shown == false, "combo host hides for classes without combo points")
_G.UnitClass = function()
  return "Rogue", "ROGUE"
end
Addon:SkinComboPoints()
assert(host.shown == true, "combo host returns for Rogue")

local toc = assert(io.open(root .. "ShadowUI.toc", "r")):read("*a")
assert(toc:find("skin\\combo.lua", 1, true), "Era TOC loads combo")
local tocTbc = assert(io.open(root .. "ShadowUI_TBC.toc", "r")):read("*a")
assert(tocTbc:find("skin\\combo.lua", 1, true), "TBC TOC loads combo")

print("combo_spec OK")

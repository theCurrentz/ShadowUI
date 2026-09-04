-- Classic maps rare-elite to the elite dragon. ShadowUI overlays a cropped,
-- smaller slice of that dragon just right of the portrait so the hidden
-- targeting-frame well cannot stretch over the compact bars.
-- Run: lua tests/rare_elite_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = { DARKEN_BLACK = { 0.05, 0.05, 0.05 } }
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function() end

assert(loadfile(root .. "skin/frames.lua"))()

assert(
  Addon:RareEliteTexture("rareelite") == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
  "rare-elite uses the winged silver dragon"
)
assert(
  Addon:RareEliteTexture("rare") == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
  "rare uses the silver dragon"
)
assert(
  Addon:RareEliteTexture("elite") == "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
  "elite uses the gold dragon"
)
assert(
  Addon:RareEliteTexture("worldboss") == "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
  "world boss uses the gold dragon"
)
assert(Addon:RareEliteTexture("normal") == nil, "normal has no dragon overlay")
assert(Addon:RareEliteTexture("minus") == nil, "minus has no dragon overlay")

local tex = { path = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite" }
function tex:SetTexture(path) self.path = path end
local portrait = { name = "portrait" }
local class = "rareelite"
_G.TargetFrame = {
  unit = "target",
  borderTexture = tex,
  portrait = portrait,
}
function _G.TargetFrame:GetName() return "TargetFrame" end
function _G.TargetFrame:CreateTexture(_, layer, _, sub)
  local overlay = {
    layer = layer,
    sub = sub,
    points = {},
    shown = true,
  }
  function overlay:SetTexture(path) overlay.path = path end
  function overlay:SetTexCoord(...) overlay.texCoord = { ... } end
  function overlay:SetSize(w, h) overlay.w, overlay.h = w, h end
  function overlay:SetDrawLayer(layer, sub)
    overlay.layer = layer
    overlay.sub = sub
  end
  function overlay:SetVertexColor(r, g, b, a)
    overlay.r, overlay.g, overlay.b, overlay.a = r, g, b, a
  end
  function overlay:ClearAllPoints() overlay.points = {} end
  function overlay:SetPoint(...) overlay.points[#overlay.points + 1] = { ... } end
  function overlay:Show() overlay.shown = true end
  function overlay:Hide() overlay.shown = false end
  return overlay
end
_G.UnitClassification = function(unit)
  return unit == "target" and class or "normal"
end

Addon:SkinRareElite(_G.TargetFrame)
assert(tex.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
  "hidden native border still swaps to Rare-Elite")
local dragon = _G.TargetFrame.shadowUIDragon
assert(dragon, "rare-elite paints a dragon overlay around the portrait")
assert(dragon.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
  "overlay uses the winged silver dragon")
assert(dragon.shown == true, "rare-elite dragon overlay is shown")
assert(dragon.w == 64 and dragon.h == 64,
  "dragon overlay is smaller than the native targeting-frame")
assert(dragon.points[1][1] == "LEFT" and dragon.points[1][2] == portrait
    and dragon.points[1][3] == "RIGHT" and dragon.points[1][4] == -8
    and dragon.points[1][5] == 0,
  "dragon overlay sits just right of the portrait")
assert(dragon.texCoord[1] == 0.484375 and dragon.texCoord[2] == 0.09375
    and dragon.texCoord[3] == 1 and dragon.texCoord[4] == 0,
  "target dragon overlay is a flipped crop of the portrait-side atlas")
assert(dragon.r == 1 and dragon.g == 1 and dragon.b == 1,
  "dragon overlay keeps native gold/silver colour")
assert(dragon.layer == "BACKGROUND" and dragon.sub == -8,
  "dragon overlay sits behind the meter well so the 12px bar art cannot ghost")

class = "rare"
Addon:SkinRareElite(_G.TargetFrame)
assert(dragon.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
  "rare swaps to the silver dragon")
assert(dragon.shown == true, "rare dragon overlay stays shown")

class = "elite"
Addon:SkinRareElite(_G.TargetFrame)
assert(dragon.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
  "elite swaps to the gold dragon")

class = "normal"
Addon:SkinRareElite(_G.TargetFrame)
assert(dragon.shown == false, "a normal target hides the dragon overlay")

print("rare_elite_spec OK")

-- Classic maps rare-elite to the elite dragon. ShadowUI swaps the native
-- Frame Art atlas. It does not crop a second overlay; that paints gold bar
-- glyphs on the portrait.
-- Run: lua tests/rare_elite_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = { DARKEN_BLACK = { 0.05, 0.05, 0.05 }, DARKEN_SOFT = { 0.14, 0.14, 0.14 } }
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
assert(Addon:RareEliteTexture("normal") == nil, "normal has no elite atlas")
assert(Addon:RareEliteTexture("minus") == nil, "minus has no elite atlas")

local tex = {
  path = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
}
function tex:SetTexture(path) self.path = path end
local created = 0
local class = "rareelite"
_G.TargetFrameTextureFrameTexture = tex
_G.TargetFrame = {
  unit = "target",
  borderTexture = tex,
  shadowUIDragon = { shown = true, Hide = function(self) self.shown = false end },
  shadowUIDragonEdge = { shown = true, Hide = function(self) self.shown = false end },
}
function _G.TargetFrame:GetName() return "TargetFrame" end
function _G.TargetFrame:CreateTexture()
  created = created + 1
end
_G.UnitClassification = function(unit)
  return unit == "target" and class or "normal"
end

Addon:SkinRareElite(_G.TargetFrame)
assert(tex.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
  "native Frame Art swaps to Rare-Elite")
assert(created == 0, "must not crop a second targeting-frame atlas")
assert(_G.TargetFrame.shadowUIDragon.shown == false,
  "stale dragon overlay hides so gold bar glyphs cannot stay")
assert(_G.TargetFrame.shadowUIDragonEdge.shown == false,
  "stale Darken rim hides")

class = "rare"
Addon:SkinRareElite(_G.TargetFrame)
assert(tex.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
  "rare swaps to the silver dragon")

class = "elite"
Addon:SkinRareElite(_G.TargetFrame)
assert(tex.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
  "elite swaps to the gold dragon")

print("rare_elite_spec OK")

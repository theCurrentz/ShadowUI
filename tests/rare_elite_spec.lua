-- Classic maps rare-elite to the elite dragon. ShadowUI uses the Rare-Elite art.
-- Run: lua tests/rare_elite_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function() end

assert(loadfile(root .. "skin/frames.lua"))()

assert(
  Addon:RareEliteTexture("rareelite") == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
  "rare-elite uses the winged silver dragon"
)
assert(Addon:RareEliteTexture("rare") == nil, "rare keeps Blizzard rare art")
assert(Addon:RareEliteTexture("elite") == nil, "elite keeps Blizzard elite art")
assert(Addon:RareEliteTexture("normal") == nil, "normal keeps Blizzard art")

local tex = { path = "Interface\\TargetingFrame\\UI-TargetingFrame-Elite" }
function tex:SetTexture(path) self.path = path end
_G.TargetFrame = {
  unit = "target",
  borderTexture = tex,
}
function _G.TargetFrame:GetName() return "TargetFrame" end
_G.UnitClassification = function(unit)
  return unit == "target" and "rareelite" or "normal"
end

Addon:SkinRareElite(_G.TargetFrame)
assert(tex.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite", "target border swaps to Rare-Elite")

print("rare_elite_spec OK")

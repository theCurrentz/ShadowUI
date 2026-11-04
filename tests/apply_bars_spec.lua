-- ApplyBars skins Blizzard ActionButtons. It does not create LibActionButton Bars.
-- Run: lua tests/apply_bars_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end

assert(loadfile(root .. "bars/manager.lua"))()

local created = false
function Addon:CreateBar()
  created = true
end
local skinned = false
function Addon:SkinBlizzardActionBars()
  skinned = true
end

Addon:ApplyBars({ layout = { bar1 = { enabled = true, buttons = 12 } } })
assert(created == false, "ApplyBars must not create ShadowUI Bars")
assert(skinned == true, "ApplyBars skins Blizzard ActionButtons")

print("apply_bars_spec OK")

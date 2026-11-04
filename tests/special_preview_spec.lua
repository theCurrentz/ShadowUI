-- ApplyBars does not create LibActionButton Special Bars. Forever skins
-- Blizzard pet and stance buttons in place.
-- Run: lua tests/special_preview_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end

assert(loadfile(root .. "bars/manager.lua"))()
function Addon:SkinBlizzardActionBars() end
Addon:ApplyBars({
  layout = {
    bar1 = { enabled = true, buttons = 12 },
    pet = { enabled = true, buttons = 10 },
    possess = { enabled = true, buttons = 2 },
  },
})
assert(Addon.bars == nil, "ApplyBars must not create ShadowUI Bars")

print("special_preview_spec OK")

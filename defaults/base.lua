--[[
  Purpose: Shared centered Base layout kept inside ±360 of screen centre.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.base
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults = Addon.Defaults or { base = {}, classes = {} }

local SIZE = 36
local function bar(point, x, y, buttons, columns, enabled)
  return {
    point = point or "CENTER",
    relativeTo = "UIParent",
    relativePoint = point or "CENTER",
    x = x, y = y,
    buttons = buttons or 12,
    columns = columns or 12,
    scale = 1,
    enabled = enabled ~= false,
    buttonSize = SIZE,
  }
end

-- Enabled by default: four bottom rows plus one vertical column per side.
-- bar7-bar10 ship parked but disabled so enabling them does not overlap.
Addon.Defaults.base = {
  layout = {
    bar1 = bar("CENTER", 0, -210, 12, 12),
    bar2 = bar("CENTER", 0, -246, 12, 12),
    bar3 = bar("CENTER", 0, -282, 12, 12),
    bar6 = bar("CENTER", 0, -318, 12, 12),
    bar4 = bar("CENTER", -300, -60, 12, 1),
    bar5 = bar("CENTER", 300, -60, 12, 1),
    bar7 = bar("CENTER", -336, -60, 12, 1, false),
    bar8 = bar("CENTER", 336, -60, 12, 1, false),
    bar9 = bar("CENTER", 0, 246, 12, 12, false),
    bar10 = bar("CENTER", 0, 282, 12, 12, false),
    pet = bar("CENTER", 0, -170, 10, 10),
    possess = bar("CENTER", 0, -46, 2, 2),
  },
  keybinds = {},
}

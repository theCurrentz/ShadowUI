--[[
  Purpose: Shared centered Base layout; all standard bars enabled.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.base
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults = Addon.Defaults or { base = {}, classes = {} }

local SIZE = 36
local function bar(point, x, y, buttons, columns)
  return {
    point = point or "CENTER",
    relativeTo = "UIParent",
    relativePoint = point or "CENTER",
    x = x, y = y,
    buttons = buttons or 12,
    columns = columns or 12,
    scale = 1,
    enabled = true,
    buttonSize = SIZE,
  }
end

Addon.Defaults.base = {
  layout = {
    bar1 = bar("CENTER", 0, -200, 12, 12),
    bar2 = bar("CENTER", 0, -236, 12, 12),
    bar3 = bar("CENTER", 0, -272, 12, 12),
    bar4 = bar("CENTER", -252, -200, 12, 1),
    bar5 = bar("CENTER", 252, -200, 12, 1),
    bar6 = bar("CENTER", 0, -308, 12, 12),
    bar7 = bar("CENTER", 0, -344, 12, 12),
    bar8 = bar("CENTER", 0, -380, 12, 12),
    bar9 = bar("CENTER", 0, -416, 12, 12),
    bar10 = bar("CENTER", 0, -452, 12, 12),
    pet = bar("CENTER", -252, -272, 10, 10),
    possess = bar("CENTER", 0, -160, 2, 2),
  },
  keybinds = {},
}

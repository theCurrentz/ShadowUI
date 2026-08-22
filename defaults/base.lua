--[[
  Purpose: Shared Base layout: six reversed rows plus 3x4 side bars.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.base
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults = Addon.Defaults or { base = {}, classes = {} }

-- 90% of the Classic 36px icon. Row y uses SIZE so bar6 stays on the screen edge.
local SIZE = 36 * 0.9
local BOTTOM = 0
local ROW_WIDTH = 12 * SIZE
local SIDE_WIDTH = 3 * SIZE
local SIDE_X = ROW_WIDTH / 2 + SIDE_WIDTH / 2

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

-- bar1 is the top row of the six-wide stack. bar6 is the bottom row.
local function row(fromTop)
  return bar("BOTTOM", 0, BOTTOM + (5 - fromTop) * SIZE, 12, 12)
end

Addon.Defaults.base = {
  layout = {
    bar1 = row(0),
    bar2 = row(1),
    bar3 = row(2),
    bar4 = row(3),
    bar5 = row(4),
    bar6 = row(5),
    bar7 = bar("BOTTOM", -SIDE_X, BOTTOM, 12, 3),
    bar8 = bar("BOTTOM", SIDE_X, BOTTOM, 12, 3),
    bar9 = bar("BOTTOM", 0, BOTTOM + 8 * SIZE, 12, 12, false),
    bar10 = bar("BOTTOM", 0, BOTTOM + 9 * SIZE, 12, 12, false),
    pet = bar("BOTTOM", 0, BOTTOM + 6 * SIZE, 10, 10),
    possess = bar("BOTTOM", 0, BOTTOM + 7 * SIZE, 2, 2),
  },
  keybinds = {},
}

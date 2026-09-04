--[[
  Purpose: Shared Base layout and Keybinds: six reversed rows, 3x4 side bars,
           bar9, bar10, pet, possess, Global gap and shape, and the default Action Slot keys.
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

local function slot(n)
  return "CLICK ShadowUIActionButton" .. n .. ":Keybind"
end

local function bar(point, x, y, buttons, columns, enabled)
  return {
    point = point or "CENTER",
    relativeTo = "UIParent",
    relativePoint = point or "CENTER",
    x = x, y = y,
    buttons = buttons or 12,
    columns = columns or 12,
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
    global = {
      gap = 0,
      iconShape = "square",
    },
    bar1 = row(0),
    bar2 = row(1),
    bar3 = row(2),
    bar4 = row(3),
    bar5 = row(4),
    bar6 = row(5),
    bar7 = bar("BOTTOM", -SIDE_X, BOTTOM, 12, 3),
    bar8 = bar("BOTTOM", SIDE_X, BOTTOM, 12, 3),
    bar9 = bar("BOTTOM", 0, BOTTOM + 8 * SIZE, 12, 12),
    bar10 = bar("BOTTOM", 0, BOTTOM + 9 * SIZE, 12, 12),
    pet = bar("BOTTOM", 0, BOTTOM + 6 * SIZE, 10, 10),
    possess = bar("BOTTOM", 0, BOTTOM + 7 * SIZE, 2, 2),
    cooldown = {
      point = "CENTER",
      relativeTo = "UIParent",
      relativePoint = "CENTER",
      x = 0,
      y = -96,
      scale = 1,
      gap = 4,
      direction = "right",
      columns = 8,
      max = 8,
      vertical = false,
      enabled = true,
      buttonSize = SIZE,
    },
  },
  -- Current Warrior Action Bar keys. Every class inherits this Base map.
  keybinds = {
    [slot(1)] = "Q",
    [slot(2)] = "E",
    [slot(3)] = "R",
    [slot(4)] = "F",
    [slot(5)] = "T",
    [slot(6)] = "G",
    [slot(7)] = "C",
    [slot(8)] = "V",
    [slot(9)] = "B",
    [slot(10)] = "X",
    [slot(11)] = "Z",
    [slot(12)] = "H",
    [slot(13)] = "1",
    [slot(14)] = "2",
    [slot(15)] = "3",
    [slot(16)] = "4",
    [slot(17)] = "5",
    [slot(18)] = "`",
    [slot(19)] = "SHIFT-Q",
    [slot(20)] = "SHIFT-E",
    [slot(21)] = "SHIFT-R",
    [slot(22)] = "SHIFT-F",
    [slot(23)] = "SHIFT-T",
    [slot(24)] = "N",
    [slot(25)] = "SHIFT-G",
    [slot(26)] = "SHIFT-C",
    [slot(27)] = "SHIFT-V",
    [slot(28)] = "SHIFT-B",
    [slot(29)] = "SHIFT-X",
    [slot(30)] = "SHIFT-Z",
    [slot(31)] = "SHIFT-H",
    [slot(32)] = "SHIFT-N",
    [slot(33)] = "6",
    [slot(34)] = "7",
    [slot(35)] = "8",
    [slot(36)] = "9",
    [slot(37)] = "SHIFT-1",
    [slot(38)] = "SHIFT-2",
    [slot(39)] = "SHIFT-3",
    [slot(40)] = "SHIFT-4",
    [slot(41)] = "SHIFT-5",
    [slot(42)] = "SHIFT-`",
    [slot(43)] = "ALT-1",
    [slot(44)] = "ALT-2",
    [slot(45)] = "ALT-3",
    [slot(46)] = "ALT-4",
    [slot(47)] = "ALT-5",
    [slot(48)] = "ALT-6",
    [slot(49)] = "ALT-Q",
    [slot(50)] = "ALT-E",
    [slot(51)] = "ALT-R",
    [slot(52)] = "ALT-F",
    [slot(53)] = "ALT-T",
    [slot(54)] = "ALT-G",
    [slot(55)] = "ALT-C",
    [slot(56)] = "ALT-V",
    [slot(57)] = "ALT-B",
    [slot(58)] = "ALT-X",
    [slot(59)] = "ALT-Z",
    [slot(60)] = "0",
    [slot(61)] = "CTRL-Q",
    [slot(62)] = "CTRL-E",
    [slot(63)] = "CTRL-R",
    [slot(64)] = "CTRL-F",
    [slot(65)] = "CTRL-T",
    [slot(66)] = "CTRL-G",
    [slot(67)] = "CTRL-C",
    [slot(68)] = "CTRL-V",
    [slot(69)] = "CTRL-B",
    [slot(70)] = "CTRL-1",
    [slot(71)] = "CTRL-2",
    [slot(72)] = "CTRL-3",
    [slot(73)] = "BUTTON5",
    [slot(74)] = "BUTTON4",
    [slot(75)] = "BUTTON3",
    [slot(76)] = "ALT-SHIFT-1",
    [slot(77)] = "ALT-SHIFT-2",
    [slot(78)] = "ALT-SHIFT-3",
    [slot(79)] = "F1",
    [slot(80)] = "ALT-SHIFT-Q",
    [slot(81)] = "ALT-SHIFT-E",
    [slot(82)] = "ALT-SHIFT-R",
    [slot(83)] = "ALT-SHIFT-F",
    [slot(84)] = "ALT-SHIFT-C",
  },
}

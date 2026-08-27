--[[
  Purpose: Shared Base layout and Keybinds: six reversed rows, 3x4 side bars,
           bar9, bar10, pet, possess, and the default Action Slot keys.
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
    bar9 = bar("BOTTOM", 0, BOTTOM + 8 * SIZE, 12, 12),
    bar10 = bar("BOTTOM", 0, BOTTOM + 9 * SIZE, 12, 12),
    pet = bar("BOTTOM", 0, BOTTOM + 6 * SIZE, 10, 10),
    possess = bar("BOTTOM", 0, BOTTOM + 7 * SIZE, 2, 2),
  },
  -- Current Warrior Action Bar keys. Every class inherits this Base map.
  keybinds = {
    [slot(1)] = "1",
    [slot(2)] = "2",
    [slot(3)] = "3",
    [slot(4)] = "4",
    [slot(5)] = "5",
    [slot(6)] = "`",
    [slot(7)] = "SHIFT-Q",
    [slot(8)] = "SHIFT-E",
    [slot(9)] = "SHIFT-R",
    [slot(10)] = "SHIFT-F",
    [slot(11)] = "SHIFT-T",
    [slot(12)] = "N",
    [slot(13)] = "SHIFT-G",
    [slot(14)] = "SHIFT-C",
    [slot(15)] = "SHIFT-V",
    [slot(16)] = "SHIFT-B",
    [slot(17)] = "SHIFT-X",
    [slot(18)] = "SHIFT-Z",
    [slot(19)] = "SHIFT-H",
    [slot(20)] = "SHIFT-N",
    [slot(21)] = "6",
    [slot(22)] = "7",
    [slot(23)] = "8",
    [slot(24)] = "9",
    [slot(25)] = "SHIFT-1",
    [slot(26)] = "SHIFT-2",
    [slot(27)] = "SHIFT-3",
    [slot(28)] = "SHIFT-4",
    [slot(29)] = "SHIFT-5",
    [slot(30)] = "SHIFT-`",
    [slot(31)] = "ALT-1",
    [slot(32)] = "ALT-2",
    [slot(33)] = "ALT-3",
    [slot(34)] = "ALT-4",
    [slot(35)] = "ALT-5",
    [slot(36)] = "ALT-6",
    [slot(37)] = "ALT-Q",
    [slot(38)] = "ALT-E",
    [slot(39)] = "ALT-R",
    [slot(40)] = "ALT-F",
    [slot(41)] = "ALT-T",
    [slot(42)] = "ALT-G",
    [slot(43)] = "ALT-C",
    [slot(44)] = "ALT-V",
    [slot(45)] = "ALT-B",
    [slot(46)] = "ALT-X",
    [slot(47)] = "ALT-Z",
    [slot(48)] = "0",
    [slot(49)] = "CTRL-Q",
    [slot(50)] = "CTRL-E",
    [slot(51)] = "CTRL-R",
    [slot(52)] = "CTRL-F",
    [slot(53)] = "CTRL-T",
    [slot(54)] = "CTRL-G",
    [slot(55)] = "CTRL-C",
    [slot(56)] = "CTRL-V",
    [slot(57)] = "CTRL-B",
    [slot(58)] = "CTRL-1",
    [slot(59)] = "CTRL-2",
    [slot(60)] = "CTRL-3",
    [slot(61)] = "ALT-SHIFT-1",
    [slot(62)] = "ALT-SHIFT-2",
    [slot(63)] = "ALT-SHIFT-3",
    [slot(64)] = "ALT-SHIFT-4",
    [slot(65)] = "ALT-SHIFT-Q",
    [slot(66)] = "ALT-SHIFT-E",
    [slot(67)] = "ALT-SHIFT-R",
    [slot(68)] = "ALT-SHIFT-F",
    [slot(69)] = "ALT-SHIFT-C",
    [slot(73)] = "Q",
    [slot(74)] = "E",
    [slot(75)] = "R",
    [slot(76)] = "F",
    [slot(77)] = "T",
    [slot(78)] = "G",
    [slot(79)] = "C",
    [slot(80)] = "V",
    [slot(81)] = "B",
    [slot(82)] = "X",
    [slot(83)] = "Z",
    [slot(84)] = "H",
    [slot(109)] = "BUTTON5",
    [slot(110)] = "BUTTON4",
    [slot(111)] = "BUTTON3",
  },
}

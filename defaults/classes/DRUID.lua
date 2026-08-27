--[[
  Purpose: Shipped class defaults for DRUID.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.DRUID
  Notes: bar1 pages Caster (1), Cat (73), Prowl (85), and Bear (97).
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

Addon.Defaults.classes.DRUID = {
  layout = {
    bar1 = { stancePages = { 1, 73, 85, 97 } },
    bar7 = { enabled = false },
    bar8 = { enabled = false },
    bar9 = { enabled = false },
  },
  keybinds = {},
}

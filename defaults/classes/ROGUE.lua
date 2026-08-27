--[[
  Purpose: Shipped class defaults for ROGUE.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.ROGUE
  Notes: bar1 pages Open (1) and Stealth (73).
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

Addon.Defaults.classes.ROGUE = {
  layout = {
    bar1 = { stancePages = { 1, 73 } },
    bar7 = { enabled = false },
  },
  keybinds = {},
}

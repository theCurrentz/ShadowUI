--[[
  Purpose: Shipped class defaults for ROGUE stealth form bar placement.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.ROGUE
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

Addon.Defaults.classes.ROGUE = {
  layout = {
    form = {
      point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER",
      x = 0, y = -84, buttons = 1, columns = 1, scale = 1, enabled = true, buttonSize = 36,
    },
  },
  keybinds = {},
}

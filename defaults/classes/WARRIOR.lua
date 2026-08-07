--[[
  Purpose: Shipped class defaults for WARRIOR stance bar placement.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.WARRIOR
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

Addon.Defaults.classes.WARRIOR = {
  layout = {
    stance = {
      point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER",
      x = 0, y = -84, buttons = 4, columns = 4, scale = 1, enabled = true, buttonSize = 36,
    },
  },
  keybinds = {},
}

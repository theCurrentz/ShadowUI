--[[
  Purpose: Shipped class defaults for PALADIN aura bar placement.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.PALADIN
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

Addon.Defaults.classes.PALADIN = {
  layout = {
    aura = {
      point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER",
      x = 0, y = -84, buttons = 6, columns = 6, scale = 1, enabled = true, buttonSize = 36 * 0.9,
    },
  },
  keybinds = {},
}

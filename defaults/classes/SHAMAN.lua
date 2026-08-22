--[[
  Purpose: Shipped class defaults for SHAMAN ghost wolf form bar placement.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.SHAMAN
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

Addon.Defaults.classes.SHAMAN = {
  layout = {
    form = {
      point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER",
      x = 0, y = -84, buttons = 1, columns = 1, scale = 1, enabled = true, buttonSize = 36 * 0.9,
    },
  },
  keybinds = {},
}

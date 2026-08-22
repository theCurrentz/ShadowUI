--[[
  Purpose: Shipped class defaults for DRUID form bar placement.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.DRUID
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

Addon.Defaults.classes.DRUID = {
  layout = {
    form = {
      point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER",
      x = 0, y = -84, buttons = 5, columns = 5, scale = 1, enabled = true, buttonSize = 36 * 0.9,
    },
  },
  keybinds = {},
  -- Rank 1 ids. Later ranks match by spell name and replace the same Action Slot.
  learnSlots = {
    [5176] = 1, -- Wrath
    [5185] = 2, -- Healing Touch
  },
}

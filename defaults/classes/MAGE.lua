--[[
  Purpose: Shipped class defaults for MAGE (bar slot rotation).
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.MAGE
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

-- Spells stay in action slots 1-120. Mage rotates bars 2-6 so old bar6
-- (slots 61-72) sits on bar2; old 2→3, 3→4, 4→5, 5→6.
Addon.Defaults.classes.MAGE = {
  layout = {
    bar2 = { firstSlot = 61 },
    bar3 = { firstSlot = 13 },
    bar4 = { firstSlot = 25 },
    bar5 = { firstSlot = 37 },
    bar6 = { firstSlot = 49 },
  },
  keybinds = {},
}

--[[
  Purpose: Shipped class defaults for MAGE (Currentz Bartender4 hotkeys).
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.MAGE
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

-- Source: WARKEYS bindings-cache + Bartender4 profile "Currentz - Fairbanks".
-- Spells stay in action slots 1-120. Mage rotates bars 2-6 so old bar6
-- (slots 61-72, Q/E/R/…) sits on bar2; old 2→3, 3→4, 4→5, 5→6. Keybinds
-- still name those slots, so they travel with the spells.
Addon.Defaults.classes.MAGE = {
  layout = {
    bar2 = { firstSlot = 61 },
    bar3 = { firstSlot = 13 },
    bar4 = { firstSlot = 25 },
    bar5 = { firstSlot = 37 },
    bar6 = { firstSlot = 49 },
  },
  keybinds = {
    ACTIONBUTTON1 = "1",
    ACTIONBUTTON2 = "2",
    ACTIONBUTTON3 = "3",
    ACTIONBUTTON4 = "4",
    ACTIONBUTTON5 = "5",
    ACTIONBUTTON6 = "6",
    ACTIONBUTTON7 = "7",
    ACTIONBUTTON8 = "8",
    ACTIONBUTTON9 = "SHIFT-F",
    ACTIONBUTTON10 = "Z",
    ACTIONBUTTON11 = "X",
    MULTIACTIONBAR1BUTTON1 = "Q",
    MULTIACTIONBAR1BUTTON2 = "E",
    MULTIACTIONBAR1BUTTON3 = "R",
    MULTIACTIONBAR1BUTTON4 = "F",
    MULTIACTIONBAR1BUTTON5 = "G",
    MULTIACTIONBAR1BUTTON6 = "C",
    MULTIACTIONBAR1BUTTON7 = "V",
    MULTIACTIONBAR1BUTTON8 = "T",
    MULTIACTIONBAR1BUTTON9 = "B",
    MULTIACTIONBAR1BUTTON10 = "N",
    MULTIACTIONBAR1BUTTON11 = "M",
    MULTIACTIONBAR3BUTTON5 = "F1",
    ["CLICK BT4Button13:Keybind"] = "CTRL-SHIFT-1",
    ["CLICK BT4Button14:Keybind"] = "CTRL-SHIFT-2",
    ["CLICK BT4Button15:Keybind"] = "CTRL-SHIFT-3",
    ["CLICK BT4Button16:Keybind"] = "CTRL-SHIFT-4",
    ["CLICK BT4Button17:Keybind"] = "BUTTON3",
    ["CLICK BT4Button18:Keybind"] = "BUTTON5",
    ["CLICK BT4Button19:Keybind"] = "BUTTON4",
    ["CLICK BT4Button21:Keybind"] = "Y",
  },
}

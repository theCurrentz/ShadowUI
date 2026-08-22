-- Covers Bartender / Blizzard binding names → ShadowUI action slots.
-- Run: lua tests/keybinds_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/keybinds.lua"))()
assert(loadfile(root .. "bars/bar.lua"))()
Addon.Defaults = { base = {}, classes = {} }
assert(loadfile(root .. "defaults/classes/MAGE.lua"))()

local function eq(name, slot)
  local got = Addon:SlotFromBindingName(name)
  assert(got == slot, tostring(name) .. " expected slot " .. tostring(slot) .. " got " .. tostring(got))
end

eq("ACTIONBUTTON1", 1)
eq("ACTIONBUTTON12", 12)
eq("MULTIACTIONBAR1BUTTON1", 61)
eq("MULTIACTIONBAR1BUTTON12", 72)
eq("MULTIACTIONBAR2BUTTON1", 49)
eq("MULTIACTIONBAR3BUTTON5", 29)
eq("MULTIACTIONBAR4BUTTON1", 37)
eq("CLICK BT4Button17:Keybind", 17)
eq("CLICK ShadowUIActionButton61:Keybind", 61)
assert(Addon:SlotFromBindingName("STRAFELEFT") == nil, "movement bind is not a slot")
assert(Addon:SlotFromBindingName(nil) == nil, "nil name")

local mage = Addon.Defaults.classes.MAGE.keybinds
eq("MULTIACTIONBAR1BUTTON1", Addon:SlotFromBindingName("MULTIACTIONBAR1BUTTON1"))
assert(mage.MULTIACTIONBAR1BUTTON1 == "Q", "Currentz Q is slot 61 (mage bar2)")
assert(mage["CLICK BT4Button17:Keybind"] == "BUTTON3", "Currentz mouse3 is slot 17 (mage bar3)")
assert(Addon.Defaults.classes.MAGE.layout.bar2.firstSlot == 61, "old bar6 slots sit on bar2")
assert(Addon.Defaults.classes.MAGE.layout.bar3.firstSlot == 13, "old bar2 slots sit on bar3")
assert(Addon.Defaults.classes.MAGE.layout.bar6.firstSlot == 49, "old bar5 slots sit on bar6")

local merged = Addon:MergeBindingTables(
  { ACTIONBUTTON1 = "1", ACTIONBUTTON2 = "F" },
  { ACTIONBUTTON2 = "Q" }
)
assert(merged.ACTIONBUTTON1 == "1", "client bind fills an empty profile slot")
assert(merged.ACTIONBUTTON2 == "Q", "profile bind wins over client")
merged = Addon:MergeBindingTables(
  { ACTIONBUTTON1 = "1", ACTIONBUTTON2 = "F" },
  { ACTIONBUTTON1 = false, ACTIONBUTTON2 = "" }
)
assert(merged.ACTIONBUTTON1 == nil, "false tombstone drops a client bind")
assert(merged.ACTIONBUTTON2 == nil, "empty string drops a client bind")
assert(Addon:ShortHotkey("CTRL-SHIFT-1") == "C-S-1", "modifiers shorten")
assert(Addon:ShortHotkey("BUTTON3") == "M3", "mouse3 shortens")
local slots = Addon:HotkeysBySlot({ ACTIONBUTTON1 = "1", ["CLICK BT4Button17:LeftButton"] = "BUTTON3" })
assert(slots[1] == "1", "hotkey map uses action slots")
assert(slots[17] == "M3", "BT4 click maps to slot 17")
assert(Addon:CanonicalBindName({ GetName = function() return "ShadowUIActionButton61" end })
  == "CLICK ShadowUIActionButton61:Keybind", "canonical name uses the button frame")
assert(Addon:NormalizeBindingKey("LSHIFT", {}) == nil, "modifier-only keys are ignored")
assert(Addon:NormalizeBindingKey("LeftButton", {}) == nil, "bare left click is not a bind")
assert(Addon:NormalizeBindingKey("LeftButton", { shift = true }) == "SHIFT-BUTTON1", "shift-click is BUTTON1")
assert(Addon:NormalizeBindingKey("1", { ctrl = true, alt = true }) == "ALT-CTRL-1", "modifiers prefix the key")
assert(Addon:NormalizeBindingKey("ESCAPE", {}) == "ESCAPE", "escape is a clear command")
assert(Addon:FirstActionSlot("bar2") == 13, "bar2 defaults to slot 13")
assert(Addon:FirstActionSlot("bar2", { firstSlot = 61 }) == 61, "mage firstSlot override")
assert(Addon:FirstActionSlot("form") == nil, "special ids have no default slot")

print("keybinds_spec OK")

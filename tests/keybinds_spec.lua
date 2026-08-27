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
assert(loadfile(root .. "defaults/base.lua"))()
assert(loadfile(root .. "defaults/classes/MAGE.lua"))()
assert(loadfile(root .. "defaults/classes/WARRIOR.lua"))()

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
assert(next(mage) == nil, "Mage uses Base Keybinds")
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
merged = Addon:MergeBindingTables(
  { MULTIACTIONBAR1BUTTON1 = "Q" },
  { ["CLICK ShadowUIActionButton13:Keybind"] = "Q" }
)
assert(merged.MULTIACTIONBAR1BUTTON1 == nil, "profile Q drops client Q on another slot")
assert(merged["CLICK ShadowUIActionButton13:Keybind"] == "Q", "profile Q on the claimed slot wins by key")
merged = Addon:MergeBindingTables(
  {
    ["CLICK BT4Button13:Keybind"] = "SHIFT-1",
    ["CLICK BT4Button14:Keybind"] = "SHIFT-Q",
    MULTIACTIONBAR1BUTTON1 = "Q",
    MULTIACTIONBAR1BUTTON2 = "E",
  },
  {
    ["CLICK ShadowUIActionButton13:Keybind"] = "Q",
    ["CLICK ShadowUIActionButton14:Keybind"] = "E",
  }
)
assert(merged["CLICK BT4Button13:Keybind"] == nil, "profile slot 13 drops leftover BT4 SHIFT-1")
assert(merged["CLICK BT4Button14:Keybind"] == nil, "profile slot 14 drops leftover BT4 SHIFT-Q")
assert(merged.MULTIACTIONBAR1BUTTON1 == nil, "profile Q still drops client Q")
assert(merged.MULTIACTIONBAR1BUTTON2 == nil, "profile E still drops client E")
assert(merged["CLICK ShadowUIActionButton13:Keybind"] == "Q", "profile Q stays on the claimed slot")
assert(merged["CLICK ShadowUIActionButton14:Keybind"] == "E", "profile E stays on the claimed slot")
local painted = Addon:HotkeysBySlot(merged)
assert(painted[13] == "Q", "claimed slot hotkey is Q not S-1")
assert(painted[14] == "E", "claimed slot hotkey is E not S-Q")
assert(Addon:ShortHotkey("CTRL-SHIFT-1") == "C-S-1", "modifiers shorten")
assert(Addon:ShortHotkey("BUTTON3") == "M3", "mouse3 shortens")
local slots = Addon:HotkeysBySlot({ ACTIONBUTTON1 = "1", ["CLICK BT4Button17:LeftButton"] = "BUTTON3" })
assert(slots[1] == "1", "hotkey map uses action slots")
assert(slots[17] == "M3", "BT4 click maps to slot 17")
assert(Addon:CanonicalBindName({ GetName = function() return "ShadowUIActionButton61" end })
  == "CLICK ShadowUIActionButton61:Keybind", "canonical name uses the button frame")
assert(Addon:BindingSlotFromButton({
  _state_action = 85,
  GetName = function() return "ShadowUIActionButton73" end,
}) == 73, "paged hotkey uses the stable button slot instead of the active stance slot")
assert(Addon:BindingSlotFromButton({ _state_action = 85 }) == 85,
  "unnamed buttons fall back to the active action slot")
assert(Addon:NormalizeBindingKey("LSHIFT", {}) == nil, "modifier-only keys are ignored")
assert(Addon:NormalizeBindingKey("LeftButton", {}) == nil, "bare left click is not a bind")
assert(Addon:NormalizeBindingKey("LeftButton", { shift = true }) == "SHIFT-BUTTON1", "shift-click is BUTTON1")
assert(Addon:NormalizeBindingKey("1", { ctrl = true, alt = true }) == "ALT-CTRL-1", "modifiers prefix the key")
assert(Addon:NormalizeBindingKey("ESCAPE", {}) == "ESCAPE", "escape is a clear command")
assert(Addon:FirstActionSlot("bar2") == 13, "bar2 defaults to slot 13")
assert(Addon:FirstActionSlot("bar2", { firstSlot = 61 }) == 61, "mage firstSlot override")
assert(Addon:FirstActionSlot("pet") == nil, "special ids have no default slot")

local warrior = Addon.Defaults.classes.WARRIOR
local baseBinds = Addon.Defaults.base.keybinds
local function wslot(n)
  return "CLICK ShadowUIActionButton" .. n .. ":Keybind"
end
assert(warrior.layout.bar1.stancePages[1] == 73, "Warrior main Bar starts on Battle slots")
assert(warrior.layout.bar2.firstSlot == 1, "Warrior fixed utility row starts at slot 1")
assert(next(warrior.keybinds) == nil, "Warrior uses Base Keybinds")
assert(baseBinds[wslot(1)] == "1", "Base utility row starts on 1")
assert(baseBinds[wslot(4)] == "4", "Base interrupt job sits on 4")
assert(baseBinds[wslot(73)] == "Q", "Base main stance Bar starts on Q")
assert(baseBinds[wslot(82)] == "X", "Base major cooldown sits on X")
assert(baseBinds[wslot(109)] == "BUTTON5", "Base mouse5 is fixed Battle Stance")
assert(baseBinds[wslot(110)] == "BUTTON4", "Base mouse4 is fixed Defensive Stance")
assert(baseBinds[wslot(111)] == "BUTTON3", "Base mouse3 is fixed Berserker Stance")
assert(warrior.variants.Arms.talentTree == 1, "Arms binds talent tree 1")
assert(warrior.variants.Fury.talentTree == 2, "Fury binds talent tree 2")
assert(warrior.variants.Protection.talentTree == 3, "Protection binds talent tree 3")
assert(next(warrior.variants.Arms.keybinds) == nil
  and next(warrior.variants.Fury.keybinds) == nil
  and next(warrior.variants.Protection.keybinds) == nil,
  "all Warrior Variants use the same physical keys")

local paintedHotkey = { shown = true, text = "" }
function paintedHotkey:SetText(text) self.text = text end
function paintedHotkey:Show() self.shown = true end
function paintedHotkey:Hide() self.shown = false end
local emptySlot = {
  HotKey = paintedHotkey,
  GetName = function() return "ShadowUIActionButton1" end,
}
function emptySlot:HasAction() return false end
Addon.bars = { bar1 = { buttons = { emptySlot } } }
Addon:PaintButtonHotkeys({ ["CLICK ShadowUIActionButton1:Keybind"] = "1" })
assert(paintedHotkey.shown == false, "PaintButtonHotkeys hides a Keybind on an empty Action Slot")
Addon.keybindMode = true
Addon:PaintButtonHotkeys({ ["CLICK ShadowUIActionButton1:Keybind"] = "1" })
assert(paintedHotkey.shown == true and paintedHotkey.text == "1",
  "Keybind Edit Mode still paints empty Action Slots")
Addon.keybindMode = false
function emptySlot:HasAction() return true end
Addon:PaintButtonHotkeys({ ["CLICK ShadowUIActionButton1:Keybind"] = "1" })
assert(paintedHotkey.shown == true and paintedHotkey.text == "1",
  "a filled Action Slot still shows its Keybind")

print("keybinds_spec OK")

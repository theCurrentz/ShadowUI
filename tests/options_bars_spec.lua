-- Options panel exposes an on/off toggle for every Bar, including Special Bars.
-- Missing Layout entries still show and read as on. The toggle reads enabled
-- through the selected Layer and writes enabled on that Layer. Stance is not a
-- Bar toggle.
-- Run: lua tests/options_bars_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
local registered
_G.LibStub = function(name)
  if name == "AceAddon-3.0" then
    return { GetAddon = function() return Addon end }
  end
  if name == "AceConfig-3.0" then
    return {
      RegisterOptionsTable = function(_, _, opts)
        registered = opts
      end,
    }
  end
  if name == "AceConfigDialog-3.0" then
    return { Open = function() end, Close = function() end }
  end
end

local layout = {
  bar1 = { enabled = true },
  bar2 = { enabled = false },
  bar9 = { enabled = false },
  pet = { enabled = true },
  possess = { enabled = true },
  player = { x = 0 },
}
local baseLayout = {
  bar1 = { enabled = true },
  bar2 = { enabled = true },
  bar9 = { enabled = true },
  pet = { enabled = true },
  possess = { enabled = true },
  player = { x = 0 },
}
local char = { editLayer = "class" }
local writes = {}
local applied = 0

function Addon:ResolveEffective(_, _, through)
  if through == "base" then
    return { layout = baseLayout }
  end
  return { layout = layout }
end
function Addon:GetCharDB()
  return char
end
function Addon:WriteLayerDelta(layer, section, key, patch)
  writes[#writes + 1] = { layer = layer, section = section, key = key, patch = patch }
end
function Addon:ApplyAll()
  applied = applied + 1
end
function Addon:GetDB()
  return { classes = { MAGE = { variants = {} } } }
end
function Addon:GetPlayerClass()
  return "MAGE"
end
function Addon:GetActiveVariantName() end
function Addon:SetVariant() end
function Addon:CreateVariant() end
function Addon:RenameVariant() end
function Addon:DeleteVariant() end
function Addon:SetEditLayer() end
function Addon:ToggleEditMode() end
function Addon:ToggleKeybindMode() end
function Addon:SetActionSlotHardLock() end

assert(loadfile(root .. "options/config.lua"))()
Addon:OpenOptions()

local bars = registered.args.bars
assert(bars and bars.type == "group", "options has an Action bars group")
assert(bars.args.bar1.type == "toggle", "Bar 1 is an on/off toggle")
assert(bars.args.bar1.name == "Bar 1", "standard Bar uses Bar N name")
assert(bars.args.pet.name == "Pet", "special Bar uses a title name")
assert(bars.args.bar1.get() == true, "enabled Bar toggle is on")
assert(bars.args.bar2.get() == false, "disabled Bar toggle is off")
assert(bars.args.bar3.get() == true, "standard Bar missing from Layout still reads as on")
assert(bars.args.bar9.get() == false, "Class Layer reads Class enabled")
char.editLayer = "base"
assert(bars.args.bar9.get() == true, "Base Layer reads Base enabled")
assert(bars.args.bar2.get() == true, "Base Layer does not use Class enabled")
char.editLayer = "class"
assert(bars.args.bar9.get() == false, "Class Layer again reads Class enabled")
assert(bars.args.bar10, "highest standard Bar has a toggle")
assert(bars.args.pet, "Pet Bar has a toggle")
assert(bars.args.possess, "Possess Bar has a toggle")
assert(bars.args.stance == nil, "Stance Bar is not a Bar toggle")
assert(bars.args.aura == nil, "Aura Bar is not a Bar toggle")
assert(bars.args.form == nil, "Form Bar is not a Bar toggle")
assert(bars.args.player == nil, "Player Frame is not a Bar toggle")
assert(registered.args.placeDeck == nil, "Place Action Deck sits in the Action Deck group")
local deck = registered.args.deck
assert(deck and deck.type == "group", "options has an Action Deck group")
assert(deck.args.from.type == "select", "Action Deck has a loadout chooser")
assert(deck.args.from.values.class == "Class", "chooser lists Class")
assert(deck.args.from.values.variant == "Variant", "chooser lists Variant")
assert(deck.args.from.values.character == "Character", "chooser lists Character")
assert(deck.args.from.get() == "character", "default loadout is Character")
char.placeDeckFrom = "variant"
assert(deck.args.from.get() == "variant", "chooser reads Variant")
deck.args.from.set(nil, "class")
assert(char.placeDeckFrom == "class", "chooser writes Class")
assert(deck.args.place, "Place Action Deck is in the Action Deck group")

assert(registered.args.shiftAndPrune, "options expose Shift and Prune")
assert(registered.args.shiftAndPrune.name == "Shift and Prune", "options use the Shift and Prune name")
assert(registered.args.shiftAndPrune.type == "execute", "Shift and Prune is an action")

bars.args.bar9.set(nil, true)
assert(#writes == 1, "toggle writes one Layer delta")
assert(writes[1].layer == "class", "toggle writes the selected Layer")
assert(writes[1].section == "layout", "toggle writes Layout")
assert(writes[1].key == "bar9", "toggle writes the Bar id")
assert(writes[1].patch.enabled == true, "on writes enabled true")
assert(applied == 1, "toggle applies Layout")

bars.args.bar1.set(nil, false)
assert(writes[2].patch.enabled == false, "off writes enabled false")

bars.args.pet.set(nil, true)
assert(writes[3].key == "pet", "toggle writes the Special Bar id")
assert(writes[3].patch.enabled == true, "on writes Special Bar enabled true")

function Addon:GetPlayerClass()
  return "WARRIOR"
end
local warriorDB = {
  classes = {
    WARRIOR = {
      layout = {},
      keybinds = {},
      variants = { Custom = { layout = {}, keybinds = {} } },
    },
  },
}
function Addon:GetDB()
  return warriorDB
end
Addon.Defaults = {
  classes = {
    WARRIOR = {
      variants = {
        Arms = { talentTree = 1 },
        Fury = { talentTree = 2 },
        Protection = { talentTree = 3 },
      },
    },
  },
}
local values = registered.args.variants.args.active.values()
assert(values.Fury == "Fury", "options list shipped Fury")
assert(values.Arms == "Arms", "options list shipped Arms")
assert(values.Protection == "Protection", "options list shipped Protection")
assert(values.Custom == "Custom", "options list account Variant overlay")

assert(loadfile(root .. "profile/variants.lua"))()
assert(Addon:DeleteVariant("Custom", "WARRIOR") == true, "delete removes account overlay")
assert(warriorDB.classes.WARRIOR.variants.Custom == nil, "account overlay is gone")
assert(Addon:DeleteVariant("Fury", "WARRIOR") == false, "delete does not remove a shipped-only name")
values = registered.args.variants.args.active.values()
assert(values.Fury == "Fury", "shipped Fury remains after delete")
assert(values.Custom == nil, "deleted account overlay leaves the list")

print("options_bars_spec OK")

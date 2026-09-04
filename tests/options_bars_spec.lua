-- Options panel exposes Global gap and shape, Bar Groups, and Bar gap pads.
-- Each Bar group writes enabled, scale, gap, fade idle, shape, Group, gap above,
-- and gap below on the selected Layer. A Bar is one Row. Missing Layout entries
-- inherit Global, then defaults.
-- Micro Cluster fade and shape write Character. Experience bar fade idle
-- writes Character. Stance is not a Bar group.
-- Cooldown Manager is a Layout host group, not a Bar group.
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
    return { Open = function() end, Close = function() end, SetDefaultSize = function() end }
  end
  if name == "AceConfigRegistry-3.0" then
    return { NotifyChange = function() end }
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

assert(loadfile(root .. "core/resolve.lua"))()
function Addon:ResolveEffective(_, _, through)
  if through == "base" then
    return { layout = baseLayout }
  end
  return { layout = layout }
end
function Addon:WriteLayerDelta(layer, section, key, patch)
  writes[#writes + 1] = { layer = layer, section = section, key = key, patch = patch }
  if section ~= "layout" then
    return
  end
  local store = char.editLayer == "base" and baseLayout or layout
  if type(patch) ~= "table" then
    store[key] = patch
    return
  end
  if type(store[key]) ~= "table" then
    store[key] = {}
  end
  Addon:SparseMerge(store[key], patch)
end
assert(loadfile(root .. "options/nav.lua"))()
assert(loadfile(root .. "options/config.lua"))()
Addon:OpenOptions()

local bars = registered.args.bars
assert(bars and bars.type == "group", "options has an Action bars group")
assert(bars.args.bar1.type == "group", "Bar 1 is a nested group")
assert(bars.args.bar1.name == "Bar 1", "standard Bar uses Bar N name")
assert(bars.args.pet.name == "Pet", "special Bar uses a title name")
local bar1 = bars.args.bar1.args
assert(bar1.enabled.type == "toggle", "Bar 1 has an Enabled toggle")
assert(bar1.scale.type == "range", "Bar 1 has a Scale slider")
assert(bar1.scale.min == 0.6 and bar1.scale.max == 1.4 and bar1.scale.step == 0.05,
  "Scale range is 0.6 to 1.4 by 0.05")
assert(bar1.gap.type == "range", "Bar 1 has a Gap between slider")
assert(bar1.gap.name == "Gap between", "Gap between uses that name")
assert(bar1.gap.min == 0 and bar1.gap.max == 16 and bar1.gap.step == 1,
  "Gap between range is 0 to 16 by 1")
assert(bar1.fadeIdle.type == "range", "Bar 1 has a Fade idle slider")
assert(bar1.iconShape.type == "select", "Bar 1 has a Shape select")
assert(bar1.enabled.get() == true, "enabled Bar toggle is on")
assert(bars.args.bar2.args.enabled.get() == false, "disabled Bar toggle is off")
assert(bars.args.bar3.args.enabled.get() == true, "standard Bar missing from Layout still reads as on")
assert(bars.args.bar3.args.scale.get() == 1, "missing Bar scale reads as 1")
assert(bars.args.bar3.args.gap.get() == 0, "missing Bar gap reads as 0")
assert(bars.args.bar3.args.fadeIdle.get() == 1, "missing Bar fade idle reads as 1")
assert(bars.args.bar3.args.iconShape.get() == "square", "missing Bar shape reads as square")
assert(bars.args.bar9.args.enabled.get() == false, "Class Layer reads Class enabled")
char.editLayer = "base"
assert(bars.args.bar9.args.enabled.get() == true, "Base Layer reads Base enabled")
assert(bars.args.bar2.args.enabled.get() == true, "Base Layer does not use Class enabled")
char.editLayer = "class"
assert(bars.args.bar9.args.enabled.get() == false, "Class Layer again reads Class enabled")
assert(bars.args.bar10, "highest standard Bar has a group")
assert(bars.args.pet, "Pet Bar has a group")
assert(bars.args.pet.args.gap.type == "range", "Pet Bar has a Gap between slider")
assert(bars.args.possess, "Possess Bar has a group")
assert(bars.args.possess.args.gap.type == "range", "Possess Bar has a Gap between slider")
assert(bars.args.stance == nil, "Stance Bar is not a Bar group")
assert(bars.args.aura == nil, "Aura Bar is not a Bar group")
assert(bars.args.form == nil, "Form Bar is not a Bar group")
assert(bars.args.player == nil, "Player Frame is not a Bar group")
assert(bars.args.cooldown == nil, "Cooldown Manager is not a Bar group")
assert(bars.args.global, "Action bars expose Global")
assert(bars.args.global.name == "Global", "Global uses that name")
assert(bars.args.global.args.gap.type == "range", "Global has a Gap between slider")
assert(bars.args.global.args.iconShape.type == "select", "Global has a Shape select")
assert(bars.args.global.args.gap.get() == 0, "Global gap reads as 0 when unset")
assert(bars.args.global.args.iconShape.get() == "square", "Global shape reads as square when unset")
assert(bars.args.groups, "Action bars expose Groups")
assert(bars.args.groups.name == "Groups", "Groups uses that name")
assert(bars.args.groups.args.create.type == "input", "Groups can create a Bar Group")
assert(bars.args.groups.args.group1, "Groups has a first slot")
assert(bars.args.groups.args.group1.hidden(), "an empty Groups list hides slot 1")
assert(bar1.group.type == "select", "Bar 1 has a Group select")
assert(bar1.gapAbove.type == "range", "Bar 1 has Gap above")
assert(bar1.gapAbove.name == "Gap above", "Gap above uses that name")
assert(bar1.gapBelow.type == "range", "Bar 1 has Gap below")
assert(bar1.gapBelow.name == "Gap below", "Gap below uses that name")
assert(bar1.gapAbove.min == 0 and bar1.gapAbove.max == 64, "Bar gap pad range is 0 to 64")
assert(bar1.gapAbove.hidden() == false, "an ungrouped Bar shows Gap above")
assert(bar1.row1GapAbove == nil, "a Bar is one Row; it has no per-grid-line pads")
assert(bars.args.bar7.args.row4GapAbove == nil, "Bar 7 does not split pads by 3x4 grid lines")
assert(bars.args.bar7.args.gapAbove.type == "range", "Bar 7 has one Gap above")
assert(registered.args.cooldown, "options expose Cooldown manager")
assert(not registered.args.general.args.shiftAndPrune, "Shift and Prune is not a Global action")
assert(registered.args.bars.args.groups.args.group1.args.shiftAndPrune, "options expose Shift and Prune on a Bar Group")
assert(registered.args.bars.args.groups.args.group1.args.shiftAndPrune.name == "Shift and Prune", "options use the Shift and Prune name")
assert(registered.args.bars.args.groups.args.group1.args.shiftAndPrune.type == "execute", "Shift and Prune is an action")
assert(registered.args.cooldown.args.enabled.type == "toggle", "Cooldown manager has Enabled")
assert(registered.args.cooldown.args.scale.type == "range", "Cooldown manager has Scale")
assert(registered.args.cooldown.args.gap.type == "range", "Cooldown manager has Gap")
assert(registered.args.cooldown.args.direction.type == "select", "Cooldown manager has Direction")
assert(registered.args.cooldown.args.max.type == "range", "Cooldown manager has Maximum")
assert(registered.args.cooldown.args.vertical == nil, "Vertical is Direction")
assert(registered.args.cooldown.args.spells.type == "group", "Cooldown manager lists class spells")
assert(registered.args.cooldown.args.spells.desc:find("Class", 1, true),
  "spell filter writes Class")
assert(registered.args.placeDeck == nil, "Place Action Deck is gone")
assert(registered.args.deck == nil, "options have no Action Deck group")
local loadouts = registered.args.loadouts
assert(loadouts and loadouts.type == "group", "options expose Loadout Snapshots")
assert(loadouts.args.save.type == "execute", "Loadouts can save the current Character")
assert(loadouts.args.source.type == "select", "Loadouts select a source Character")
assert(loadouts.args.actions.type == "toggle", "Loadouts can include Actions")
assert(loadouts.args.macros.type == "toggle", "Loadouts can include required macros")
assert(loadouts.args.keybinds.type == "toggle", "Loadouts can include Keybinds")
assert(loadouts.args.barLayout.type == "toggle", "Loadouts can include Bar Layout")
assert(loadouts.args.otherLayout.type == "toggle", "Loadouts can include other Layout hosts")
assert(loadouts.args.selectedBars.type == "multiselect", "Loadouts can select Bars")
assert(loadouts.args.includeDisabledBars.type == "toggle", "Loadouts can include disabled source Bars")
assert(loadouts.args.exact.type == "toggle", "Loadouts choose merge or exact Action Slots")
assert(loadouts.args.sourcePage.type == "select", "Loadouts map a cross-Class source page")
assert(loadouts.args.targetPage.type == "select", "Loadouts map a cross-Class target page")
assert(loadouts.args.preview.type == "execute", "Loadouts preview before apply")
assert(loadouts.args.apply.confirm == true, "Loadout apply requires confirmation")
assert(loadouts.args.restore.confirm == true, "Loadout backup restore requires confirmation")
assert(registered.args.general.args.microFadeIdle, "options expose Micro Cluster fade idle")
assert(registered.args.general.args.microIconShape, "options expose Micro Cluster shape")
assert(registered.args.general.args.microFadeIdle.get() == 1, "Micro Cluster fade idle defaults to 1")
assert(registered.args.general.args.microIconShape.get() == "square", "Micro Cluster shape defaults to square")
assert(registered.args.general.args.xpFadeIdle, "options expose Experience bar fade idle")
assert(registered.args.general.args.xpFadeIdle.get() == 1, "Experience bar fade idle defaults to 1")

bars.args.bar9.args.enabled.set(nil, true)
assert(#writes == 1, "toggle writes one Layer delta")
assert(writes[1].layer == "class", "toggle writes the selected Layer")
assert(writes[1].section == "layout", "toggle writes Layout")
assert(writes[1].key == "bar9", "toggle writes the Bar id")
assert(writes[1].patch.enabled == true, "on writes enabled true")
assert(applied == 1, "toggle applies Layout")

bars.args.bar1.args.enabled.set(nil, false)
assert(writes[2].patch.enabled == false, "off writes enabled false")

bars.args.pet.args.enabled.set(nil, true)
assert(writes[3].key == "pet", "toggle writes the Special Bar id")
assert(writes[3].patch.enabled == true, "on writes Special Bar enabled true")

bars.args.bar1.args.scale.set(nil, 1.2)
assert(writes[4].key == "bar1", "scale writes the Bar id")
assert(writes[4].patch.scale == 1.2, "scale writes Layout.scale")
assert(applied == 4, "scale applies Layout")

bars.args.bar1.args.fadeIdle.set(nil, 0.4)
assert(writes[5].patch.fadeIdle == 0.4, "fade idle writes Layout.fadeIdle")

bars.args.bar1.args.iconShape.set(nil, "circle")
assert(writes[6].patch.iconShape == "circle", "shape writes Layout.iconShape")
assert(writes[6].layer == "class", "shape writes the selected Layer")

bars.args.bar1.args.gap.set(nil, 2)
assert(writes[7].key == "bar1", "gap writes the Bar id")
assert(writes[7].patch.gap == 2, "gap writes Layout.gap")
assert(writes[7].layer == "class", "gap writes the selected Layer")
assert(applied == 7, "gap applies Layout")

registered.args.general.args.microFadeIdle.set(nil, 0.3)
assert(char.microFadeIdle == 0.3, "Micro Cluster fade idle writes Character")
assert(applied == 8, "Micro Cluster fade idle applies")
registered.args.general.args.microIconShape.set(nil, "diamond")
assert(char.microIconShape == "diamond", "Micro Cluster shape writes Character")
registered.args.general.args.xpFadeIdle.set(nil, 0.2)
assert(char.xpFadeIdle == 0.2, "Experience bar fade idle writes Character")
assert(#writes == 7, "Character fade controls do not write a Layer delta")

local n = #writes
bars.args.global.args.gap.set(nil, 4)
assert(writes[n + 1].key == "global", "Global gap writes layout.global")
assert(writes[n + 1].patch.gap == 4, "Global gap writes the value")
assert(bars.args.bar3.args.gap.get() == 4, "missing Bar inherits Global gap")
bars.args.global.args.iconShape.set(nil, "circle")
assert(writes[n + 2].patch.iconShape == "circle", "Global shape writes the value")
assert(bars.args.bar3.args.iconShape.get() == "circle", "missing Bar inherits Global shape")
assert(bars.args.bar1.args.gap.get() == 2, "Bar gap override wins over Global")

bars.args.groups.args.create.set(nil, " Main ")
assert(writes[n + 3].key == "barGroups", "create writes layout.barGroups")
assert(type(writes[n + 3].patch.Main) == "table", "create stores the Bar Group name")
assert(bars.args.groups.args.group1.hidden() == false, "a created Bar Group shows slot 1")
assert(bars.args.groups.args.group1.name() == "Main", "slot 1 uses the Bar Group name")
local beforeInvalid = #writes
bars.args.groups.args.create.set(nil, "bar1")
assert(#writes == beforeInvalid, "create rejects a Bar id as a Bar Group name")
bars.args.groups.args.group1.args.members.set(nil, "bar3", true)
assert(writes[beforeInvalid + 1].key == "bar3", "member assign writes the Bar")
assert(writes[beforeInvalid + 1].patch.group == "Main", "member assign sets Bar.group")
bars.args.groups.args.group1.args.gap.set(nil, 6)
assert(writes[beforeInvalid + 2].patch.Main.gap == 6, "Bar Group gap writes barGroups")
assert(bars.args.bar3.args.gap.get() == 6, "grouped Bar inherits Bar Group gap")
assert(bars.args.bar1.args.gap.get() == 2, "Bar gap override wins over Bar Group")
assert(bars.args.groups.args.group1.args.gapAbove.type == "range", "Bar Group has Gap above")
assert(bars.args.groups.args.group1.args.gapBelow.type == "range", "Bar Group has Gap below")
assert(bars.args.bar3.args.gapAbove.hidden() == true,
  "a grouped Bar hides per-Bar gap pads")

bars.args.bar1.args.gapAbove.set(nil, 4)
assert(writes[beforeInvalid + 3].patch.gapAbove == 4, "Gap above writes the Bar")
bars.args.bar1.args.gapBelow.set(nil, 8)
assert(layout.bar1.gapAbove == 4, "Gap below keeps gap above")
assert(layout.bar1.gapBelow == 8, "Gap below writes the Bar")
bars.args.groups.args.group1.args.gapAbove.set(nil, 2)
assert(writes[beforeInvalid + 5].patch.Main.gapAbove == 2, "Bar Group gap above writes barGroups")
bars.args.groups.args.group1.args.gapBelow.set(nil, 6)
assert(writes[beforeInvalid + 6].patch.Main.gapBelow == 6, "Bar Group gap below writes barGroups")

bars.args.bar1.args.group.set(nil, "Main")
assert(writes[beforeInvalid + 7].patch.group == "Main", "Bar Group select writes Bar.group")
assert(bars.args.bar1.args.gapAbove.hidden() == true,
  "grouping a Bar hides its gap pads")

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

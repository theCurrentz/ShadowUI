-- Loadout Snapshots copy selected Character action-bar state in game.
-- Run: lua tests/loadout_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end

local player = { name = "Tazzy", realm = "Nightslayer", class = "WARRIOR", version = "ERA" }
local db = { loadouts = {} }
local char = { layout = {}, keybinds = {} }
local messages, placed = {}, {}
local runtimeActions = {}
local sourceMacros = {
  { name = "ChargeMacro", icon = 1, body = "/cast Charge" },
}
local targetMacros = {}
local sourceMode = true
local combat = false
local cursor

_G.MAX_ACCOUNT_MACROS = 120
_G.MAX_CHARACTER_MACROS = 18
_G.UnitName = function() return player.name end
_G.GetRealmName = function() return player.realm end
_G.GetServerTime = function() return 12345 end
_G.InCombatLockdown = function() return combat end
_G.GetSpellInfo = function(id) return id == 100 and "Charge" or ("Spell" .. tostring(id)) end
_G.GetItemInfo = function(id) return "Item" .. tostring(id) end
_G.IsSpellKnown = function(id) return player.class == "WARRIOR" and id == 100 end
_G.GetActionInfo = function(slot)
  if sourceMode then
    if slot == 1 then return "spell", 100 end
    if slot == 2 then return "macro", 121 end
    if slot == 13 then return "item", 200 end
    if slot == 25 then return "companion", 300 end
    if slot == 61 then return "item", 400 end
  end
  local action = runtimeActions[slot]
  if action then return action.type, action.id end
end
_G.GetNumMacros = function()
  return 0, #(sourceMode and sourceMacros or targetMacros)
end
_G.GetMacroInfo = function(index)
  local list = sourceMode and sourceMacros or targetMacros
  local macro = list[index - 120]
  if macro then return macro.name, macro.icon, macro.body end
end
_G.GetMacroBody = function(index)
  local list = sourceMode and sourceMacros or targetMacros
  local macro = list[index - 120]
  return macro and macro.body
end
_G.CreateMacro = function(name, icon, body)
  targetMacros[#targetMacros + 1] = { name = name, icon = icon, body = body }
  return 120 + #targetMacros
end
_G.GetCursorInfo = function()
  return cursor and cursor.type
end
_G.ClearCursor = function() cursor = nil end
_G.PickupSpell = function(id)
  if _G.IsSpellKnown(id) then cursor = { type = "spell", id = id } end
end
_G.PickupItem = function(id) cursor = { type = "item", id = id } end
_G.PickupMacro = function(id) cursor = { type = "macro", id = id } end
_G.PickupAction = function(slot)
  cursor = runtimeActions[slot]
  runtimeActions[slot] = nil
end
_G.PlaceAction = function(slot)
  runtimeActions[slot] = cursor
  placed[#placed + 1] = slot
  cursor = nil
end

function Addon:DeepCopy(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for key, child in pairs(value) do out[key] = self:DeepCopy(child) end
  return out
end
function Addon:GetDB() return db end
function Addon:GetCharDB() return char end
function Addon:GetPlayerClass() return player.class end
function Addon:GetVersion() return player.version end
function Addon:GetActiveVariantName() return "Fury" end
function Addon:Print(text) messages[#messages + 1] = text end
function Addon:SlotFromBindingName(name)
  return tonumber((name or ""):match("ShadowUIActionButton(%d+)"))
end
function Addon:MergeBindingTables(client, profile)
  local out = {}
  for name, key in pairs(client or {}) do out[name] = key end
  for name, key in pairs(profile or {}) do out[name] = key end
  return out
end
function Addon:CollectClientActionBinds() return {} end
function Addon:WithUnlockedActionBars(fn) fn() end
function Addon:ApplyAll() end

local function standardLayout()
  local layout = {}
  for index = 1, 10 do
    layout["bar" .. index] = {
      point = "BOTTOM", x = index, y = index * 2, buttons = 12, columns = 12,
      scale = 1, enabled = true,
    }
  end
  layout.pet = { point = "BOTTOM", x = 0, y = 200, buttons = 10, columns = 10, enabled = true }
  layout.possess = { point = "BOTTOM", x = 0, y = 240, buttons = 2, columns = 2, enabled = true }
  return layout
end
local function warriorLayout()
  return standardLayout()
end

local sourceCfg = {
  layout = warriorLayout(),
  keybinds = {
    ["CLICK ShadowUIActionButton1:Keybind"] = "Q",
    ["CLICK ShadowUIActionButton2:Keybind"] = "E",
  },
}
sourceCfg.layout.player = { point = "CENTER", x = -200, y = -179 }
local targetCfg = { layout = warriorLayout(), keybinds = {} }
local inheritedCfg = { layout = warriorLayout(), keybinds = {} }
function Addon:ResolveEffective(_, _, through)
  if through == "variant" then return inheritedCfg end
  return sourceMode and sourceCfg or targetCfg
end

assert(loadfile(root .. "bars/bar.lua"))()
assert(loadfile(root .. "profile/loadouts.lua"))()

local sourceKey = Addon:SaveCurrentLoadout()
local source = db.loadouts[sourceKey]
assert(sourceKey == "ERA/Nightslayer/Tazzy", "default snapshot key identifies Version, realm, and Character")
local namedEra = Addon:SaveCurrentLoadout("Raid")
assert(namedEra == "ERA/named/Raid", "custom snapshot names are Version-qualified")
local pathLikeName = Addon:SaveCurrentLoadout("ERA/Nightslayer/Tazzy")
assert(pathLikeName == "ERA/named/ERA/Nightslayer/Tazzy" and db.loadouts[sourceKey],
  "custom names cannot replace a normal Character snapshot key")
player.version = "TBC"
local namedTbc = Addon:SaveCurrentLoadout("Raid")
assert(namedTbc == "TBC/named/Raid" and db.loadouts[namedEra], "same custom name does not replace another Version")
player.version = "ERA"
local loadoutValues = Addon:LoadoutValues()
assert(loadoutValues[namedEra] and not loadoutValues[namedTbc], "source choices show only this Version")
assert(Addon:FindLoadoutKey("Raid") == namedEra, "commands resolve a Version-qualified custom name")
assert(source.actions.bar1.pages[1].actions[1].type == "spell", "capture stores spells")
assert(source.actions.bar1.pages[1].actions[2].body == "/cast Charge", "capture stores macro bodies")
assert(#source.actions.bar1.pages == 1, "capture stores one fixed page per Bar")
assert(source.actions.bar2.pages[1].actions[1].type == "item", "capture stores the next fixed Bar")
assert(source.actions.bar3.pages[1].actions[1].unsupported == true, "capture records unsupported action types")
assert(source.keybinds.bar1[1] == "Q", "capture stores effective keys by physical button")

sourceMode = false
player.name, player.realm = "Tazman", "Whitemane"
targetCfg.layout.bar1.x = 99
inheritedCfg.layout.bar1.x = 50
local options = Addon:DefaultLoadoutOptions()
local sameClass = Addon:BuildLoadoutPlan(sourceKey, options)
assert(sameClass.canApply == true, "same-Version snapshot can apply")
assert(#sameClass.keybindOps == 120, "same-Class plan maps every fixed Bar Keybind slot")
assert(#sameClass.layoutOps == 12, "Bar Layout includes standard and Special Bars that exist")
assert(#sameClass.macroCreates == 1, "missing source macro is planned for the Character tab")
assert(sameClass.skipped == 1, "unsupported action is reported")

local selectedOptions = Addon:DefaultLoadoutOptions()
for barId in pairs(selectedOptions.selectedBars) do selectedOptions.selectedBars[barId] = false end
selectedOptions.selectedBars.bar1 = true
local selectedPlan = Addon:BuildLoadoutPlan(sourceKey, selectedOptions)
assert(#selectedPlan.keybindOps == 12, "selected Bar limits copied Keybinds")
assert(#selectedPlan.layoutOps == 1, "selected Bar limits copied Bar Layout")

local sectionOptions = Addon:DefaultLoadoutOptions()
sectionOptions.actions = false
sectionOptions.keybinds = false
sectionOptions.barLayout = false
sectionOptions.otherLayout = true
local sectionPlan = Addon:BuildLoadoutPlan(sourceKey, sectionOptions)
assert(#sectionPlan.actionOps == 0 and #sectionPlan.keybindOps == 0,
  "section choices can omit Actions and Keybinds")
assert(#sectionPlan.layoutOps == 1 and sectionPlan.layoutOps[1].id == "player",
  "other Layout hosts copy independently")

assert(Addon:ApplyLoadoutPlan(sameClass) == true, "same-Class Loadout applies")
assert(runtimeActions[1] and runtimeActions[1].type == "spell", "spell is placed on its fixed slot")
assert(runtimeActions[2] and runtimeActions[2].type == "macro", "created macro is placed")
assert(runtimeActions[13] and runtimeActions[13].type == "item", "the next fixed Bar applies")
assert(char.layout.bar1 and char.layout.bar1.x == 1, "visual Layout difference writes to Character")
assert(char.keybinds["CLICK ShadowUIActionButton1:Keybind"] == "Q", "Keybind writes to Character")
assert(db.loadouts[Addon:BackupLoadoutKey()].backup == true, "apply saves a rolling target backup")

local restoreOptions = Addon:DefaultLoadoutOptions()
restoreOptions.includeDisabledBars = true
restoreOptions.exact = true
local restorePlan = Addon:BuildLoadoutPlan(Addon:BackupLoadoutKey(), restoreOptions)
assert(#restorePlan.keybindOps == 120, "backup restore includes disabled Bars")
assert(Addon:RestoreLoadoutBackup() == true, "rolling backup restores")
assert(runtimeActions[1] == nil and runtimeActions[2] == nil and runtimeActions[13] == nil,
  "backup restores prior empty Actions")
assert(char.layout.bar1 and char.layout.bar1.x == 99, "backup restores prior target Layout")
assert(#targetMacros == 1, "restore keeps new Character macros that other slots can use")
sameClass = Addon:BuildLoadoutPlan(sourceKey, Addon:DefaultLoadoutOptions())
assert(Addon:ApplyLoadoutPlan(sameClass) == true, "source can apply again after restore")

runtimeActions[3] = { type = "item", id = 999 }
options = Addon:DefaultLoadoutOptions()
options.exact = true
local exactPlan = Addon:BuildLoadoutPlan(sourceKey, options)
Addon:ApplyLoadoutPlan(exactPlan)
assert(runtimeActions[3] == nil, "exact mode clears a target slot empty in the source")

player.class = "MAGE"
targetCfg.layout = standardLayout()
inheritedCfg.layout = standardLayout()
char.layout, char.keybinds = {}, {}
options = Addon:DefaultLoadoutOptions()
local unmapped = Addon:BuildLoadoutPlan(sourceKey, options)
local warnedForPage = false
for _, warning in ipairs(unmapped.warnings) do
  if warning:find("choose a source and target page", 1, true) then warnedForPage = true end
end
assert(not warnedForPage, "cross-Class fixed Bars need no page map")

assert(source.actions.bar1.pages[1].actions[1].type == "spell", "source spell remains captured")
assert(Addon:FirstActionSlot("bar1", targetCfg.layout.bar1) == 1, "target main Bar starts at fixed slot 1")
assert(_G.IsSpellKnown(100) == false, "target does not know source spell")
local unknownSpell = Addon:BuildLoadoutPlan(sourceKey, options)
local skippedSpell = false
local unknownKinds = {}
for _, operation in ipairs(unknownSpell.actionOps) do
  unknownKinds[#unknownKinds + 1] = operation.barId .. ":" .. tostring(operation.action and operation.action.type)
  if operation.action and operation.action.type == "spell" and operation.skip then skippedSpell = true end
end
assert(skippedSpell, "cross-Class plan skips a spell the target does not know: "
  .. table.concat(unknownSpell.warnings, " | ") .. " ops=" .. table.concat(unknownKinds, ","))

player.class = "DRUID"
targetCfg.layout = standardLayout()
targetCfg.layout.bar1.stancePages = { 1, 73, 85, 97 }
inheritedCfg.layout = targetCfg.layout
options = Addon:DefaultLoadoutOptions()
local collisionPlan = Addon:BuildLoadoutPlan(sourceKey, options)
local collisionWarning = false
for _, warning in ipairs(collisionPlan.warnings) do
  if warning:find("target Action Slot 73 is already mapped", 1, true) then collisionWarning = true end
end
assert(not collisionWarning, "legacy stancePages do not create duplicate target mappings")

player.class = "WARRIOR"
targetCfg.layout = warriorLayout()
inheritedCfg.layout = warriorLayout()
targetMacros = {
  { name = "ChargeMacro", icon = 1, body = "/say different" },
}
local conflictOptions = Addon:DefaultLoadoutOptions()
local conflictPlan = Addon:BuildLoadoutPlan(sourceKey, conflictOptions)
local conflictWarning = false
for _, warning in ipairs(conflictPlan.warnings) do
  if warning:find("different macro named ChargeMacro", 1, true) then conflictWarning = true end
end
assert(conflictWarning, "macro name conflicts skip by default")
conflictOptions.macroConflict = "character-copy"
local copiedConflict = Addon:BuildLoadoutPlan(sourceKey, conflictOptions)
assert(#copiedConflict.macroCreates == 1, "macro conflict can create a unique Character copy")
assert(copiedConflict.macroCreates[1].name ~= "ChargeMacro", "macro conflict copy gets a unique name")

targetMacros = {}
for index = 1, 18 do
  targetMacros[index] = { name = "Full" .. index, icon = 1, body = "/say " .. index }
end
local fullPlan = Addon:BuildLoadoutPlan(sourceKey, Addon:DefaultLoadoutOptions())
local fullWarning = false
for _, warning in ipairs(fullPlan.warnings) do
  if warning:find("macro tab is full", 1, true) then fullWarning = true end
end
assert(fullWarning, "macro capacity failure is in the preview")

targetMacros = {}
combat = true
assert(Addon:ApplyLoadoutPlan(Addon:BuildLoadoutPlan(sourceKey, Addon:DefaultLoadoutOptions())) == false,
  "combat blocks Loadout apply")
combat = false

local pickupItem = _G.PickupItem
_G.PickupItem = function() end
local failedApply = Addon:BuildLoadoutPlan(sourceKey, Addon:DefaultLoadoutOptions())
assert(Addon:ApplyLoadoutPlan(failedApply) == false, "partial action placement reports failure")
_G.PickupItem = pickupItem

local placeAction = _G.PlaceAction
_G.PlaceAction = nil
assert(Addon:ApplyLoadoutPlan(Addon:BuildLoadoutPlan(sourceKey, Addon:DefaultLoadoutOptions()), true) == false,
  "missing live Action Slot functions report failure")
_G.PlaceAction = placeAction

source.version = "TBC"
local wrongVersion = Addon:BuildLoadoutPlan(sourceKey, Addon:DefaultLoadoutOptions())
assert(wrongVersion.canApply == false, "Version mismatch blocks apply")
source.version = "ERA"

source.layout.global = { gap = 2, iconShape = "circle" }
source.layout.barGroups = { Main = { gap = 1 } }
source.layout.bar1.group = "Main"
source.layout.bar1.rowGaps = { { above = 4, below = 8 } }
local extras = Addon:BuildLoadoutPlan(sourceKey, Addon:DefaultLoadoutOptions())
local copiedGlobal, copiedGroups, copiedBarFields
for _, operation in ipairs(extras.layoutOps) do
  if operation.id == "global" then
    copiedGlobal = operation.fields.gap == 2 and operation.fields.iconShape == "circle"
  elseif operation.id == "barGroups" then
    copiedGroups = operation.fields.Main and operation.fields.Main.gap == 1
  elseif operation.id == "bar1" then
    copiedBarFields = operation.fields.group == "Main"
      and operation.fields.rowGaps and operation.fields.rowGaps[1].above == 4
  end
end
assert(copiedGlobal, "Bar Layout copies Global gap and shape")
assert(copiedGroups, "Bar Layout copies Bar Groups")
assert(copiedBarFields, "Bar Layout copies Bar Group membership and row gaps")

print("loadout_spec OK")

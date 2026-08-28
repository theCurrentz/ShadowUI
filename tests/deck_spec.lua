-- Action Deck: shipped catalog macros onto Action Slots.
-- Run: lua tests/deck_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "core/deck.lua"))()
Addon.Defaults = { base = {}, classes = {}, catalog = {} }
assert(loadfile(root .. "defaults/base.lua"))()
assert(loadfile(root .. "defaults/classes/WARRIOR.lua"))()
assert(loadfile(root .. "defaults/catalog.lua"))()

function Addon:GetCharDB()
  return {}
end
function Addon:GetDB()
  return { classes = {} }
end

local fury = Addon:ResolveDeck("WARRIOR", "Fury")
assert(fury[1].id == "w-h", "Fury loadout puts Heroic Strike on the utility row")
assert(fury[5].id == "w-hm", "Hamstring stays on the loadout")
assert(fury[8].id == "w-deathwish", "Fury T is Death Wish")
assert(fury[9].id == "w-intimid", "Intimidating Shout sits on the utility row")
assert(fury[73].id == "w-s", "Fury Battle 1 is Sunder")
assert(fury[74].id == "w-bt" and fury[86].id == "w-bt" and fury[98].id == "w-bt",
  "Fury keeps Bloodthirst on the stance pages")
assert(fury[75].id == "w-ww", "Whirlwind sits on Battle 3")
assert(fury[77].id == "w-charge", "Charge sits on Battle 5")
assert(fury[78].id == "w-interrupt", "interrupt sits on the Battle page")
assert(fury[13].id == "w-disarm", "Fury loadout puts Disarm on bar3")
assert(fury[22].id == "spell:20600", "Fury loadout puts Perception on bar3")
assert(fury[24].id == "spell:8690", "Fury loadout puts Hearthstone on bar3")
assert(fury[25].id == "spell:7919", "Fury loadout puts Shoot Crossbow on bar3")
assert(fury[109] == nil and fury[110] == nil and fury[111] == nil,
  "Fury leaves mouse stance Action Slots empty")
for _, entry in pairs(fury) do
  assert(entry.id ~= "shared-can", "Human Warrior deck must not contain Cannibalize")
end

local arms = Addon:ResolveDeck("WARRIOR", "Arms")
assert(arms[1].id == "w-h", "Arms shares the current loadout utility row")
assert(arms[74].id == "w-bt", "Arms loadout keeps Bloodthirst on Battle 2")

local prot = Addon:ResolveDeck("WARRIOR", "Protection")
assert(prot[1].id == "w-h", "Protection shares the current loadout utility row")
assert(prot[8].id == "w-deathwish", "Protection loadout keeps Death Wish")

local classOnly = Addon:ResolveDeck("WARRIOR", "Unknown")
assert(classOnly[8] == nil and classOnly[73] == nil
  and classOnly[85] == nil and classOnly[97] == nil,
  "a Warrior with no Variant leaves the spec cooldown and primary positions clear")

local furySlot1 = Addon.Defaults.classes.WARRIOR.variants.Fury.actions[1]
Addon.Defaults.classes.WARRIOR.variants.Fury.actions[1] = false
local furyClear = Addon:ResolveDeck("WARRIOR", "Fury")
assert(furyClear[1] == nil, "Variant false clears a Class Action Deck slot")
Addon.Defaults.classes.WARRIOR.variants.Fury.actions[1] = furySlot1

for _, deck in ipairs({ fury, arms, prot }) do
  for slot, entry in pairs(deck) do
    local isSpell = entry.kind == "spell" or type(entry.spellId) == "number"
      or (type(entry.id) == "string" and entry.id:find("^spell:", 1, true))
    if isSpell then
      assert(type(entry.spellId) == "number" or type(entry.id) == "string",
        "spell Action Deck slot " .. slot .. " needs a spell id")
    else
      assert(type(entry.match) == "string" and entry.match ~= "",
        "Warrior deck slot " .. slot .. " must select a macro by body, not name alone")
      local rec = Addon.Defaults.catalog[entry.id]
      assert(type(rec) == "table" and type(rec.body) == "string",
        "Warrior deck slot " .. slot .. " needs catalog " .. tostring(entry.id))
      assert(rec.body:find(entry.match, 1, true),
        entry.id .. " catalog body must contain the Action Deck match")
      if entry.notMatch then
        assert(not rec.body:find(entry.notMatch, 1, true),
          entry.id .. " catalog body must not contain notMatch")
      end
    end
  end
end

local managed = Addon:ResolveDeckSlots("WARRIOR")
assert(managed[1] and managed[12] and managed[73] and managed[108] and managed[111],
  "Warrior deck owns its utility row, stance pages, and stance buttons")
assert(not managed[13] and not managed[72] and not managed[112],
  "Warrior deck preserves unrelated fixed Action Slots")

assert(Addon.Defaults.catalog["w-c"].name == "c", "Cleave keeps catalog name c")
local catalogNames = {}
for id, rec in pairs(Addon.Defaults.catalog) do
  assert(type(rec.name) == "string" and rec.name ~= "", id .. " needs a name")
  local other = catalogNames[rec.name]
  assert(other == nil, "catalog name " .. rec.name .. " is used by " .. tostring(other) .. " and " .. id)
  catalogNames[rec.name] = id
end
assert(Addon.Defaults.catalog["w-charge"].body:find("nocombat,nostance:1", 1, true),
  "Charge macro enters Battle out of combat")
assert(Addon.Defaults.catalog["w-charge"].body:find("combat,nostance:3", 1, true),
  "Charge macro enters Berserker for Intercept in combat")
assert(Addon.Defaults.catalog["w-interrupt"].body:find("Shield Bash", 1, true)
  and Addon.Defaults.catalog["w-interrupt"].body:find("Pummel", 1, true)
  and Addon.Defaults.catalog["w-interrupt"].body:find("noequipped:Shields", 1, true),
  "interrupt macro selects a shield interrupt or dances to Pummel")
assert(Addon.Defaults.catalog["w-ex"].body:find("[stance:2] Battle Stance", 1, true),
  "Execute leaves Defensive Stance")
assert(Addon.Defaults.catalog["w-h"].body:find("/cast Heroic Strike", 1, true)
  and not Addon.Defaults.catalog["w-h"].body:find("Rank 3", 1, true),
  "Heroic Strike uses maximum rank")
assert(Addon.Defaults.catalog["w-intimid"].body:find("/stopattack", 1, true),
  "Intimidating Shout stops auto-attack")
assert(Addon.Defaults.catalog["w-shout"].body:find("[mod:shift] Demoralizing Shout", 1, true),
  "Battle Shout keeps Demoralizing Shout on Shift")
assert(Addon.Defaults.catalog["w-major-cd"].body:find("Retaliation", 1, true)
  and Addon.Defaults.catalog["w-major-cd"].body:find("Shield Wall", 1, true)
  and Addon.Defaults.catalog["w-major-cd"].body:find("Recklessness", 1, true),
  "major cooldown follows the active stance")
assert(Addon.Defaults.catalog["w-deathwish"].body:find("Death Wish", 1, true),
  "Fury ships standalone Death Wish")
assert(Addon.Defaults.catalog["w-reck"].body:find("Recklessness", 1, true),
  "Recklessness is in the Action Deck catalog")
assert(Addon:ResolveDeck("MAGE", nil)[13] == nil, "Mage defaults are not loaded in this spec")

local prints = {}
function Addon:Print(msg)
  prints[#prints + 1] = msg
end

_G.InCombatLockdown = function() return true end
assert(Addon:PlaceDeck("WARRIOR", "Fury") == false, "combat blocks PlaceDeck")
assert(prints[1]:find("combat", 1, true), "combat tells the player to leave combat")

_G.InCombatLockdown = function() return false end

local macros = {
  { name = "c", body = "#showtooltip\n/cast Cannibalize(Racial)" },
  { name = "c", body = "#showtooltip\n/cast Cone of Cold" },
  { name = "c", body = "#showtooltip Cleave\n/cast Cleave" },
  { name = "d", body = "#showtooltip Disarm\n/cast Disarm" },
  { name = "d", body = "#showtooltip Defensive Stance\n/cast Defensive Stance" },
  { name = "hm", body = "#showtooltip Hamstring\n/cast Hamstring" },
  { name = "charge", body = "#showtooltip Charge\n/cast Charge\n/cast Intercept" },
  { name = "ex", body = "#showtooltip Execute\n/cast Execute" },
}
_G.GetNumMacros = function()
  return #macros, 0
end
_G.GetMacroInfo = function(i)
  local m = macros[i]
  if not m then return nil end
  return m.name, "icon", m.body
end
assert(Addon:FindMacroIndex("c", "Cleave", "Cannibalize") == 3,
  "Cleave skips same-name Cannibalize and Cone of Cold macros")
assert(Addon:FindMacroIndex("d", "Disarm") == 4, "Disarm is the first d")
assert(Addon:FindMacroIndex("d", "Defensive Stance", "Disarm") == 5, "stance d skips Disarm")

local picked, placed, cleared = {}, {}, {}
_G.ClearCursor = function() end
_G.PickupAction = function(slot)
  cleared[slot] = true
end
_G.PickupMacro = function(index)
  picked[#picked + 1] = index
end
_G.PickupSpell = function(name)
  picked[#picked + 1] = "spell:" .. tostring(name)
end
_G.PlaceAction = function(slot)
  placed[slot] = picked[#picked]
end
_G.CreateMacro = function(name, icon, body, perChar)
  macros[#macros + 1] = { name = name, body = body, icon = icon, perChar = perChar }
  return #macros
end
_G.DeleteMacro = function(index)
  table.remove(macros, index)
end

prints = {}
local refreshed = 0
local lockWrites = {}
_G.GetCVar = function(name)
  if name == "lockActionBars" then return "1" end
end
_G.SetCVar = function(name, value)
  lockWrites[#lockWrites + 1] = { name, value }
end
Addon.bars = {
  bar2 = {
    buttons = {
      {
        UpdateAction = function(_, force)
          if force then refreshed = refreshed + 1 end
        end,
      },
    },
  },
}
assert(Addon:PlaceDeck("WARRIOR", "Fury") == true, "PlaceDeck runs out of combat")
assert(refreshed == 1, "PlaceDeck refreshes ShadowUI Action Buttons")
assert(lockWrites[1] and lockWrites[1][2] == "0", "PlaceDeck unlocks lockActionBars to place")
assert(lockWrites[2] and lockWrites[2][2] == "1", "PlaceDeck restores lockActionBars")
assert(prints[1] and prints[1]:find("Placed", 1, true), "PlaceDeck reports placed slots")
assert(cleared[1] and cleared[12] and cleared[73] and cleared[108] and cleared[111],
  "PlaceDeck clears every managed slot before placement")
for _, slot in ipairs({ 109, 110, 111 }) do
  assert(cleared[slot] and not placed[slot],
    "PlaceDeck clears empty mouse-stance slot " .. slot)
end
assert(cleared[13], "PlaceDeck clears the loadout slot on bar3")
assert(not cleared[72] and not cleared[112],
  "PlaceDeck does not clear unrelated fixed slots")
local function bodyAt(slot)
  local macro = macros[placed[slot]]
  return macro and macro.body or ""
end
assert(bodyAt(1):find("/cast Heroic Strike", 1, true),
  "utility 1 gets Heroic Strike")
assert(bodyAt(5):find("[stance:2] Battle Stance", 1, true),
  "Hamstring keeps the stance-aware body")
assert(bodyAt(77):find("nocombat,nostance:1", 1, true),
  "Charge keeps the stance-aware Charge and Intercept body")
assert(bodyAt(76):find("Cleave", 1, true)
  and not bodyAt(76):find("Cannibalize", 1, true)
  and not bodyAt(76):find("Cone of Cold", 1, true),
  "Cleave lands despite same-name account macros")
assert(bodyAt(78):find("Shield Bash", 1, true) and bodyAt(78):find("Pummel", 1, true),
  "smart interrupt lands on the Battle page")
assert(bodyAt(74):find("Bloodthirst", 1, true)
  and bodyAt(86):find("Bloodthirst", 1, true)
  and bodyAt(98):find("Bloodthirst", 1, true),
  "Bloodthirst lands on the stance pages")
assert(bodyAt(91):find("[stance:2] Battle Stance", 1, true),
  "Defensive Execute keeps the stance-aware body instead of the stale same-name macro")
assert(cleared[109] and not placed[109], "Fury does not place Battle Stance on mouse 5")
assert(cleared[110] and not placed[110], "Fury does not place Defensive Stance on mouse 4")
assert(cleared[111] and not placed[111], "Fury does not place Berserker Stance on mouse 3")

macros = {
  { name = "hm", body = "/cast Hamstring" },
}
_G.CreateMacro = function(name, icon, body, perChar)
  macros[#macros + 1] = { name = name, body = body, icon = icon, perChar = perChar }
  return #macros
end
_G.EditMacro = function(index, name, icon, body)
  local m = macros[index]
  if name then m.name = name end
  if icon then m.icon = icon end
  if body then m.body = body end
  return index
end
_G.DeleteMacro = function(index)
  table.remove(macros, index)
end
local created = Addon:EnsureDeckMacro(fury[77])
assert(macros[2].name == "suiCharge", "missing deck Charge uses a collision-safe name")
assert(macros[2].perChar == false, "new deck macros go on the account tab")
assert(created == 2, "EnsureDeckMacro returns the new index")
assert(macros[2].body:find("Intercept", 1, true), "created body is the catalog Charge+Intercept")

macros = {
  { name = "suiCharge", body = "#showtooltip Charge\n/cast Charge" },
}
created = Addon:EnsureDeckMacro(fury[77])
assert(created == 1, "a stale collision-safe name is rewritten in place")
assert(#macros == 1, "a stale collision-safe name does not spawn a sibling")
assert(macros[1].body:find("nocombat,nostance:1", 1, true),
  "EditMacro writes the catalog Charge+Intercept body")

macros = {
  { name = "suiCharge", body = "#showtooltip Charge\n/cast Charge" },
  { name = "suiCharge", body = "#showtooltip Charge\n/cast Charge" },
}
created = Addon:EnsureDeckMacro(fury[77])
assert(#macros == 1, "extra collision-safe copies are removed after repair")
assert(created == 1 and macros[1].body:find("nocombat,nostance:1", 1, true),
  "the kept collision-safe Charge has the catalog body")

local savedCharge = Addon.Defaults.catalog["w-charge"].body
Addon.Defaults.catalog["w-charge"].body = "#showtooltip Charge\n/cast Charge"
macros = { { name = "charge", body = "/cast Frostbolt" } }
local createdCount = 0
_G.CreateMacro = function(name, icon, body, perChar)
  createdCount = createdCount + 1
  macros[#macros + 1] = { name = name, body = body, icon = icon, perChar = perChar }
  return #macros
end
assert(Addon:EnsureDeckMacro(fury[77]) == nil,
  "a catalog body that cannot satisfy match does not place Charge")
assert(createdCount == 0 and #macros == 1,
  "a catalog body that cannot satisfy match does not spawn General-tab duplicates")
Addon.Defaults.catalog["w-charge"].body = savedCharge
_G.CreateMacro = function(name, icon, body, perChar)
  macros[#macros + 1] = { name = name, body = body, icon = icon, perChar = perChar }
  return #macros
end

local collisionCases = {}
for _, entry in ipairs({
  fury[5], fury[6], fury[7], fury[77], fury[76], fury[78], fury[79], fury[80],
  classOnly[110], classOnly[111],
}) do
  if entry and entry.createName and entry.match then
    collisionCases[#collisionCases + 1] = { entry = entry, wrong = "/cast Frostbolt" }
  end
end
assert(#collisionCases > 0, "collision cases cover loadout macros with create names")
for _, case in ipairs(collisionCases) do
  macros = { { name = case.entry.name, body = case.wrong } }
  local index = Addon:EnsureDeckMacro(case.entry)
  assert(index == 2, case.entry.id .. " skips a same-name macro from another class")
  assert(macros[2].name == case.entry.createName, case.entry.id .. " uses a collision-safe name")
  assert(macros[2].body:find(case.entry.match, 1, true),
    case.entry.id .. " creates the required Warrior body")
end

macros = {}
local disarm = Addon:EnsureDeckMacro(fury[7])
local stance = Addon:EnsureDeckMacro(classOnly[110])
assert(macros[1].name == "disarm", "new Disarm uses a unique create name")
assert(macros[2].name == "defstan", "new Defensive Stance uses a unique create name")
assert(disarm == 1 and stance == 2, "both stance-name collisions are created")

Addon.Defaults.classes.WARRIOR.variants.Fury.actions[13] = {
  id = "w-disarm", name = "disarm", match = DISARM_MATCH, createName = "disarm",
}
Addon.Defaults.classes.WARRIOR.variants.Fury.actions[22] = {
  id = "spell:20600", name = "Perception", kind = "spell", spellId = 20600,
}
local pickedSpells = {}
_G.PickupSpell = function(id)
  pickedSpells[#pickedSpells + 1] = id
  picked[#picked + 1] = "spell:" .. tostring(id)
end
picked, placed, cleared = {}, {}, {}
prints = {}
macros = {
  { name = "disarm", body = "#showtooltip Disarm\n/startattack\n/cast [nostance:2] Defensive Stance\n/cast Disarm" },
}
assert(Addon:PlaceDeck("WARRIOR", "Fury") == true, "PlaceDeck places overlay slots")
assert(placed[13], "PlaceDeck places a macro outside the Warrior-owned stance range")
assert(cleared[13], "PlaceDeck clears that overlay slot first")
assert(placed[22] == "spell:Perception" or placed[22] == "spell:20600",
  "PlaceDeck places a spell ability")
assert(cleared[22], "PlaceDeck clears the spell Action Slot first")

print("deck_spec OK")

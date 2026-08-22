-- Learned spells write a shipped Action Slot. New ranks replace the old rank.
-- Run: lua tests/learn_slot_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = { Defaults = { classes = {} } }
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end

local NAMES = {
  [5176] = "Wrath",
  [5177] = "Wrath",
  [5185] = "Healing Touch",
  [5186] = "Healing Touch",
  [774] = "Rejuvenation",
}

_G.GetSpellInfo = function(id) return NAMES[id] end
_G.InCombatLockdown = function() return false end
_G.GetCursorInfo = function() return nil end
_G.GetActionInfo = function() return nil end

local picked, placed, cleared
_G.PickupSpell = function(id) picked = id; _G.GetCursorInfo = function() return "spell", id end end
_G.PlaceAction = function(slot) placed = slot; _G.GetCursorInfo = function() return nil end end
_G.ClearCursor = function() cleared = true; _G.GetCursorInfo = function() return nil end end

assert(loadfile(root .. "defaults/classes/DRUID.lua"))()
assert(loadfile(root .. "bars/learn.lua"))()

function Addon:GetPlayerClass() return "DRUID" end

assert(Addon:LearnSlotForSpell(5176) == 1, "Wrath rank 1 maps to slot 1")
assert(Addon:LearnSlotForSpell(5177) == 1, "Wrath rank 2 uses the same slot")
assert(Addon:LearnSlotForSpell(5185) == 2, "Healing Touch maps to slot 2")
assert(Addon:LearnSlotForSpell(774) == nil, "unmapped spells stay off the bar")

Addon:OnLearnedSpell("LEARNED_SPELL_IN_TAB", 5176)
assert(picked == 5176, "picks up Wrath")
assert(placed == 1, "places Wrath on slot 1")

picked, placed = nil, nil
_G.GetCursorInfo = function() return nil end
_G.GetActionInfo = function(slot)
  if slot == 1 then return "spell", 5176 end
end
Addon:OnLearnedSpell("LEARNED_SPELL_IN_TAB", 5177)
assert(picked == 5177, "picks up the new Wrath rank")
assert(placed == 1, "new rank replaces slot 1")

picked, placed = nil, nil
_G.GetCursorInfo = function() return nil end
_G.GetActionInfo = function() return "spell", 5177 end
Addon:OnLearnedSpell("LEARNED_SPELL_IN_TAB", 5177)
assert(picked == nil and placed == nil, "same rank does not pickup again")

picked, placed = nil, nil
_G.GetActionInfo = function() return nil end
_G.GetCursorInfo = function() return "item", 6948 end
Addon:OnLearnedSpell("LEARNED_SPELL_IN_TAB", 5185)
assert(picked == nil, "does not steal the cursor")

_G.GetCursorInfo = function() return nil end
_G.GetActionInfo = function() return nil end
_G.InCombatLockdown = function() return true end
Addon:OnLearnedSpell("LEARNED_SPELL_IN_TAB", 5186)
assert(Addon._pendingLearn[2] == 5186, "queues while in combat")
assert(placed == nil, "does not PlaceAction in combat")

_G.InCombatLockdown = function() return false end
Addon:FlushPendingLearn()
assert(picked == 5186, "flush picks up Healing Touch rank 2")
assert(placed == 2, "flush writes slot 2")
assert(Addon._pendingLearn == nil, "pending queue clears")

function Addon:GetPlayerClass() return "MAGE" end
assert(Addon:LearnSlotForSpell(5176) == nil, "other classes have no learn map")

print("learn_slot_spec OK")

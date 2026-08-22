-- First ApplyAll turns Auto Loot on (autoLootDefault). New characters start
-- with it off. Run: lua tests/auto_loot_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return {
    NewAddon = function() return Addon end,
    GetAddon = function() return Addon end,
  }
end
assert(loadfile(root .. "core/init.lua"))()

local sets = {}
_G.SetCVar = function(name, value)
  sets[#sets + 1] = { name, value }
end
_G.InCombatLockdown = function()
  return false
end
function Addon:ResolveEffective()
  return {}
end
function Addon:Print() end

Addon:ApplyAutoLoot()
assert(#sets == 1, "ApplyAutoLoot writes one CVar")
assert(sets[1][1] == "autoLootDefault" and tostring(sets[1][2]) == "1", "Auto Loot CVar is on")

sets = {}
Addon:ApplyAll()
local found
for _, entry in ipairs(sets) do
  if entry[1] == "autoLootDefault" then
    found = tostring(entry[2])
  end
end
assert(found == "1", "ApplyAll turns Auto Loot on")

print("auto_loot_spec OK")

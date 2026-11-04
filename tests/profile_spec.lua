-- One Account Profile: flatten named stores and drop Character selection.
-- Run: lua tests/profile_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/resolve.lua"))()

local account, char
function Addon:GetDB() return account end
function Addon:GetCharDB() return char end
function Addon:GetPlayerClass() return "MAGE" end

account = {
  defaultProfile = "Default",
  profiles = {
    Default = { layout = { bar1 = { x = 1 } }, keybinds = { Q = "Q" }, actions = {} },
    Raid = { layout = { bar1 = { x = 9 } }, keybinds = {}, actions = {} },
  },
}
char = { activeProfile = "Raid" }

Addon:EnsureProfile()
assert(account.layout.bar1.x == 9, "Character selection flattens that named store")
assert(account.profiles == nil, "named Profile map is gone")
assert(account.defaultProfile == nil, "Default Profile name is gone")
assert(char.activeProfile == nil, "Character selection is gone")
assert(Addon:GetProfile() == account, "GetProfile returns the Account store")

account = {
  defaultProfile = "Default",
  profiles = {
    Default = { layout = { bar1 = { y = 4 } }, keybinds = {}, actions = {} },
  },
}
char = { activeProfile = nil }
Addon:EnsureProfile()
assert(account.layout.bar1.y == 4, "empty Character uses Default named store")

account = { layout = {}, keybinds = {}, actions = {} }
char = {}
assert(Addon:GetProfile().layout, "a fresh store still has Layout")
Addon:WriteProfileDelta("layout", "bar1", { y = 9 })
assert(account.layout.bar1.y == 9, "writes land on the Account Profile")

print("profile_spec OK")

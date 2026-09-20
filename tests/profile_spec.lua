-- Named Profiles: create, rename, default, delete.
-- Run: lua tests/profile_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "profile/profiles.lua"))()

local account, char
function Addon:GetDB() return account end
function Addon:GetCharDB() return char end
function Addon:GetPlayerClass() return "MAGE" end
function Addon:ApplyAll()
  Addon.applied = (Addon.applied or 0) + 1
end
function Addon:Print() end

account = {
  defaultProfile = "Default",
  profiles = {
    Default = { layout = { bar1 = { x = 1 } }, keybinds = {} },
  },
}
char = { activeProfile = nil }

assert(Addon:GetActiveProfileName() == "Default", "empty Character uses Default Profile")
assert(Addon:CreateProfile("Raid") == true, "create copies the active Profile")
assert(account.profiles.Raid.layout.bar1.x == 1, "new Profile copies Layout")
assert(Addon:SetActiveProfile("Raid") == true, "Character can select the new Profile")
assert(char.activeProfile == "Raid", "selection is stored on Character")
assert(Addon:SetDefaultProfile("Raid") == true, "Raid can be Default Profile")
assert(account.defaultProfile == "Raid", "Default Profile is Raid")
assert(Addon:RenameProfile("Raid", "Mythic") == true, "rename keeps the store")
assert(account.profiles.Raid == nil and account.profiles.Mythic, "old name is gone")
assert(account.defaultProfile == "Mythic", "rename updates Default Profile")
assert(char.activeProfile == "Mythic", "rename updates Character selection")
assert(Addon:DeleteProfile("Default") == true, "delete removes a spare Profile")
assert(Addon:DeleteProfile("Mythic") == false, "the last Profile stays")
assert(account.profiles.Mythic, "last Profile is still present")

print("profile_spec OK")

-- /shadowui profile switches and marks Default.
-- Run: lua tests/layer_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "profile/profiles.lua"))()

local account = {
  defaultProfile = "Default",
  profiles = {
    Default = { layout = {}, keybinds = {} },
    Raid = { layout = {}, keybinds = {} },
  },
}
local char = { activeProfile = nil }
local messages = {}
function Addon:GetDB() return account end
function Addon:GetCharDB() return char end
function Addon:Print(text) messages[#messages + 1] = text end
function Addon:ApplyAll() end

Addon:HandleProfileCommand("")
assert(messages[#messages] == "Active Profile: Default (Default Profile)",
  "empty command reports Default Profile")
Addon:HandleProfileCommand("Raid")
assert(char.activeProfile == "Raid", "named command selects that Profile")
Addon:HandleProfileCommand("default")
assert(account.defaultProfile == "Raid", "default with no name uses the active Profile")
Addon:HandleProfileCommand("default Default")
assert(account.defaultProfile == "Default", "default Name sets that Profile")

print("layer_spec OK")

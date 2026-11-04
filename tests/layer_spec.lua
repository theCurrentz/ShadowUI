-- /shadowui has no Profile picker.
-- Run: lua tests/layer_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return {
    NewAddon = function() return Addon end,
    GetAddon = function() return Addon end,
  }
end
assert(loadfile(root .. "core/init.lua"))()

function Addon:SetupDB() end
function Addon:RegisterChatCommand() end
function Addon:OpenOptions() end
function Addon:ToggleEditMode() end
function Addon:ToggleKeybindMode() end
function Addon:ShiftAndPruneBars() end
local messages = {}
function Addon:Print(text) messages[#messages + 1] = text end

Addon:SlashCommand("profile Raid")
assert(messages[#messages]:find("Usage:", 1, true), "/shadowui profile is not a command")
assert(not messages[#messages]:find("profile]", 1, true), "usage does not list profile")

print("layer_spec OK")

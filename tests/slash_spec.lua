-- /shadowui and /sui share one handler. Run: lua tests/slash_spec.lua
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
local registered = {}
function Addon:RegisterChatCommand(command, func)
  registered[command] = func
end
Addon:OnInitialize()
assert(registered.shadowui == "SlashCommand", "/shadowui opens options")
assert(registered.sui == "SlashCommand", "/sui is a short form of /shadowui")

local placed = 0
function Addon:PlaceDeck()
  placed = placed + 1
end
function Addon:Print() end
Addon:SlashCommand("deck")
assert(placed == 1, "/shadowui deck places the Action Deck")
Addon:SlashCommand("place")
assert(placed == 2, "/shadowui place is the same command")

print("slash_spec OK")

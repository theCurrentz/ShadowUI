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

function Addon:Print() end
local prunedGroup
function Addon:ShiftAndPruneBars(groupName)
  prunedGroup = groupName
end
Addon:SlashCommand("prune Main")
assert(prunedGroup == "Main", "/shadowui prune packs Keybinds in that Bar Group")
Addon:SlashCommand("shift Side")
assert(prunedGroup == "Side", "/shadowui shift is the same command")

local loadoutRest
function Addon:HandleLoadoutCommand(rest)
  loadoutRest = rest
end
Addon:SlashCommand("loadout preview Tazzy")
assert(loadoutRest == "preview Tazzy", "/shadowui loadout delegates its subcommand")

local dumped = 0
function Addon:DumpXPStack()
  dumped = dumped + 1
end
Addon:SlashCommand("xpstack")
assert(dumped == 1, "/shadowui xpstack dumps the live Tracking XP host")

print("slash_spec OK")

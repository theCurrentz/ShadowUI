-- GetVersion reads the running client. Era is the default.
-- Run: lua tests/version_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return {
    NewAddon = function() return Addon end,
    GetAddon = function() return Addon end,
  }
end
assert(loadfile(root .. "core/init.lua"))()

_G.GetBuildInfo = nil
_G.WOW_PROJECT_ID = nil
_G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
assert(Addon:GetVersion() == "ERA", "missing client data is Era")

_G.GetBuildInfo = function()
  return "1.15.9", "0", "date", 11509
end
assert(Addon:GetVersion() == "ERA", "interface 11509 is Era")

_G.GetBuildInfo = function()
  return "2.5.6", "0", "date", 20506
end
assert(Addon:GetVersion() == "TBC", "interface 20506 is TBC")

_G.GetBuildInfo = nil
_G.WOW_PROJECT_ID = 5
assert(Addon:GetVersion() == "TBC", "Burning Crusade project id is TBC")

print("version_spec OK")

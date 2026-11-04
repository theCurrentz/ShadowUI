-- GetVersion is Forever. This addon does not branch Era or TBC.
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

assert(Addon:GetVersion() == "FOREVER", "this addon is Forever only")
_G.GetBuildInfo = function()
  return "1.15.9", "0", "date", 11509
end
assert(Addon:GetVersion() == "FOREVER", "interface numbers do not select Era")
_G.GetBuildInfo = function()
  return "2.5.6", "0", "date", 20506
end
_G.WOW_PROJECT_ID = 5
_G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
assert(Addon:GetVersion() == "FOREVER", "interface numbers do not select TBC")

print("version_spec OK")

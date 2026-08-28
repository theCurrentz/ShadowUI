-- Layer picker writes Base, Class, Variant, or Character.
-- Run: lua tests/layer_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "edit/layer.lua"))()

local char = { editLayer = "variant" }
function Addon:GetCharDB()
  return char
end
function Addon:Print() end

assert(Addon:SetEditLayer("character") == true, "Character is a valid Layer")
assert(char.editLayer == "character", "Character Layer writes CharDB")
assert(Addon:SetEditLayer("base") == true, "Base stays valid")
assert(Addon:SetEditLayer("profile") == false, "unknown Layer is rejected")
assert(char.editLayer == "base", "rejected Layer does not replace the last valid Layer")

print("layer_spec OK")

-- /shadowui uses a tree outline and a Search that hides groups that do not match.
-- Run: lua tests/options_nav_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
local registered
local notified
_G.LibStub = function(name)
  if name == "AceAddon-3.0" then
    return { GetAddon = function() return Addon end }
  end
  if name == "AceConfig-3.0" then
    return {
      RegisterOptionsTable = function(_, _, opts)
        registered = opts
      end,
    }
  end
  if name == "AceConfigDialog-3.0" then
    return {
      Open = function() end,
      Close = function() end,
      SetDefaultSize = function() end,
    }
  end
  if name == "AceConfigRegistry-3.0" then
    return {
      NotifyChange = function(_, app)
        notified = app
      end,
    }
  end
end

function Addon:GetCharDB()
  return { activeProfile = nil, microFadeIdle = nil, microIconShape = nil, xpFadeIdle = nil }
end
function Addon:GetDB()
  return {
    defaultProfile = "Default",
    profiles = { Default = { layout = {}, keybinds = {} } },
    loadouts = {},
  }
end
function Addon:GetPlayerClass()
  return "MAGE"
end
function Addon:GetActiveProfileName() return "Default" end
function Addon:SetActiveProfile() end
function Addon:CreateProfile() end
function Addon:RenameProfile() end
function Addon:DeleteProfile() end
function Addon:SetDefaultProfile() end
function Addon:ProfileValues()
  return { Default = "Default" }
end
function Addon:GetProfile()
  return Addon:GetDB().profiles.Default
end
function Addon:ToggleEditMode() end
function Addon:ToggleKeybindMode() end
function Addon:SetActionSlotHardLock() end
function Addon:ResolveEffective()
  return { layout = {} }
end
function Addon:ApplyAll() end
function Addon:WriteProfileDelta() end
function Addon:LoadoutValues()
  return {}
end
function Addon:DefaultLoadoutOptions()
  return { selectedBars = {} }
end
function Addon:BackupLoadoutKey()
  return "backup"
end

assert(loadfile(root .. "core/resolve.lua"))()
function Addon:ResolveEffective()
  return { layout = {} }
end
assert(loadfile(root .. "options/nav.lua"))()
assert(loadfile(root .. "options/config.lua"))()
Addon:OpenOptions()

assert(registered.childGroups == "tree", "options use a tree outline")
assert(registered.args.search, "options expose Search")
assert(registered.args.search.type == "input", "Search is an input")
assert(registered.args.search.name == "Search", "Search uses that name")
assert(registered.args.general, "outline has General")
assert(registered.args.general.type == "group", "General is a group")
assert(not registered.args.general.inline, "General is an outline node")
assert(registered.args.profiles and not registered.args.profiles.inline,
  "Profiles is an outline node")
assert(registered.args.bars and not registered.args.bars.inline,
  "Action bars is an outline node")
assert(registered.args.cooldown and not registered.args.cooldown.inline,
  "Cooldown manager is an outline node")
assert(registered.args.loadouts and not registered.args.loadouts.inline,
  "Loadouts is an outline node")
assert(not registered.args.bars.args.global.inline, "Global is nested in the outline")
assert(not registered.args.bars.args.groups.inline, "Groups is nested in the outline")
assert(not registered.args.bars.args.bar1.inline, "Bar 1 is nested in the outline")
assert(registered.args.general.args.microFadeIdle, "General holds Micro Cluster fade idle")
assert(registered.args.general.args.showExperienceBar, "General holds Experience bar toggle")
assert(registered.args.general.args.xpFadeIdle, "General holds Experience bar fade idle")
assert(registered.args.general.args.editLayout, "General holds Edit layout")
assert(registered.args.unitFrames, "outline has Unit Frames")
assert(registered.args.unitFrames.type == "group", "Unit Frames is a group")
assert(not registered.args.unitFrames.inline, "Unit Frames is an outline node")
assert(registered.args.unitFrames.args.studio.dialogControl == "ShadowUI-UnitStudio",
  "Unit Frames hosts the visual studio")
assert(not registered.args.general.args.shiftAndPrune, "General does not hold Shift and Prune")
assert(registered.args.bars.args.groups.args.group1.args.shiftAndPrune,
  "each Bar Group holds Shift and Prune")

assert(Addon:GetOptionsSearch() == "", "Search starts empty")
assert(registered.args.profiles.hidden() ~= true, "empty Search keeps Profiles")
assert(registered.args.bars.hidden() ~= true, "empty Search keeps Action bars")

registered.args.search.set(nil, " loadout ")
assert(Addon:GetOptionsSearch() == "loadout", "Search stores a trimmed lowercase query")
assert(notified == "ShadowUI", "Search refresh notifies AceConfig")
assert(registered.args.loadouts.hidden() ~= true, "Loadout query keeps Loadouts")
assert(registered.args.profiles.hidden() == true, "Loadout query hides Profiles")
assert(registered.args.bars.hidden() == true, "Loadout query hides Action bars")

registered.args.search.set(nil, "Gap")
assert(registered.args.bars.hidden() ~= true, "Gap query keeps Action bars")
assert(registered.args.bars.args.bar1.hidden() ~= true, "Gap query keeps Bar 1")
assert(registered.args.bars.args.global.hidden() ~= true, "Gap query keeps Global")
assert(registered.args.profiles.hidden() == true, "Gap query hides Profiles")
assert(registered.args.cooldown.hidden() ~= true, "Gap query keeps Cooldown manager")

registered.args.search.set(nil, "Action bars")
assert(registered.args.bars.hidden() ~= true, "Action bars query keeps that node")
assert(registered.args.bars.args.bar1.hidden() ~= true,
  "a matching parent keeps nested outline nodes")
assert(registered.args.profiles.hidden() == true, "Action bars query hides Profiles")

registered.args.search.set(nil, "Bar 1")
assert(registered.args.bars.hidden() ~= true, "Bar 1 query keeps Action bars")
assert(registered.args.bars.args.bar1.hidden() ~= true, "Bar 1 query keeps Bar 1")
assert(registered.args.bars.args.bar2.hidden() == true, "Bar 1 query hides Bar 2")

registered.args.search.set(nil, "")
assert(registered.args.profiles.hidden() ~= true, "clearing Search shows Profiles again")
assert(registered.args.search.hidden == nil or registered.args.search.hidden() ~= true,
  "Search stays visible")

local function assertAceKeys(node, path)
  for key in pairs(node) do
    assert(key ~= "_optionsSearchShow" and key ~= "_optionsSearchHide"
      and key ~= "optionsSearchKeep",
      path .. "." .. key .. " is not a valid AceConfig parameter")
  end
  if node.args then
    for name, child in pairs(node.args) do
      assertAceKeys(child, path .. "." .. name)
    end
  end
end
assertAceKeys(registered, "ShadowUI")

print("options_nav_spec OK")

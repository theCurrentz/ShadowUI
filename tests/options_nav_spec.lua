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
  return { microFadeIdle = nil }
end
function Addon:GetDB()
  return { layout = {}, keybinds = {}, actions = {} }
end
function Addon:GetPlayerClass()
  return "MAGE"
end
function Addon:GetProfile()
  return Addon:GetDB()
end
function Addon:ToggleEditMode() end
function Addon:ToggleKeybindMode() end
function Addon:SetActionSlotHardLock() end
function Addon:ResolveEffective()
  return { layout = {} }
end
function Addon:ApplyAll() end

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
assert(registered.args.profiles == nil, "outline has no Profiles")
assert(registered.args.bars == nil, "outline has no Action bars")
assert(registered.args.cooldown == nil, "outline has no Cooldown manager")
assert(registered.args.loadouts == nil, "outline has no Loadouts")
assert(registered.args.general.args.microFadeIdle, "General holds Micro Cluster fade idle")
assert(not registered.args.general.args.xpFadeIdle, "General has no Experience bar opacity")
assert(not registered.args.general.args.showExperienceBar, "General has no Experience bar toggle")
assert(registered.args.general.args.editLayout, "General holds Edit layout")
assert(registered.args.unitFrames == nil, "outline has no Unit Frames")
assert(not registered.args.general.args.shiftAndPrune, "General does not hold Shift and Prune")

assert(Addon:GetOptionsSearch() == "", "Search starts empty")
assert(registered.args.general.hidden() ~= true, "empty Search keeps General")

registered.args.search.set(nil, " minimap ")
assert(Addon:GetOptionsSearch() == "minimap", "Search stores a trimmed lowercase query")
assert(notified == "ShadowUI", "Search refresh notifies AceConfig")
assert(registered.args.general.hidden() ~= true, "minimap query keeps General")

registered.args.search.set(nil, "Hard lock")
assert(registered.args.general.hidden() ~= true, "Hard lock query keeps General")
assert(registered.args.general.args.hardLockActionSlots.hidden() ~= true,
  "Hard lock query keeps that control")
assert(registered.args.general.args.editLayout.hidden() == true,
  "Hard lock query hides Edit layout")

registered.args.search.set(nil, "Edit layout")
assert(registered.args.general.hidden() ~= true, "Edit layout query keeps General")
assert(registered.args.general.args.editLayout.hidden() ~= true,
  "Edit layout query keeps that control")
assert(registered.args.general.args.hardLockActionSlots.hidden() == true,
  "Edit layout query hides Hard lock")

registered.args.search.set(nil, "")
assert(registered.args.general.hidden() ~= true, "clearing Search shows General again")
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

-- Options panel keeps Character chrome and edit sessions.
-- Action bars and named Profiles live off this pane.
-- Action Slot and Micro Cluster icons stay square. Loadouts are gone.
-- Run: lua tests/options_bars_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
local registered
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
    return { Open = function() end, Close = function() end, SetDefaultSize = function() end }
  end
  if name == "AceConfigRegistry-3.0" then
    return { NotifyChange = function() end }
  end
end

local char = {}
local applied = 0

function Addon:GetCharDB()
  return char
end
function Addon:ApplyAll()
  applied = applied + 1
end
function Addon:GetDB()
  return { layout = {}, keybinds = {}, actions = {} }
end
function Addon:GetPlayerClass()
  return "MAGE"
end
function Addon:ToggleEditMode() end
function Addon:ToggleKeybindMode() end
function Addon:SetActionSlotHardLock() end

assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "options/nav.lua"))()
assert(loadfile(root .. "options/config.lua"))()
Addon:OpenOptions()

assert(registered.args.bars == nil, "options have no Action bars group")
assert(registered.args.profiles == nil, "options have no Profiles group")
assert(registered.args.cooldown == nil, "options have no Cooldown manager")
assert(registered.args.placeDeck == nil, "Place Action Deck is gone")
assert(registered.args.deck == nil, "options have no Action Deck group")
assert(registered.args.loadouts == nil, "options have no Loadouts")
assert(not registered.args.general.args.shiftAndPrune, "Shift and Prune is not a General action")
assert(registered.args.general.args.microFadeIdle, "options expose Micro Cluster fade idle")
assert(registered.args.general.args.darkness, "options expose Darkness")
assert(not registered.args.general.args.xpFadeIdle, "options have no Experience bar opacity")
assert(registered.args.general.args.microIconShape == nil, "options have no Micro Cluster shape")
assert(registered.args.general.args.useShadowUIMinimap, "options expose ShadowUI minimap toggle")
assert(registered.args.general.args.microFadeIdle.get() == 1, "Micro Cluster fade idle defaults to 1")
assert(registered.args.general.args.darkness.get() == 1, "Darkness defaults to 1")
assert(registered.args.general.args.useShadowUIMinimap.get() == true, "ShadowUI minimap defaults on")
assert(not registered.args.general.args.showExperienceBar, "options have no Experience bar toggle")
assert(registered.args.general.args.resetLayer.name == "Reset Profile", "reset clears the Profile")

registered.args.general.args.microFadeIdle.set(nil, 0.3)
assert(char.microFadeIdle == 0.3, "Micro Cluster fade idle writes Character")
assert(applied == 1, "Micro Cluster fade idle applies")
registered.args.general.args.darkness.set(nil, 0.5)
assert(char.darkness == 0.5, "Darkness writes Character")
assert(applied == 2, "Darkness applies")
registered.args.general.args.useShadowUIMinimap.set(nil, false)
assert(char.useShadowUIMinimap == false, "ShadowUI minimap toggle writes Character")
assert(applied == 3, "ShadowUI minimap toggle applies")

print("options_bars_spec OK")

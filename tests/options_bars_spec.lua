-- Options panel exposes an on/off toggle for each Bar.
-- The toggle writes enabled on the selected Layer and applies Layout.
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
    return { Open = function() end, Close = function() end }
  end
end

local layout = {
  bar1 = { enabled = true },
  bar2 = { enabled = false },
  bar9 = { enabled = false },
  pet = { enabled = true },
  possess = { enabled = true },
  stance = { enabled = true },
  player = { x = 0 },
}
local char = { editLayer = "class" }
local writes = {}
local applied = 0

function Addon:ResolveEffective()
  return { layout = layout }
end
function Addon:GetCharDB()
  return char
end
function Addon:WriteLayerDelta(layer, section, key, patch)
  writes[#writes + 1] = { layer = layer, section = section, key = key, patch = patch }
end
function Addon:ApplyAll()
  applied = applied + 1
end
function Addon:GetDB()
  return { classes = { MAGE = { variants = {} } } }
end
function Addon:GetPlayerClass()
  return "MAGE"
end
function Addon:GetActiveVariantName() end
function Addon:SetVariant() end
function Addon:CreateVariant() end
function Addon:RenameVariant() end
function Addon:DeleteVariant() end
function Addon:SetEditLayer() end
function Addon:ToggleEditMode() end
function Addon:ToggleKeybindMode() end
function Addon:SetActionSlotHardLock() end

assert(loadfile(root .. "options/config.lua"))()
Addon:OpenOptions()

local bars = registered.args.bars
assert(bars and bars.type == "group", "options has an Action bars group")
assert(bars.args.bar1.type == "toggle", "Bar 1 is an on/off toggle")
assert(bars.args.bar1.name == "Bar 1", "standard Bar uses Bar N name")
assert(bars.args.pet.name == "Pet", "special Bar uses a title name")
assert(bars.args.bar1.get() == true, "enabled Bar toggle is on")
assert(bars.args.bar2.get() == false, "disabled Bar toggle is off")
assert(bars.args.stance.hidden() == false, "class Bar in Layout stays shown")
assert(bars.args.form.hidden() == true, "class Bar missing from Layout stays hidden")
assert(bars.args.player == nil, "Player Frame is not a Bar toggle")

bars.args.bar9.set(nil, true)
assert(#writes == 1, "toggle writes one Layer delta")
assert(writes[1].layer == "class", "toggle writes the selected Layer")
assert(writes[1].section == "layout", "toggle writes Layout")
assert(writes[1].key == "bar9", "toggle writes the Bar id")
assert(writes[1].patch.enabled == true, "on writes enabled true")
assert(applied == 1, "toggle applies Layout")

bars.args.bar1.set(nil, false)
assert(writes[2].patch.enabled == false, "off writes enabled false")

print("options_bars_spec OK")

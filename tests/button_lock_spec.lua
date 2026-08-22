-- Action buttons stay locked. Click uses the Action Slot. Shift-drag
-- (PICKUPACTION) moves a spell or item. Hard lock blocks that move.
-- Run: lua tests/button_lock_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return {
    GetAddon = function() return Addon end,
    RegisterCallback = function() end,
  }
end
_G.InCombatLockdown = function() return false end

assert(loadfile(root .. "bars/button.lua"))()

local char = { hardLockActionSlots = false }
function Addon:GetCharDB()
  return char
end

local function fakeButton()
  local button = { attrs = {}, clicks = {} }
  function button:SetAttribute(key, value)
    self.attrs[key] = value
  end
  function button:RegisterForClicks(...)
    self.clicks = { ... }
  end
  function button:DisableDragNDrop(flag)
    self:SetAttribute("LABdisableDragNDrop", flag and true or nil)
  end
  return button
end

local button = fakeButton()
Addon:LockBarButton(button)
assert(button.attrs.buttonlock == true, "Action Slot stays locked so a click uses the action")
assert(button.attrs.useOnKeyDown == true, "Keybind fires the action on key down")
assert(button.clicks[1] == "AnyDown", "mouse click fires the action on down")
assert(not button.attrs.LABdisableDragNDrop, "Shift-drag still moves a spell or item")

char.hardLockActionSlots = true
Addon.bars = { bar1 = { buttons = { button } } }
Addon:ApplyActionSlotLock()
assert(button.attrs.buttonlock == true, "hard lock still uses the action on click")
assert(button.attrs.LABdisableDragNDrop == true, "hard lock blocks Shift-drag")

char.hardLockActionSlots = false
Addon:SetActionSlotHardLock(true)
assert(char.hardLockActionSlots == true, "option writes character hard lock")
assert(button.attrs.LABdisableDragNDrop == true, "option apply blocks drag")

local dbSrc = assert(io.open(root .. "core/db.lua", "r")):read("*a")
assert(dbSrc:find("hardLockActionSlots%s*=%s*false"), "character default is not hard locked")

local buttonSrc = assert(io.open(root .. "bars/button.lua", "r")):read("*a")
assert(buttonSrc:find("LockBarButton%(button%)"), "create path locks each button")
assert(buttonSrc:find('SetAttribute%("buttonlock"'), "LAB buttonlock blocks drag without PICKUPACTION")
assert(buttonSrc:find('SetAttribute%("useOnKeyDown"'), "LAB useOnKeyDown fires the action on key down")
assert(buttonSrc:find("RegisterForClicks"), "create lock registers click down")

local configSrc = assert(io.open(root .. "options/config.lua", "r")):read("*a")
assert(configSrc:find("hardLockActionSlots"), "/shadowui exposes hard lock")
assert(configSrc:find("SetActionSlotHardLock"), "options toggle applies lock")
assert(configSrc:find("ToggleEditMode"), "/shadowui can open Layout Edit Mode")
assert(configSrc:find("ToggleKeybindMode"), "/shadowui can open Keybind Edit Mode")

local managerSrc = assert(io.open(root .. "bars/manager.lua", "r")):read("*a")
assert(managerSrc:find("ApplyActionSlotLock"), "ApplyBars refreshes Action Slot lock")

print("button_lock_spec OK")

-- Layout Edit Mode and Keybind Edit Mode are mutually exclusive.
-- Run: lua tests/edit_session_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "edit/mode.lua"))()
assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "core/keybinds.lua"))()

_G.InCombatLockdown = function() return false end

local account = {
  base = { layout = {}, keybinds = {} },
  classes = {
    MAGE = { layout = {}, keybinds = {}, variants = { Default = { layout = {}, keybinds = {} } } },
  },
}
local char = { editLayer = "class", activeVariant = "Default", variantManual = true }
function Addon:GetDB() return account end
function Addon:GetCharDB() return char end
function Addon:GetPlayerClass() return "MAGE" end
function Addon:GetActiveVariantName() return "Default" end
function Addon:ApplyAll() self.applied = (self.applied or 0) + 1 end
function Addon:ApplyKeybinds() self.keybindsApplied = (self.keybindsApplied or 0) + 1 end
function Addon:ResolveEffective()
  return { layout = {}, keybinds = account.classes.MAGE.keybinds }
end
function Addon:CollectClientActionBinds()
  return { ACTIONBUTTON1 = "1" }
end
Addon.applied = 0
Addon.keybindsApplied = 0

Addon:SetEditSession("layout")
assert(Addon.editMode == true, "layout session enables bar drag")
Addon.ApplyEditSession = function() end
Addon:ToggleEditMode()
assert(Addon.editSession == nil, "toggle must leave Layout Edit Mode")
Addon:ToggleEditMode()
assert(Addon.editSession == "layout", "toggle must enter Layout Edit Mode")
Addon:SetEditSession("layout")
assert(Addon.keybindMode == false, "layout session is not keybind mode")
assert(Addon:SetEditSession("keybinds") == "keybinds", "keybind session replaces layout")
assert(Addon.editMode == false, "keybind session disables bar drag")
assert(Addon.keybindMode == true, "keybind session enables hover-bind")
assert(Addon:SetEditSession(nil) == nil, "nil ends the session")
assert(Addon.editMode == false and Addon.keybindMode == false, "no session means play mode")
assert(Addon:SetEditSession("frames") == nil, "unknown session is play mode")

local button = {
  GetName = function() return "ShadowUIActionButton61" end,
}
Addon:SetEditSession("keybinds")
assert(Addon:BindButtonKey(button, "1") == true, "bind writes while in keybind session")
assert(account.classes.MAGE.keybinds["CLICK ShadowUIActionButton61:Keybind"] == "1", "bind lands on the edit Layer")
assert(account.classes.MAGE.keybinds.ACTIONBUTTON1 == false, "the same key is freed from other names")
assert(Addon.keybindsApplied >= 1, "bind reapplies overrides")

assert(Addon:ClearButtonBinds(button) == true, "escape clears the button")
assert(account.classes.MAGE.keybinds["CLICK ShadowUIActionButton61:Keybind"] == false, "clear writes a tombstone")

Addon:PersistBarPosition({ barId = "bar1", GetPoint = function() return "CENTER", nil, "CENTER", 10, 20 end })
assert(account.classes.MAGE.layout.bar1 == nil, "layout persist ignores keybind session")

Addon:SetEditSession("layout")
local persisted = {
  barId = "bar1",
  left = 36,
  bottom = 72,
  GetLeft = function(self) return self.left end,
  GetBottom = function(self) return self.bottom end,
  ClearAllPoints = function(self) self.points = {} end,
  SetPoint = function(self, point, _, _, x, y)
    self.anchor = point
    self.left, self.bottom = x, y
  end,
}
Addon:PersistBarPosition(persisted)
assert(account.classes.MAGE.layout.bar1.point == "BOTTOMLEFT", "persist stores the grid origin")
assert(account.classes.MAGE.layout.bar1.x == 32.4, "layout persist snaps to the 32.4 grid")
assert(account.classes.MAGE.layout.bar1.y == 64.8, "layout persist snaps y")

local shiftHeld = false
_G.IsShiftKeyDown = function() return shiftHeld end
shiftHeld = true
persisted.left, persisted.bottom = 100, 50
Addon:PersistBarPosition(persisted)
assert(account.classes.MAGE.layout.bar1.x == 100, "Shift persist keeps x off the snap grid")
assert(account.classes.MAGE.layout.bar1.y == 50, "Shift persist keeps y off the snap grid")

print("edit_session_spec OK")

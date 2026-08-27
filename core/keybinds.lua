--[[
  Purpose: Apply profile keybinds as overrides onto ShadowUI LAB buttons.
  Deps: ShadowUI addon table; PLAYER_REGEN_ENABLED wired in init.lua
  Notes: MergeBindingTables — profile wins by key and by Action Slot.
  Public: SlotFromBindingName, MergeBindingTables, CanonicalBindName,
          NormalizeBindingKey, BindButtonKey, ClearButtonBinds,
          CollectClientActionBinds, ApplyKeybinds, FlushPendingKeybinds
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

-- Blizzard extra-bar slot bases (Classic): BL, BR, Right, Left.
local MULTI_BAR_FIRST_SLOT = { 61, 49, 25, 37 }

function Addon:SlotFromBindingName(name)
  if type(name) ~= "string" then
    return nil
  end
  local slot = name:match("^CLICK BT4Button(%d+):")
    or name:match("^CLICK ShadowUIActionButton(%d+):")
    or name:match("^ACTIONBUTTON(%d+)$")
  if slot then
    return tonumber(slot)
  end
  local bar, button = name:match("^MULTIACTIONBAR(%d+)BUTTON(%d+)$")
  local first = bar and MULTI_BAR_FIRST_SLOT[tonumber(bar)]
  if first and button then
    return first + tonumber(button) - 1
  end
  return nil
end

function Addon:ShortHotkey(key)
  if type(key) ~= "string" then
    return key
  end
  return (key:gsub("SHIFT%-", "S-"):gsub("CTRL%-", "C-"):gsub("ALT%-", "A-")
    :gsub("BUTTON3", "M3"):gsub("BUTTON4", "M4"):gsub("BUTTON5", "M5"))
end

function Addon:MergeBindingTables(client, profile)
  local out = {}
  local byKey = {}
  local bySlot = {}

  local function dropName(name)
    local key = name and out[name]
    if not name or key == nil then
      return
    end
    out[name] = nil
    if byKey[key] == name then
      byKey[key] = nil
    end
    local slot = self:SlotFromBindingName(name)
    if slot and bySlot[slot] == name then
      bySlot[slot] = nil
    end
  end

  local function set(name, key)
    dropName(name)
    local priorKey = byKey[key]
    if priorKey then
      dropName(priorKey)
    end
    local slot = self:SlotFromBindingName(name)
    if slot then
      local priorSlot = bySlot[slot]
      if priorSlot then
        dropName(priorSlot)
      end
      bySlot[slot] = name
    end
    byKey[key] = name
    out[name] = key
  end

  for name, key in pairs(client or {}) do
    if key and key ~= "" then
      set(name, key)
    end
  end
  for name, key in pairs(profile or {}) do
    if key == false or key == "" then
      dropName(name)
    elseif key then
      set(name, key)
    end
  end
  return out
end

function Addon:CanonicalBindName(button)
  if type(button) == "string" then
    if button:match("^CLICK ") then
      return button
    end
    return "CLICK " .. button .. ":Keybind"
  end
  local name = button and button.GetName and button:GetName()
  if type(name) ~= "string" or name == "" then
    return nil
  end
  return "CLICK " .. name .. ":Keybind"
end

local IGNORE_KEYS = {
  UNKNOWN = true,
  LSHIFT = true,
  RSHIFT = true,
  LCTRL = true,
  RCTRL = true,
  LALT = true,
  RALT = true,
  LMETA = true,
  RMETA = true,
}

function Addon:NormalizeBindingKey(key, mods)
  if type(key) ~= "string" or IGNORE_KEYS[key] then
    return nil
  end
  if key == "ESCAPE" then
    return "ESCAPE"
  end
  mods = mods or {}
  if key == "LeftButton" or key == "RightButton" then
    if not (mods.shift or mods.ctrl or mods.alt or mods.meta) then
      return nil
    end
    key = key == "LeftButton" and "BUTTON1" or "BUTTON2"
  elseif key == "MiddleButton" then
    key = "BUTTON3"
  elseif key:match("^Button%d+$") then
    key = key:upper()
  end
  if mods.shift then
    key = "SHIFT-" .. key
  end
  if mods.ctrl then
    key = "CTRL-" .. key
  end
  if mods.alt then
    key = "ALT-" .. key
  end
  if mods.meta then
    key = "META-" .. key
  end
  return key
end

function Addon:BindingSlotFromButton(button)
  if not button then
    return nil
  end
  local name = button.GetName and button:GetName()
  if type(name) == "string" then
    local slot = tonumber(name:match("ShadowUIActionButton(%d+)"))
    if slot then
      return slot
    end
  end
  local slot = button._state_action
  if type(slot) == "number" then
    return slot
  end
  return nil
end

function Addon:FreeKeyOnLayer(layer, key, keepName)
  if not key or key == "" then
    return
  end
  local merged = self:MergeBindingTables(
    self:CollectClientActionBinds(),
    (self:ResolveEffective() or {}).keybinds
  )
  for name, bound in pairs(merged) do
    if bound == key and name ~= keepName then
      self:WriteLayerDelta(layer, "keybinds", name, false)
    end
  end
end

function Addon:BindButtonKey(button, key)
  if not self.keybindMode or InCombatLockdown() then
    return false
  end
  local name = self:CanonicalBindName(button)
  if not name or type(key) ~= "string" or key == "" or key == "ESCAPE" then
    return false
  end
  local layer = self:GetCharDB().editLayer
  self:FreeKeyOnLayer(layer, key, name)
  self:WriteLayerDelta(layer, "keybinds", name, key)
  self:ApplyKeybinds(self:ResolveEffective())
  return true
end

function Addon:ClearButtonBinds(button)
  if not self.keybindMode or InCombatLockdown() then
    return false
  end
  local name = self:CanonicalBindName(button)
  if not name then
    return false
  end
  self:WriteLayerDelta(self:GetCharDB().editLayer, "keybinds", name, false)
  self:ApplyKeybinds(self:ResolveEffective())
  return true
end

function Addon:HotkeysBySlot(binds)
  local slots = {}
  for name, key in pairs(binds or {}) do
    local slot = self:SlotFromBindingName(name)
    if slot then
      slots[slot] = self:ShortHotkey(key)
    end
  end
  return slots
end

function Addon:CollectClientActionBinds()
  local out = {}
  if type(GetBindingKey) ~= "function" then
    return out
  end
  local function take(name)
    local key = GetBindingKey(name)
    if key and key ~= "" then
      out[name] = key
    end
  end
  for i = 1, 12 do
    take("ACTIONBUTTON" .. i)
  end
  for bar = 1, 4 do
    for i = 1, 12 do
      take("MULTIACTIONBAR" .. bar .. "BUTTON" .. i)
    end
  end
  for i = 1, 120 do
    take("CLICK BT4Button" .. i .. ":Keybind")
    take("CLICK BT4Button" .. i .. ":LeftButton")
  end
  return out
end

local function ownerFrame(addon)
  if not addon.keybindOwner then
    addon.keybindOwner = CreateFrame("Frame")
  end
  return addon.keybindOwner
end

function Addon:PaintButtonHotkeys(binds)
  local bySlot = self:HotkeysBySlot(binds)
  local byName = binds or {}
  for _, bar in pairs(self.bars or {}) do
    for _, button in ipairs(bar.buttons or {}) do
      local slot = self:BindingSlotFromButton(button)
      local name = self:CanonicalBindName(button)
      button.shadowUIHotkey = (slot and bySlot[slot])
        or (name and byName[name] and self:ShortHotkey(byName[name]))
        or nil
      local hotkey = button.HotKey
      if hotkey then
        if button.shadowUIHotkey then
          hotkey:SetText(button.shadowUIHotkey)
        else
          hotkey:SetText("")
        end
        local filled = not button.HasAction or button:HasAction()
        if button.shadowUIHotkey and (filled or self.keybindMode) then
          hotkey:Show()
        elseif hotkey.Hide then
          hotkey:Hide()
        end
      end
      if self.PaintEmptySlotVisibility then
        self:PaintEmptySlotVisibility(button)
      end
    end
  end
end

function Addon:ApplyKeybinds(cfg)
  self._pendingKeybinds = cfg.keybinds or {}
  if InCombatLockdown() then
    return
  end
  self:FlushPendingKeybinds()
end

function Addon:FlushPendingKeybinds()
  local pending = self._pendingKeybinds
  if not pending or InCombatLockdown() then
    return
  end
  local binds = self:MergeBindingTables(self:CollectClientActionBinds(), pending)
  local owner = ownerFrame(self)
  ClearOverrideBindings(owner)
  for name, key in pairs(binds) do
    if key and key ~= "" then
      local slot = self:SlotFromBindingName(name)
      if slot then
        SetOverrideBindingClick(
          owner, true, key, "ShadowUIActionButton" .. slot, "Keybind"
        )
      else
        SetOverrideBinding(owner, true, key, name)
      end
    end
  end
  self:PaintButtonHotkeys(binds)
  self._pendingKeybinds = nil
end

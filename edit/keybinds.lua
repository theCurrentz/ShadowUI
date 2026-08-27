--[[
  Purpose: Bartender-style Keybind Edit Mode: hover a button, press a key.
  Deps: ShadowUI:BindButtonKey(), ShadowUI:ClearButtonBinds(), layer picker
  Public: ShadowUI:ApplyKeybindSession(), ShadowUI:SetKeybindTarget()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local function modifiers()
  return {
    shift = IsShiftKeyDown and IsShiftKeyDown(),
    ctrl = IsControlKeyDown and IsControlKeyDown(),
    alt = IsAltKeyDown and IsAltKeyDown(),
    meta = IsMetaKeyDown and IsMetaKeyDown(),
  }
end

function Addon:HookButtonForKeybinds(button)
  if not button or button.shadowUIKeybindHooked then
    return
  end
  button.shadowUIKeybindHooked = true
  if button.HookScript then
    button:HookScript("OnEnter", function(self)
      Addon:SetKeybindTarget(self)
    end)
  end
end

function Addon:HookBarsForKeybinds()
  for _, bar in pairs(self.bars or {}) do
    for _, button in ipairs(bar.buttons or {}) do
      self:HookButtonForKeybinds(button)
    end
  end
end

function Addon:CreateKeybindHelp()
  local help = CreateFrame("Frame", "ShadowUIKeybindHelp", UIParent, "BackdropTemplate")
  help:SetSize(420, 52)
  help:SetPoint("TOP", UIParent, "TOP", 0, -148)
  help:SetFrameStrata("DIALOG")
  help:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  help:SetBackdropColor(0.02, 0.02, 0.02, 0.92)
  local text = help:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  text:SetPoint("LEFT", 10, 0)
  text:SetPoint("RIGHT", -10, 0)
  text:SetJustifyH("CENTER")
  text:SetText("Hover a button, then press a key. Escape clears. Writes go to the selected Layer.")
  help:Hide()
  self.keybindHelp = help
  return help
end

function Addon:CreateKeybindBinder()
  local binder = CreateFrame("Button", "ShadowUIKeybindBinder", UIParent)
  binder:SetFrameStrata("DIALOG")
  binder:SetToplevel(true)
  binder:EnableMouse(true)
  binder:EnableKeyboard(true)
  binder:EnableMouseWheel(true)
  binder:RegisterForClicks("AnyUp")
  local fill = binder:CreateTexture(nil, "BACKGROUND")
  fill:SetAllPoints(binder)
  fill:SetColorTexture(0, 1, 1, 0.35)
  local label = binder:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  label:SetAllPoints(binder)
  label:SetTextColor(0, 1, 0)
  binder.label = label

  local function capture(_, key)
    Addon:CaptureKeybind(key)
  end
  binder:SetScript("OnKeyDown", capture)
  binder:SetScript("OnClick", function(_, mouse)
    Addon:CaptureKeybind(mouse)
  end)
  binder:SetScript("OnMouseWheel", function(_, delta)
    Addon:CaptureKeybind(delta and delta > 0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN")
  end)
  binder:SetScript("OnLeave", function()
    Addon:SetKeybindTarget(nil)
  end)
  binder:Hide()
  self.keybindBinder = binder
  return binder
end

function Addon:SetKeybindTarget(button)
  if not self.keybindMode or not button or InCombatLockdown() then
    if self.keybindBinder then
      self.keybindBinder.button = nil
      self.keybindBinder:Hide()
    end
    return
  end
  local binder = self.keybindBinder or self:CreateKeybindBinder()
  binder.button = button
  binder:SetAllPoints(button)
  local hotkey = button.shadowUIHotkey or (button.GetHotkey and button:GetHotkey()) or ""
  binder.label:SetText(hotkey)
  binder:Show()
  if binder.SetPropagateKeyboardInput then
    binder:SetPropagateKeyboardInput(false)
  end
end

function Addon:CaptureKeybind(key)
  local binder = self.keybindBinder
  local button = binder and binder.button
  if not button or not self.keybindMode then
    return
  end
  local normalized = self:NormalizeBindingKey(key, modifiers())
  if not normalized then
    return
  end
  if type(GetBindingKey) == "function" then
    if GetBindingKey("SCREENSHOT") == key then
      if Screenshot then
        Screenshot()
      end
      return
    end
    if GetBindingKey("OPENCHAT") == key then
      if ChatFrame_OpenChat then
        ChatFrame_OpenChat("")
      end
      return
    end
  end
  if normalized == "ESCAPE" then
    self:ClearButtonBinds(button)
  else
    self:BindButtonKey(button, normalized)
  end
  self:SetKeybindTarget(button)
end

function Addon:ApplyKeybindSession()
  local help = self.keybindHelp or self:CreateKeybindHelp()
  help:SetShown(self.keybindMode == true)
  if self.keybindMode then
    self:HookBarsForKeybinds()
    self:Print("Keybind Edit Mode: hover a button, then press a key.")
  else
    self:SetKeybindTarget(nil)
  end
  if self.PaintEmptySlotVisibility then
    for _, bar in pairs(self.bars or {}) do
      for _, button in ipairs(bar.buttons or {}) do
        self:PaintEmptySlotVisibility(button)
      end
    end
  end
end

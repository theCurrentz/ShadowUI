--[[
  Purpose: Create LibActionButton action buttons with Action Slot Lock and Lorti-dark icon chrome.
  Deps: ShadowUI addon table, LibActionButton-1.0
  Public: ShadowUI:CreateBarButton(parent, id, actionSlot), ShadowUI:SkinBarButton(),
          ShadowUI:LockBarButton(), ShadowUI:ApplyActionSlotLock(),
          ShadowUI:SetActionSlotHardLock(), ShadowUI:SkinCooldownCount()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local LAB = LibStub("LibActionButton-1.0")
-- Crop rounded icon art. 0.07 keeps the square fill without over-zoom.
local CROP = 0.07
local INSET = 2
local HOVER_ALPHA = 0.22
local PRESS_ALPHA = 0.45

function Addon:SkinCooldownCount(button) end

local CONFIG = {
  outOfRangeColoring = "button",
  showGrid = true,
  colors = {
    range = { 0.8, 0.1, 0.1 },
    mana = { 0.5, 0.5, 1 },
  },
  hideElements = {
    border = true,
    borderIfEmpty = true,
    equipped = true,
    macro = true,
  },
  masqueSkinned = true,
}

local function strip(texture)
  if not texture then
    return
  end
  pcall(texture.SetTexture, texture, "")
  texture:SetAlpha(0)
  texture:Hide()
end

local function flatten(button, texture, r, g, b, a, blend)
  if not texture then
    return
  end
  texture:SetTexture("Interface\\Buttons\\WHITE8X8")
  texture:SetVertexColor(r, g, b, a)
  texture:SetBlendMode(blend or "ADD")
  texture:ClearAllPoints()
  texture:SetAllPoints(button)
  texture:SetAlpha(a)
end

local function inset(region)
  if not region then
    return
  end
  region:ClearAllPoints()
  region:SetPoint("TOPLEFT", INSET, -INSET)
  region:SetPoint("BOTTOMRIGHT", -INSET, INSET)
end

local function skinCooldown(button)
  local cooldown = button.cooldown
  if not cooldown or button.shadowUICooldownSkinned then
    return
  end
  button.shadowUICooldownSkinned = true
  inset(cooldown)
  if cooldown.SetDrawSwipe then
    cooldown:SetDrawSwipe(true)
  end
  if cooldown.SetSwipeColor then
    cooldown:SetSwipeColor(0, 0, 0, 0.8)
  end
  if cooldown.SetDrawEdge then
    cooldown:SetDrawEdge(true)
  end
  if cooldown.SetDrawBling then
    cooldown:SetDrawBling(true)
  end
  if button.GetFrameLevel and cooldown.SetFrameLevel then
    cooldown:SetFrameLevel(button:GetFrameLevel() + 1)
  end
end

local function paintChrome(button)
  local chrome = button.shadowUIChrome
  if not chrome and button.CreateTexture then
    chrome = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    button.shadowUIChrome = chrome
  end
  if not chrome then
    return
  end
  chrome:ClearAllPoints()
  chrome:SetAllPoints(button)
  chrome:SetColorTexture(0.05, 0.05, 0.05, 1)
  chrome:Show()
end

function Addon:SkinBarButton(button)
  paintChrome(button)
  self:ApplyOuterChrome(button)
  strip(button.NormalTexture or (button.GetNormalTexture and button:GetNormalTexture()))
  strip(button.Border)
  strip(button.SlotBackground)
  strip(button.Flash)
  strip(button.FloatingBG)
  strip(button.IconBorder)
  flatten(button, button.CheckedTexture or (button.GetCheckedTexture and button:GetCheckedTexture()), 1, 0.82, 0.25, 0.22)
  local hover = button.HighlightTexture or (button.GetHighlightTexture and button:GetHighlightTexture())
  local pressed = button.PushedTexture or (button.GetPushedTexture and button:GetPushedTexture())
  flatten(button, hover, 0, 0, 0, HOVER_ALPHA, "BLEND")
  flatten(button, pressed, 0, 0, 0, PRESS_ALPHA, "BLEND")
  inset(hover)
  inset(pressed)

  local icon = button.icon or button.Icon
  if not icon and button.GetName then
    icon = _G[button:GetName() .. "Icon"]
    button.icon = icon
  end
  if icon then
    if button.IconMask then
      if icon.RemoveMaskTexture then
        icon:RemoveMaskTexture(button.IconMask)
      end
      button.IconMask:Hide()
    end
    inset(icon)
    icon:SetTexCoord(CROP, 1 - CROP, CROP, 1 - CROP)
    if icon.SetDrawLayer then
      icon:SetDrawLayer("ARTWORK", 0)
    end
  end
  skinCooldown(button)
  self:SkinCooldownCount(button)
  -- SetHitRectInsets is protected on action buttons. LAB OnButtonUpdate
  -- runs on ACTIONBAR_SLOT_CHANGED in combat.
  if not InCombatLockdown() and button.SetHitRectInsets then
    button:SetHitRectInsets(0, 0, 0, 0)
  end
end

if LAB.RegisterCallback then
  LAB.RegisterCallback("ShadowUI", "OnButtonUpdate", function(_, button)
    Addon:SkinBarButton(button)
  end)
end

function Addon:LockBarButton(button)
  if not button then
    return
  end
  -- buttonlock: click uses the action. Drag needs IsModifiedClick("PICKUPACTION")
  -- (Shift by default) and must not fire the action.
  button:SetAttribute("buttonlock", true)
  button:SetAttribute("useOnKeyDown", true)
  -- AnyDown+AnyUp would use the action twice on Classic. Prefer down only.
  if not pcall(button.RegisterForClicks, button, "AnyDown") then
    button:RegisterForClicks("AnyUp")
  end
  local char = self.GetCharDB and self:GetCharDB()
  local hard = char and char.hardLockActionSlots == true
  if button.DisableDragNDrop then
    button:DisableDragNDrop(hard)
  else
    button:SetAttribute("LABdisableDragNDrop", hard or nil)
  end
end

function Addon:ApplyActionSlotLock()
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  for _, bar in pairs(self.bars or {}) do
    for _, button in ipairs(bar.buttons or {}) do
      self:LockBarButton(button)
    end
  end
end

function Addon:SetActionSlotHardLock(locked)
  local char = self:GetCharDB()
  char.hardLockActionSlots = locked and true or false
  self:ApplyActionSlotLock()
end

function Addon:CreateBarButton(parent, id, actionSlot)
  local name = "ShadowUIActionButton" .. id
  local button = LAB:CreateButton(id, name, parent, CONFIG)
  button.MasqueSkinned = true
  self:SkinBarButton(button)
  button:SetState(0, "action", actionSlot)
  self:LockBarButton(button)
  if self.HookButtonForKeybinds then
    self:HookButtonForKeybinds(button)
  end
  return button
end

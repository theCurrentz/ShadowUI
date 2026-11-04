--[[
  Purpose: Apply Lorti icon chrome and a circle Outer Edge to the Blizzard
           Extra Action Button. Keep Blizzard place. Do not hide ExtraActionBarFrame.
  Deps: ShadowUI:ApplyOuterChrome(), ShadowUI:ApplyIconShape()
  Public: ShadowUI:SkinExtraActionButton(), ShadowUI:SkinExtraActionBar()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local CROP = 0.07
local INSET = 2
local BUTTONS = { "ExtraActionButton1", "ExtraActionButton2" }
local STYLE = { "ExtraActionButtonStyle", "ExtraActionButtonStyleTexture" }

local function strip(texture)
  if not texture then
    return
  end
  pcall(texture.SetTexture, texture, "")
end

local function inset(region)
  if not region then
    return
  end
  region:ClearAllPoints()
  region:SetPoint("TOPLEFT", INSET, -INSET)
  region:SetPoint("BOTTOMRIGHT", -INSET, INSET)
end

local function extraIcon(button, name)
  return button.icon or button.Icon or (name and _G[name .. "Icon"])
end

local function hideChrome(button)
  if button.shadowUIChrome and button.shadowUIChrome.Hide then
    button.shadowUIChrome:Hide()
  end
  if button.shadowUIOuter and button.shadowUIOuter.Hide then
    button.shadowUIOuter:Hide()
  end
end

local function hasTexture(icon)
  if not icon or not icon.GetTexture then
    return false
  end
  local tex = icon:GetTexture()
  if tex == nil then
    return false
  end
  if issecretvalue and issecretvalue(tex) then
    return true
  end
  return tex ~= "" and tex ~= 0
end

local function extraIsActive(button, name)
  if button.IsShown and not button:IsShown() then
    return false
  end
  return hasTexture(extraIcon(button, name))
end

local function placeOuter(button, outer)
  if not outer then
    return
  end
  local parent = button.GetParent and button:GetParent()
  if parent and outer.SetParent then
    outer:SetParent(parent)
  end
  if button.GetFrameLevel and outer.SetFrameLevel then
    local level = button:GetFrameLevel()
    if level > 0 then
      outer:SetFrameLevel(level - 1)
    end
  end
  Addon:PaintOuterChrome(outer)
end

function Addon:SkinExtraActionButton(button)
  if not button then
    return
  end
  local name = button.GetName and button:GetName()
  if not extraIsActive(button, name) then
    hideChrome(button)
    return
  end
  local chrome = button.shadowUIChrome
  if not chrome and button.CreateTexture then
    chrome = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    button.shadowUIChrome = chrome
  end
  if chrome then
    chrome:ClearAllPoints()
    chrome:SetAllPoints(button)
    local black = self.DARKEN_BLACK or { 0.05, 0.05, 0.05 }
    chrome:SetColorTexture(black[1], black[2], black[3], 1)
    chrome:Show()
  end
  placeOuter(button, self:ApplyOuterChrome(button, "circle"))
  if button.shadowUIOuter and button.shadowUIOuter.Show then
    button.shadowUIOuter:Show()
  end
  strip(button.NormalTexture or (button.GetNormalTexture and button:GetNormalTexture()))
  strip(button.style or button.Style)
  local icon = extraIcon(button, name)
  if icon then
    -- Blizzard Update reads button.icon. Writing it taints that code.
    if button.icon == nil then
      button.icon = icon
    end
    inset(icon)
    if icon.SetTexCoord then
      icon:SetTexCoord(CROP, 1 - CROP, CROP, 1 - CROP)
    end
    if icon.SetDrawLayer then
      icon:SetDrawLayer("ARTWORK", 0)
    end
  end
  if self.ApplyIconShape then
    self:ApplyIconShape(button, "circle")
  end
end

function Addon:SkinExtraActionBar()
  if self.RegisterEvent and not self._extraActionEvents then
    self._extraActionEvents = true
    pcall(self.RegisterEvent, self, "UPDATE_EXTRA_ACTIONBAR", "SkinExtraActionBar")
  end
  for _, name in ipairs(STYLE) do
    strip(_G[name])
  end
  for _, name in ipairs(BUTTONS) do
    self:SkinExtraActionButton(_G[name])
  end
end

local function restyle()
  Addon:SkinExtraActionBar()
end

if hooksecurefunc then
  if ExtraActionBar_Update then
    hooksecurefunc("ExtraActionBar_Update", restyle)
  end
  if ExtraActionButton_Update then
    hooksecurefunc("ExtraActionButton_Update", restyle)
  end
end

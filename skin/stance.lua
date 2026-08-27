--[[
  Purpose: Apply Lorti icon chrome and Outer Edge to Blizzard Stance Bar
           buttons. Unused shapeshift slots stay empty. ShadowUI does not
           replace StanceBarFrame / ShapeshiftBarFrame.
  Deps: ShadowUI:ApplyOuterChrome()
  Public: ShadowUI:SkinStanceButton(), ShadowUI:SkinStanceBar()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local CROP = 0.07
local INSET = 2
local LAST = 10
local PREFIXES = { "StanceButton", "ShapeshiftButton" }
local ART = {
  "StanceBarLeft", "StanceBarMiddle", "StanceBarRight",
  "ShapeshiftBarLeft", "ShapeshiftBarMiddle", "ShapeshiftBarRight",
}
local BARS = { "StanceBarFrame", "ShapeshiftBarFrame" }

local function strip(texture)
  if not texture then
    return
  end
  pcall(texture.SetTexture, texture, "")
  if texture.SetAlpha then
    texture:SetAlpha(0)
  end
  if texture.Hide then
    texture:Hide()
  end
end

local function inset(region)
  if not region then
    return
  end
  region:ClearAllPoints()
  region:SetPoint("TOPLEFT", INSET, -INSET)
  region:SetPoint("BOTTOMRIGHT", -INSET, INSET)
end

local function stanceIcon(button, name)
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

local function stanceIsActive(button, name)
  if button.IsShown and not button:IsShown() then
    return false
  end
  local icon = stanceIcon(button, name)
  if not icon then
    return false
  end
  local tex = icon.GetTexture and icon:GetTexture()
  if not tex or tex == "" or tex == 0 then
    return false
  end
  return true
end

local function placeOuter(button, outer)
  if not outer then
    return
  end
  local parent = button.GetParent and button:GetParent()
  if parent and outer.SetParent then
    outer:SetParent(parent)
  end
  if button.SetClipsChildren then
    button:SetClipsChildren(false)
  end
  if button.GetFrameLevel and outer.SetFrameLevel then
    local level = button:GetFrameLevel()
    if level > 0 then
      outer:SetFrameLevel(level - 1)
    end
  end
  Addon:PaintOuterChrome(outer)
end

function Addon:SkinStanceButton(button)
  if not button then
    return
  end
  local name = button.GetName and button:GetName()
  if not stanceIsActive(button, name) then
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
    chrome:SetColorTexture(0.05, 0.05, 0.05, 1)
    chrome:Show()
  end
  placeOuter(button, self:ApplyOuterChrome(button))
  if button.shadowUIOuter and button.shadowUIOuter.Show then
    button.shadowUIOuter:Show()
  end
  strip(button.NormalTexture or (button.GetNormalTexture and button:GetNormalTexture()))
  local icon = stanceIcon(button, name)
  if icon then
    button.icon = icon
    inset(icon)
    if icon.SetTexCoord then
      icon:SetTexCoord(CROP, 1 - CROP, CROP, 1 - CROP)
    end
    if icon.SetDrawLayer then
      icon:SetDrawLayer("ARTWORK", 0)
    end
  end
end

function Addon:SkinStanceBar()
  for _, name in ipairs(ART) do
    strip(_G[name])
  end
  for _, name in ipairs(BARS) do
    local bar = _G[name]
    if bar and bar.SetClipsChildren then
      bar:SetClipsChildren(false)
    end
  end
  local seen = {}
  for _, prefix in ipairs(PREFIXES) do
    for i = 1, LAST do
      local button = _G[prefix .. i]
      if button and not seen[button] then
        seen[button] = true
        self:SkinStanceButton(button)
      end
    end
  end
end

local function restyle()
  Addon:SkinStanceBar()
end

if hooksecurefunc then
  if ShapeshiftBar_Update then
    hooksecurefunc("ShapeshiftBar_Update", restyle)
  end
  if StanceBar_Update then
    hooksecurefunc("StanceBar_Update", restyle)
  end
  if ShapeshiftBar_UpdateState then
    hooksecurefunc("ShapeshiftBar_UpdateState", restyle)
  end
  if StanceBar_UpdateState then
    hooksecurefunc("StanceBar_UpdateState", restyle)
  end
end

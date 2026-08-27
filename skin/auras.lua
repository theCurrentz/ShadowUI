--[[
  Purpose: Darken buff and debuff icon chrome the Lorti way, including the outer edge.
  Unused slots stay empty. Player buffs sit 4px below the top of the screen
  and 4px left of the square minimap.
  Deps: ShadowUI:LockVertex(), ShadowUI:ApplyOuterChrome(), ShadowUI:ParkFrame()
  Public: ShadowUI:SkinAuraButton(), ShadowUI:SkinAuras()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:SkinAuraDuration(button) end
local INSET = 2
local OUTER_PAD = 4
local SCREEN_GAP = 4
local GROUPS = {
  { "BuffButton", 32 },
  { "DebuffButton", 16 },
  { "TempEnchant", 3 },
  { "TargetFrameBuff", 32 },
  { "TargetFrameDebuff", 16 },
  { "FocusFrameBuff", 32 },
  { "FocusFrameDebuff", 16 },
}

local function inset(region)
  if not region then
    return
  end
  region:ClearAllPoints()
  region:SetPoint("TOPLEFT", INSET, -INSET)
  region:SetPoint("BOTTOMRIGHT", -INSET, INSET)
end

local function auraIcon(button, name)
  return button.Icon or button.icon or (name and _G[name .. "Icon"])
end

local function auraBorder(button, name)
  return button.DebuffBorder or button.border or (name and _G[name .. "Border"])
end

local function isDebuff(button, name)
  if button.auraType == "Debuff" or button.auraType == "DeadlyDebuff" then
    return true
  end
  return name and name:find("Debuff")
end

local function hideAuraChrome(button)
  if button.shadowUIChrome and button.shadowUIChrome.Hide then
    button.shadowUIChrome:Hide()
  end
  if button.shadowUIOuter and button.shadowUIOuter.Hide then
    button.shadowUIOuter:Hide()
  end
end

local function auraIsActive(button, name)
  if button.isAuraAnchor then
    return false
  end
  if button.hasValidInfo == false then
    return false
  end
  if button.IsShown and not button:IsShown() then
    return false
  end
  local icon = auraIcon(button, name)
  if not icon then
    return false
  end
  local tex = icon.GetTexture and icon:GetTexture()
  if not tex or tex == "" or tex == 0 then
    return false
  end
  return true
end

function Addon:SkinAuraButton(button)
  if not button then
    return
  end
  local name = button.GetName and button:GetName()
  if not auraIsActive(button, name) then
    hideAuraChrome(button)
    return
  end
  local icon = auraIcon(button, name)
  local chrome = button.shadowUIChrome
  if not chrome and button.CreateTexture then
    chrome = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    button.shadowUIChrome = chrome
  end
  if chrome then
    chrome:ClearAllPoints()
    if icon then
      chrome:SetPoint("TOPLEFT", icon, "TOPLEFT", -INSET, INSET)
      chrome:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", INSET, -INSET)
    else
      chrome:SetAllPoints(button)
    end
    chrome:SetColorTexture(0.05, 0.05, 0.05, 1)
    chrome:Show()
  end
  self:ApplyOuterChrome(button)
  local outer = button.shadowUIOuter
  if outer then
    if outer.Show then
      outer:Show()
    end
    if icon and outer.ClearAllPoints then
      outer:ClearAllPoints()
      outer:SetPoint("TOPLEFT", icon, "TOPLEFT", -OUTER_PAD, OUTER_PAD)
      outer:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", OUTER_PAD, -OUTER_PAD)
    end
  end
  if icon then
    if not button.Icon then
      inset(icon)
    end
    if icon.SetTexCoord then
      icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    if icon.SetDrawLayer then
      icon:SetDrawLayer("ARTWORK", 0)
    end
  end
  local border = auraBorder(button, name)
  if border and not isDebuff(button, name) then
    self:LockVertex(border, self.DARKEN_BLACK)
  end
  self:SkinAuraDuration(button)
end

local function skinPool(frame)
  if not frame then
    return
  end
  if frame.AuraContainer and frame.AuraContainer.SetClipsChildren then
    frame.AuraContainer:SetClipsChildren(false)
  end
  if frame.SetClipsChildren then
    frame:SetClipsChildren(false)
  end
  for _, button in ipairs(frame.auraFrames or {}) do
    Addon:SkinAuraButton(button)
  end
end

function Addon:SkinAuras()
  local holder = _G.ShadowUIMinimapHolder
  if self.ParkFrame then
    local relative = holder or _G.UIParent
    local relativePoint = holder and "TOPLEFT" or "TOPRIGHT"
    if _G.BuffFrame then
      self:ParkFrame(_G.BuffFrame, "TOPRIGHT", -SCREEN_GAP, -SCREEN_GAP, nil, nil,
        relative, relativePoint)
    end
    if _G.DebuffFrame then
      self:ParkFrame(_G.DebuffFrame, "TOPRIGHT", -13, -5, nil, nil,
        _G.BuffFrame or relative, _G.BuffFrame and "BOTTOMRIGHT" or relativePoint)
    end
  end
  for _, group in ipairs(GROUPS) do
    local prefix, count = group[1], group[2]
    for i = 1, count do
      self:SkinAuraButton(_G[prefix .. i])
    end
  end
  for p = 1, 4 do
    for i = 1, 4 do
      self:SkinAuraButton(_G["PartyMemberFrame" .. p .. "Debuff" .. i])
    end
  end
  skinPool(_G.BuffFrame)
  skinPool(_G.DebuffFrame)
end

local function restyle()
  Addon:SkinAuras()
end

if hooksecurefunc then
  if BuffFrame_UpdateAllBuffAnchors then
    hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", restyle)
  end
  if DebuffButton_UpdateAnchors then
    hooksecurefunc("DebuffButton_UpdateAnchors", restyle)
  end
  if TargetFrame_UpdateAuras then
    hooksecurefunc("TargetFrame_UpdateAuras", restyle)
  end
  if AuraFrameMixin and AuraFrameMixin.UpdateAuraButtons then
    hooksecurefunc(AuraFrameMixin, "UpdateAuraButtons", restyle)
  end
  if AuraContainerMixin and AuraContainerMixin.UpdateGridLayout then
    hooksecurefunc(AuraContainerMixin, "UpdateGridLayout", restyle)
  end
end

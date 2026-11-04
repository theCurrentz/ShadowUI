--[[
  Purpose: Zoom player buff and debuff icons by 0.07 and hide their border.
  No Darken ring and no Outer Edge. Unused slots stay empty.
  Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place.
  Target Frame, Target of Target, Focus, and party auras stay Blizzard.
  Deps: none
  Public: ShadowUI:SkinAuraButton(), ShadowUI:SkinAuras()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local CROP = 0.07
local GROUPS = {
  { "BuffButton", 32 },
  { "DebuffButton", 16 },
  { "TempEnchant", 3 },
}

local function auraIcon(button, name)
  return button.Icon or button.icon or (name and _G[name .. "Icon"])
end

local function auraBorder(button, name)
  return button.DebuffBorder or button.border or (name and _G[name .. "Border"])
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
  return hasTexture(auraIcon(button, name))
end

local function hideBorder(border)
  if border and border.Hide then
    border:Hide()
  end
end

function Addon:SkinAuraButton(button)
  if not button then
    return
  end
  local name = button.GetName and button:GetName()
  if not auraIsActive(button, name) then
    return
  end
  local icon = auraIcon(button, name)
  if icon and icon.SetTexCoord then
    icon:SetTexCoord(CROP, 1 - CROP, CROP, 1 - CROP)
  end
  hideBorder(auraBorder(button, name))
end

local function skinPool(frame)
  if not frame then
    return
  end
  for _, button in ipairs(frame.auraFrames or {}) do
    Addon:SkinAuraButton(button)
  end
end

function Addon:SkinAuras()
  for _, group in ipairs(GROUPS) do
    local prefix, count = group[1], group[2]
    for i = 1, count do
      self:SkinAuraButton(_G[prefix .. i])
    end
  end
  skinPool(_G.BuffFrame)
  skinPool(_G.DebuffFrame)
end

local function restyle()
  Addon:SkinAuras()
end

local function restylePlayerFrame(frame)
  if frame == _G.BuffFrame or frame == _G.DebuffFrame then
    restyle()
  end
end

if hooksecurefunc then
  if BuffFrame_UpdateAllBuffAnchors then
    hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", restyle)
  end
  if DebuffButton_UpdateAnchors then
    hooksecurefunc("DebuffButton_UpdateAnchors", restyle)
  end
  if AuraFrameMixin and AuraFrameMixin.UpdateAuraButtons then
    hooksecurefunc(AuraFrameMixin, "UpdateAuraButtons", restylePlayerFrame)
  end
  if AuraContainerMixin and AuraContainerMixin.UpdateGridLayout then
    hooksecurefunc(AuraContainerMixin, "UpdateGridLayout", restylePlayerFrame)
  end
end

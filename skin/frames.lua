--[[
  Purpose: Darken unit-frame chrome the Lorti way. Player Frame and Target Frame
  stay Blizzard. Target Frame Art uses soft Darken so original chrome and the
  dragon still show. Frame Art keeps the border shadow and drops the inner
  shadow on the bar wells. CheckClassification sizes TargetFrameBackground over
  half the health slot; paintTarget hides that well. WatchBlizzardUnitEdit wraps
  FocusFrame.SetSmallSize so FocusFrame cannot stay snapped to FocusFrameToT.
  Target of Target stays on the Blizzard default BOTTOMRIGHT offset.
  Deps: ShadowUI:LockVertex(), ShadowUI:DarkenNamed(), ShadowUI:DarkenFrameRegions(),
        media/frameart border-shadow TGAs
  Public: ShadowUI:SkinUnitFrames(), ShadowUI:SkinRaidFrames(),
          ShadowUI:WatchBlizzardUnitEdit(), ShadowUI:OnEditModeLayoutsUpdated()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local BORDER_SHADOW = "Interface\\AddOns\\ShadowUI\\media\\frameart\\"

-- Blizzard bakes a shadow inside the bar wells. These files keep the border shadow only.
local BORDER_SHADOW_FILE = {
  ["interface\\targetingframe\\ui-targetingframe"] = BORDER_SHADOW .. "UI-TargetingFrame",
  ["interface\\targetingframe\\ui-targetingframe-elite"] = BORDER_SHADOW .. "UI-TargetingFrame-Elite",
  ["interface\\targetingframe\\ui-targetingframe-rare"] = BORDER_SHADOW .. "UI-TargetingFrame-Rare",
  ["interface\\targetingframe\\ui-targetingframe-rare-elite"] = BORDER_SHADOW .. "UI-TargetingFrame-Rare-Elite",
  ["interface\\targetingframe\\ui-targetingframe-minus"] = BORDER_SHADOW .. "UI-TargetingFrame-Minus",
  ["interface\\targetingframe\\ui-targetingframe-nolevel"] = BORDER_SHADOW .. "UI-TargetingFrame-NoLevel",
}

local function artKey(path)
  if type(path) ~= "string" then
    return nil
  end
  path = path:gsub("/", "\\"):lower()
  path = path:gsub("%.blp$", ""):gsub("%.tga$", "")
  return path
end

local function keepBorderShadow(region)
  if not region or not region.SetTexture then
    return
  end
  if not region._shadowUIBorderShadow and hooksecurefunc then
    region._shadowUIBorderShadow = true
    hooksecurefunc(region, "SetTexture", function(self, path)
      if self._shadowUIArtSwap then
        return
      end
      local file = BORDER_SHADOW_FILE[artKey(path)]
      if not file then
        return
      end
      self._shadowUIArtSwap = true
      self:SetTexture(file)
      self._shadowUIArtSwap = nil
    end)
  end
  if region.GetTexture then
    local file = BORDER_SHADOW_FILE[artKey(region:GetTexture())]
    if file then
      region:SetTexture(file)
    end
  end
end

local BLACK_NAMES = {
  "PlayerFrameTexture",
  "PlayerFrameVehicleTexture",
  "PlayerFrameAlternateManaBarBorder",
  "PlayerFrameAlternateManaBarLeftBorder",
  "PlayerFrameAlternateManaBarRightBorder",
  "PlayerFrameAlternatePowerBarBorder",
  "PlayerFrameAlternatePowerBarLeftBorder",
  "PlayerFrameAlternatePowerBarRightBorder",
  "PetFrameTexture",
  "TargetFrameToTTextureFrameTexture",
  "FocusFrameToTTextureFrameTexture",
  "CastingBarFrameBorder",
  "MirrorTimer1Border",
  "MirrorTimer2Border",
  "MirrorTimer3Border",
  "MinimapBorder",
  "MinimapBorderTop",
  "MiniMapMailBorder",
  "MiniMapTrackingBorder",
}

local function hideStay(region)
  if not region then
    return
  end
  if region.Hide then
    region:Hide()
  end
  if region.Show then
    region.Show = function() end
  end
end

local function darkenContainer(frame, color)
  if not frame then
    return
  end
  local container = frame.PlayerFrameContainer or frame.TargetFrameContainer
  if not container then
    return
  end
  color = color or Addon.DARKEN_BLACK
  Addon:LockVertex(container.FrameTexture, color)
  Addon:LockVertex(container.VehicleFrameTexture, color)
  keepBorderShadow(container.FrameTexture)
  keepBorderShadow(container.VehicleFrameTexture)
end

local function paintTarget(frame)
  frame = type(frame) == "table" and frame or _G.TargetFrame
  if not frame then
    return
  end
  local soft = Addon.DARKEN_SOFT or Addon.DARKEN_BAR
  Addon:LockVertex(frame.borderTexture, soft)
  keepBorderShadow(frame.borderTexture)
  local name = frame.GetName and frame:GetName()
  if name then
    Addon:LockVertex(_G[name .. "TextureFrameTexture"], soft)
    Addon:LockVertex(_G[name .. "Texture"], soft)
    keepBorderShadow(_G[name .. "TextureFrameTexture"])
    keepBorderShadow(_G[name .. "Texture"])
    hideStay(_G[name .. "Background"])
  end
  darkenContainer(frame, soft)
  -- CheckClassification sizes this well to 25px from y=-26. Health is 12px at
  -- y=-45, so the well covers only the top half of an empty health slot.
  hideStay(frame.Background)
end

local function watchClassification(frame)
  if not frame or frame._shadowUIClassHook or not hooksecurefunc then
    return
  end
  if not frame.CheckClassification then
    return
  end
  frame._shadowUIClassHook = true
  hooksecurefunc(frame, "CheckClassification", paintTarget)
end

local function dim(region, alpha)
  if region and region.SetAlpha then
    region:SetAlpha(alpha)
  end
end

local function muteText(region)
  if region and region.SetText then
    region:SetText(nil)
    region.SetText = function() end
  end
end

local TOT_X, TOT_Y = -35, -10
local TOT_SMALL_X, TOT_SMALL_Y = -13, -17

local function reparkUnits()
  if Addon.SkinUnitFrames then
    Addon:SkinUnitFrames()
  end
end

local totSnapping = {}

local function totOf(frame)
  if frame and frame.totFrame then
    return frame.totFrame
  end
  local name = frame and frame.GetName and frame:GetName()
  if name then
    return _G[name .. "ToT"]
  end
  if frame == _G.FocusFrame then
    return _G.FocusFrameToT
  end
end

local function totOffset(frame)
  if frame and frame.smallSize then
    return TOT_SMALL_X, TOT_SMALL_Y
  end
  return TOT_X, TOT_Y
end

local function restoreBlizzardTot(frame)
end

local function relativeIsTot(relative, tot)
  if not relative or not tot then
    return false
  end
  if relative == tot then
    return true
  end
  local parent = relative.GetParent and relative:GetParent()
  return parent == tot
end

local function breakSnapToTot(frame, tot)
end

local function wrapSetSmallSize(mixin)
end

local function wrapFocusTot()
  wrapSetSmallSize(_G.FocusFrameMixin)
  wrapSetSmallSize(_G.FocusFrame)
end

function Addon:OnEditModeLayoutsUpdated()
  if self._editModeLayoutQueued then
    return
  end
  self._editModeLayoutQueued = true
  local function run()
    self._editModeLayoutQueued = nil
    reparkUnits()
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(0, run)
  else
    run()
  end
end

function Addon:WatchBlizzardUnitEdit()
  wrapFocusTot()
  if hooksecurefunc and _G.EditModeManagerFrame and not self._unitEditModeHook then
    self._unitEditModeHook = true
    if EditModeManagerFrame.ExitEditMode then
      hooksecurefunc(EditModeManagerFrame, "ExitEditMode", reparkUnits)
    end
    if EditModeManagerFrame.SaveLayouts then
      hooksecurefunc(EditModeManagerFrame, "SaveLayouts", reparkUnits)
    end
  end
  if self._unitResetHooks then
    return
  end
  self._unitResetHooks = true
  if self.RegisterEvent then
    pcall(self.RegisterEvent, self, "EDIT_MODE_LAYOUTS_UPDATED", "OnEditModeLayoutsUpdated")
  end
  if not hooksecurefunc then
    return
  end
  for _, name in ipairs({
    "PlayerFrame_ResetUserPlacedPosition",
    "TargetFrame_ResetUserPlacedPosition",
    "PlayerFrame_ResetPosition",
    "TargetFrame_ResetPosition",
  }) do
    if _G[name] then
      hooksecurefunc(name, reparkUnits)
    end
  end
end

function Addon:SkinRaidFrames()
  local black = self.DARKEN_BLACK
  for g = 1, NUM_RAID_GROUPS or 8 do
    self:DarkenFrameRegions(_G["CompactRaidGroup" .. g .. "BorderFrame"], black)
    for m = 1, 5 do
      self:DarkenFrameRegions(_G["CompactRaidGroup" .. g .. "Member" .. m], black, "Border")
      self:DarkenFrameRegions(_G["CompactRaidFrame" .. m], black, "Border")
    end
  end
  self:DarkenFrameRegions(_G.CompactRaidFrameContainerBorderFrame, black)
  self:DarkenFrameRegions(_G.CompactRaidFrameManager, black)
  self:DarkenFrameRegions(_G.CompactRaidFrameManagerContainerResizeFrame, black, "Border")
end

function Addon:SkinUnitFrames()
  local black = self.DARKEN_BLACK
  self:DarkenNamed(BLACK_NAMES, black)
  for _, name in ipairs(BLACK_NAMES) do
    keepBorderShadow(_G[name])
  end
  for i = 1, 4 do
    self:DarkenNamed({
      "PartyMemberFrame" .. i .. "Texture",
      "PartyMemberFrame" .. i .. "PetFrameTexture",
    }, black)
    dim(_G["PartyMemberFrame" .. i .. "PVPIcon"], 0)
    hideStay(_G["PartyMemberFrame" .. i .. "NotPresentIcon"])
  end
  self:DarkenChild(_G.CastingBarFrame, "Border", black)
  self:DarkenChild(_G.TargetFrameSpellBar, "Border", black)
  self:DarkenChild(_G.FocusFrameSpellBar, "Border", black)
  restoreBlizzardTot(_G.TargetFrame)
  darkenContainer(_G.PlayerFrame)
  paintTarget(_G.TargetFrame)
  paintTarget(_G.FocusFrame)
  watchClassification(_G.TargetFrame)
  watchClassification(_G.FocusFrame)
  dim(_G.PlayerPVPIcon, 0.35)
  dim(_G.TargetFrameTextureFramePVPIcon, 0.35)
  dim(_G.PlayerFrameGroupIndicator, 0)
  muteText(_G.PlayerHitIndicator)
  muteText(_G.PetHitIndicator)
  self:LockBackdropBorder(_G.GameTooltip, black)
  self:SkinRaidFrames()
  restoreBlizzardTot(_G.TargetFrame)
  self:WatchBlizzardUnitEdit()
end

wrapFocusTot()

if hooksecurefunc then
  if TargetFrame_CheckClassification then
    hooksecurefunc("TargetFrame_CheckClassification", paintTarget)
  end
  if TargetFrameMixin and TargetFrameMixin.CheckClassification then
    hooksecurefunc(TargetFrameMixin, "CheckClassification", paintTarget)
  end
  if GameTooltip_ShowCompareItem then
    hooksecurefunc("GameTooltip_ShowCompareItem", function(tooltip)
      local shopping = tooltip and tooltip.shoppingTooltips
      local black = Addon.DARKEN_BLACK
      Addon:LockBackdropBorder(shopping and shopping[1], black)
      Addon:LockBackdropBorder(shopping and shopping[2], black)
    end)
  end
end

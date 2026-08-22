--[[
  Purpose: Darken unit-frame chrome the Lorti way and park player/target from Layout.
  Classic maps rare-elite to elite art. SkinRareElite uses the Rare-Elite dragon.
  1.15.9 CheckClassification lives on TargetFrameMixin, not a global.
  Deps: ShadowUI:LockVertex(), ShadowUI:DarkenNamed(), ShadowUI:DarkenFrameRegions()
  Public: ShadowUI:RareEliteTexture(), ShadowUI:SkinRareElite(),
          ShadowUI:SkinUnitFrames(), ShadowUI:SkinRaidFrames(),
          ShadowUI:WatchBlizzardUnitEdit()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

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
  "TargetFrameTextureFrameTexture",
  "TargetFrameToTTextureFrameTexture",
  "FocusFrameTextureFrameTexture",
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

function Addon:RareEliteTexture(classification)
  if classification == "rareelite" then
    return "Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite"
  end
end

local function setBorderTexture(frame, path)
  if frame.borderTexture and frame.borderTexture.SetTexture then
    frame.borderTexture:SetTexture(path)
  end
  local name = frame.GetName and frame:GetName()
  if not name then
    return
  end
  local layered = _G[name .. "TextureFrameTexture"]
  if layered and layered.SetTexture then
    layered:SetTexture(path)
  end
  local vanilla = _G[name .. "Texture"]
  if vanilla and vanilla.SetTexture then
    vanilla:SetTexture(path)
  end
end

function Addon:SkinRareElite(frame)
  frame = type(frame) == "table" and frame or _G.TargetFrame
  if not frame or not UnitClassification then
    return
  end
  local unit = frame.unit or "target"
  local path = self:RareEliteTexture(UnitClassification(unit))
  if path then
    setBorderTexture(frame, path)
  end
end

local function darkenContainer(frame)
  if not frame then
    return
  end
  local container = frame.PlayerFrameContainer or frame.TargetFrameContainer
  if not container then
    return
  end
  Addon:LockVertex(container.FrameTexture, Addon.DARKEN_BLACK)
  Addon:LockVertex(container.VehicleFrameTexture, Addon.DARKEN_BLACK)
end

local function paintTarget(frame)
  frame = type(frame) == "table" and frame or _G.TargetFrame
  if not frame then
    return
  end
  Addon:SkinRareElite(frame)
  Addon:LockVertex(frame.borderTexture, Addon.DARKEN_BLACK)
  local name = frame.GetName and frame:GetName()
  if name then
    Addon:LockVertex(_G[name .. "TextureFrameTexture"], Addon.DARKEN_BLACK)
    Addon:LockVertex(_G[name .. "Texture"], Addon.DARKEN_BLACK)
  end
  darkenContainer(frame)
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

local UNIT_PARK = {
  player = { point = "CENTER", x = -200, y = -179 },
  target = { point = "CENTER", x = 202, y = -179 },
}

local function unitLayout(self, id)
  local shipped = UNIT_PARK[id]
  local layout
  if self.ResolveEffective then
    local resolved = self:ResolveEffective()
    layout = resolved and resolved.layout and resolved.layout[id]
  end
  layout = layout or {}
  local point = layout.point or shipped.point
  local x = layout.x
  if x == nil then
    x = shipped.x
  end
  local y = layout.y
  if y == nil then
    y = shipped.y
  end
  return point, x, y, layout.relativeTo, layout.relativePoint or point
end

local function lockBlizzardMove(frame)
  if not frame then
    return
  end
  frame.isLocked = true
  if frame.UnregisterForDrag then
    frame:UnregisterForDrag()
  end
  if frame.SetMovable then
    frame:SetMovable(Addon.editMode == true)
  end
  if frame.IgnoreFramePositionManager then
    pcall(frame.IgnoreFramePositionManager, frame, true)
  end
end

local function reparkUnits()
  if Addon.SkinUnitFrames then
    Addon:SkinUnitFrames()
  end
end

function Addon:WatchBlizzardUnitEdit()
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
    pcall(self.RegisterEvent, self, "EDIT_MODE_LAYOUTS_UPDATED", "SkinUnitFrames")
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
  local playerPoint, playerX, playerY, playerRelative, playerRelativePoint = unitLayout(self, "player")
  local targetPoint, targetX, targetY, targetRelative, targetRelativePoint = unitLayout(self, "target")
  self:ParkFrame(_G.PlayerFrame, playerPoint, playerX, playerY, nil, nil, playerRelative, playerRelativePoint)
  self:ParkFrame(_G.TargetFrame, targetPoint, targetX, targetY, nil, nil, targetRelative, targetRelativePoint)
  lockBlizzardMove(_G.PlayerFrame)
  lockBlizzardMove(_G.TargetFrame)
  self:WatchBlizzardUnitEdit()
end

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

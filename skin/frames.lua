--[[
  Purpose: Darken unit-frame chrome the Lorti way and park player/target from Layout.
  Classic maps rare-elite to elite art. SkinRareElite uses the Rare-Elite dragon.
  1.15.9 CheckClassification lives on TargetFrameMixin, not a global.
  CheckClassification also sizes TargetFrameBackground over half the health slot.
  paintTarget hides that well so it cannot cover an empty health bar.
  SetSmallSize SetPoint FocusFrameToT. Edit Mode errors if FocusFrame is already
  in that ToT family. WatchBlizzardUnitEdit wraps FocusFrame.SetSmallSize (the
  XML mixin copy) so FocusFrame cannot stay snapped to FocusFrameToT.
  Target of Target stays on the Blizzard default BOTTOMRIGHT offset.
  The Target Frame spell bar sits flush under the mana bar at mana width and
  shows remaining / duration.
  Deps: ShadowUI:LockVertex(), ShadowUI:DarkenNamed(), ShadowUI:DarkenFrameRegions()
  Public: ShadowUI:RareEliteTexture(), ShadowUI:SkinRareElite(),
          ShadowUI:SpellBarTimerCaption(), ShadowUI:PaintSpellBarTimer(),
          ShadowUI:SkinUnitFrames(), ShadowUI:SkinRaidFrames(),
          ShadowUI:WatchBlizzardUnitEdit(), ShadowUI:OnEditModeLayoutsUpdated()
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
    hideStay(_G[name .. "Background"])
  end
  darkenContainer(frame)
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

local UNIT_PARK = {
  player = { point = "CENTER", x = -200, y = -179 },
  target = { point = "CENTER", x = 202, y = -179 },
}
local TOT_X, TOT_Y = -35, -10
local TOT_SMALL_X, TOT_SMALL_Y = -13, -17
local MANA_WIDTH = 119

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
  local tot = totOf(frame)
  if not tot or not frame or totSnapping[tot] then
    return
  end
  totSnapping[tot] = true
  if tot.SetParent then
    tot:SetParent(frame)
  end
  local x, y = totOffset(frame)
  local clear = tot.ClearAllPointsBase or tot.ClearAllPoints
  local setPoint = tot.SetPointBase or tot.SetPoint
  if clear then
    clear(tot)
  end
  if setPoint then
    setPoint(tot, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", x, y)
  end
  totSnapping[tot] = nil
end

local function manaBarOf(frame)
  if not frame then
    return nil
  end
  if frame.manabar then
    return frame.manabar
  end
  if frame.powerbar then
    return frame.powerbar
  end
  local name = frame.GetName and frame:GetName()
  return name and _G[name .. "ManaBar"]
end

local function spellBarOf(frame)
  if not frame then
    return nil
  end
  if frame.spellbar then
    return frame.spellbar
  end
  local name = frame.GetName and frame:GetName()
  return name and _G[name .. "SpellBar"]
end

function Addon:SpellBarTimerCaption(remaining, duration)
  if not remaining or not duration or duration <= 0 then
    return nil
  end
  if remaining < 0 then
    remaining = 0
  end
  return string.format("%.1f / %.1f", remaining, duration)
end

local function ensureSpellTimer(bar)
  if bar.shadowUITime then
    return bar.shadowUITime
  end
  if not bar.CreateFontString then
    return nil
  end
  local fs = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  if fs.SetJustifyH then
    fs:SetJustifyH("RIGHT")
  end
  if fs.ClearAllPoints then
    fs:ClearAllPoints()
  end
  if fs.SetPoint then
    fs:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
  end
  if fs.SetFont then
    local path = _G.STANDARD_TEXT_FONT
    if fs.GetFont then
      path = fs:GetFont() or path
    end
    if path then
      fs:SetFont(path, 10, "OUTLINE")
    end
  end
  bar.shadowUITime = fs
  return fs
end

function Addon:PaintSpellBarTimer(bar)
  if not bar then
    return
  end
  local fs = ensureSpellTimer(bar)
  if not fs then
    return
  end
  local remaining, duration
  if bar.casting or bar.channeling then
    if bar.startTime and bar.endTime then
      duration = bar.endTime - bar.startTime
      remaining = bar.endTime - (GetTime and GetTime() or 0)
    elseif bar.GetMinMaxValues and bar.GetValue then
      local minV, maxV = bar:GetMinMaxValues()
      duration = (maxV or 0) - (minV or 0)
      local value = bar:GetValue() or 0
      if bar.channeling then
        remaining = value - (minV or 0)
      else
        remaining = (maxV or 0) - value
      end
    end
  end
  local text = Addon:SpellBarTimerCaption(remaining, duration)
  if not text then
    if fs.Hide then
      fs:Hide()
    end
    return
  end
  if fs.SetFormattedText then
    fs:SetFormattedText("%.1f / %.1f", remaining, duration)
  elseif fs.SetText then
    fs:SetText(text)
  end
  if fs.Show then
    fs:Show()
  end
end

local function placeSpellBar(bar, frame)
  local mana = manaBarOf(frame)
  if not bar or not mana or not bar.SetPoint then
    return
  end
  if bar._shadowUISpellNest then
    return
  end
  bar._shadowUISpellNest = true
  if bar.ClearAllPoints then
    bar:ClearAllPoints()
  end
  bar:SetPoint("TOPLEFT", mana, "BOTTOMLEFT", 0, 0)
  local width = (mana.GetWidth and mana:GetWidth()) or MANA_WIDTH
  if bar.SetWidth then
    bar:SetWidth(width)
  end
  bar._shadowUISpellNest = nil
end

local function watchSpellBar(bar, frame)
  if not bar or bar._shadowUISpellWatch then
    return
  end
  bar._shadowUISpellWatch = true
  if hooksecurefunc and bar.SetPoint then
    hooksecurefunc(bar, "SetPoint", function(self)
      if self._shadowUISpellNest then
        return
      end
      placeSpellBar(self, frame)
    end)
  end
  if bar.HookScript then
    bar:HookScript("OnUpdate", function(self)
      Addon:PaintSpellBarTimer(self)
    end)
  end
  placeSpellBar(bar, frame)
  Addon:PaintSpellBarTimer(bar)
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

-- FocusFrameMixin:SetSmallSize does FocusFrameToT:SetPoint("BOTTOMRIGHT", -13, -17)
-- with no ClearAllPoints. That errors when FocusFrame is already in the ToT family.
local function breakSnapToTot(frame, tot)
  if not frame or not tot or not frame.GetPoint then
    return
  end
  local count = frame.GetNumPoints and frame:GetNumPoints() or 0
  local snapped = false
  for i = 1, count do
    local _, relative = frame:GetPoint(i)
    if relativeIsTot(relative, tot) then
      snapped = true
      break
    end
  end
  if not snapped then
    return
  end
  local x = frame.GetLeft and frame:GetLeft()
  local y = frame.GetBottom and frame:GetBottom()
  if frame.ClearAllPointsBase then
    frame:ClearAllPointsBase()
  elseif frame.ClearAllPoints then
    frame:ClearAllPoints()
  end
  local setPoint = frame.SetPointBase or frame.SetPoint
  if setPoint then
    setPoint(frame, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", x or 0, y or 0)
  end
end

local function wrapSetSmallSize(mixin)
  if not mixin or mixin._shadowUISmallSize or type(mixin.SetSmallSize) ~= "function" then
    return
  end
  mixin._shadowUISmallSize = true
  local orig = mixin.SetSmallSize
  mixin.SetSmallSize = function(self, smallSize, onChange)
    local tot = totOf(self)
    if tot then
      breakSnapToTot(self, tot)
      if tot.ClearAllPoints then
        tot:ClearAllPoints()
      end
      if tot.SetParent and self then
        tot:SetParent(self)
      end
    end
    local result = orig(self, smallSize, onChange)
    restoreBlizzardTot(self)
    return result
  end
end

local function wrapTotSetPoint(tot)
  if not tot or tot._shadowUITotPoint or type(tot.SetPoint) ~= "function" then
    return
  end
  tot._shadowUITotPoint = true
  local orig = tot.SetPoint
  tot.SetPoint = function(self, ...)
    local frame = _G.FocusFrame
    if frame and (self == frame.totFrame or self == _G.FocusFrameToT) then
      breakSnapToTot(frame, self)
    end
    return orig(self, ...)
  end
end

local function wrapTargetTot()
  local tot = (_G.TargetFrame and _G.TargetFrame.totFrame) or _G.TargetFrameToT
  if not tot or tot._shadowUITotPark or not tot.SetPoint then
    return
  end
  tot._shadowUITotPark = true
  if hooksecurefunc then
    hooksecurefunc(tot, "SetPoint", function(self)
      if totSnapping[self] then
        return
      end
      restoreBlizzardTot(_G.TargetFrame)
    end)
  end
end

local function wrapFocusTot()
  wrapSetSmallSize(_G.FocusFrameMixin)
  wrapSetSmallSize(_G.FocusFrame)
  wrapTotSetPoint(_G.FocusFrameToT)
  wrapTotSetPoint(_G.FocusFrame and _G.FocusFrame.totFrame)
  wrapTargetTot()
  if Addon._focusSmallSizeFn or type(_G.FocusFrame_SetSmallSize) ~= "function" then
    return
  end
  Addon._focusSmallSizeFn = true
  local orig = _G.FocusFrame_SetSmallSize
  _G.FocusFrame_SetSmallSize = function(smallSize, onChange)
    local frame = _G.FocusFrame
    local tot = totOf(frame)
    if tot then
      breakSnapToTot(frame, tot)
      if tot.ClearAllPoints then
        tot:ClearAllPoints()
      end
      if tot.SetParent and frame then
        tot:SetParent(frame)
      end
    end
    local result = orig(smallSize, onChange)
    restoreBlizzardTot(frame)
    return result
  end
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
  watchSpellBar(spellBarOf(_G.TargetFrame), _G.TargetFrame)
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
  local playerPoint, playerX, playerY, playerRelative, playerRelativePoint = unitLayout(self, "player")
  local targetPoint, targetX, targetY, targetRelative, targetRelativePoint = unitLayout(self, "target")
  self:ParkFrame(_G.PlayerFrame, playerPoint, playerX, playerY, nil, nil, playerRelative, playerRelativePoint)
  self:ParkFrame(_G.TargetFrame, targetPoint, targetX, targetY, nil, nil, targetRelative, targetRelativePoint)
  restoreBlizzardTot(_G.TargetFrame)
  watchSpellBar(spellBarOf(_G.TargetFrame), _G.TargetFrame)
  lockBlizzardMove(_G.PlayerFrame)
  lockBlizzardMove(_G.TargetFrame)
  if self.ParkBlizzardStanceBar then
    self:ParkBlizzardStanceBar()
  end
  self:WatchBlizzardUnitEdit()
end

wrapFocusTot()

if hooksecurefunc then
  if TargetSpellBarMixin and TargetSpellBarMixin.AdjustPosition then
    hooksecurefunc(TargetSpellBarMixin, "AdjustPosition", function(self)
      local parent = self.GetParent and self:GetParent()
      if parent ~= _G.TargetFrame then
        return
      end
      placeSpellBar(self, parent)
      Addon:PaintSpellBarTimer(self)
    end)
  end
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

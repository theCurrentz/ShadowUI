--[[
  Purpose: Apply a tight matte fill to ShadowUI action bars and Lorti outer chrome.
  Deps: ShadowUI bars, media/outer_shadow.tga
  Public: ShadowUI:ParkFrame(), ShadowUI:ApplyOuterChrome(), ShadowUI:ApplyBarChrome(),
          ShadowUI:SkinBarChrome(), ShadowUI:ApplySkins()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:SkinTargetStatus() end
function Addon:SkinTargetThreat() end
local snapping = {}
local OUTER_PAD = 4
local OUTER_EDGE = 5
local OUTER_BACKDROP = {
  edgeFile = "Interface\\AddOns\\ShadowUI\\media\\outer_shadow",
  tile = false,
  tileSize = 32,
  edgeSize = OUTER_EDGE,
  insets = {
    left = OUTER_EDGE,
    right = OUTER_EDGE,
    top = OUTER_EDGE,
    bottom = OUTER_EDGE,
  },
}

function Addon:ParkFrame(frame, point, x, y, width, height, relativeTo, relativePoint)
  if not frame or not frame.SetPoint then
    return
  end
  frame._shadowUIPark = {
    point = point,
    x = x,
    y = y,
    width = width,
    height = height,
    relativeTo = relativeTo,
    relativePoint = relativePoint,
  }
  if hooksecurefunc and not frame._shadowUIWatch then
    frame._shadowUIWatch = true
    hooksecurefunc(frame, "SetPoint", function(self)
      if snapping[self] or self._shadowUIDragging then
        return
      end
      local spec = self._shadowUIPark
      if spec then
        Addon:ParkFrame(self, spec.point, spec.x, spec.y, spec.width, spec.height,
          spec.relativeTo, spec.relativePoint)
      end
    end)
  end
  snapping[frame] = true
  if frame.ClearAllPoints then
    frame:ClearAllPoints()
  end
  frame:SetPoint(point, relativeTo or UIParent, relativePoint or point, x, y)
  if width and frame.SetWidth then
    frame:SetWidth(width)
  end
  if height and frame.SetHeight then
    frame:SetHeight(height)
  end
  if width and height and frame.SetSize then
    frame:SetSize(width, height)
  end
  -- BuffFrame and other Blizzard hosts can report movable and still reject
  -- SetUserPlaced. A throw here used to abort ApplySkins.
  if frame.SetUserPlaced then
    pcall(frame.SetUserPlaced, frame, true)
  end
  snapping[frame] = nil
end

function Addon:ApplyOuterChrome(host)
  if not host or host.shadowUIOuter or not CreateFrame then
    return host and host.shadowUIOuter
  end
  if host.GetFrameLevel and host:GetFrameLevel() < 1 and host.SetFrameLevel then
    host:SetFrameLevel(1)
  end
  local ok, outer = pcall(CreateFrame, "Frame", nil, host, "BackdropTemplate")
  if not ok or not outer then
    outer = CreateFrame("Frame", nil, host)
  end
  host.shadowUIOuter = outer
  if outer.ClearAllPoints then
    outer:ClearAllPoints()
  end
  outer:SetPoint("TOPLEFT", host, "TOPLEFT", -OUTER_PAD, OUTER_PAD)
  outer:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", OUTER_PAD, -OUTER_PAD)
  if host.GetFrameLevel and outer.SetFrameLevel then
    local level = host:GetFrameLevel()
    if level > 0 then
      outer:SetFrameLevel(level - 1)
    end
  end
  if outer.SetBackdrop then
    outer:SetBackdrop(OUTER_BACKDROP)
    outer:SetBackdropBorderColor(0, 0, 0, 0.9)
  end
  if outer.Show then
    outer:Show()
  end
  return outer
end

function Addon:SkinDetails() end
function Addon:SkinItemRack() end
function Addon:SkinTime() end

function Addon:ApplyBarChrome(bar)
  local fill = bar.fill
  if not fill then
    fill = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    bar.fill = fill
  end
  fill:ClearAllPoints()
  fill:SetAllPoints(bar)
  fill:SetColorTexture(0, 0, 0, 1)
  fill:Show()
  if bar.shadow then
    bar.shadow:Hide()
  end
end

function Addon:SkinBarChrome()
  for _, bar in pairs(self.bars or {}) do
    self:ApplyBarChrome(bar)
  end
end

function Addon:ApplySkins()
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  self:SkinBarChrome()
  self:SkinChat()
  self:SkinMicroAndBags()
  self:SkinTrackingBars()
  self:SkinMinimap()
  self:SkinDarken()
  self:SkinAuras()
  self:SkinTargetStatus()
  self:SkinTargetThreat()
  self:SkinDetails()
  self:SkinItemRack()
end

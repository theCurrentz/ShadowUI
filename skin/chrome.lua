--[[
  Purpose: Apply Lorti outer chrome to ShadowUI hosts. Action Bars have no matte fill
           so empty Action Slots stay hidden. ApplySkins also skins the Stance Bar
           and the Extra Action Button.
  Deps: ShadowUI bars, media/outer_shadow.tga, media/outer_shadow_roundrect.tga
  Public: ShadowUI:ParkFrame(), ShadowUI:ApplyOuterChrome(), ShadowUI:PaintOuterChrome(),
          ShadowUI:ApplyBarChrome(), ShadowUI:SkinBarChrome(), ShadowUI:ApplySkins(),
          ShadowUI:ApplyStatusBarGradient()
  Notes: ParkFrame uses SetPointBase when 1.15.9 Edit Mode has replaced SetPoint.
         outer_shadow.tga is white RGB. PaintOuterChrome tints it black. BackdropTemplate
         ApplyBackdrop resets that tint to white. A secret frame size skips
         SetupTextureCoordinates so loot cannot divide that width. Circle,
         diamond, and roundrect Outer Edge use matching drop textures instead
         of the 9-slice. Roundrect is a 2:1 ring so a meter well does not
         stretch square corner quads.
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")


-- SetGradientAlpha was removed from the client; SetGradient takes ColorMixins.
function Addon:ApplyStatusBarGradient(texture, orientation, from, to)
  if not texture then
    return
  end
  if CreateColor and texture.SetGradient then
    local ok = pcall(
      texture.SetGradient,
      texture,
      orientation,
      CreateColor(from[1], from[2], from[3], from[4]),
      CreateColor(to[1], to[2], to[3], to[4])
    )
    if ok then
      return
    end
  end
  if texture.SetGradientAlpha then
    local ok = pcall(
      texture.SetGradientAlpha,
      texture,
      orientation,
      from[1], from[2], from[3], from[4],
      to[1], to[2], to[3], to[4]
    )
    if ok then
      return
    end
  end
  if texture.SetGradient then
    local ok = pcall(
      texture.SetGradient,
      texture,
      orientation,
      from[1], from[2], from[3],
      to[1], to[2], to[3]
    )
    if ok then
      return
    end
  end
  texture:SetVertexColor(to[1], to[2], to[3], to[4])
end
local snapping = {}
local OUTER_PAD = 4
local OUTER_EDGE = 5
local OUTER_CHROME_REV = 2
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

local function hookEditModePark()
  if Addon._editModeParkHook or not hooksecurefunc then
    return
  end
  local mixin = _G.EditModeSystemMixin
  if not mixin or not mixin.ApplySystemAnchor then
    return
  end
  Addon._editModeParkHook = true
  hooksecurefunc(mixin, "ApplySystemAnchor", function(frame)
    if snapping[frame] or not frame or not frame._shadowUIPark then
      return
    end
    local spec = frame._shadowUIPark
    Addon:ParkFrame(frame, spec.point, spec.x, spec.y, spec.width, spec.height,
      spec.relativeTo, spec.relativePoint)
  end)
end

function Addon:ParkFrame(frame, point, x, y, width, height, relativeTo, relativePoint)
  if not frame or not (frame.SetPointBase or frame.SetPoint) then
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
  hookEditModePark()
  if hooksecurefunc and not frame._shadowUIWatch then
    frame._shadowUIWatch = true
    if frame.SetPoint then
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
  end
  snapping[frame] = true
  -- 1.15.9 Edit Mode replaces SetPoint. The override notifies Edit Mode, which
  -- re-applies its layout while snapping is on. SetPointBase skips that fight.
  local clear = frame.ClearAllPointsBase or frame.ClearAllPoints
  local setPoint = frame.SetPointBase or frame.SetPoint
  if relativeTo == _G.FocusFrameToT or relativeTo == _G.TargetFrameToT
      or relativeTo == "FocusFrameToT" or relativeTo == "TargetFrameToT" then
    relativeTo = UIParent
  end
  if clear then
    clear(frame)
  end
  setPoint(frame, point, relativeTo or UIParent, relativePoint or point, x, y)
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

local function guardSecretBackdrop(outer)
  if not outer or outer._shadowUISecretBackdrop or not outer.SetupTextureCoordinates then
    return
  end
  outer._shadowUISecretBackdrop = true
  local setup = outer.SetupTextureCoordinates
  function outer:SetupTextureCoordinates()
    local width = self.GetWidth and self:GetWidth()
    local height = self.GetHeight and self:GetHeight()
    if issecretvalue and (issecretvalue(width) or issecretvalue(height)) then
      return
    end
    return setup(self)
  end
end

function Addon:PaintOuterChrome(outer)
  if not outer then
    return
  end
  if outer.SetBackdropColor then
    outer:SetBackdropColor(0, 0, 0, 0)
  end
  if outer.SetBackdropBorderColor then
    outer:SetBackdropBorderColor(0, 0, 0, 0.9)
  end
end

function Addon:ApplyOuterChrome(host, shape)
  if not host or not CreateFrame then
    return host and host.shadowUIOuter
  end
  shape = shape or "square"
  if host.shadowUIOuter and host.shadowUIOuterShape == shape
      and host.shadowUIOuterRev == OUTER_CHROME_REV then
    guardSecretBackdrop(host.shadowUIOuter)
    self:PaintOuterChrome(host.shadowUIOuter)
    if host.shadowUIOuter.Show then
      host.shadowUIOuter:Show()
    end
    return host.shadowUIOuter
  end
  local outer = host.shadowUIOuter
  if not outer then
    -- SetFrameLevel on default ActionButtons raises ADDON_ACTION_FORBIDDEN.
    local ok, created = pcall(CreateFrame, "Frame", nil, host, "BackdropTemplate")
    if not ok or not created then
      created = CreateFrame("Frame", nil, host)
    end
    outer = created
    host.shadowUIOuter = outer
    -- The edge sits on the slot. It must not take the drop click.
    if outer.EnableMouse then
      outer:EnableMouse(false)
    end
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
  end
  host.shadowUIOuterShape = shape
  if shape == "square" then
    if outer.shadowUIDrop and outer.shadowUIDrop.Hide then
      outer.shadowUIDrop:Hide()
    end
    if outer.SetBackdrop then
      outer:SetBackdrop(OUTER_BACKDROP)
      self:PaintOuterChrome(outer)
    end
    if hooksecurefunc and outer.ApplyBackdrop and not outer._shadowUIOuterPaint then
      outer._shadowUIOuterPaint = true
      hooksecurefunc(outer, "ApplyBackdrop", function(self)
        Addon:PaintOuterChrome(self)
      end)
    end
  else
    if outer.SetBackdrop then
      outer:SetBackdrop(nil)
    end
    local drop = outer.shadowUIDrop
    if not drop and outer.CreateTexture then
      drop = outer:CreateTexture(nil, "BACKGROUND")
      outer.shadowUIDrop = drop
    end
    if drop then
      if drop.SetTexture then
        drop:SetTexture(self:OuterEdgeFile(shape))
      end
      if drop.SetAllPoints then
        drop:SetAllPoints(outer)
      end
      if drop.SetVertexColor then
        drop:SetVertexColor(0, 0, 0, 0.9)
      end
      if drop.Show then
        drop:Show()
      end
    end
  end
  if outer.Show then
    outer:Show()
  end
  guardSecretBackdrop(outer)
  host.shadowUIOuterRev = OUTER_CHROME_REV
  return outer
end

function Addon:SkinDetails() end
function Addon:SkinItemRack() end
function Addon:SkinBags() end -- parked: skin/bags.lua is not in the TOC
function Addon:SkinStanceBar() end
function Addon:SkinExtraActionBar() end
function Addon:SkinTime() end

function Addon:ApplyBarChrome(bar)
  local fill = bar.fill
  if fill and fill.Hide then
    fill:Hide()
  end
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
  if self.RefreshDarkenPalette then
    self:RefreshDarkenPalette()
  end
  self:SkinBarChrome()
  self:SkinChat()
  self:SkinMicroAndBags()
  self:SkinTrackingBars()
  self:SkinMinimap()
  self:SkinDarken()
  self:SkinAuras()
  self:SkinDetails()
  self:SkinItemRack()
  self:SkinStanceBar()
  if self.SkinExtraActionBar then
    self:SkinExtraActionBar()
  end
  if self.SkinBlizzardActionBars then
    self:SkinBlizzardActionBars()
  end
end

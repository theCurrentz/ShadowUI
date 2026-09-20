--[[
  Purpose: Unit Frame Layout: Baseline targeting-frame Widgets, horizontal
           mirror, sparse resolve, and Widget place. This is the seam tests
           and Unit Frame Designer share. Host screen park stays on the same
           Layout key as the Widgets.
  Deps: ShadowUI:SparseMerge(), ShadowUI:DeepCopy()
  Public: UNIT_FRAME_IDS, UNIT_WIDGET_KIND, ShadowUI:UnitFrameHostSize(),
          ShadowUI:UnitFrameArtTexCoord(), ShadowUI:PaintUnitFrameArt(),
          ShadowUI:BaselineUnitFrameLayout(), ShadowUI:MirrorUnitFrameLayout(),
          ShadowUI:SanitizeUnitFrameLayout(), ShadowUI:ClampWidgetRect(),
          ShadowUI:PlaceUnitWidgets(), ShadowUI:OffsetsForAnchor(),
          ShadowUI:ResolveWidgetRects(), ShadowUI:WidgetGeometryFromRect(),
          ShadowUI:PersistWidgetGeometry(), ShadowUI:PersistWidgetPosition(),
          ShadowUI:WidgetStack(), ShadowUI:NudgeWidgetStack(),
          ShadowUI:ApplyUnitWidgetStack()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

Addon.UNIT_FRAME_IDS = { "player", "target" }
Addon.UNIT_FRAME_TOKENS = { player = "player", target = "target" }

-- Kind decides which region CreateUnitFrame builds. Order is place order:
-- host-relative Widgets first, then Widgets that anchor to another Widget.
Addon.UNIT_WIDGET_KIND = {
  art = "texture",
  portrait = "texture",
  nameBackground = "texture",
  health = "statusbar",
  power = "statusbar",
  name = "fontstring",
  level = "fontstring",
  healthText = "fontstring",
  powerText = "fontstring",
  auras = "frame",
  spellBar = "statusbar",
}

Addon.UNIT_WIDGET_ORDER = {
  "art", "portrait", "nameBackground", "health", "power", "name", "level",
  "healthText", "powerText", "auras", "spellBar",
}

Addon.UNIT_WIDGET_LABELS = {
  art = "Frame Art",
  portrait = "Portrait",
  nameBackground = "Name Background",
  health = "Health",
  power = "Power",
  name = "Name",
  level = "Level",
  healthText = "Health Text",
  powerText = "Power Text",
  auras = "Auras",
  spellBar = "Spell Bar",
}

-- Higher stack paints in front. Not a Profile Layer.
Addon.UNIT_WIDGET_STACK = {
  art = 1,
  portrait = 2,
  nameBackground = 2,
  health = 3,
  power = 3,
  name = 4,
  level = 4,
  healthText = 5,
  powerText = 5,
  auras = 6,
  spellBar = 6,
}

Addon.UNIT_WIDGET_STACK_MIN = 1
Addon.UNIT_WIDGET_STACK_MAX = 16

function Addon:WidgetStack(spec, widgetId)
  if type(spec) == "table" and type(spec.stack) == "number" then
    return spec.stack
  end
  return (self.UNIT_WIDGET_STACK or {})[widgetId] or 1
end

local HOST_W = 232
local HOST_H = 100
-- UI-TargetingFrame.blp is a 256 atlas. PlayerFrame.xml crops and flips it:
-- left=1, right=0.09375 (24/256), top=0, bottom=0.78125. Target is unflipped.
local ART_FILE = "Interface\\TargetingFrame\\UI-TargetingFrame"
local ART_CROP_LEFT = 0.09375
local ART_CROP_BOTTOM = 0.78125

function Addon:UnitFrameArtTexCoord(frameId, artRect)
  artRect = artRect or {}
  local left = artRect.left or 0
  local bottom = artRect.bottom or 0
  local width = artRect.width or HOST_W
  local height = artRect.height or HOST_H
  if width < 1 then
    width = 1
  end
  if height < 1 then
    height = 1
  end
  local topFrac = (HOST_H - (bottom + height)) / HOST_H
  local botFrac = (HOST_H - bottom) / HOST_H
  local v0 = topFrac * ART_CROP_BOTTOM
  local v1 = botFrac * ART_CROP_BOTTOM
  local x0 = left / HOST_W
  local x1 = (left + width) / HOST_W
  if frameId == "player" then
    local u0 = 1 + x0 * (ART_CROP_LEFT - 1)
    local u1 = 1 + x1 * (ART_CROP_LEFT - 1)
    return u0, u1, v0, v1
  end
  local u0 = ART_CROP_LEFT + x0 * (1 - ART_CROP_LEFT)
  local u1 = ART_CROP_LEFT + x1 * (1 - ART_CROP_LEFT)
  return u0, u1, v0, v1
end

function Addon:PaintUnitFrameArt(texture, frameId, artRect)
  if not texture then
    return
  end
  if texture.SetTexture then
    texture:SetTexture(ART_FILE)
  end
  if texture.SetTexCoord then
    texture:SetTexCoord(self:UnitFrameArtTexCoord(frameId, artRect))
  end
end

local PARK = {
  player = { x = -200, y = -179, portraitSide = "left" },
  target = { x = 202, y = -179, portraitSide = "right" },
}

local function widget(spec)
  spec.point = spec.point or "TOPLEFT"
  spec.relativePoint = spec.relativePoint or spec.point
  spec.x = spec.x or 0
  spec.y = spec.y or 0
  if spec.enabled == nil then
    spec.enabled = true
  end
  return spec
end

local function playerWidgets()
  return {
    art = widget({ x = 0, y = 0, width = HOST_W, height = HOST_H }),
    portrait = widget({ x = 42, y = -12, width = 64, height = 64 }),
    health = widget({ x = 106, y = -41, width = 119, height = 12 }),
    power = widget({ x = 106, y = -52, width = 119, height = 12 }),
    name = widget({ x = 97, y = -27, width = 100, height = 12 }),
    level = widget({
      point = "CENTER",
      relativeTo = "portrait",
      relativePoint = "BOTTOM",
      x = 0,
      y = 8,
      width = 20,
      height = 12,
    }),
    healthText = widget({
      point = "CENTER",
      relativeTo = "health",
      relativePoint = "CENTER",
      width = 119,
      height = 12,
    }),
    powerText = widget({
      point = "CENTER",
      relativeTo = "power",
      relativePoint = "CENTER",
      width = 119,
      height = 12,
    }),
  }
end

local function targetOnlyWidgets()
  return {
    nameBackground = widget({ x = 7, y = -22, width = 119, height = 18 }),
    auras = widget({
      point = "TOPLEFT",
      relativePoint = "TOPRIGHT",
      x = 2,
      y = 0,
      width = 32,
      height = 32,
    }),
    spellBar = widget({
      point = "BOTTOM",
      relativeTo = "nameBackground",
      relativePoint = "TOP",
      x = 0,
      y = 2,
      width = 119,
      height = 10,
    }),
  }
end

local function hostPark(id)
  local park = PARK[id] or PARK.player
  return {
    point = "CENTER",
    relativeTo = "UIParent",
    relativePoint = "CENTER",
    x = park.x,
    y = park.y,
    width = HOST_W,
    height = HOST_H,
    portraitSide = park.portraitSide,
    enabled = true,
  }
end

function Addon:UnitFrameHostSize(layout)
  layout = layout or {}
  return layout.width or HOST_W, layout.height or HOST_H
end

local function flipX(x, width, hostWidth)
  x = x or 0
  width = width or 0
  return hostWidth - x - width
end

function Addon:MirrorUnitFrameLayout(layout)
  layout = layout or {}
  local copy = self.DeepCopy and self:DeepCopy(layout) or layout
  local hostWidth = select(1, self:UnitFrameHostSize(copy))
  if copy.portraitSide == "left" then
    copy.portraitSide = "right"
  elseif copy.portraitSide == "right" then
    copy.portraitSide = "left"
  end
  for _, id in ipairs(self.UNIT_WIDGET_ORDER) do
    local spec = copy[id]
    if type(spec) == "table" and not spec.relativeTo then
      local rel = spec.relativePoint or spec.point or "TOPLEFT"
      if rel == "TOPLEFT" or rel == "BOTTOMLEFT" or rel == "LEFT" then
        spec.x = flipX(spec.x, spec.width, hostWidth)
      elseif rel == "TOP" or rel == "BOTTOM" or rel == "CENTER" then
        spec.x = -(spec.x or 0)
      end
    end
  end
  return copy
end

function Addon:BaselineUnitFrameLayout(id)
  local layout = hostPark(id)
  local widgets = playerWidgets()
  for key, spec in pairs(widgets) do
    layout[key] = spec
  end
  if id == "target" then
    layout = self:MirrorUnitFrameLayout(layout)
    layout.x = PARK.target.x
    layout.y = PARK.target.y
    layout.portraitSide = PARK.target.portraitSide
    for key, spec in pairs(targetOnlyWidgets()) do
      layout[key] = spec
    end
  end
  return layout
end

local function isWidgetKey(key)
  return Addon.UNIT_WIDGET_KIND[key] ~= nil
end

local ANCHOR_POINTS = {
  TOPLEFT = { 0, 1 },
  TOP = { 0.5, 1 },
  TOPRIGHT = { 1, 1 },
  LEFT = { 0, 0.5 },
  CENTER = { 0.5, 0.5 },
  RIGHT = { 1, 0.5 },
  BOTTOMLEFT = { 0, 0 },
  BOTTOM = { 0.5, 0 },
  BOTTOMRIGHT = { 1, 0 },
}

Addon.UNIT_ANCHOR_POINTS = {
  "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT",
  "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT",
}

function Addon:NormalizeAnchorPoint(point)
  if type(point) == "string" and ANCHOR_POINTS[point] then
    return point
  end
  return "TOPLEFT"
end

function Addon:AnchorCoords(left, bottom, width, height, point)
  local factor = ANCHOR_POINTS[self:NormalizeAnchorPoint(point)]
  return (left or 0) + (width or 0) * factor[1], (bottom or 0) + (height or 0) * factor[2]
end

function Addon:OffsetsForAnchor(child, relative, point, relativePoint)
  child = child or {}
  relative = relative or {}
  local cx, cy = self:AnchorCoords(child.left, child.bottom, child.width, child.height, point)
  local rx, ry = self:AnchorCoords(
    relative.left,
    relative.bottom,
    relative.width,
    relative.height,
    relativePoint
  )
  return cx - rx, cy - ry
end

function Addon:ResolveWidgetRects(frameLayout)
  frameLayout = frameLayout or {}
  local hostW, hostH = self:UnitFrameHostSize(frameLayout)
  local host = { left = 0, bottom = 0, width = hostW, height = hostH }
  local rects = { host = host }
  local function relativeRect(spec)
    local relativeTo = spec.relativeTo
    if type(relativeTo) == "string" and relativeTo ~= "" and relativeTo ~= "host" then
      return rects[relativeTo]
    end
    return host
  end
  local function place(id, spec)
    local relative = relativeRect(spec)
    if not relative then
      return false
    end
    local point = self:NormalizeAnchorPoint(spec.point)
    local relativePoint = self:NormalizeAnchorPoint(spec.relativePoint or spec.point)
    local width = spec.width
    local height = spec.height
    if not width or not height then
      local kind = (self.UNIT_WIDGET_KIND or {})[id]
      if kind == "fontstring" then
        width = width or 80
        height = height or 12
      else
        width = width or relative.width or 24
        height = height or relative.height or 12
      end
    end
    local rx, ry = self:AnchorCoords(
      relative.left,
      relative.bottom,
      relative.width,
      relative.height,
      relativePoint
    )
    local factor = ANCHOR_POINTS[point]
    local cx = rx + (spec.x or 0)
    local cy = ry + (spec.y or 0)
    rects[id] = {
      left = cx - width * factor[1],
      bottom = cy - height * factor[2],
      width = width,
      height = height,
    }
    return true
  end
  local pending = true
  local guard = 0
  while pending and guard < 8 do
    pending = false
    guard = guard + 1
    for _, id in ipairs(self.UNIT_WIDGET_ORDER or {}) do
      local spec = frameLayout[id]
      if type(spec) == "table" and spec.enabled ~= false and not rects[id] then
        if not place(id, spec) then
          pending = true
        end
      end
    end
  end
  return rects
end

function Addon:WidgetGeometryFromRect(spec, childRect, relativeRect)
  spec = spec or {}
  local point = self:NormalizeAnchorPoint(spec.point)
  local relativePoint = self:NormalizeAnchorPoint(spec.relativePoint or spec.point)
  local x, y = self:OffsetsForAnchor(childRect, relativeRect, point, relativePoint)
  local out = {
    point = point,
    relativePoint = relativePoint,
    x = x,
    y = y,
  }
  local relativeTo = spec.relativeTo
  if type(relativeTo) == "string" and relativeTo ~= "" and relativeTo ~= "host" then
    out.relativeTo = relativeTo
  end
  childRect = childRect or {}
  if childRect.width then
    out.width = childRect.width
  end
  if childRect.height then
    out.height = childRect.height
  end
  if spec.enabled == false then
    out.enabled = false
  end
  return out
end

function Addon:RegionScreenRect(region)
  if not region then
    return nil
  end
  local left = region.GetLeft and region:GetLeft()
  local bottom = region.GetBottom and region:GetBottom()
  if left == nil or bottom == nil then
    return nil
  end
  return {
    left = left,
    bottom = bottom,
    width = (region.GetWidth and region:GetWidth()) or region.width or 0,
    height = (region.GetHeight and region:GetHeight()) or region.height or 0,
  }
end

function Addon:UnitWidgetLayout(frameLayout, widgetId)
  frameLayout = frameLayout or {}
  local spec = frameLayout[widgetId]
  if type(spec) ~= "table" then
    return nil
  end
  return spec
end

function Addon:UnitFrameLayoutForApply(layout, id)
  layout = layout or {}
  local shipped = self:BaselineUnitFrameLayout(id)
  local overlay = layout[id]
  if type(overlay) ~= "table" then
    return shipped
  end
  local merged = shipped
  if self.SparseMerge then
    merged = self:SparseMerge(shipped, overlay)
  end
  return self:SanitizeUnitFrameLayout(merged, id)
end

local function isFinite(n)
  return type(n) == "number" and n == n and n > -100000 and n < 100000
end

function Addon:SanitizeUnitFrameLayout(frameLayout, frameId)
  frameLayout = frameLayout or {}
  local shipped = self:BaselineUnitFrameLayout(frameId or "player")
  local hostW, hostH = self:UnitFrameHostSize(frameLayout)
  for _, id in ipairs(self.UNIT_WIDGET_ORDER or {}) do
    local spec = frameLayout[id]
    local base = shipped[id]
    if type(spec) == "table" and type(base) == "table" then
      if not isFinite(spec.width) or spec.width < 1 or spec.width > hostW * 2 then
        spec.width = base.width
      end
      if not isFinite(spec.height) or spec.height < 1 or spec.height > hostH * 2 then
        spec.height = base.height
      end
      if not isFinite(spec.x) or spec.x < -hostW or spec.x > hostW * 2 then
        spec.x = base.x or 0
      end
      if not isFinite(spec.y) or spec.y < -hostH * 2 or spec.y > hostH then
        spec.y = base.y or 0
      end
      if id == "art" then
        if (spec.width or 0) > hostW then
          spec.width = hostW
        end
        if (spec.height or 0) > hostH then
          spec.height = hostH
        end
        if not isFinite(spec.x) or spec.x < 0 or spec.x > hostW then
          spec.x = base.x or 0
        end
        if not isFinite(spec.y) or spec.y > 0 or spec.y < -hostH then
          spec.y = base.y or 0
        end
      end
    end
  end
  return frameLayout
end

function Addon:ClampWidgetRect(widgetId, rect, hostW, hostH)
  hostW = hostW or HOST_W
  hostH = hostH or HOST_H
  rect = rect or {}
  local minSize = 4
  local left = rect.left or 0
  local bottom = rect.bottom or 0
  local width = rect.width or minSize
  local height = rect.height or minSize
  if not isFinite(left) then
    left = 0
  end
  if not isFinite(bottom) then
    bottom = 0
  end
  if not isFinite(width) then
    width = minSize
  end
  if not isFinite(height) then
    height = minSize
  end
  if widgetId == "art" then
    if width > hostW then
      width = hostW
    end
    if height > hostH then
      height = hostH
    end
    if left < 0 then
      left = 0
    end
    if bottom < 0 then
      bottom = 0
    end
    if left + width > hostW then
      left = math.max(0, hostW - width)
    end
    if bottom + height > hostH then
      bottom = math.max(0, hostH - height)
    end
  else
    if width > hostW * 2 then
      width = hostW
    end
    if height > hostH * 2 then
      height = hostH
    end
    if left < -hostW or left > hostW * 2 then
      left = 0
    end
    if bottom < -hostH or bottom > hostH * 2 then
      bottom = 0
    end
  end
  if width < minSize then
    width = minSize
  end
  if height < minSize then
    height = minSize
  end
  return { left = left, bottom = bottom, width = width, height = height }
end

local function regionOf(host, widgetId)
  if not host then
    return nil
  end
  if host.widgets and host.widgets[widgetId] then
    return host.widgets[widgetId]
  end
  return host[widgetId]
end

local function placeOne(host, spec, relative)
  if not spec or spec.enabled == false then
    return
  end
  local region = relative and relative.region
  if not region then
    return
  end
  if spec.width and spec.height and region.SetSize then
    region:SetSize(spec.width, spec.height)
  else
    if spec.width and region.SetWidth then
      region:SetWidth(spec.width)
    end
    if spec.height and region.SetHeight then
      region:SetHeight(spec.height)
    end
  end
  if region.ClearAllPoints then
    region:ClearAllPoints()
  end
  if not region.SetPoint then
    return
  end
  local target = relative.anchor or host
  region:SetPoint(
    spec.point or "TOPLEFT",
    target,
    spec.relativePoint or spec.point or "TOPLEFT",
    spec.x or 0,
    spec.y or 0
  )
end

function Addon:PlaceUnitWidgets(host, frameLayout)
  if not host or type(frameLayout) ~= "table" then
    return
  end
  local width, height = self:UnitFrameHostSize(frameLayout)
  if host.SetSize then
    host:SetSize(width, height)
  end
  host.unitFrameLayout = frameLayout
  local placed = {}
  local function resolveAnchor(spec)
    if spec.relativeTo and spec.relativeTo ~= "" then
      return regionOf(host, spec.relativeTo)
    end
    return host
  end
  local function pass(wantRelative)
    for _, id in ipairs(self.UNIT_WIDGET_ORDER) do
      local spec = frameLayout[id]
      if type(spec) == "table" and not placed[id] then
        local hasRelative = type(spec.relativeTo) == "string" and spec.relativeTo ~= ""
        if hasRelative == wantRelative then
          local anchor = resolveAnchor(spec)
          if anchor then
            placeOne(host, spec, { region = regionOf(host, id), anchor = anchor })
            placed[id] = true
          end
        end
      end
    end
  end
  pass(false)
  pass(true)
  self:ApplyUnitWidgetStack(host, frameLayout)
  local artRegion = regionOf(host, "art")
  local artTex = artRegion and (artRegion.texture or artRegion)
  if artTex and self.PaintUnitFrameArt then
    local rects = self:ResolveWidgetRects(frameLayout)
    self:PaintUnitFrameArt(artTex, host.unitFrameId, rects.art)
  end
end

function Addon:ApplyUnitWidgetStack(host, frameLayout)
  if not host or type(frameLayout) ~= "table" then
    return
  end
  local base = (host.GetFrameLevel and host:GetFrameLevel()) or host.level or 1
  for _, id in ipairs(self.UNIT_WIDGET_ORDER or {}) do
    local spec = frameLayout[id]
    local region = regionOf(host, id)
    if type(spec) == "table" and spec.enabled ~= false and region then
      local stack = self:WidgetStack(spec, id)
      if region.SetFrameLevel then
        region:SetFrameLevel(base + stack)
      elseif region.SetDrawLayer then
        local sub = stack - 8
        if sub < -8 then
          sub = -8
        end
        if sub > 7 then
          sub = 7
        end
        region:SetDrawLayer("ARTWORK", sub)
      end
    end
  end
end

function Addon:PersistWidgetGeometry(frameId, widgetId, childRect)
  if not frameId or not widgetId or not isWidgetKey(widgetId) then
    return
  end
  if type(childRect) ~= "table" then
    return
  end
  local cfg = (self.ResolveEffective and self:ResolveEffective()) or {}
  local applied = self:UnitFrameLayoutForApply(cfg.layout or {}, frameId)
  local spec = self:UnitWidgetLayout(applied, widgetId)
  if type(spec) ~= "table" then
    return
  end
  local rects = self:ResolveWidgetRects(applied)
  local relative = rects.host
  if spec.relativeTo and spec.relativeTo ~= "" and spec.relativeTo ~= "host" then
    relative = rects[spec.relativeTo] or rects.host
  end
  local hostW, hostH = self:UnitFrameHostSize(applied)
  childRect = self:ClampWidgetRect(widgetId, childRect, hostW, hostH)
  local geometry = self:WidgetGeometryFromRect(spec, childRect, relative)
  local patch = { [widgetId] = geometry }
  if self.WriteProfileDelta then
    self:WriteProfileDelta("layout", frameId, patch)
  end
  if self.RefreshUnitStudio then
    self:RefreshUnitStudio()
  end
  local host = self.unitFrames and self.unitFrames[frameId]
  if host and self.UpdateUnitFrameLayout then
    local nextLayout = self:UnitFrameLayoutForApply(
      ((self.ResolveEffective and self:ResolveEffective()) or {}).layout or {},
      frameId
    )
    self:UpdateUnitFrameLayout(host, nextLayout)
  end
  return patch
end

function Addon:NudgeWidgetStack(frameId, widgetId, delta)
  if not frameId or not widgetId or not isWidgetKey(widgetId) then
    return
  end
  local cfg = (self.ResolveEffective and self:ResolveEffective()) or {}
  local applied = self:UnitFrameLayoutForApply(cfg.layout or {}, frameId)
  local spec = self:UnitWidgetLayout(applied, widgetId)
  local stack = self:WidgetStack(spec, widgetId) + (tonumber(delta) or 0)
  local minS = self.UNIT_WIDGET_STACK_MIN or 1
  local maxS = self.UNIT_WIDGET_STACK_MAX or 16
  if stack < minS then
    stack = minS
  end
  if stack > maxS then
    stack = maxS
  end
  if self.WriteProfileDelta then
    self:WriteProfileDelta("layout", frameId, { [widgetId] = { stack = stack } })
  end
  if self.RefreshUnitStudio then
    self:RefreshUnitStudio()
  end
  local host = self.unitFrames and self.unitFrames[frameId]
  if host and self.UpdateUnitFrameLayout then
    local nextLayout = self:UnitFrameLayoutForApply(
      ((self.ResolveEffective and self:ResolveEffective()) or {}).layout or {},
      frameId
    )
    self:UpdateUnitFrameLayout(host, nextLayout)
  end
  return stack
end

function Addon:PersistWidgetPosition(host, frameId, widgetId, rect)
  if not host or not frameId or not widgetId then
    return
  end
  local child = rect
  if not child then
    local region = regionOf(host, widgetId)
    local screen = self:RegionScreenRect(region)
    local hostRect = self:RegionScreenRect(host)
    if screen and hostRect then
      child = {
        left = screen.left - hostRect.left,
        bottom = screen.bottom - hostRect.bottom,
        width = screen.width,
        height = screen.height,
      }
    end
  end
  return self:PersistWidgetGeometry(frameId, widgetId, child)
end

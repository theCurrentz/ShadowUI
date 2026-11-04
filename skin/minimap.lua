--[[
  Purpose: Square the Forever Blizzard minimap in place. Hide the compass ring
           and the Forever day/night dial (DielFrame), which sits on the map
           face and blocks pings. A Darken fade square plus Outer Edge sits
           behind the map. Cluster header widgets stay: Zone Text, Time,
           calendar, mail, tracking. Map-edge icons sit on the SexyMap square
           path, including late LFG, ItemRack, and LibDBIcon buttons. World
           Layer from Nova World Buffs sits on the bottom of the holder. The
           mouse wheel zooms. After 5 seconds the map zooms out. Left-click
           pings the full square face (Blizzard only accepts the inscribed
           circle). The player can drag every map-edge icon.
  Deps: ShadowUI:LockVertex(), ShadowUI:ApplyOuterChrome(),
        ShadowUI:SkinTime()
  Public: ShadowUI:SkinMinimap()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local MAP = 160
local BUFFER = 16
local FILL = 0.6
local ICON_PAD = 10
local ZOOM_DELAY = 5
-- SexyMap Shapes.lua Square: file 130871 / Interface\BUTTONS\WHITE8X8.
-- A full-white mask removes the default circular clip.
local MASK = "Interface\\BUTTONS\\WHITE8X8"
local MASK_FALLBACK = "Interface\\ChatFrame\\ChatFrameBackground"
local MASK_ROUND = "Textures\\MinimapMask"
-- SexyMap square geometry: linear interpolation between corners.
-- Angle 0 is east; 90 is north. Icons sit on this path, not the old circle.
local SQUARE = {
  { a = 0, x = 1, y = 0 },
  { a = 45, x = 1, y = 1 },
  { a = 135, x = -1, y = 1 },
  { a = 225, x = -1, y = -1 },
  { a = 315, x = 1, y = -1 },
  { a = 360, x = 1, y = 0 },
}
local HIDE = {
  "MinimapBorder",
  "MinimapNorthTag",
  "MinimapCompassTexture",
  "MiniMapWorldMapButton",
}
local DARKEN = {
  "MiniMapMailBorder",
  "MiniMapTrackingBorder",
  "MiniMapTrackingBackground",
  "MinimapBorderTop",
}
-- Map-edge buttons that may parent to the cluster. Header widgets stay put.
local EDGE = {
  LFGMinimapFrame = true,
  MiniMapLFGFrame = true,
  MiniMapBattlefieldFrame = true,
  QueueStatusMinimapButton = true,
  QueueStatusButton = true,
  MiniMapInstanceDifficulty = true,
  GuildInstanceDifficulty = true,
  MiniMapChallengeMode = true,
}
local HEADER = {
  MinimapZoneText = true,
  MinimapZoneTextButton = true,
  TimeManagerClockButton = true,
  TimeManagerClockTicker = true,
  GameTimeFrame = true,
  GameTimeTexture = true,
  MiniMapMailFrame = true,
  MiniMapMailIcon = true,
  MiniMapMailBorder = true,
  MiniMapTracking = true,
  MiniMapTrackingFrame = true,
  MiniMapTrackingButton = true,
  MiniMapTrackingIcon = true,
  MiniMapTrackingBorder = true,
  MiniMapTrackingBackground = true,
  MinimapBorderTop = true,
  MinimapClusterTracking = true,
  MinimapClusterIndicatorFrame = true,
}
local IGNORE = {
  Minimap = true,
  MinimapCluster = true,
  MinimapContainer = true,
  ShadowUIMinimapHolder = true,
  ShadowUIMinimapIconWatch = true,
  MiniMapMailBorder = true,
  MiniMapMailIcon = true,
  MiniMapTrackingBorder = true,
  MiniMapTrackingBackground = true,
  MiniMapTrackingButton = true,
  MiniMapTrackingIcon = true,
  MiniMapBattlefieldIcon = true,
  MinimapLayerFrame = true,
  MinimapLayerFrameFS = true,
  NWBVersionDragTooltip = true,
  ShadowUIMinimapIconDrag = true,
  GameTimeFrame = true,
  GameTimeTexture = true,
  TimeManagerClockButton = true,
  TimeManagerClockTicker = true,
  MinimapZoomIn = true,
  MinimapZoomOut = true,
  HybridMinimap = true,
}
for i = 1, #HIDE do
  IGNORE[HIDE[i]] = true
end
for name in pairs(HEADER) do
  IGNORE[name] = true
end

local function useShadowUIMinimap()
  local get = Addon.GetCharDB
  if not get then
    return true
  end
  local char = get(Addon)
  return not char or char.useShadowUIMinimap ~= false
end

_G.GetMinimapShape = function()
  if useShadowUIMinimap() then
    return "SQUARE"
  end
  return "ROUND"
end

-- SexyMap calls Frame methods from a dummy so hooked Minimap methods do not
-- recurse. FontString methods must come from a FontString dummy; Frame.Show
-- and Frame.SetFrameStrata reject MinimapZoneText in the client.
local proto = CreateFrame and CreateFrame("Frame")
local protoButton = CreateFrame and CreateFrame("Button")
local protoFont = protoButton and protoButton.CreateFontString
  and protoButton:CreateFontString()
local function native(host, method, ...)
  local fn = proto and proto[method]
  if fn then
    return fn(host, ...)
  end
  if host and host[method] then
    return host[method](host, ...)
  end
end

local holder
local dragHost
local applyingMask
local placing
local dragging
local watchingAddons
local watchingCreate
local zoomArmed
local pingArmed
local zoomStarted, zoomCurrent = 0, 0
local parkIcon
local makeMovable
local keepHolder
local origMinimapOnClick

local function regionName(region)
  if not region then
    return nil
  end
  if region.GetName then
    return region:GetName()
  end
  return region.name
end

local function hideStay(region)
  if not region then
    return
  end
  if region.Hide then
    region:Hide()
  end
  if region.Show then
    if not region._shadowUIShow then
      region._shadowUIShow = region.Show
    end
    region.Show = region.Hide
  end
end

local function restoreStay(region)
  if not region then
    return
  end
  if region._shadowUIShow then
    region.Show = region._shadowUIShow
    region._shadowUIShow = nil
  end
  if region.Show then
    region:Show()
  end
end

local function squareOffset(angle, radius)
  if angle < 0 then
    angle = 360 + angle
  end
  angle = angle % 360
  local pre, post = SQUARE[1], SQUARE[#SQUARE]
  for i = 1, #SQUARE do
    local key = SQUARE[i]
    if key.a <= angle then
      pre = key
    else
      post = key
      break
    end
  end
  local span = post.a - pre.a
  local pct = 0
  if span ~= 0 then
    pct = (angle - pre.a) / span
  end
  local x = pre.x + ((post.x - pre.x) * pct)
  local y = pre.y + ((post.y - pre.y) * pct)
  return x * radius, y * radius
end

local function compassAngle(dx, dy)
  -- SexyMap Buttons.lua: atan(h/w) in degrees, then +180 when west.
  local w = dx
  local h = dy
  if not w or not h then
    return 225
  end
  if w == 0 and h == 0 then
    return 225
  end
  if w == 0 then
    w = 0.001
  end
  local angle
  if atan then
    angle = atan(h / w)
  else
    angle = math.deg(math.atan(h / w))
  end
  if w < 0 then
    angle = angle + 180
  end
  return angle
end

local function mapSize()
  local width, height = 0, 0
  if Minimap and Minimap.GetWidth then
    width = Minimap:GetWidth() or 0
  end
  if Minimap and Minimap.GetHeight then
    height = Minimap:GetHeight() or 0
  end
  if width <= 0 then
    width = MAP
  end
  if height <= 0 then
    height = MAP
  end
  return width, height
end

local function mapParent()
  if Minimap and Minimap.GetParent then
    local parent = Minimap:GetParent()
    if parent then
      return parent
    end
  end
  return MinimapCluster or UIParent
end

local function applyHybridMask(path)
  local hybrid = _G.HybridMinimap
  if not hybrid then
    return
  end
  local canvas = hybrid.MapCanvas
  local mask = hybrid.CircleMask
  if canvas and canvas.SetUseMaskTexture then
    canvas:SetUseMaskTexture(false)
  end
  if mask and mask.SetTexture then
    mask:SetTexture(path)
  end
  if canvas and canvas.SetUseMaskTexture then
    canvas:SetUseMaskTexture(true)
  end
end

local function applyMask()
  if applyingMask or not useShadowUIMinimap() or not Minimap or not Minimap.SetMaskTexture then
    return
  end
  applyingMask = true
  if not pcall(Minimap.SetMaskTexture, Minimap, MASK) then
    pcall(Minimap.SetMaskTexture, Minimap, MASK_FALLBACK)
  end
  applyHybridMask(MASK)
  applyingMask = false
end

local function muteBlobRing()
  if not Minimap then
    return
  end
  pcall(Minimap.SetArchBlobRingScalar, Minimap, 0)
  pcall(Minimap.SetArchBlobRingAlpha, Minimap, 0)
  pcall(Minimap.SetQuestBlobRingScalar, Minimap, 0)
  pcall(Minimap.SetQuestBlobRingAlpha, Minimap, 0)
end

local function ensureHolder()
  if holder then
    return holder
  end
  holder = CreateFrame("Frame", "ShadowUIMinimapHolder", UIParent)
  holder:SetFrameStrata("BACKGROUND")
  if holder.SetFrameLevel then
    holder:SetFrameLevel(1)
  end
  if holder.SetFixedFrameStrata then
    holder:SetFixedFrameStrata(true)
  end
  if holder.SetFixedFrameLevel then
    holder:SetFixedFrameLevel(true)
  end
  local fill = holder:CreateTexture(nil, "BACKGROUND", nil, -8)
  holder.shadowUIBackdrop = fill
  fill:SetAllPoints(holder)
  local black = Addon.DARKEN_BLACK or { 0.05, 0.05, 0.05 }
  fill:SetColorTexture(black[1], black[2], black[3], FILL)
  return holder
end

local function paintHolderFade()
  if not holder or not holder.shadowUIBackdrop then
    return
  end
  local black = Addon.DARKEN_BLACK or { 0.05, 0.05, 0.05 }
  holder.shadowUIBackdrop:SetColorTexture(black[1], black[2], black[3], FILL)
end

keepHolder = function()
  if placing or not useShadowUIMinimap() or not holder or not Minimap then
    return
  end
  placing = true
  local parent = mapParent()
  native(holder, "SetParent", parent)
  native(holder, "ClearAllPoints")
  native(holder, "SetPoint", "CENTER", Minimap, "CENTER")
  local width, height = mapSize()
  native(holder, "SetSize", width + BUFFER * 2, height + BUFFER * 2)
  placing = false
end

local function zoomButton(delta)
  local map = Minimap
  local button
  if delta > 0 then
    button = (map and map.ZoomIn) or _G.MinimapZoomIn
  else
    button = (map and map.ZoomOut) or _G.MinimapZoomOut
  end
  if button and button.Click then
    button:Click()
  end
end

local function zoomOut()
  zoomCurrent = zoomCurrent + 1
  if zoomStarted ~= zoomCurrent then
    return
  end
  local levels = 0
  if Minimap and Minimap.GetZoom then
    levels = Minimap:GetZoom() or 0
  end
  for _ = 1, levels do
    if Minimap_ZoomOutClick then
      Minimap_ZoomOutClick()
    elseif Minimap and Minimap.ZoomOut and Minimap.ZoomOut.Click then
      Minimap.ZoomOut:Click()
    end
  end
  zoomStarted, zoomCurrent = 0, 0
end

local function scheduleZoomOut()
  zoomStarted = zoomStarted + 1
  if C_Timer and C_Timer.After then
    C_Timer.After(ZOOM_DELAY, zoomOut)
  end
end

local function onMouseWheel(_, delta)
  zoomButton(delta)
end

local function watchZoom()
  if zoomArmed or not Minimap then
    return
  end
  zoomArmed = true
  if Minimap.EnableMouseWheel then
    Minimap:EnableMouseWheel(true)
  end
  if Minimap.SetScript then
    Minimap:SetScript("OnMouseWheel", onMouseWheel)
  end
  local function hookZoom(button)
    if not button then
      return
    end
    if button.HookScript then
      button:HookScript("OnClick", scheduleZoomOut)
    end
  end
  hookZoom(Minimap.ZoomIn)
  hookZoom(Minimap.ZoomOut)
  hookZoom(_G.MinimapZoomIn)
  hookZoom(_G.MinimapZoomOut)
  scheduleZoomOut()
end

-- Blizzard MinimapMixin:OnClick only pings inside the inscribed circle. A
-- square mask still receives corner clicks, so replace OnClick while the
-- ShadowUI map is on.
local function squarePingClick(self)
  if not self or not GetCursorPosition or not self.PingLocation then
    return
  end
  local x, y = GetCursorPosition()
  local scale = 1
  if self.GetEffectiveScale then
    scale = self:GetEffectiveScale() or 1
  end
  if scale == 0 then
    scale = 1
  end
  x, y = x / scale, y / scale
  local cx, cy = 0, 0
  if self.GetCenter then
    cx, cy = self:GetCenter()
  end
  x, y = x - (cx or 0), y - (cy or 0)
  local halfW, halfH = 0, 0
  if self.GetWidth then
    halfW = (self:GetWidth() or 0) / 2
  end
  if self.GetHeight then
    halfH = (self:GetHeight() or 0) / 2
  end
  if math.abs(x) <= halfW and math.abs(y) <= halfH then
    self:PingLocation(x, y)
  end
end

local function armSquarePing()
  if not Minimap or not Minimap.SetScript then
    return
  end
  if not pingArmed then
    if Minimap.GetScript then
      origMinimapOnClick = Minimap:GetScript("OnClick")
    end
    pingArmed = true
  end
  Minimap:SetScript("OnClick", squarePingClick)
end

local function restorePingClick()
  if not pingArmed or not Minimap or not Minimap.SetScript then
    return
  end
  Minimap:SetScript("OnClick", origMinimapOnClick)
end

local function hideDielFrame()
  local diel = MinimapCluster and MinimapCluster.DielFrame
  hideStay(diel)
end

local function restoreDielFrame()
  local diel = MinimapCluster and MinimapCluster.DielFrame
  restoreStay(diel)
end

local function watchMinimap()
  if not Minimap or Minimap._shadowUISquare or not hooksecurefunc then
    return
  end
  Minimap._shadowUISquare = true
  hooksecurefunc(Minimap, "SetMaskTexture", function(_, path)
    if applyingMask or not useShadowUIMinimap() then
      return
    end
    if path ~= MASK and path ~= MASK_FALLBACK then
      applyMask()
    end
  end)
  hooksecurefunc(Minimap, "SetParent", keepHolder)
  hooksecurefunc(Minimap, "SetPoint", keepHolder)
  if Minimap.HookScript then
    Minimap:HookScript("OnShow", applyMask)
  end
end

local function savedIcons()
  local get = Addon.GetCharDB
  if not get then
    return {}
  end
  local char = get(Addon)
  if not char then
    return {}
  end
  if not char.minimapIcons then
    char.minimapIcons = {}
  end
  return char.minimapIcons
end

local function iconAngle(frame)
  local name = regionName(frame)
  local saved = name and savedIcons()[name]
  if saved then
    return saved
  end
  local x, y
  if frame.GetPoint then
    local _, _, _, px, py = frame:GetPoint(1)
    x, y = px, py
  end
  return compassAngle(x, y)
end

local function headerParent(parent)
  if not parent then
    return false
  end
  if parent == MinimapCluster then
    return true
  end
  if MinimapCluster then
    if parent == MinimapCluster.Tracking then
      return true
    end
    if parent == MinimapCluster.IndicatorFrame then
      return true
    end
    if parent == MinimapCluster.BorderTop then
      return true
    end
    if parent == MinimapCluster.ZoneTextButton then
      return true
    end
  end
  return false
end

local function isEdgeIcon(frame)
  local name = regionName(frame)
  if not name or IGNORE[name] then
    return false
  end
  local kind = frame.objectType or (frame.GetObjectType and frame:GetObjectType())
  if kind == "FontString" then
    return false
  end
  if name:find("Coord", 1, true) then
    return false
  end
  if HEADER[name] then
    return false
  end
  if EDGE[name] then
    return true
  end
  local parent = frame.GetParent and frame:GetParent()
  if headerParent(parent) and not EDGE[name] then
    return false
  end
  if name:find("LibDBIcon", 1, true) then
    return true
  end
  if name:find("ItemRack", 1, true) then
    if name == "ItemRackMenuFrame" or name == "ItemRackFrame"
        or name:find("ItemRackMenu", 1, true)
        or name:find("ItemRackButton", 1, true) then
      return false
    end
    return true
  end
  if name:find("MinimapButton", 1, true) then
    return true
  end
  if name:find("QueueStatus", 1, true) then
    return true
  end
  if parent == Minimap or parent == _G.MinimapBackdrop
      or parent == _G.MinimapContainer then
    if name:find("MiniMap", 1, true) or name:find("Minimap", 1, true) then
      return true
    end
  end
  return false
end

local function ensureDragHost()
  if dragHost then
    return dragHost
  end
  dragHost = CreateFrame("Frame", "ShadowUIMinimapIconDrag")
  return dragHost
end

local function iconRadius()
  local width = MAP
  if Minimap and Minimap.GetWidth then
    local live = Minimap:GetWidth()
    if live and live > 0 then
      width = live
    end
  end
  return (width / 2) + ICON_PAD
end

makeMovable = function(frame)
  if not frame or frame._shadowUIDrag then
    return
  end
  frame._shadowUIDrag = true
  if frame.EnableMouse then
    frame:EnableMouse(true)
  end
  if frame.RegisterForDrag then
    frame:RegisterForDrag("LeftButton")
  end
  local function start()
    dragging = true
    local host = ensureDragHost()
    if not host.SetScript then
      return
    end
    host:SetScript("OnUpdate", function()
      if not GetCursorPosition or not Minimap then
        return
      end
      local x, y = GetCursorPosition()
      local scale = 1
      if Minimap.GetEffectiveScale then
        scale = Minimap:GetEffectiveScale() or 1
      end
      if scale == 0 then
        scale = 1
      end
      x, y = x / scale, y / scale
      local mx, my = 0, 0
      if Minimap.GetCenter then
        mx, my = Minimap:GetCenter()
      end
      local angle = compassAngle(x - mx, y - my)
      local name = regionName(frame)
      if name then
        savedIcons()[name] = angle
      end
      parkIcon(frame, angle)
    end)
  end
  local function stop()
    dragging = false
    local host = ensureDragHost()
    if host.SetScript then
      host:SetScript("OnUpdate", nil)
    end
  end
  if frame.SetScript then
    frame:SetScript("OnDragStart", start)
    frame:SetScript("OnDragStop", stop)
  end
end

parkIcon = function(frame, angle)
  if not frame or not useShadowUIMinimap() then
    return
  end
  angle = angle or iconAngle(frame)
  local x, y = squareOffset(angle, iconRadius())
  placing = true
  native(frame, "SetParent", Minimap)
  native(frame, "ClearAllPoints")
  native(frame, "SetPoint", "CENTER", Minimap, "CENTER", x, y)
  native(frame, "SetFrameStrata", "MEDIUM")
  native(frame, "SetFrameLevel", 8)
  if frame.SetFixedFrameStrata then
    native(frame, "SetFixedFrameStrata", true)
  end
  if frame.SetFixedFrameLevel then
    native(frame, "SetFixedFrameLevel", true)
  end
  placing = false
  makeMovable(frame)
  if frame._shadowUIWatch or not hooksecurefunc then
    return
  end
  frame._shadowUIWatch = true
  hooksecurefunc(frame, "SetPoint", function()
    if placing or dragging then
      return
    end
    parkIcon(frame, iconAngle(frame))
  end)
  hooksecurefunc(frame, "SetParent", function()
    if placing or dragging then
      return
    end
    parkIcon(frame, iconAngle(frame))
  end)
end

local function parkHostIcons(host)
  if not host or not host.GetChildren then
    return
  end
  local children = { host:GetChildren() }
  for i = 1, #children do
    local child = children[i]
    if isEdgeIcon(child) then
      parkIcon(child, iconAngle(child))
    end
  end
end

local function parkLibDBIcons()
  local ldbi = LibStub and LibStub("LibDBIcon-1.0", true)
  if not ldbi then
    return
  end
  local buttons = ldbi.GetButtonList and ldbi:GetButtonList()
  if type(buttons) ~= "table" then
    return
  end
  for i = 1, #buttons do
    local button = ldbi.GetMinimapButton and ldbi:GetMinimapButton(buttons[i])
    if not button and type(buttons[i]) == "string" then
      button = _G["LibDBIcon10_" .. buttons[i]]
    end
    parkIcon(button)
  end
end

local function parkAllIcons()
  for name in pairs(EDGE) do
    parkIcon(_G[name])
  end
  if MinimapCluster and MinimapCluster.InstanceDifficulty then
    parkIcon(MinimapCluster.InstanceDifficulty)
  end
  parkHostIcons(Minimap)
  parkHostIcons(_G.MinimapBackdrop)
  parkHostIcons(_G.MinimapContainer)
  parkLibDBIcons()
end

local function parkWorldLayer()
  local frame = _G.MinimapLayerFrame
  if not frame or not Minimap then
    return
  end
  local box = ensureHolder()
  placing = true
  native(frame, "SetParent", box)
  native(frame, "ClearAllPoints")
  native(frame, "SetPoint", "BOTTOM", Minimap, "BOTTOM", 0, 4)
  native(frame, "SetFrameStrata", "HIGH")
  native(frame, "SetFrameLevel", 9)
  native(frame, "Show")
  placing = false
  if frame._shadowUIWorldLayer or not hooksecurefunc then
    return
  end
  frame._shadowUIWorldLayer = true
  hooksecurefunc(frame, "SetPoint", function()
    if placing or dragging then
      return
    end
    parkWorldLayer()
  end)
  hooksecurefunc(frame, "SetParent", function()
    if placing or dragging then
      return
    end
    parkWorldLayer()
  end)
end

local function passTrackingClicks()
  local button = _G.MiniMapTrackingButton
  if not button then
    return
  end
  if button.SetPropagateMouseClicks then
    button:SetPropagateMouseClicks(true)
  end
  if button.SetPropagateMouseMotion then
    button:SetPropagateMouseMotion(true)
  end
end

local function watchLateIcons()
  if watchingAddons or not CreateFrame then
    return
  end
  watchingAddons = true
  local watch = CreateFrame("Frame", "ShadowUIMinimapIconWatch")
  if watch.RegisterEvent then
    watch:RegisterEvent("ADDON_LOADED")
  end
  if watch.SetScript then
    watch:SetScript("OnEvent", function(_, _, name)
      if name == "Blizzard_GroupFinder_VanillaStyle"
        or name == "Blizzard_LookingForGroupUI"
        or name == "Blizzard_TimeManager"
        or name == "Blizzard_HybridMinimap"
        or name == "NovaWorldBuffs"
        or name == "ItemRack" then
        Addon:SkinMinimap()
      end
    end)
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(1, function()
      Addon:SkinMinimap()
    end)
  end
  local ldbi = LibStub and LibStub("LibDBIcon-1.0", true)
  if ldbi and ldbi.RegisterCallback then
    ldbi.RegisterCallback(Addon, "LibDBIcon_IconCreated", function(_, button)
      if type(button) == "table" then
        parkIcon(button, iconAngle(button))
      end
    end)
  end
  if watchingCreate or not hooksecurefunc then
    return
  end
  watchingCreate = true
  hooksecurefunc("CreateFrame", function(_, name, parent)
    if placing or dragging then
      return
    end
    if type(name) == "string" and name:find("ShadowUI", 1, true) then
      return
    end
    if name == "MinimapLayerFrame" then
      parkWorldLayer()
      return
    end
    if name == "TimeManagerClockButton" then
      Addon:SkinTime()
      return
    end
    if parent ~= Minimap and parent ~= _G.MinimapCluster
        and parent ~= _G.MinimapBackdrop and parent ~= _G.MinimapContainer then
      return
    end
    if type(name) == "string" and IGNORE[name] then
      return
    end
    local frame = type(name) == "string" and _G[name]
    if isEdgeIcon(frame) then
      parkIcon(frame, iconAngle(frame))
    end
  end)
end

local function restoreBlizzardMinimap()
  if holder then
    native(holder, "Hide")
    if holder.shadowUIOuter and holder.shadowUIOuter.Hide then
      holder.shadowUIOuter:Hide()
    end
  end
  if not Minimap then
    return
  end
  applyingMask = true
  if Minimap.SetMaskTexture then
    pcall(Minimap.SetMaskTexture, Minimap, MASK_ROUND)
  end
  applyHybridMask(MASK_ROUND)
  applyingMask = false
  restorePingClick()
  restoreDielFrame()
  for _, name in ipairs(HIDE) do
    restoreStay(_G[name])
  end
end

function Addon:SkinMinimap()
  if not Minimap or not MinimapCluster or not CreateFrame then
    return
  end
  if not useShadowUIMinimap() then
    restoreBlizzardMinimap()
    if self.SkinTime then
      self:SkinTime()
    end
    return
  end

  local box = ensureHolder()
  paintHolderFade()
  keepHolder()
  native(box, "Show")
  self:ApplyOuterChrome(box)

  applyMask()
  muteBlobRing()
  watchMinimap()
  watchZoom()
  armSquarePing()
  watchLateIcons()
  parkAllIcons()
  parkWorldLayer()
  passTrackingClicks()
  self:SkinTime()

  for _, name in ipairs(HIDE) do
    hideStay(_G[name])
  end
  hideDielFrame()
  -- Hide and EnableMouse on MinimapCluster raise ADDON_ACTION_FORBIDDEN.

  for _, name in ipairs(DARKEN) do
    self:LockVertex(_G[name], self.DARKEN_BLACK)
  end
  if self.DarkenFrameRegions then
    self:DarkenFrameRegions(MinimapCluster.BorderTop, self.DARKEN_BLACK)
    self:DarkenFrameRegions(_G.MinimapBorderTop, self.DARKEN_BLACK)
  end
end

--[[
  Purpose: Square the Blizzard minimap the SexyMap way, inside a Darken buffer
           with Zone Text on top and an Outer Edge. Cluster icons sit on the
           square path, including late LFG, ItemRack, and LibDBIcon buttons.
           World Layer from Nova World Buffs sits on the bottom of the holder.
           Time is Blizzard TimeManagerClockButton, restyled under the map.
           GameTimeFrame stays hidden. The mouse wheel zooms. After 5 seconds
           the map zooms out. The player can drag every minimap icon.
  Deps: ShadowUI:LockVertex(), ShadowUI:DarkenFrameRegions(), ShadowUI:ApplyOuterChrome(),
        ShadowUI:SkinTime()
  Public: ShadowUI:SkinMinimap()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local MAP = 160
local BUFFER = 16
local ZONE_GAP = 3
local ZONE_TOP = 4
local FILL = 0.6
local ICON_PAD = 10
local ZOOM_DELAY = 5
-- SexyMap Shapes.lua Square: file 130871 / Interface\BUTTONS\WHITE8X8.
-- A full-white mask removes the default circular clip.
local MASK = "Interface\\BUTTONS\\WHITE8X8"
local MASK_FALLBACK = "Interface\\ChatFrame\\ChatFrameBackground"
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
  "MinimapBorderTop",
  "MinimapNorthTag",
  "MinimapBackdrop",
  "MinimapCompassTexture",
  "MiniMapWorldMapButton",
  "MinimapToggleButton",
  "GameTimeFrame",
  "MinimapZoomIn",
  "MinimapZoomOut",
}
local DARKEN = {
  "MiniMapMailBorder",
  "MiniMapTrackingBorder",
  "MiniMapTrackingBackground",
}
-- Blizzard cluster buttons keep XML points on the circle. Park them on the
-- square at the same compass angles SexyMap would use. LFG loads after the
-- first PLAYER_ENTERING_WORLD skin.
local ICONS = {
  { name = "MiniMapTrackingFrame", angle = 135 },
  { name = "MiniMapTracking", angle = 135 },
  { name = "MiniMapMailFrame", angle = 315 },
  { name = "MiniMapBattlefieldFrame", angle = 45 },
  { name = "LFGMinimapFrame", angle = 225 },
  { name = "MiniMapLFGFrame", angle = 225 },
}
local ICON_ANGLE = {}
for i = 1, #ICONS do
  ICON_ANGLE[ICONS[i].name] = ICONS[i].angle
end
local IGNORE = {
  Minimap = true,
  MinimapCluster = true,
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
}
for i = 1, #HIDE do
  IGNORE[HIDE[i]] = true
end

_G.GetMinimapShape = function()
  return "SQUARE"
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

local function nativeFont(host, method, ...)
  local fn = protoFont and protoFont[method]
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
local zoomStarted, zoomCurrent = 0, 0
local parkIcon
local makeMovable

local KEEP = {
  MinimapZoneText = true,
  MinimapZoneTextButton = true,
  MinimapLayerFrame = true,
}
for name in pairs(KEEP) do
  IGNORE[name] = true
end

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
  local name = regionName(region)
  if name and KEEP[name] then
    return
  end
  if region.Hide then
    region:Hide()
  end
  if region.Show then
    region.Show = region.Hide
  end
end

local function hideRegions(frame)
  if not frame or not frame.GetRegions then
    return
  end
  local regions = { frame:GetRegions() }
  for i = 1, #regions do
    hideStay(regions[i])
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

local function applyMask()
  if applyingMask or not Minimap or not Minimap.SetMaskTexture then
    return
  end
  applyingMask = true
  if not pcall(Minimap.SetMaskTexture, Minimap, MASK) then
    pcall(Minimap.SetMaskTexture, Minimap, MASK_FALLBACK)
  end
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
  holder:SetFrameStrata("LOW")
  if holder.SetFrameLevel then
    holder:SetFrameLevel(1)
  end
  local fill = holder:CreateTexture(nil, "BACKGROUND", nil, -8)
  holder.shadowUIBackdrop = fill
  fill:SetAllPoints(holder)
  fill:SetColorTexture(0.05, 0.05, 0.05, FILL)
  return holder
end

local function keepOnHolder()
  if placing or not holder or not Minimap then
    return
  end
  placing = true
  native(Minimap, "SetParent", holder)
  native(Minimap, "ClearAllPoints")
  native(Minimap, "SetPoint", "BOTTOM", holder, "BOTTOM", 0, BUFFER)
  native(Minimap, "SetSize", MAP, MAP)
  placing = false
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
  if delta > 0 then
    if MinimapZoomIn and MinimapZoomIn.Click then
      MinimapZoomIn:Click()
    end
  elseif delta < 0 then
    if MinimapZoomOut and MinimapZoomOut.Click then
      MinimapZoomOut:Click()
    end
  end
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
  hookZoom(_G.MinimapZoomIn)
  hookZoom(_G.MinimapZoomOut)
  scheduleZoomOut()
end

local function watchMinimap()
  if not Minimap or Minimap._shadowUISquare or not hooksecurefunc then
    return
  end
  Minimap._shadowUISquare = true
  hooksecurefunc(Minimap, "SetMaskTexture", function(_, path)
    if applyingMask then
      return
    end
    if path ~= MASK and path ~= MASK_FALLBACK then
      applyMask()
    end
  end)
  hooksecurefunc(Minimap, "SetParent", keepOnHolder)
  hooksecurefunc(Minimap, "SetPoint", keepOnHolder)
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
  if name and ICON_ANGLE[name] then
    return ICON_ANGLE[name]
  end
  local x, y
  if frame.GetPoint then
    local _, _, _, px, py = frame:GetPoint(1)
    x, y = px, py
  end
  return compassAngle(x, y)
end

local function isEdgeIcon(frame)
  local name = regionName(frame)
  if not name or IGNORE[name] then
    return false
  end
  if ICON_ANGLE[name] then
    return true
  end
  if name:find("LibDBIcon", 1, true) then
    return true
  end
  if name:find("ItemRack", 1, true) then
    return true
  end
  if name:find("MinimapButton", 1, true) then
    return true
  end
  if name:find("QueueStatus", 1, true) then
    return true
  end
  if name:find("MiniMap", 1, true) or name:find("Minimap", 1, true) then
    return true
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
  local radius = MAP / 2
  if Minimap and Minimap.GetWidth then
    local width = Minimap:GetWidth()
    if width and width > 0 then
      radius = width / 2
    end
  end
  return radius + ICON_PAD
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
  if not frame then
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
  for i = 1, #ICONS do
    parkIcon(_G[ICONS[i].name])
  end
  parkHostIcons(Minimap)
  parkHostIcons(_G.MinimapCluster)
  parkHostIcons(_G.MinimapBackdrop)
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

local function restoreTrackingIcon()
  if not GetTrackingTexture then
    return
  end
  local icon = GetTrackingTexture()
  if not icon then
    return
  end
  if MiniMapTrackingIcon and MiniMapTrackingIcon.SetTexture then
    MiniMapTrackingIcon:SetTexture(icon)
  end
  if MiniMapTracking and MiniMapTracking.Show then
    MiniMapTracking:Show()
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
    if parent ~= Minimap and parent ~= _G.MinimapCluster and parent ~= _G.MinimapBackdrop then
      return
    end
    if type(name) == "string" and IGNORE[name] then
      if name == "MinimapLayerFrame" then
        parkWorldLayer()
      elseif name == "TimeManagerClockButton" then
        Addon:SkinTime()
      elseif name == "GameTimeFrame" then
        hideStay(_G[name])
      end
      return
    end
    local frame = type(name) == "string" and _G[name]
    if isEdgeIcon(frame) then
      parkIcon(frame, iconAngle(frame))
    end
  end)
end

local function parkZoneText(box)
  local button = _G.MinimapZoneTextButton
  local text = _G.MinimapZoneText
  if button then
    native(button, "SetParent", box)
    native(button, "ClearAllPoints")
    if Minimap then
      native(button, "SetPoint", "BOTTOM", Minimap, "TOP", 0, ZONE_GAP)
    else
      native(button, "SetPoint", "TOP", box, "TOP", 0, 0)
    end
    native(button, "SetSize", MAP, BUFFER - ZONE_GAP)
    native(button, "SetFrameStrata", "MEDIUM")
    native(button, "SetFrameLevel", 4)
    if button.EnableMouse then
      button:EnableMouse(true)
    end
    native(button, "Show")
  end
  if not text then
    return
  end
  nativeFont(text, "SetParent", button or box)
  nativeFont(text, "ClearAllPoints")
  if button then
    nativeFont(text, "SetPoint", "CENTER", button, "CENTER")
  else
    nativeFont(text, "SetPoint", "TOP", box, "TOP", 0, 0)
  end
  if text.SetJustifyH then
    text:SetJustifyH("CENTER")
  end
  nativeFont(text, "Show")
end

function Addon:SkinMinimap()
  if not Minimap or not MinimapCluster or not CreateFrame then
    return
  end

  local box = ensureHolder()
  native(box, "ClearAllPoints")
  native(box, "SetPoint", "TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
  native(box, "SetSize", MAP + BUFFER * 2, MAP + BUFFER * 2 + ZONE_TOP)
  native(box, "Show")
  self:ApplyOuterChrome(box)

  placing = true
  native(Minimap, "SetParent", box)
  native(Minimap, "SetFrameStrata", "LOW")
  native(Minimap, "SetFrameLevel", 2)
  if Minimap.SetFixedFrameStrata then
    native(Minimap, "SetFixedFrameStrata", true)
  end
  if Minimap.SetFixedFrameLevel then
    native(Minimap, "SetFixedFrameLevel", true)
  end
  native(Minimap, "ClearAllPoints")
  native(Minimap, "SetPoint", "BOTTOM", box, "BOTTOM", 0, BUFFER)
  native(Minimap, "SetSize", MAP, MAP)
  native(Minimap, "SetWidth", MAP)
  native(Minimap, "SetHeight", MAP)
  placing = false

  applyMask()
  muteBlobRing()
  watchMinimap()
  watchZoom()
  watchLateIcons()
  parkAllIcons()
  parkWorldLayer()
  passTrackingClicks()
  restoreTrackingIcon()
  self:SkinTime()

  if MinimapCluster.EnableMouse then
    MinimapCluster:EnableMouse(false)
  end
  hideRegions(MinimapCluster)
  hideRegions(_G.MinimapBackdrop)
  for _, name in ipairs(HIDE) do
    hideStay(_G[name])
  end
  hideStay(MinimapCluster)
  parkZoneText(box)

  for _, name in ipairs(DARKEN) do
    self:LockVertex(_G[name], self.DARKEN_BLACK)
  end
  self:DarkenFrameRegions(_G.MiniMapTrackingButton, self.DARKEN_BLACK)
  self:DarkenFrameRegions(_G.MiniMapTrackingFrame, self.DARKEN_BLACK)
  self:DarkenFrameRegions(_G.MiniMapMailFrame, self.DARKEN_BLACK)
  self:DarkenFrameRegions(_G.LFGMinimapFrame, self.DARKEN_BLACK)
  self:DarkenFrameRegions(_G.MiniMapLFGFrame, self.DARKEN_BLACK)
end

--[[
  Purpose: Square the Blizzard minimap the SexyMap way, inside a Darken buffer
           with Zone Text on top and an Outer Edge. Cluster icons sit on the
           square path, including late LFG, ItemRack, and LibDBIcon buttons. World Layer
           from Nova World Buffs sits on the bottom of the holder. Blizzard Time sits
           on the map and opens the Stopwatch. The player can drag every minimap icon.
  Deps: ShadowUI:LockVertex(), ShadowUI:DarkenFrameRegions(), ShadowUI:ApplyOuterChrome()
  Public: ShadowUI:SkinMinimap()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local MAP = 160
local BUFFER = 16
local ZONE_GAP = 3
local ZONE_TOP = 4
local FILL = 0.6
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
  { name = "MiniMapTrackingButton", angle = 135 },
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
  MiniMapTrackingBorder = true,
  MiniMapTrackingBackground = true,
  MinimapLayerFrame = true,
  MinimapLayerFrameFS = true,
  NWBVersionDragTooltip = true,
  ShadowUIMinimapIconDrag = true,
  TimeManagerClockButton = true,
  TimeManagerClockTicker = true,
}
for i = 1, #HIDE do
  IGNORE[HIDE[i]] = true
end

_G.GetMinimapShape = function()
  return "SQUARE"
end

local holder
local dragHost
local applyingMask
local snapping
local dragging
local watchingAddons
local watchingCreate
local parkIcon
local makeMovable

local KEEP = {
  MinimapZoneText = true,
  MinimapZoneTextButton = true,
  MinimapLayerFrame = true,
  TimeManagerClockButton = true,
  TimeManagerClockTicker = true,
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
  angle = angle % 360
  if angle < 0 then
    angle = angle + 360
  end
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
  if snapping or not holder or not Minimap then
    return
  end
  Addon:SkinMinimap()
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

local function angleFromOffset(x, y)
  if not x or not y or (x == 0 and y == 0) then
    return 225
  end
  local rad
  if math.atan2 then
    rad = math.atan2(y, x)
  else
    rad = math.atan(y, x)
  end
  local angle = math.deg(rad)
  if angle < 0 then
    angle = angle + 360
  end
  return angle
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
  return angleFromOffset(x, y)
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
      local angle = angleFromOffset(x - mx, y - my)
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
  if frame.HookScript then
    frame:HookScript("OnDragStart", start)
    frame:HookScript("OnDragStop", stop)
  elseif frame.SetScript then
    frame:SetScript("OnDragStart", start)
    frame:SetScript("OnDragStop", stop)
  end
end

parkIcon = function(frame, angle)
  if not frame or not frame.SetPoint then
    return
  end
  angle = angle or iconAngle(frame)
  local radius = MAP / 2
  if Minimap and Minimap.GetWidth then
    local width = Minimap:GetWidth()
    if width and width > 0 then
      radius = width / 2
    end
  end
  local x, y = squareOffset(angle, radius)
  snapping = true
  if frame.SetParent then
    frame:SetParent(Minimap)
  end
  if frame.ClearAllPoints then
    frame:ClearAllPoints()
  end
  frame:SetPoint("CENTER", Minimap, "CENTER", x, y)
  if frame.SetFrameStrata then
    frame:SetFrameStrata("MEDIUM")
  end
  snapping = false
  makeMovable(frame)
  if frame._shadowUIWatch or not hooksecurefunc then
    return
  end
  frame._shadowUIWatch = true
  hooksecurefunc(frame, "SetPoint", function()
    if snapping or dragging then
      return
    end
    parkIcon(frame, iconAngle(frame))
  end)
  hooksecurefunc(frame, "SetParent", function()
    if snapping or dragging then
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
  if not frame or not frame.SetPoint or not Minimap then
    return
  end
  local box = ensureHolder()
  snapping = true
  if frame.SetParent then
    frame:SetParent(box)
  end
  if frame.ClearAllPoints then
    frame:ClearAllPoints()
  end
  frame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 4)
  if frame.SetFrameStrata then
    frame:SetFrameStrata("HIGH")
  end
  if frame.SetFrameLevel then
    frame:SetFrameLevel(9)
  end
  if frame.Show then
    frame:Show()
  end
  snapping = false
  if frame._shadowUIWorldLayer or not hooksecurefunc then
    return
  end
  frame._shadowUIWorldLayer = true
  hooksecurefunc(frame, "SetPoint", function()
    if snapping or dragging then
      return
    end
    parkWorldLayer()
  end)
  hooksecurefunc(frame, "SetParent", function()
    if snapping or dragging then
      return
    end
    parkWorldLayer()
  end)
end

local function loadTimeManager()
  if _G.TimeManagerClockButton then
    return
  end
  pcall(function()
    if C_AddOns and C_AddOns.LoadAddOn then
      C_AddOns.LoadAddOn("Blizzard_TimeManager")
    elseif LoadAddOn then
      LoadAddOn("Blizzard_TimeManager")
    end
  end)
end

local function parkBlizzardTime()
  loadTimeManager()
  local timeFrame = _G.TimeManagerClockButton
  if not timeFrame or not timeFrame.SetPoint or not Minimap then
    return
  end
  snapping = true
  if timeFrame.SetParent then
    timeFrame:SetParent(Minimap)
  end
  if timeFrame.ClearAllPoints then
    timeFrame:ClearAllPoints()
  end
  timeFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -2, 2)
  if timeFrame.SetFrameStrata then
    timeFrame:SetFrameStrata("MEDIUM")
  end
  if timeFrame.SetFrameLevel then
    timeFrame:SetFrameLevel(8)
  end
  if timeFrame.EnableMouse then
    timeFrame:EnableMouse(true)
  end
  if timeFrame.Show then
    timeFrame:Show()
  end
  snapping = false
  if timeFrame._shadowUIStopwatch then
    return
  end
  timeFrame._shadowUIStopwatch = true
  if timeFrame.SetScript then
    timeFrame:SetScript("OnClick", function()
      loadTimeManager()
      if Stopwatch_Toggle then
        Stopwatch_Toggle()
      end
    end)
  end
  if timeFrame._shadowUITimeWatch or not hooksecurefunc then
    return
  end
  timeFrame._shadowUITimeWatch = true
  hooksecurefunc(timeFrame, "SetPoint", function()
    if snapping or dragging then
      return
    end
    parkBlizzardTime()
  end)
  hooksecurefunc(timeFrame, "SetParent", function()
    if snapping or dragging then
      return
    end
    parkBlizzardTime()
  end)
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
    if snapping or dragging then
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
        parkBlizzardTime()
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
    if button.SetParent then
      button:SetParent(box)
    end
    if button.ClearAllPoints then
      button:ClearAllPoints()
    end
    if button.SetPoint then
      if Minimap then
        button:SetPoint("BOTTOM", Minimap, "TOP", 0, ZONE_GAP)
      else
        button:SetPoint("TOP", box, "TOP", 0, 0)
      end
    end
    if button.SetSize then
      button:SetSize(MAP, BUFFER - ZONE_GAP)
    end
    if button.SetFrameStrata then
      button:SetFrameStrata("MEDIUM")
    end
    if button.SetFrameLevel then
      button:SetFrameLevel(4)
    end
    if button.EnableMouse then
      button:EnableMouse(true)
    end
    if button.Show then
      button:Show()
    end
  end
  if not text then
    return
  end
  if text.SetParent then
    text:SetParent(button or box)
  end
  if text.ClearAllPoints then
    text:ClearAllPoints()
  end
  if text.SetPoint then
    if button then
      text:SetPoint("CENTER", button, "CENTER")
    else
      text:SetPoint("TOP", box, "TOP", 0, 0)
    end
  end
  if text.SetJustifyH then
    text:SetJustifyH("CENTER")
  end
  if text.SetFrameStrata then
    text:SetFrameStrata("MEDIUM")
  end
  if text.Show then
    text:Show()
  end
end

function Addon:SkinMinimap()
  if not Minimap or not MinimapCluster or not CreateFrame then
    return
  end

  local box = ensureHolder()
  box:ClearAllPoints()
  box:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
  box:SetSize(MAP + BUFFER * 2, MAP + BUFFER * 2 + ZONE_TOP)
  if box.Show then
    box:Show()
  end
  self:ApplyOuterChrome(box)

  snapping = true
  Minimap:SetParent(box)
  if Minimap.SetFrameStrata then
    Minimap:SetFrameStrata("LOW")
  end
  if Minimap.SetFrameLevel then
    Minimap:SetFrameLevel(2)
  end
  Minimap:ClearAllPoints()
  Minimap:SetPoint("BOTTOM", box, "BOTTOM", 0, BUFFER)
  Minimap:SetSize(MAP, MAP)
  if Minimap.SetWidth then
    Minimap:SetWidth(MAP)
    Minimap:SetHeight(MAP)
  end
  snapping = false

  applyMask()
  muteBlobRing()
  watchMinimap()
  watchLateIcons()
  parkAllIcons()
  parkWorldLayer()
  parkBlizzardTime()

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

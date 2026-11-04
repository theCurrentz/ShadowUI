-- Forever square minimap chrome skins the Blizzard cluster in place. The map
-- uses SexyMap's square mask. A 16px Darken fade plus Outer Edge replaces the
-- compass ring. Forever DielFrame hides so it does not block pings. Left-click
-- pings the full square face. Cluster header widgets (Zone Text, Time,
-- calendar, mail, tracking) stay put. Map-edge icons, including late LFG and
-- LibDBIcon buttons, sit on the square path. World Layer from Nova World Buffs
-- sits on the bottom. The mouse wheel zooms. After 5 seconds the map zooms
-- out. The player can drag every map-edge icon, including LFG.
-- Run: lua tests/minimap_spec.lua
local unpack = unpack or table.unpack
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
local ldbiCreated
_G.LibStub = function(name)
  if name == "LibDBIcon-1.0" then
    return {
      RegisterCallback = function(_, _, fn)
        ldbiCreated = fn
      end,
      GetButtonList = function()
        return { "ItemRack" }
      end,
      GetMinimapButton = function(_, buttonName)
        return _G["LibDBIcon10_" .. buttonName]
      end,
    }
  end
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local name = object
    local orig = _G[name]
    if type(orig) ~= "function" then
      return
    end
    _G[name] = function(...)
      local results = { orig(...) }
      fn(...)
      return unpack(results)
    end
    return
  end
  local orig = object[method]
  if type(orig) ~= "function" then
    orig = function() end
  end
  object[method] = function(self, ...)
    local results = { orig(self, ...) }
    fn(self, ...)
    return unpack(results)
  end
end

-- MinimapZoneText is a FontString. Frame methods from the SexyMap dummy
-- cannot run on it (SetFrameStrata Usage error in the client).
local function fakeFontString(name)
  local fs = { name = name, points = {}, text = "", hidden = false, objectType = "FontString" }
  function fs:GetObjectType() return "FontString" end
  function fs:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function fs:SetParent(parent) self.parent = parent end
  function fs:GetName() return self.name end
  function fs:SetFont() end
  function fs:SetJustifyH() end
  function fs:SetTextColor() end
  function fs:ClearAllPoints() self.points = {} end
  function fs:SetAllPoints(target) self.all = target end
  function fs:SetText(value) self.text = value end
  function fs:GetText() return self.text end
  function fs:GetUnboundedStringWidth() return 32 end
  function fs:GetStringHeight() return 10 end
  function fs:Hide() self.hidden = true end
  function fs:Show() self.hidden = false end
  function fs:IsShown() return not self.hidden end
  return fs
end

local function fakeFrame(name)
  local frame = { name = name, points = {}, hidden = false, children = {}, objectType = "Frame" }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:GetPoint(index)
    local p = self.points[index or #self.points]
    if not p then
      return
    end
    return p[1], p[2], p[3], p[4], p[5]
  end
  function frame:SetParent(parent)
    if self.parent and self.parent.children then
      local old = self.parent.children
      for i = #old, 1, -1 do
        if old[i] == self then
          table.remove(old, i)
        end
      end
    end
    self.parent = parent
    if parent then
      parent.children = parent.children or {}
      parent.children[#parent.children + 1] = self
    end
  end
  function frame:GetParent()
    return self.parent
  end
  function frame:GetChildren()
    local kids = self.children or {}
    return unpack(kids)
  end
  function frame:RegisterEvent() end
  function frame:GetWidth() return self.width end
  function frame:GetHeight() return self.height end
  function frame:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function frame:SetWidth(width) self.width = width end
  function frame:SetHeight(height) self.height = height end
  function frame:SetScale() end
  function frame:GetName() return self.name end
  function frame:GetFrameLevel() return self.level or 1 end
  function frame:SetFrameStrata()
    if self.objectType == "FontString" then
      error("bad argument #1 to 'fn' (Usage: self:SetFrameStrata(strata))")
    end
  end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:EnableMouse(enabled) self.mouse = enabled end
  function frame:EnableMouseWheel(enabled) self.mouseWheel = enabled end
  function frame:GetZoom() return self.zoom or 0 end
  function frame:Click()
    if self.OnClick then
      self:OnClick()
    end
    if self.hook_OnClick then
      self.hook_OnClick(self)
    end
  end
  function frame:SetFixedFrameStrata(locked) self.fixedStrata = locked end
  function frame:SetFixedFrameLevel(locked) self.fixedLevel = locked end
  function frame:SetPropagateMouseClicks(v) self.propagateClicks = v end
  function frame:SetPropagateMouseMotion(v) self.propagateMotion = v end
  function frame:SetMaskTexture(path) self.mask = path end
  function frame:Hide() self.hidden = true end
  function frame:Show()
    if self.objectType == "FontString" then
      error("bad argument #1 to 'fn' (Usage: self:SetFrameStrata(strata))")
    end
    self.hidden = false
  end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:SetJustifyH() end
  function frame:SetScript(event, fn) self[event] = fn end
  function frame:HookScript(event, fn)
    self["hook_" .. event] = fn
  end
  function frame:RegisterForDrag() self.drag = true end
  function frame:RegisterForClicks() self.clicks = true end
  function frame:IsShown() return not self.hidden end
  function frame:GetCenter()
    return self.cx or ((self.width or 0) / 2), self.cy or ((self.height or 0) / 2)
  end
  function frame:GetEffectiveScale() return 1 end
  function frame:CreateFontString()
    local fs = fakeFontString()
    frame.font = fs
    return fs
  end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:ClearAllPoints() self.points = {} end
    function tex:SetAllPoints(target) self.all = target end
    function tex:SetPoint(point, relative, relativePoint, x, y)
      self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
    end
    function tex:SetColorTexture(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a
    end
    function tex:Hide() self.hidden = true end
    function tex:Show() self.hidden = false end
    frame.backdrop = tex
    return tex
  end
  function frame:GetRegions()
    return frame.backdrop
  end
  return frame
end

_G.UIParent = { name = "UIParent" }
_G.CreateFrame = function(_, name, parent, template)
  local frame = fakeFrame(name)
  frame:SetParent(parent or _G.UIParent)
  frame.template = template
  if name then
    _G[name] = frame
  end
  return frame
end

_G.MinimapCluster = fakeFrame("MinimapCluster")
function _G.MinimapCluster:Hide()
  error("Hide is protected")
end
function _G.MinimapCluster:EnableMouse()
  error("EnableMouse is protected")
end
_G.MinimapCluster.DielFrame = fakeFrame("MinimapClusterDielFrame")
_G.MinimapCluster.DielFrame:SetParent(_G.MinimapCluster)
_G.Minimap = fakeFrame("Minimap")
_G.Minimap:SetSize(198, 198)
_G.Minimap.PingLocation = function(self, x, y)
  self.pinged = { x, y }
end
_G.Minimap.GetEffectiveScale = function()
  return 1
end
_G.Minimap.GetScript = function(self, event)
  return self[event]
end
-- Blizzard circular OnClick rejects square corners outside the inscribed circle.
_G.Minimap.OnClick = function(self)
  local x, y = _G.GetCursorPosition()
  x = x / self:GetEffectiveScale()
  y = y / self:GetEffectiveScale()
  local cx, cy = self:GetCenter()
  x, y = x - cx, y - cy
  if math.sqrt(x * x + y * y) < (self:GetWidth() / 2) then
    self:PingLocation(x, y)
  end
end
_G.MinimapContainer = fakeFrame("MinimapContainer")
_G.MinimapCluster.MinimapContainer = _G.MinimapContainer
_G.MinimapContainer:SetParent(_G.MinimapCluster)
_G.Minimap:SetParent(_G.MinimapContainer)
_G.Minimap.ZoomIn = fakeFrame("MinimapZoomIn")
_G.Minimap.ZoomOut = fakeFrame("MinimapZoomOut")
_G.MinimapBorder = fakeFrame("MinimapBorder")
_G.MinimapZoomIn = _G.Minimap.ZoomIn
_G.MinimapZoomOut = _G.Minimap.ZoomOut
_G.MinimapBackdrop = fakeFrame("MinimapBackdrop")
_G.MinimapCompassTexture = fakeFrame("MinimapCompassTexture")
_G.MinimapNorthTag = fakeFrame("MinimapNorthTag")
_G.MinimapBorderTop = fakeFrame("MinimapBorderTop")
_G.MinimapCluster.BorderTop = _G.MinimapBorderTop
_G.MinimapCluster.Tracking = fakeFrame("MinimapClusterTracking")
_G.MinimapCluster.Tracking:SetParent(_G.MinimapCluster)
_G.MinimapCluster.IndicatorFrame = fakeFrame("MinimapClusterIndicatorFrame")
_G.MinimapCluster.IndicatorFrame:SetParent(_G.MinimapCluster)
_G.MiniMapTrackingBorder = fakeFrame("MiniMapTrackingBorder")
_G.MiniMapMailFrame = fakeFrame("MiniMapMailFrame")
_G.MiniMapMailFrame:SetParent(_G.MinimapCluster.IndicatorFrame)
_G.MinimapCluster.IndicatorFrame.MailFrame = _G.MiniMapMailFrame
_G.MiniMapTrackingFrame = fakeFrame("MiniMapTrackingFrame")
_G.MiniMapTrackingFrame:SetParent(_G.MinimapCluster.Tracking)
_G.HybridMinimap = {
  MapCanvas = {
    useMask = true,
    SetUseMaskTexture = function(self, enabled) self.useMask = enabled end,
  },
  CircleMask = {
    texture = "Textures\\MinimapMask",
    SetTexture = function(self, path) self.texture = path end,
  },
}
local function fakeIconTexture(name)
  local tex = { name = name, r = 1, g = 1, b = 1 }
  function tex:GetName() return self.name end
  function tex:SetVertexColor(r, g, b)
    self.r, self.g, self.b = r, g, b
  end
  function tex:IsObjectType(kind) return kind == "Texture" end
  function tex:SetTexture() end
  return tex
end
_G.MiniMapMailIcon = fakeIconTexture("MiniMapMailIcon")
_G.MiniMapTrackingIcon = fakeIconTexture("MiniMapTrackingIcon")
function _G.MiniMapMailFrame:GetRegions()
  return _G.MiniMapMailIcon
end
function _G.MiniMapTrackingFrame:GetRegions()
  return _G.MiniMapTrackingIcon
end
_G.MinimapZoneTextButton = fakeFrame("MinimapZoneTextButton")
_G.MinimapZoneTextButton:SetParent(_G.MinimapCluster)
_G.MinimapCluster.ZoneTextButton = _G.MinimapZoneTextButton
_G.MinimapZoneText = fakeFontString("MinimapZoneText")
_G.GameTimeFrame = fakeFrame("GameTimeFrame")
_G.GameTimeFrame:SetParent(_G.MinimapCluster)
_G.TimeManagerClockButton = fakeFrame("TimeManagerClockButton")
_G.TimeManagerClockButton:SetParent(_G.MinimapCluster)
_G.TimeManagerClockTicker = _G.TimeManagerClockButton:CreateFontString()
_G.TimeManagerClockTicker:SetText("7:40")
_G.MinimapLayerFrame = fakeFrame("MinimapLayerFrame")
_G.MinimapLayerFrame:SetParent(_G.Minimap)
_G.MinimapLayerFrame:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 2, 4)
function _G.MiniMapTrackingBorder:SetVertexColor(r, g, b)
  self.r, self.g, self.b = r, g, b
end

local char = { minimapIcons = {} }
function Addon:GetCharDB()
  return char
end

_G.GetCursorPosition = function()
  return 180, 100
end

local timers = {}
_G.C_Timer = {
  After = function(delay, fn)
    timers[#timers + 1] = { delay = delay, fn = fn }
  end,
}

_G.Minimap_ZoomOutClick = function()
  local map = _G.Minimap
  map.zoom = (map.zoom or 0) - 1
end

_G.GetGameTime = function()
  return 19, 40
end
_G.GetTime = function()
  return 10
end
local tooltipLines = {}
_G.GameTooltip = {
  SetOwner = function() end,
  ClearLines = function() tooltipLines = {} end,
  AddLine = function(_, text) tooltipLines[#tooltipLines + 1] = text end,
  AddDoubleLine = function(_, left, right)
    tooltipLines[#tooltipLines + 1] = left
    tooltipLines[#tooltipLines + 1] = right
  end,
  Show = function() end,
  Hide = function() end,
}
_G.GameTime_UpdateTooltip = function()
  tooltipLines[#tooltipLines + 1] = "realm"
  tooltipLines[#tooltipLines + 1] = "local"
end

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/minimap.lua"))()
assert(loadfile(root .. "skin/time.lua"))()
Addon:SkinMinimap()

local box = _G.ShadowUIMinimapHolder
local cluster = _G.MinimapCluster
local map = _G.Minimap
local container = _G.MinimapContainer
local fill = box and box.shadowUIBackdrop
assert(box, "Darken fade lives on a holder behind the Forever map")
assert(_G.GetMinimapShape() == "SQUARE", "GetMinimapShape reports SQUARE for LibDBIcon")
assert(fill, "minimap keeps a chrome fill")
assert(fill.r == 0.05 and fill.g == 0.05 and fill.b == 0.05, "minimap chrome is Lorti darkest")
assert(fill.a == 0.6, "Darken fade is translucent")
assert(fill.all == box, "fill is the square holder")
assert(map.parent == container, "map stays on the Forever cluster")
assert(map.width == 198 and map.height == 198, "do not resize the Forever map")
assert(box.parent == container, "Darken fade follows the map host")
local park = box.points[#box.points]
assert(park and park[1] == "CENTER" and park[2] == map, "fade square is centred on the map")
assert(box.width == 230 and box.height == 230, "16px Darken fade sits around the map")
assert(box.width - map.width == 32, "16px Darken fade sits on each side")
local outer = box.shadowUIOuter
assert(outer, "minimap keeps an Outer Edge")
assert(outer.template == "BackdropTemplate", "Outer Edge uses BackdropTemplate")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true), "Outer Edge uses the Lorti shadow texture")
assert(outer.points[1][1] == "TOPLEFT" and outer.points[1][4] == -4,
  "Outer Edge extends 4px past the holder")
assert(map.mask == "Interface\\BUTTONS\\WHITE8X8", "SexyMap square mask clips the map")
assert(_G.HybridMinimap.CircleMask.texture == "Interface\\BUTTONS\\WHITE8X8",
  "HybridMinimap uses the square mask")
assert(map.width < box.width, "map insets so the dark frame is visible")
assert(not cluster.hidden, "do not Hide MinimapCluster")
assert(cluster.mouse == nil, "do not EnableMouse MinimapCluster")
assert(_G.MinimapBorder.hidden, "round silver ring stays hidden on the square map")
assert(_G.MinimapCompassTexture.hidden, "compass ring stays hidden")
assert(_G.MinimapNorthTag.hidden, "north tag stays hidden")
assert(not _G.MinimapZoomOut.hidden, "Forever zoom buttons stay")
assert(not _G.MinimapZoneText.hidden, "Zone Text stays visible")
assert(_G.MinimapZoneTextButton.parent == cluster, "Zone Text stays on the cluster header")
assert(not _G.GameTimeFrame.hidden, "calendar stays on the cluster header")
assert(_G.TimeManagerClockButton.parent == cluster, "Time stays on the cluster header")
assert(_G.ShadowUIMinimapClock == nil, "Time does not create a custom clock")
assert(_G.ShadowUIStopwatch == nil, "Time does not create a custom Stopwatch")
assert(_G.MiniMapMailFrame.parent == _G.MinimapCluster.IndicatorFrame,
  "mail stays in the cluster header")
assert(_G.MiniMapTrackingFrame.parent == _G.MinimapCluster.Tracking,
  "tracking stays on the cluster header")
assert(_G.MiniMapMailIcon.r == 1 and _G.MiniMapMailIcon.g == 1 and _G.MiniMapMailIcon.b == 1,
  "mail glyph is not painted Darken black")
assert(_G.MiniMapTrackingIcon.r == 1 and _G.MiniMapTrackingIcon.g == 1 and _G.MiniMapTrackingIcon.b == 1,
  "tracking glyph is not painted Darken black")
assert(not _G.MiniMapMailFrame.hidden, "mail host stays able to Show")
assert(_G.MiniMapMailFrame.Show ~= _G.MiniMapMailFrame.Hide, "mail Show is not replaced")

local timeFrame = _G.TimeManagerClockButton
Addon:SkinMinimap()
assert(_G.TimeManagerClockButton == timeFrame, "Time does not replace the Blizzard clock")
assert(timeFrame.parent == cluster, "Time does not leave the cluster header")

_G.MinimapZoomOut:Show()
assert(not _G.MinimapZoomOut.hidden, "zoom buttons stay after Show")

map:SetMaskTexture("Textures\\MinimapMask")
assert(map.mask == "Interface\\BUTTONS\\WHITE8X8", "Blizzard cannot restore the circular mask")

_G.MiniMapMailFrame:SetPoint("TOPRIGHT", cluster, "TOPRIGHT", -8, -2)
local mailAfter = _G.MiniMapMailFrame.points[#_G.MiniMapMailFrame.points]
assert(mailAfter[2] == cluster, "mail cannot leave the cluster header")

-- Dungeon finder sits on the map edge. A later skin must lift it onto the
-- square SW corner at the same compass angle.
local lfg = fakeFrame("LFGMinimapFrame")
_G.LFGMinimapFrame = lfg
lfg:SetParent(map)
lfg:SetPoint("CENTER", map, "CENTER", -57, -57)
Addon:SkinMinimap()
assert(lfg.parent == map, "dungeon finder stays on the map")
assert(not lfg.hidden, "dungeon finder stays visible")
local lfgPark = lfg.points[#lfg.points]
assert(lfgPark and lfgPark[4] == -109 and lfgPark[5] == -109,
  "dungeon finder sits on the south-west square corner, not the circle")

-- Addon buttons that still SetPoint on the circle must snap to the square.
local addonBtn = fakeFrame("LibDBIcon10_Test")
addonBtn:SetParent(map)
addonBtn:SetPoint("CENTER", map, "CENTER", -57, -57)
Addon:SkinMinimap()
local addonPark = addonBtn.points[#addonBtn.points]
assert(addonPark and addonPark[4] == -109 and addonPark[5] == -109,
  "addon minimap icons sit on the square edge, not the circular path")

-- Nova World Buffs already parents MinimapLayerFrame to Minimap. Keep it on
-- the bottom of the square map. Do not treat it as an edge icon.
local worldLayer = _G.MinimapLayerFrame
assert(worldLayer.parent == box, "World Layer sits on the square holder, not the map mask")
assert(not worldLayer.hidden, "World Layer stays visible")
local layerPark = worldLayer.points[#worldLayer.points]
assert(layerPark and layerPark[1] == "BOTTOM" and layerPark[2] == map,
  "World Layer sits on the bottom of the map")
assert(layerPark[3] == "BOTTOM" and layerPark[5] == 4,
  "World Layer keeps a 4px inset from the map bottom")

-- A button that parents to Minimap after the first skin still parks.
local lateBtn = _G.CreateFrame("Button", "TestMinimapButton", map)
local latePark = lateBtn.points[#lateBtn.points]
assert(latePark and latePark[1] == "CENTER" and latePark[2] == map,
  "buttons that register to Minimap park on the square path")

-- Drag stores the angle so a later skin does not snap LFG back to SW.
map.cx, map.cy = 100, 100
assert(lfg.drag, "dungeon finder accepts a drag")
assert(lfg.OnDragStart, "dungeon finder drag starts from the mouse")
lfg:OnDragStart()
local dragHost = _G.ShadowUIMinimapIconDrag
assert(dragHost and dragHost.OnUpdate, "icon drag updates from the cursor")
dragHost:OnUpdate()
lfg:OnDragStop()
assert(char.minimapIcons.LFGMinimapFrame == 0,
  "a drag to the east of the map stores angle 0")
Addon:SkinMinimap()
local lfgAfterDrag = lfg.points[#lfg.points]
assert(lfgAfterDrag[4] == 109 and lfgAfterDrag[5] == 0,
  "dungeon finder stays where the player dragged it")

-- World Layer must still Show after the cluster is hidden. Nova World Buffs
-- starts the frame hidden, then Shows it when it knows the shard.
assert(worldLayer.Show ~= worldLayer.Hide, "World Layer Show is not replaced")
worldLayer.hidden = true
worldLayer:Show()
assert(not worldLayer.hidden, "Nova World Buffs can Show World Layer after skin")
Addon:SkinMinimap()
assert(not worldLayer.hidden, "World Layer stays shown on the square map")
assert(worldLayer.parent ~= cluster, "World Layer does not stay on the hidden cluster")
assert(worldLayer.level and worldLayer.level >= 9,
  "World Layer sits above the map face")

-- ItemRack uses LibDBIcon10_ItemRack. It may parent to MinimapBackdrop, not
-- Minimap. The hidden cluster must not swallow it.
local itemRack = fakeFrame("LibDBIcon10_ItemRack")
_G.LibDBIcon10_ItemRack = itemRack
itemRack:SetParent(_G.MinimapBackdrop)
itemRack:SetPoint("CENTER", map, "CENTER", 40, -40)
Addon:SkinMinimap()
assert(itemRack.parent == map, "ItemRack leaves MinimapBackdrop for the square map")
assert(not itemRack.hidden, "ItemRack stays visible")
local itemRackPark = itemRack.points[#itemRack.points]
assert(itemRackPark and itemRackPark[1] == "CENTER" and itemRackPark[2] == map,
  "ItemRack sits on the square path")

-- LibDBIcon fires (event, button, name). Park the button, not the name string.
assert(ldbiCreated, "LibDBIcon_IconCreated is watched")
local lateRack = fakeFrame("LibDBIcon10_ItemRack")
_G.LibDBIcon10_ItemRack = lateRack
lateRack:SetParent(map)
ldbiCreated("LibDBIcon_IconCreated", lateRack, "ItemRack")
assert(lateRack.parent == map, "LibDBIcon ItemRack parks from IconCreated")
local lateRackPark = lateRack.points[#lateRack.points]
assert(lateRackPark and lateRackPark[1] == "CENTER" and lateRackPark[2] == map,
  "LibDBIcon ItemRack sits on the square path after IconCreated")

-- Coordinates under the map stay put. Do not park FontStrings as edge icons.
local coords = fakeFontString("MinimapCoordinates")
coords:SetParent(map)
coords:SetPoint("TOP", map, "BOTTOM", 0, -4)
Addon:SkinMinimap()
assert(coords.parent == map, "coordinates stay on the map")
local coordsPark = coords.points[#coords.points]
assert(coordsPark and coordsPark[1] == "TOP" and coordsPark[3] == "BOTTOM",
  "coordinates stay under the map")

-- ItemRack set menu is named ItemRackMenuFrame. It must not park as a
-- Minimap Icon when it is a child of the map.
local rackMenu = fakeFrame("ItemRackMenuFrame")
_G.ItemRackMenuFrame = rackMenu
rackMenu:SetParent(map)
rackMenu:SetPoint("TOPLEFT", map, "BOTTOMLEFT", 0, 0)
Addon:SkinMinimap()
assert(rackMenu.parent == map, "ItemRack set menu is not a Minimap Icon")
local rackMenuPark = rackMenu.points[#rackMenu.points]
assert(rackMenuPark and rackMenuPark[3] == "BOTTOMLEFT",
  "ItemRack set menu keeps its dock on the map")

-- Tracking button stays on the cluster header host.
local trackBtn = fakeFrame("MiniMapTrackingButton")
_G.MiniMapTrackingButton = trackBtn
trackBtn:SetParent(_G.MiniMapTrackingFrame)
Addon:SkinMinimap()
assert(trackBtn.parent == _G.MiniMapTrackingFrame,
  "tracking button stays on the tracking host")
assert(trackBtn.propagateClicks and trackBtn.propagateMotion,
  "tracking clicks pass through to the tracking host")

assert(map.mouseWheel == true, "mouse wheel zooms the square map")
assert(map.OnMouseWheel, "mouse wheel is wired")
local zoomOutTimer
for i = 1, #timers do
  if timers[i].delay == 5 then
    zoomOutTimer = timers[i].fn
  end
end
assert(zoomOutTimer, "auto zoom-out is scheduled")
map.zoom = 3
zoomOutTimer()
assert(map.zoom == 0, "auto zoom-out returns to the default zoom")
_G.MinimapZoomOut.OnClick = function(self)
  self.clicked = true
end
map:OnMouseWheel(-1)
assert(_G.MinimapZoomOut.clicked, "mouse wheel uses the Blizzard zoom-out click")

-- Forever day/night dial sits on the map face and eats pings in the middle.
assert(_G.MinimapCluster.DielFrame.hidden, "DielFrame hides so the square map accepts pings")
assert(_G.MinimapCluster.DielFrame.Show == _G.MinimapCluster.DielFrame.Hide,
  "DielFrame cannot Show again over the square map")

-- Square OnClick pings the full map face, including corners Blizzard rejects.
map.cx, map.cy = 100, 100
map.width, map.height = 198, 198
map.pinged = nil
_G.GetCursorPosition = function()
  return 100 + 90, 100 + 90
end
assert(map.OnClick, "square map installs an OnClick ping")
map:OnClick()
assert(map.pinged and map.pinged[1] == 90 and map.pinged[2] == 90,
  "square OnClick pings a corner outside the inscribed circle")
map.pinged = nil
_G.GetCursorPosition = function()
  return 100, 100
end
map:OnClick()
assert(map.pinged and map.pinged[1] == 0 and map.pinged[2] == 0,
  "square OnClick pings the map centre")

char.useShadowUIMinimap = false
Addon:SkinMinimap()
assert(box.hidden == true, "ShadowUI minimap holder hides when the Blizzard map is on")
assert(map.parent == container, "map stays on the Forever cluster")
assert(_G.GetMinimapShape() == "ROUND", "GetMinimapShape reports ROUND when ShadowUI minimap is off")
assert(map.mask == "Textures\\MinimapMask", "circular mask returns when ShadowUI minimap is off")
assert(_G.HybridMinimap.CircleMask.texture == "Textures\\MinimapMask",
  "HybridMinimap circular mask returns when ShadowUI minimap is off")
assert(not _G.MinimapBorder.hidden, "round silver ring returns when ShadowUI minimap is off")
assert(not _G.MinimapCompassTexture.hidden, "compass ring returns when ShadowUI minimap is off")
assert(not _G.MinimapCluster.DielFrame.hidden, "DielFrame returns when ShadowUI minimap is off")
assert(not _G.MinimapZoomOut.hidden, "zoom buttons stay when ShadowUI minimap is off")
assert(_G.MinimapZoneTextButton.parent == cluster, "Zone Text stays on the cluster header")
map:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
assert(map.mask == "Interface\\BUTTONS\\WHITE8X8", "Blizzard can keep a mask when ShadowUI minimap is off")
-- Blizzard circular OnClick returns with the round map.
map.pinged = nil
_G.GetCursorPosition = function()
  return 100 + 90, 100 + 90
end
map:OnClick()
assert(map.pinged == nil, "round OnClick rejects a square corner")
char.useShadowUIMinimap = true
Addon:SkinMinimap()
assert(not box.hidden, "ShadowUI minimap holder shows when the toggle is on")
assert(map.parent == container, "map stays on the Forever cluster when the toggle is on")
assert(_G.GetMinimapShape() == "SQUARE", "GetMinimapShape reports SQUARE when ShadowUI minimap is on")
assert(_G.MinimapCluster.DielFrame.hidden, "DielFrame hides again when ShadowUI minimap is on")

local dbSrc = assert(io.open(root .. "core/db.lua", "r")):read("*a")
assert(dbSrc:find("useShadowUIMinimap%s*=%s*true"), "character default uses the ShadowUI minimap")
local configSrc = assert(io.open(root .. "options/config.lua", "r")):read("*a")
assert(configSrc:find("useShadowUIMinimap"), "/shadowui exposes the minimap toggle")

print("minimap_spec OK")

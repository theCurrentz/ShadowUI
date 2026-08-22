-- Square minimap chrome is a 16px Darken buffer around the map, with Zone Text
-- on top and an Outer Edge. The map uses SexyMap's square mask and icon path.
-- Cluster icons, including late LFG and LibDBIcon buttons, sit on that square.
-- World Layer from Nova World Buffs sits on the bottom. Time is a clock square
-- on the map. Hover shows realm time and local time. A click opens the
-- Stopwatch. GameTimeFrame stays hidden. The player can drag every minimap
-- icon, including LFG.
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

local function fakeFrame(name)
  local frame = { name = name, points = {}, hidden = false, children = {} }
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
  function frame:SetFrameStrata() end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:EnableMouse(enabled) self.mouse = enabled end
  function frame:SetMaskTexture(path) self.mask = path end
  function frame:Hide() self.hidden = true end
  function frame:Show() self.hidden = false end
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
    local fs = { points = {}, text = "" }
    function fs:SetPoint(point, relative, relativePoint, x, y)
      fs.points[#fs.points + 1] = { point, relative, relativePoint, x, y }
    end
    function fs:SetFont() end
    function fs:SetJustifyH() end
    function fs:SetTextColor() end
    function fs:SetText(text) fs.text = text end
    function fs:GetText() return fs.text end
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
_G.Minimap = fakeFrame("Minimap")
_G.MinimapBorder = fakeFrame("MinimapBorder")
_G.MinimapZoomOut = fakeFrame("MinimapZoomOut")
_G.MinimapBackdrop = fakeFrame("MinimapBackdrop")
_G.MiniMapTrackingBorder = fakeFrame("MiniMapTrackingBorder")
_G.MiniMapMailFrame = fakeFrame("MiniMapMailFrame")
_G.MiniMapTrackingFrame = fakeFrame("MiniMapTrackingFrame")
_G.MinimapZoneTextButton = fakeFrame("MinimapZoneTextButton")
_G.MinimapZoneText = fakeFrame("MinimapZoneText")
_G.GameTimeFrame = fakeFrame("GameTimeFrame")
_G.GameTimeFrame:SetParent(_G.MinimapCluster)
_G.TimeManagerClockButton = fakeFrame("TimeManagerClockButton")
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
local fill = box and box.shadowUIBackdrop
assert(box, "square map lives on a holder, not the circular cluster")
assert(_G.GetMinimapShape() == "SQUARE", "GetMinimapShape reports SQUARE for LibDBIcon")
assert(fill, "minimap keeps a chrome fill")
assert(fill.r == 0.05 and fill.g == 0.05 and fill.b == 0.05, "minimap chrome is Lorti darkest")
assert(fill.a == 0.6, "Darken buffer is translucent")
assert(fill.all == box, "fill is the square holder")
local park = box.points[1]
assert(park and park[1] == "TOPRIGHT" and park[2] == _G.UIParent, "holder parks at TOPRIGHT")
assert(park[4] == 0 and park[5] == 0, "map is flush to the top-right")
assert(box.width == 192 and box.height == 196, "holder keeps side buffer and a 4px top inset")
assert(map.width == 160 and map.height == 160, "map stays 160 inside the buffer")
assert(box.width - map.width == 32, "16px Darken buffer sits on each side")
local mapPark = map.points[1]
assert(mapPark and mapPark[1] == "BOTTOM" and mapPark[5] == 16,
  "map sits on the bottom buffer so extra space is above Zone Text")
local outer = box.shadowUIOuter
assert(outer, "minimap keeps an Outer Edge")
assert(outer.template == "BackdropTemplate", "Outer Edge uses BackdropTemplate")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true), "Outer Edge uses the Lorti shadow texture")
assert(outer.points[1][1] == "TOPLEFT" and outer.points[1][4] == -4,
  "Outer Edge extends 4px past the holder")
assert(map.parent == box, "map leaves the circular MinimapCluster")
assert(map.mask == "Interface\\BUTTONS\\WHITE8X8", "SexyMap square mask clips the map")
assert(map.width < box.width, "map insets so the dark frame is visible")
assert(cluster.hidden, "circular cluster does not sit behind the square map")
assert(cluster.mouse == false, "cluster has no dead mouse zone")
assert(_G.MinimapBorder.hidden, "round silver ring stays hidden on the square map")
assert(_G.MinimapZoomOut.hidden, "zoom buttons stay hidden")
assert(not _G.MinimapZoneText.hidden, "Zone Text stays visible")
assert(_G.MinimapZoneTextButton.parent == box, "Zone Text sits on the square holder")
local zone = _G.MinimapZoneTextButton.points[1]
assert(zone and zone[1] == "BOTTOM" and zone[2] == map, "Zone Text sits above the map")
assert(zone[3] == "TOP" and zone[5] == 3, "Zone Text keeps a 3px gap above the map")
assert(_G.MiniMapTrackingBorder.r == 0.05, "tracking ring is Lorti darkest")

local mail = _G.MiniMapMailFrame.points[1]
assert(mail and mail[1] == "CENTER" and mail[2] == map, "mail icon is parented to the square map")
assert(mail[4] > 0 and mail[5] < 0, "mail sits on the south-east square corner, not the circle")
local track = _G.MiniMapTrackingFrame.points[1]
assert(track[4] < 0 and track[5] > 0, "tracking sits on the north-west square corner, not the circle")

assert(_G.GameTimeFrame.hidden, "sun/moon Time art stays hidden")
assert(_G.TimeManagerClockButton.hidden, "digital Time Manager clock stays hidden")
local timeFrame = _G.ShadowUIMinimapClock
assert(timeFrame, "Time is a clock square")
assert(not timeFrame.hidden, "Time stays visible")
assert(timeFrame.parent == map, "Time sits on the map")
assert(timeFrame.width == 36 and timeFrame.height == 36, "Time is a little square")
assert(timeFrame.text and timeFrame.text.text == "7:40", "Time shows realm time")
local timePark = timeFrame.points[#timeFrame.points]
assert(timePark and timePark[1] == "BOTTOMRIGHT" and timePark[2] == map,
  "Time sits on the map, not the square icon path")
assert(timePark[3] == "BOTTOMRIGHT" and timePark[4] == -2 and timePark[5] == 2,
  "Time keeps a 2px inset from the map corner")
assert(timeFrame.OnEnter, "Time hover is wired")
timeFrame:OnEnter()
assert(tooltipLines[1] == "realm" and tooltipLines[2] == "local",
  "Time hover shows realm time and local time")
assert(timeFrame.OnClick, "Time click is wired")
local stopwatch = _G.ShadowUIStopwatch
assert(stopwatch, "Stopwatch exists")
assert(stopwatch.hidden, "Stopwatch starts hidden")
timeFrame:OnClick()
assert(not stopwatch.hidden, "Time click opens the Stopwatch")
timeFrame:OnClick()
assert(stopwatch.hidden, "Time click hides the Stopwatch")
Addon:SkinMinimap()
assert(_G.ShadowUIMinimapClock == timeFrame, "Time does not create a second clock")

_G.MinimapZoomOut:Show()
assert(_G.MinimapZoomOut.hidden, "zoom buttons cannot come back")

map:SetMaskTexture("Textures\\MinimapMask")
assert(map.mask == "Interface\\BUTTONS\\WHITE8X8", "Blizzard cannot restore the circular mask")

_G.MiniMapMailFrame:SetPoint("CENTER", map, "CENTER", 0, 40)
local mailAfter = _G.MiniMapMailFrame.points[#_G.MiniMapMailFrame.points]
assert(mailAfter[5] < 0, "mail cannot return to the circular cluster path")

-- Classic Era dungeon finder loads after the first skin, parented to the
-- hidden cluster. A later skin must lift it onto the square SW corner.
local lfg = fakeFrame("LFGMinimapFrame")
_G.LFGMinimapFrame = lfg
lfg:SetParent(cluster)
lfg:SetPoint("CENTER", map, "CENTER", -57, -57)
Addon:SkinMinimap()
assert(lfg.parent == map, "dungeon finder leaves the hidden cluster")
assert(not lfg.hidden, "dungeon finder stays visible")
local lfgPark = lfg.points[#lfg.points]
assert(lfgPark and lfgPark[4] == -80 and lfgPark[5] == -80,
  "dungeon finder sits on the south-west square corner, not the circle")

-- Addon buttons that still SetPoint on the circle must snap to the square.
local addonBtn = fakeFrame("LibDBIcon10_Test")
addonBtn:SetParent(map)
addonBtn:SetPoint("CENTER", map, "CENTER", -57, -57)
Addon:SkinMinimap()
local addonPark = addonBtn.points[#addonBtn.points]
assert(addonPark and addonPark[4] == -80 and addonPark[5] == -80,
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
assert(lfg.hook_OnDragStart, "dungeon finder drag starts from the mouse")
lfg.hook_OnDragStart(lfg)
local dragHost = _G.ShadowUIMinimapIconDrag
assert(dragHost and dragHost.OnUpdate, "icon drag updates from the cursor")
dragHost:OnUpdate()
lfg.hook_OnDragStop(lfg)
assert(char.minimapIcons.LFGMinimapFrame == 0,
  "a drag to the east of the map stores angle 0")
Addon:SkinMinimap()
local lfgAfterDrag = lfg.points[#lfg.points]
assert(lfgAfterDrag[4] == 80 and lfgAfterDrag[5] == 0,
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

print("minimap_spec OK")

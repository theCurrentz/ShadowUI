-- Time is Blizzard TimeManagerClockButton on the Forever cluster header.
-- Hover Time Info shows realm time and local time via GameTime_UpdateTooltip.
-- A click keeps the Blizzard Stopwatch. GameTimeFrame is the calendar and stays.
-- Run: lua tests/time_spec.lua
local unpack = unpack or table.unpack
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
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
  function frame:SetParent(parent)
    self.parent = parent
  end
  function frame:GetName() return self.name end
  function frame:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function frame:SetWidth(width) self.width = width end
  function frame:SetHeight(height) self.height = height end
  function frame:SetFrameStrata(strata) self.strata = strata end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetFixedFrameStrata(locked) self.fixedStrata = locked end
  function frame:SetFixedFrameLevel(locked) self.fixedLevel = locked end
  function frame:SetClampedToScreen(v) self.clamped = v end
  function frame:SetClampRectInsets(a, b, c, d)
    self.clampInsets = { a, b, c, d }
  end
  function frame:EnableMouse(enabled) self.mouse = enabled end
  function frame:Hide() self.hidden = true end
  function frame:Show() self.hidden = false end
  function frame:IsShown() return not self.hidden end
  function frame:SetScript(event, fn) self[event] = fn end
  function frame:GetScript(event) return self[event] end
  function frame:HookScript(event, fn)
    local prior = self[event]
    self[event] = function(...)
      if prior then
        prior(...)
      end
      fn(...)
    end
  end
  function frame:CreateFontString()
    local fs = { points = {}, text = "" }
    function fs:ClearAllPoints() self.points = {} end
    function fs:SetAllPoints(target) self.all = target end
    function fs:SetPoint(point, relative, relativePoint, x, y)
      self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
    end
    function fs:SetFont() end
    function fs:SetJustifyH() end
    function fs:SetTextColor(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a
    end
    function fs:SetText(value) self.text = value end
    function fs:GetText() return self.text end
    function fs:GetUnboundedStringWidth() return 32 end
    function fs:GetStringHeight() return 10 end
    return fs
  end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:SetAllPoints(target) self.all = target end
    function tex:SetColorTexture(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a
    end
    function tex:Hide() self.hidden = true end
    frame.backdrop = tex
    return tex
  end
  function frame:GetRegions()
    return frame.border
  end
  return frame
end

_G.UIParent = fakeFrame("UIParent")
_G.Minimap = fakeFrame("Minimap")
_G.MinimapCluster = fakeFrame("MinimapCluster")
_G.GameTimeFrame = fakeFrame("GameTimeFrame")
_G.GameTimeFrame:SetParent(_G.MinimapCluster)
_G.TimeManagerClockButton = fakeFrame("TimeManagerClockButton")
_G.TimeManagerClockButton:SetParent(_G.MinimapCluster)
_G.TimeManagerClockButton.border = fakeFrame("TimeManagerClockBorder")
_G.TimeManagerClockTicker = _G.TimeManagerClockButton:CreateFontString()
_G.TimeManagerClockTicker:SetText("7:40")
local tooltipLines = {}
_G.GameTooltip = {
  SetOwner = function(_, owner)
    _G.GameTooltip.owner = owner
  end,
  ClearLines = function() tooltipLines = {} end,
  AddLine = function(_, text) tooltipLines[#tooltipLines + 1] = text end,
  AddDoubleLine = function(_, left, right)
    tooltipLines[#tooltipLines + 1] = left
    tooltipLines[#tooltipLines + 1] = right
  end,
  Show = function() _G.GameTooltip.shown = true end,
  Hide = function() _G.GameTooltip.shown = false end,
}
_G.GameTime_UpdateTooltip = function()
  tooltipLines[#tooltipLines + 1] = "Realm Time"
  tooltipLines[#tooltipLines + 1] = "Local Time"
end
_G.CreateFrame = function(_, name, parent, template)
  local frame = fakeFrame(name)
  frame.parent = parent or _G.UIParent
  frame.template = template
  if name then
    _G[name] = frame
  end
  return frame
end

assert(loadfile(root .. "skin/time.lua"))()
Addon:SkinTime()

assert(not _G.GameTimeFrame.hidden, "calendar stays on the cluster header")
_G.GameTimeFrame:Show()
assert(not _G.GameTimeFrame.hidden, "calendar can Show")

assert(_G.ShadowUIMinimapClock == nil, "Time does not create a custom clock")
assert(_G.ShadowUIStopwatch == nil, "Time does not create a custom Stopwatch")

local clock = _G.TimeManagerClockButton
assert(not clock.hidden, "Time stays the Blizzard clock")
assert(clock.parent == _G.MinimapCluster, "Time stays on the cluster header")
assert(#clock.points == 0, "Time does not park under the map")
assert(clock.shadowUIBackdrop == nil, "Time does not add a Darken chip")
assert(clock.OnClick == nil, "Time keeps the Blizzard Stopwatch click")
assert(clock.mouse == true, "Time accepts hover")
clock:OnEnter(clock)
assert(_G.GameTooltip.owner == clock, "Time Info anchors to Time")
local sawRealm, sawLocal
for i = 1, #tooltipLines do
  if tooltipLines[i] == "Realm Time" then
    sawRealm = true
  end
  if tooltipLines[i] == "Local Time" then
    sawLocal = true
  end
end
assert(sawRealm and sawLocal, "Time Info shows realm time and local time")
assert(_G.GameTooltip.shown, "Time Info stays open while the mouse is on Time")
clock:OnLeave(clock)
assert(_G.GameTooltip.shown == false, "Time Info hides when the mouse leaves Time")

clock:SetPoint("TOPRIGHT", _G.MinimapCluster, "TOPRIGHT", -40, -2)
local after = clock.points[#clock.points]
assert(after[1] == "TOPRIGHT" and after[2] == _G.MinimapCluster,
  "Time keeps its cluster header point")

Addon:SkinTime()
assert(_G.TimeManagerClockButton == clock, "Time does not replace the Blizzard clock")
assert(not clock.hidden, "Time stays visible after a later skin")
assert(clock.parent == _G.MinimapCluster, "Time stays on the cluster header after a later skin")
assert(not _G.GameTimeFrame.hidden, "calendar stays after a later skin")

print("time_spec OK")

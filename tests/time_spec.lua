-- Time is a clock square on the minimap. Hover shows realm time and local time.
-- A click opens the Stopwatch. GameTimeFrame stays hidden.
-- Run: lua tests/time_spec.lua
local unpack = unpack or table.unpack
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
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
  function frame:SetFrameStrata() end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:EnableMouse(enabled) self.mouse = enabled end
  function frame:SetMovable() self.movable = true end
  function frame:RegisterForDrag() self.drag = true end
  function frame:RegisterForClicks() self.clicks = true end
  function frame:Hide() self.hidden = true end
  function frame:Show() self.hidden = false end
  function frame:IsShown() return not self.hidden end
  function frame:SetScript(event, fn) self[event] = fn end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:CreateFontString()
    local fs = { points = {}, text = "" }
    function fs:SetPoint(point, relative, relativePoint, x, y)
      fs.points[#fs.points + 1] = { point, relative, relativePoint, x, y }
    end
    function fs:SetFont() end
    function fs:SetJustifyH() end
    function fs:SetTextColor(r, g, b, a)
      fs.r, fs.g, fs.b, fs.a = r, g, b, a
    end
    function fs:SetText(text) fs.text = text end
    function fs:GetText() return fs.text end
    return fs
  end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:SetAllPoints(target) self.all = target end
    function tex:SetColorTexture(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a
    end
    frame.backdrop = tex
    return tex
  end
  return frame
end

_G.UIParent = fakeFrame("UIParent")
_G.Minimap = fakeFrame("Minimap")
_G.GameTimeFrame = fakeFrame("GameTimeFrame")
_G.CreateFrame = function(_, name, parent, template)
  local frame = fakeFrame(name)
  frame.parent = parent or _G.UIParent
  frame.template = template
  if name then
    _G[name] = frame
  end
  return frame
end

local now = 10
_G.GetTime = function()
  return now
end
_G.GetGameTime = function()
  return 19, 40
end

local tooltipLines = {}
_G.GameTooltip = {
  SetOwner = function() end,
  ClearLines = function() tooltipLines = {} end,
  AddLine = function(_, text) tooltipLines[#tooltipLines + 1] = text end,
  AddDoubleLine = function(_, left, right)
    tooltipLines[#tooltipLines + 1] = { left, right }
  end,
  Show = function(tip) tip.shown = true end,
  Hide = function(tip) tip.shown = false end,
}

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/time.lua"))()
Addon:SkinTime()

assert(_G.GameTimeFrame.hidden, "sun/moon Time art stays hidden")
_G.GameTimeFrame:Show()
assert(_G.GameTimeFrame.hidden, "sun/moon Time art cannot come back")

local clock = _G.ShadowUIMinimapClock
assert(clock, "Time is a clock square")
assert(clock.width == 36 and clock.height == 36, "Time is a little square")
assert(clock.parent == _G.Minimap, "Time sits on the map")
assert(clock.mouse == true, "Time accepts hover and click")
assert(clock.text and clock.text.text == "7:40", "Time shows realm time")
assert(clock.shadowUIBackdrop.r == 0.05, "Time fill is Lorti darkest")
assert(clock.shadowUIOuter, "Time keeps an Outer Edge")

clock:OnEnter()
assert(tooltipLines[1] == "Time Info", "Time hover title is Time Info")
assert(tooltipLines[2][1] == "Realm time" and tooltipLines[2][2] == "7:40 PM",
  "Time hover shows realm time")
assert(tooltipLines[3][1] == "Local time", "Time hover shows local time")

local sw = _G.ShadowUIStopwatch
assert(sw, "Stopwatch exists")
assert(sw.hidden, "Stopwatch starts hidden")
assert(sw.time and sw.time.text == "0:00", "Stopwatch starts at zero")
assert(sw.title and sw.title.text == "Stopwatch", "Stopwatch is labelled")
clock:OnClick()
assert(not sw.hidden, "Time click opens the Stopwatch")

sw:OnClick("LeftButton")
assert(sw.running, "left click starts the Stopwatch")
now = 25
sw:OnUpdate()
assert(sw.time.text == "0:15", "Stopwatch counts elapsed seconds")
sw:OnClick("LeftButton")
assert(not sw.running, "left click pauses the Stopwatch")
now = 40
sw:OnUpdate()
assert(sw.time.text == "0:15", "paused Stopwatch does not advance")
sw:OnClick("RightButton")
assert(not sw.running, "right click stops the Stopwatch")
assert(sw.time.text == "0:00", "right click resets the Stopwatch")

clock:OnClick()
assert(sw.hidden, "Time click hides the Stopwatch")
Addon:SkinTime()
assert(_G.ShadowUIMinimapClock == clock, "Time does not create a second clock")
assert(_G.ShadowUIStopwatch == sw, "Time does not create a second Stopwatch")

print("time_spec OK")

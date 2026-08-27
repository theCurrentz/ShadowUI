-- Edit Mode SetSmallSize must SetPoint FocusFrameToT without an anchor-family loop.
-- Classic copies FocusFrameMixin.SetSmallSize onto FocusFrame. Edit Mode then
-- calls FocusFrame:SetSmallSize, which SetPoint FocusFrameToT with no ClearAllPoints.
-- That fails when FocusFrame is already in the ToT family (Edit Mode snap).
-- Run: lua tests/focus_tot_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local orig = _G[object]
    if type(orig) ~= "function" then
      return
    end
    _G[object] = function(...)
      orig(...)
      fn(...)
    end
    return
  end
  local orig = object[method]
  if type(orig) ~= "function" then
    return
  end
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.UIParent = { name = "UIParent", points = {} }

local function reaches(from, target, seen)
  if not from or from == target then
    return from == target
  end
  seen = seen or {}
  if seen[from] then
    return false
  end
  seen[from] = true
  if from.parent and reaches(from.parent, target, seen) then
    return true
  end
  for _, pt in ipairs(from.points or {}) do
    local rel = pt[2]
    if type(rel) == "table" and reaches(rel, target, seen) then
      return true
    end
  end
  return false
end

local function fakeFrame(name, parent)
  local frame = { name = name, parent = parent, points = {} }
  function frame:GetName()
    return self.name
  end
  function frame:GetParent()
    return self.parent
  end
  function frame:SetParent(nextParent)
    self.parent = nextParent
  end
  function frame:GetNumPoints()
    return #self.points
  end
  function frame:GetPoint(index)
    local pt = self.points[index]
    if not pt then
      return
    end
    return pt[1], pt[2], pt[3], pt[4], pt[5]
  end
  function frame:GetLeft()
    return self.left or 400
  end
  function frame:GetBottom()
    return self.bottom or 200
  end
  function frame:ClearAllPoints()
    self.points = {}
  end
  function frame:SetPoint(point, relative, relativePoint, x, y)
    if type(relative) == "number" then
      x, y = relative, relativePoint
      relative, relativePoint = self.parent, point
    end
    if relative and reaches(relative, self) then
      error("SetPoint would result in anchor family connection")
    end
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:SetPointBase(point, relative, relativePoint, x, y)
    self:SetPoint(point, relative, relativePoint, x, y)
  end
  function frame:ClearAllPointsBase()
    self:ClearAllPoints()
  end
  function frame:SetUserPlaced() end
  function frame:SetScale() end
  function frame:Update() end
  function frame:UnregisterEvent() end
  function frame:RegisterEvent() end
  _G[name] = frame
  return frame
end

_G.FocusFrame = fakeFrame("FocusFrame", _G.UIParent)
_G.FocusFrameToT = fakeFrame("FocusFrameToT", _G.FocusFrame)
_G.FocusFrame.totFrame = _G.FocusFrameToT
_G.FocusFrame.smallSize = false
_G.FocusFrame.maxBuffs = nil
_G.FocusFrame.spellbar = { SetScale = function() end }
_G.FocusFrame.pvpIcon = { Hide = function() end }
_G.FocusFrame.leaderIcon = { Hide = function() end }
_G.FocusFrameHealthBar = { TextString = { SetFontObject = function() end, SetPoint = function() end } }
_G.FocusFrameTextureFrameName = { SetFontObject = function() end, SetWidth = function() end }
_G.PlayerFrame = fakeFrame("PlayerFrame", _G.UIParent)
_G.TargetFrame = fakeFrame("TargetFrame", _G.UIParent)

-- XML Mixin copies SetSmallSize onto FocusFrame. Wrapping FocusFrameMixin later
-- does not change FocusFrame.SetSmallSize. Edit Mode calls the instance method.
local function blizzardSetSmallSize(self, smallSize)
  if smallSize and not self.smallSize then
    self.smallSize = true
    _G.FocusFrameToT:SetScale(1.25)
    _G.FocusFrameToT:SetPoint("BOTTOMRIGHT", -13, -17)
  elseif not smallSize and self.smallSize then
    self.smallSize = false
    _G.FocusFrameToT:SetScale(1)
    _G.FocusFrameToT:SetPoint("BOTTOMRIGHT", -35, -10)
  end
end
_G.FocusFrameMixin = { SetSmallSize = blizzardSetSmallSize }
_G.FocusFrame.SetSmallSize = blizzardSetSmallSize

_G.FocusFrame:SetPoint("CENTER", _G.UIParent, "CENTER", 200, 0)
_G.FocusFrameToT:SetParent(_G.UIParent)
_G.FocusFrameToT:SetPoint("BOTTOMRIGHT", _G.UIParent, "BOTTOMRIGHT", -35, -10)
-- Edit Mode snap: Focus Frame sits on its ToT while ToT is not yet a child.
_G.FocusFrame:ClearAllPoints()
_G.FocusFrame:SetPoint("TOPLEFT", _G.FocusFrameToT, "TOPLEFT", 0, 0)
_G.FocusFrameToT:SetParent(_G.FocusFrame)

local ok, err = pcall(_G.FocusFrame.SetSmallSize, _G.FocusFrame, true)
assert(not ok and tostring(err):find("anchor family", 1, true),
  "unpatched FocusFrame:SetSmallSize must fail when FocusFrame is already in the ToT family")

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/frames.lua"))()

Addon:WatchBlizzardUnitEdit()
_G.FocusFrame.smallSize = false
_G.FocusFrame:SetSmallSize(true)
assert(_G.FocusFrameToT.points[1][2] == _G.FocusFrame,
  "patched SetSmallSize pins ToT to FocusFrame")
assert(_G.FocusFrame.points[1][2] ~= _G.FocusFrameToT,
  "FocusFrame cannot stay snapped to its ToT")

print("focus_tot_spec OK")

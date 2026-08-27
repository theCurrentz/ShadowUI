-- Target Range Display sits BOTTOM/TOP on the combat meter group.
-- Run: lua tests/range_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
local fakeRange = { min = 8, max = 20 }

local function rangeLib()
  return {
    GetRange = function()
      return fakeRange.min, fakeRange.max
    end,
  }
end

-- In-game LibStub is a table with __call, not a function.
local stub = {}
setmetatable(stub, {
  __call = function(_, name)
    if name == "LibRangeCheck-3.0" then
      return rangeLib()
    end
    return { GetAddon = function() return Addon end }
  end,
})
_G.LibStub = stub
_G.UIParent = { name = "UIParent" }
_G.UnitExists = function() return true end
_G.UnitIsUnit = function() return false end
local function fakeFont()
  local fs = { text = "", r = 1, g = 1, b = 1, a = 1, shown = true }
  function fs:SetPoint() end
  function fs:SetJustifyH() end
  function fs:SetFont(file, size, flags)
    self.fontFile, self.fontSize, self.fontFlags = file, size, flags
  end
  function fs:SetText(text) self.text = text or "" end
  function fs:SetTextColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function fs:Show() self.shown = true end
  function fs:Hide() self.shown = false end
  return fs
end

_G.CreateFrame = function(_, name)
  local frame = { name = name, points = {}, shown = true }
  function frame:SetSize(w, h) self.width = w; self.height = h end
  function frame:SetPoint(point, relativeTo, relativePoint, x, y)
    self.points[#self.points + 1] = {
      point = point,
      relativeTo = relativeTo,
      relativePoint = relativePoint,
      x = x,
      y = y,
    }
  end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetFrameStrata() end
  function frame:EnableMouse() end
  function frame:CreateFontString()
    local fs = fakeFont()
    self.fontString = fs
    return fs
  end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:RegisterEvent(event) self.event = event end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  return frame
end

local castGroup = { name = "ShadowUICastGroup" }
function Addon:CombatMeterGroup()
  return castGroup
end

assert(loadfile(root .. "cast/range.lua"))()

Addon:ApplyRangeDisplay()
local frame = Addon.rangeDisplay
assert(frame, "creates the Range Display")
assert(frame.points[1].point == "BOTTOM", "tethers from the bottom")
assert(frame.points[1].relativeTo == castGroup, "anchors to the combat meter group")
assert(frame.points[1].relativePoint == "TOP", "sits on the top of the stack")
assert(frame.points[1].x == 0 and frame.points[1].y == 0, "centred on the Cast Bar with no gap")
assert(frame.width == 112 and frame.height == 36, "RangeDisplay default size")
assert(frame.text.fontFile == "Fonts\\ARIALN.TTF", "Range Display uses Arial Narrow")
assert(frame.text.fontSize == 18, "Range Display uses size 18")
assert(frame.text.fontFlags == "THICKOUTLINE", "Range Display uses a strong outline")
assert(frame.event == "PLAYER_TARGET_CHANGED", "listens for target changes")

function Addon:ResolveEffective()
  return { layout = { range = { point = "BOTTOMLEFT", relativeTo = UIParent, x = 40, y = 80 } } }
end
Addon:ApplyRangeDisplay()
assert(frame.points[1].point == "BOTTOMLEFT", "Layout park wins over the shipped centre lock")
assert(frame.points[1].x == 40 and frame.points[1].y == 80, "Range Display follows Layout")
function Addon:ResolveEffective() return { layout = {} } end
Addon:ApplyRangeDisplay()
assert(frame.points[1].point == "BOTTOM", "empty Layout restores the tether")
assert(frame.points[1].relativeTo == castGroup, "empty Layout restores the combat meter group")
assert(frame.points[1].x == 0 and frame.points[1].y == 0, "empty Layout restores the centre lock")

local melee = Addon:RangeState(0, 5)
assert(melee.text == "0 - 5", "close range text")
assert(melee.r == 0.9 and melee.g == 0.9, "close range is white")

local short = Addon:RangeState(8, 20)
assert(short.text == "8 - 20", "short range text")
assert(math.abs(short.g - 0.875) < 0.001, "short range is cyan")

local mid = Addon:RangeState(21, 30)
assert(math.abs(mid.g - 0.865) < 0.001, "medium range is green")

local def = Addon:RangeState(31, 35)
assert(def.r == 1 and math.abs(def.g - 0.82) < 0.001, "default section is gold")

local oor = Addon:RangeState(40, 45)
assert(math.abs(oor.r - 0.9) < 0.001 and math.abs(oor.g - 0.055) < 0.001, "out of range is red")

assert(Addon:RangeState(nil, nil) == nil, "no estimate hides the numbers")
assert(Addon:RangeState(100, nil) == nil, "min at the range limit hides the numbers")
local over = Addon:RangeState(28, nil)
assert(over.text == "28 +", "unknown max uses over-limit text")

local minR, maxR = Addon:RangeFromClient("target")
assert(minR == 8 and maxR == 20, "reads LibRangeCheck through table LibStub")

Addon:RangePaint(frame, 8, 20)
assert(frame.shown == true, "keeps the meter frame shown")
assert(frame.text.shown == true, "shows numbers when a band is known")
assert(frame.text.text == "8 - 20", "paints min-max")

Addon:RangePaint(frame, 28, nil)
assert(frame.shown == true, "shows over-limit min when max is unknown")
assert(frame.text.text == "28 +", "paints over-limit text")

Addon:RangePaint(frame, nil, nil)
assert(frame.shown == true, "keeps the meter frame for OnUpdate")
assert(frame.text.shown == false, "hides the numbers when range is unknown")

_G.UnitExists = function() return false end
Addon:RangeRefresh(frame)
assert(frame.shown == true, "keeps the frame with no target")
assert(frame.text.shown == false, "hides numbers with no target")

_G.UnitExists = function() return true end
_G.UnitIsUnit = function() return true end
Addon:RangeRefresh(frame)
assert(frame.text.shown == false, "hides numbers when the target is the player")

_G.UnitIsUnit = function() return false end
fakeRange.min, fakeRange.max = 5, 10
Addon:RangeRefresh(frame)
assert(frame.text.shown == true, "shows for a real target")
assert(frame.text.text == "5 - 10", "reads LibRangeCheck")

print("range_spec OK")

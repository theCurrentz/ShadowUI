--[[
  Purpose: Target Range Display from Whitemane Currentz RangeDisplay.
  Deps: LibRangeCheck-3.0, PLAYER_TARGET_CHANGED
  Public: ShadowUI:ApplyRangeDisplay(), ShadowUI:RangeState(),
          ShadowUI:RangePaint(), ShadowUI:RangeFromClient()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local WIDTH, HEIGHT, FONT_SIZE = 112, 36, 20
local FONT = "Fonts\\ARIALN.TTF"
local X, Y = -6, -170
local UPDATE_DELAY = 0.1
local RANGE_LIMIT = 100
local TEXT = "%d - %d"
local OVER_LIMIT = "%d +"
local SECTIONS = {
  { enabled = true, max = 5, color = { 0.9, 0.9, 0.9, 1 } },
  { enabled = true, max = 20, color = { 0.055, 0.875, 0.825, 1 } },
  { enabled = true, max = 30, color = { 0.035, 0.865, 0.0, 1 } },
  { enabled = false, max = 35, color = { 1.0, 0.82, 0, 1 } },
}

local DEFAULT_COLOR = { 1.0, 0.82, 0, 1 }
local OOR = { enabled = true, min = 40, color = { 0.9, 0.055, 0.075, 1 } }

local function colorState(text, color)
  return {
    text = text,
    r = color[1],
    g = color[2],
    b = color[3],
    a = color[4],
  }
end

function Addon:RangeFromClient(unit)
  local rc = LibStub("LibRangeCheck-3.0", true)
  if not rc or not rc.GetRange then
    return nil, nil
  end
  local ok, minRange, maxRange = pcall(rc.GetRange, rc, unit)
  if not ok then
    return nil, nil
  end
  return minRange, maxRange
end

function Addon:RangeState(minRange, maxRange)
  if minRange == nil or minRange >= RANGE_LIMIT then
    return nil
  end
  if maxRange == nil then
    local color = DEFAULT_COLOR
    if OOR.enabled and minRange >= OOR.min then
      color = OOR.color
    end
    return colorState(OVER_LIMIT:format(minRange), color)
  end
  local color
  for _, section in ipairs(SECTIONS) do
    if section.enabled and maxRange <= section.max then
      color = section.color
      break
    end
  end
  if not color then
    if OOR.enabled and minRange >= OOR.min then
      color = OOR.color
    else
      color = DEFAULT_COLOR
    end
  end
  return colorState(TEXT:format(minRange, maxRange), color)
end

function Addon:RangePaint(frame, minRange, maxRange)
  frame:Show()
  local state = self:RangeState(minRange, maxRange)
  if not state then
    frame.text:Hide()
    return nil
  end
  frame.text:SetText(state.text)
  frame.text:SetTextColor(state.r, state.g, state.b, state.a)
  frame.text:Show()
  return state
end

function Addon:RangeShouldShow()
  if not UnitExists("target") or UnitIsUnit("target", "player") then
    return false
  end
  return true
end

local function layoutHost(self, id, shipped)
  local layout
  if self.ResolveEffective then
    local resolved = self:ResolveEffective()
    layout = resolved and resolved.layout and resolved.layout[id]
  end
  layout = layout or {}
  return {
    point = layout.point or shipped.point,
    x = layout.x ~= nil and layout.x or shipped.x,
    y = layout.y ~= nil and layout.y or shipped.y,
    width = layout.width ~= nil and layout.width or shipped.width,
    height = layout.height ~= nil and layout.height or shipped.height,
    relativeTo = layout.relativeTo,
    relativePoint = layout.relativePoint or layout.point or shipped.point,
  }
end

local function parkDisplay(self, frame)
  local park = layoutHost(self, "range", {
    point = "CENTER",
    x = X,
    y = Y,
    width = WIDTH,
    height = HEIGHT,
  })
  if frame.ClearAllPoints then
    frame:ClearAllPoints()
  end
  frame:SetPoint(park.point, park.relativeTo or UIParent, park.relativePoint, park.x, park.y)
  if frame.SetSize then
    frame:SetSize(park.width, park.height)
  end
end

function Addon:RangeRefresh(frame)
  if not self:RangeShouldShow() then
    self:RangePaint(frame, nil, nil)
    return
  end
  self:RangePaint(frame, self:RangeFromClient("target"))
end

local function createDisplay()
  local frame = CreateFrame("Frame", "ShadowUIRangeDisplay", UIParent)
  frame:SetSize(WIDTH, HEIGHT)
  frame:SetPoint("CENTER", UIParent, "CENTER", X, Y)
  frame:SetFrameStrata("HIGH")
  frame:EnableMouse(false)
  local text = frame:CreateFontString(nil, "OVERLAY")
  text:SetPoint("CENTER", frame, "CENTER", 0, 0)
  text:SetJustifyH("CENTER")
  text:SetFont(FONT, FONT_SIZE, "THICKOUTLINE")
  frame.text = text
  frame.lastUpdate = 0
  text:Hide()
  frame:SetScript("OnUpdate", function(self, elapsed)
    self.lastUpdate = (self.lastUpdate or 0) + elapsed
    if self.lastUpdate < UPDATE_DELAY then
      return
    end
    self.lastUpdate = 0
    Addon:RangeRefresh(self)
  end)
  frame:SetScript("OnEvent", function(self)
    Addon:RangeRefresh(self)
  end)
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:Show()
  return frame
end

function Addon:ApplyRangeDisplay()
  if not self.rangeDisplay then
    self.rangeDisplay = createDisplay()
  end
  parkDisplay(self, self.rangeDisplay)
  self:RangeRefresh(self.rangeDisplay)
  if self.editMode and self.RefreshUnitDragOverlays then
    self:RefreshUnitDragOverlays()
  end
end

-- Target Frame shows a full-width Threat Bar flush on the nameplate. Solo still paints.
-- Classic Era has no Wrath numeric threat caption. Run: lua tests/threat_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function() end
_G.GetNumGroupMembers = function() return 5 end
_G.UnitDetailedThreatSituation = function(unit, mob)
  if unit == "player" and mob == "target" then
    return false, 1, 72
  end
end
_G.CreateFrame = function(_, _, parent)
  local frame = { parent = parent, shown = true, points = {}, h = 12, value = 0 }
  function frame:SetSize(w, h) frame.w, frame.h = w, h end
  function frame:SetHeight(h) frame.h = h end
  function frame:SetMinMaxValues(lo, hi) frame.min, frame.max = lo, hi end
  function frame:SetValue(v) frame.value = v end
  function frame:SetStatusBarTexture() end
  function frame:SetStatusBarColor(r, g, b) frame.fillR, frame.fillG, frame.fillB = r, g, b end
  function frame:SetPoint(...)
    frame.points[#frame.points + 1] = { ... }
    frame.point = { ... }
  end
  function frame:ClearAllPoints() frame.points = {} frame.point = nil end
  function frame:SetFrameLevel() end
  function frame:SetScript() end
  function frame:Show() frame.shown = true end
  function frame:Hide() frame.shown = false end
  function frame:CreateTexture()
    local tex = {}
    function tex:SetAllPoints() end
    function tex:SetColorTexture() end
    function tex:SetVertexColor(r, g, b) tex.r, tex.g, tex.b = r, g, b end
    frame.bg = tex
    return tex
  end
  function frame:CreateFontString()
    local fs = {}
    function fs:SetPoint() end
    function fs:SetText(text) fs.text = text end
    frame.font = fs
    return fs
  end
  return frame
end

_G.TargetFrame = { unit = "target", buffsOnTop = false }
function _G.TargetFrame:GetName() return "TargetFrame" end

assert(loadfile(root .. "skin/threat.lua"))()

assert(Addon:ThreatCaption(72) == "72%", "threat is a percent")
assert(Addon:ThreatCaption(72.4) == "72%", "threat percent rounds")
assert(Addon:ThreatCaption(100) == "100%", "solo still shows threat number")
assert(Addon:ThreatCaption(0) == nil, "zero threat hides")
assert(Addon:ThreatCaption(nil) == nil, "missing threat hides")

local function near(a, b)
  return math.abs(a - b) < 0.02
end

local r0, g0, b0 = Addon:ThreatBarColor(0)
assert(near(r0, 0.53) and near(g0, 0.53) and near(b0, 0.53), "low threat is desaturated grey")
local rMid, gMid, bMid = Addon:ThreatBarColor(70)
assert(near(rMid, 1.0) and near(gMid, 0.45) and near(bMid, 0.05), "mid-high threat is orange")
local rFull, gFull, bFull = Addon:ThreatBarColor(100)
assert(near(rFull, 0.75) and near(gFull, 0) and near(bFull, 0), "full threat is blood red")
assert(rMid > r0 and gMid < g0, "grey climbs toward orange")
assert(gFull < gMid and rFull < rMid, "orange falls toward blood red")

Addon:SkinTargetThreat()
local bar = _G.TargetFrame.shadowUIThreat
assert(bar.font.text == "72%", "target paints threat")
assert(bar.shown == true, "threat bar shows")
assert(bar.h == 12, "threat bar stays skinny")
assert(bar.value == 72, "fill matches threat percent")
local r72, g72 = Addon:ThreatBarColor(72)
assert(near(bar.fillR, r72) and near(bar.fillG, g72), "fill uses the threat colour")
local left = bar.points[1]
local right = bar.points[2]
assert(left[1] == "BOTTOMLEFT" and left[2] == _G.TargetFrame and left[3] == "TOPLEFT" and left[4] == 0 and left[5] == 0,
  "threat bar sits flush on the left of the nameplate")
assert(right[1] == "BOTTOMRIGHT" and right[2] == _G.TargetFrame and right[3] == "TOPRIGHT" and right[4] == 0 and right[5] == 0,
  "threat bar spans the full nameplate width with zero gap")

_G.GetNumGroupMembers = function() return 0 end
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.shown == true, "solo still shows the threat bar")
assert(_G.TargetFrame.shadowUIThreat.points[1][1] == "BOTTOMLEFT", "solo threat stays flush on the nameplate")

-- Classic still ships TargetFrameNumericalThreat. Blizzard hides that stub
-- after paint, so Threat Number must live on our bar, not the native host.
_G.GetNumGroupMembers = function() return 5 end
local native = { shown = false }
function native:Show() native.shown = true end
function native:Hide() native.shown = false end
function native:SetPoint() end
function native:ClearAllPoints() end
native.text = {
  SetText = function(_, text) native.text.value = text end,
}
_G.TargetFrameNumericalThreat = native
_G.TargetFrame.shadowUIThreat = nil
Addon:SkinTargetThreat()
native:Hide()
assert(_G.TargetFrame.shadowUIThreat.shown == true, "threat bar survives native hide")
assert(_G.TargetFrame.shadowUIThreat.font.text == "72%", "threat stays on the ShadowUI bar")
assert(native.shown == false, "native threat stub stays hidden")

-- scaled percent wins; raw is the fallback so Classic nil scaled still paints.
_G.UnitDetailedThreatSituation = function()
  return false, 0, nil, 41
end
_G.TargetFrame.shadowUIThreat = nil
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.font.text == "41%", "raw threat fills when scaled is missing")
assert(_G.TargetFrame.shadowUIThreat.value == 41, "raw threat sets the fill")

_G.UnitDetailedThreatSituation = function()
  return true, 3, nil, nil
end
_G.TargetFrame.shadowUIThreat = nil
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.font.text == "100%", "tanking with no percent is full threat")
assert(_G.TargetFrame.shadowUIThreat.value == 100, "tanking fill is full")

_G.UnitDetailedThreatSituation = function()
  return false, 2, 118
end
_G.TargetFrame.shadowUIThreat = nil
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.font.text == "118%", "over-pull threat stays accurate")
assert(_G.TargetFrame.shadowUIThreat.value == 100, "fill caps at full width")

_G.TargetFrameNameBackground = { id = "nameplate" }
_G.TargetFrame.shadowUIThreat = nil
_G.UnitDetailedThreatSituation = function()
  return false, 1, 72
end
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.points[1][2] == _G.TargetFrameNameBackground,
  "threat bar uses the nameplate when it exists")
assert(_G.TargetFrame.shadowUIThreat.points[2][2] == _G.TargetFrameNameBackground,
  "threat bar spans the nameplate")

print("threat_spec OK")

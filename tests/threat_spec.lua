-- Target Frame shows Threat Number above the nameplate. Solo still paints.
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
  local frame = { parent = parent, shown = true }
  function frame:SetSize(w, h) frame.w, frame.h = w, h end
  function frame:SetPoint(...) frame.point = { ... } end
  function frame:ClearAllPoints() frame.point = nil end
  function frame:SetFrameLevel() end
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

local r, g, b = Addon:ThreatStatusColor(3)
assert(r == 1 and g == 0 and b == 0, "tanking threat is red")

Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.font.text == "72%", "target paints threat")
assert(_G.TargetFrame.shadowUIThreat.shown == true, "threat number shows")
local point = _G.TargetFrame.shadowUIThreat.point
assert(point[1] == "BOTTOM" and point[2] == _G.TargetFrame and point[3] == "TOP", "threat number sits above the nameplate")

_G.GetNumGroupMembers = function() return 0 end
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.shown == true, "solo still shows the threat number")
assert(_G.TargetFrame.shadowUIThreat.point[1] == "BOTTOM", "solo threat stays above the nameplate")

-- Classic still ships TargetFrameNumericalThreat. Blizzard hides that stub
-- after paint, so Threat Number must live on our pip, not the native host.
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
assert(_G.TargetFrame.shadowUIThreat.shown == true, "threat number survives native hide")
assert(_G.TargetFrame.shadowUIThreat.font.text == "72%", "threat stays on the ShadowUI pip")
assert(native.shown == false, "native threat stub stays hidden")

print("threat_spec OK")

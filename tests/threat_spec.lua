-- Target Frame shows the Threat Bar as a bubble tab on the portrait side.
-- Aggro Glow is orange at high threat and blood red while the target attacks the player.
-- Classic Era has no Wrath numeric threat caption. Run: lua tests/threat_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = { DARKEN_BLACK = { 0.05, 0.05, 0.05 } }
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
function Addon:ApplyStatusBarGradient(texture, orientation, from, to)
  if not texture then
    return
  end
  texture.orientation = orientation
  texture.from = from
  texture.to = to
end
function Addon:ApplyOuterChrome(host)
  if not host or host.shadowUIOuter then
    return host and host.shadowUIOuter
  end
  host.shadowUIOuter = {
    shown = true,
    points = { { "TOPLEFT", host, "TOPLEFT", -4, 4 } },
  }
  return host.shadowUIOuter
end
_G.CreateFrame = function(_, _, parent)
  local frame = { parent = parent, shown = true, points = {}, h = 16, w = 56, textures = {} }
  function frame:SetSize(w, h) frame.w, frame.h = w, h end
  function frame:SetHeight(h) frame.h = h end
  function frame:SetWidth(w) frame.w = w end
  function frame:SetPoint(...)
    frame.points[#frame.points + 1] = { ... }
    frame.point = { ... }
  end
  function frame:SetAllPoints(host)
    frame.all = host or frame
    frame.points = { { "ALL", host } }
    frame.point = { "ALL", host }
  end
  function frame:ClearAllPoints() frame.points = {} frame.point = nil frame.all = nil end
  function frame:SetFrameLevel() end
  function frame:GetFrameLevel() return 5 end
  function frame:SetScript() end
  function frame:Show() frame.shown = true end
  function frame:Hide() frame.shown = false end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:SetAllPoints(host) tex.all = host or frame end
    function tex:SetTexture(path) tex.path = path end
    function tex:SetVertexColor(r, g, b, a)
      tex.r, tex.g, tex.b, tex.a = r, g, b, a
    end
    function tex:SetSize(w, h) tex.w, tex.h = w, h end
    function tex:SetPoint(...) tex.points[#tex.points + 1] = { ... } end
    function tex:ClearAllPoints() tex.points = {} end
    function tex:SetTexCoord(...) tex.texCoord = { ... } end
    function tex:SetBlendMode(mode) tex.blend = mode end
    function tex:SetDrawLayer(layer, sub)
      tex.layer = layer
      tex.sub = sub
    end
    function tex:Show() tex.shown = true end
    function tex:Hide() tex.shown = false end
    tex.shown = true
    frame.textures[#frame.textures + 1] = tex
    return tex
  end
  function frame:CreateFontString()
    local fs = { points = {} }
    function fs:SetPoint(...)
      fs.points[#fs.points + 1] = { ... }
      fs.point = { ... }
    end
    function fs:SetAllPoints(host) fs.all = host or frame end
    function fs:ClearAllPoints() fs.points = {} fs.point = nil fs.all = nil end
    function fs:SetWidth(w) fs.w = w end
    function fs:SetHeight(h) fs.h = h end
    function fs:SetWordWrap(v) fs.wordWrap = v end
    function fs:SetMaxLines(n) fs.maxLines = n end
    function fs:SetJustifyH(h) fs.justifyH = h end
    function fs:SetJustifyV(v) fs.justifyV = v end
    function fs:SetText(text) fs.text = text end
    function fs:GetFont() return "Fonts\\FRIZQT__.TTF", 12, "" end
    function fs:SetFont(path, size, flags)
      fs.fontPath, fs.fontSize, fs.fontFlags = path, size, flags
    end
    frame.font = fs
    return fs
  end
  return frame
end

local portrait = { id = "portrait" }
_G.TargetFrame = { unit = "target", buffsOnTop = false, portrait = portrait }
function _G.TargetFrame:GetName() return "TargetFrame" end
function _G.TargetFrame:GetFrameLevel() return 5 end

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
assert(near(r0, 0) and near(g0, 0) and near(b0, 0), "low threat is dark")
local rWarn, gWarn, bWarn = Addon:ThreatBarColor(70)
assert(near(rWarn, 1.0) and near(gWarn, 0.85) and near(bWarn, 0.18),
  "70% threat is yellow")
local rHigh, gHigh, bHigh = Addon:ThreatBarColor(88)
assert(near(rHigh, 1.0) and near(gHigh, 0.50) and near(bHigh, 0.06),
  "88% threat is orange")
local rFull, gFull, bFull = Addon:ThreatBarColor(100)
assert(near(rFull, 0.95) and near(gFull, 0.10) and near(bFull, 0.08),
  "full threat is red")
assert(Addon:ThreatBarColor(118) == Addon:ThreatBarColor(100),
  "over-pull stays on the full-threat hue")

local from41, to41 = Addon:ThreatBarGradient(41)
assert(near(from41[1], 0) and near(from41[4], 0.58), "low threat is dark glass")
assert(to41[4] > from41[4], "low threat stays more opaque at the light end")
local from72, to72 = Addon:ThreatBarGradient(72)
assert(to72[2] > from72[2], "70-88% runs yellow at the light end to orange at the dark end")
assert(near(to72[4], 0.84) and near(from72[4], 0.76),
  "threat fill is slightly transparent")
local from90, to90 = Addon:ThreatBarGradient(90)
assert(from90[1] < to90[1] and from90[2] < to90[2],
  "88-99% runs orange at the light end to deep orange at the dark end")
local from100, to100 = Addon:ThreatBarGradient(100)
assert(from100[1] < to100[1] and from100[2] <= to100[2],
  "100% runs red at the light end to deep red at the dark end")
local fromOver, toOver = Addon:ThreatBarGradient(118)
assert(near(fromOver[1], from100[1]) and near(toOver[1], to100[1]),
  "over-pull uses the full-threat gradient")

Addon:SkinTargetThreat()
local tab = _G.TargetFrame.shadowUIThreat
assert(tab.font.text == "72%", "target paints threat")
assert(tab.shown == true, "threat tab shows")
assert(tab.w == 32 and tab.h == 32, "threat tab is a round bubble")
assert(tab.w == tab.h, "bubble stays circular like the portrait")
assert(tab.value == nil, "threat tab is not a StatusBar fill")
assert(tab.fill.path == "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
  "fill is the portrait circle")
assert(tab.fill.w == 26 and tab.fill.h == 26, "fill sits inside the stroke")
assert(tab.rim.path == "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
  "stroke is the portrait circle")
assert(tab.rim.w == 32 and tab.rim.h == 32, "stroke matches the bubble")
assert(near(tab.rim.r, 0.05) and near(tab.rim.a, 0.84),
  "stroke matches Darken chrome at 84% opacity")
assert(not tab.inner or tab.inner.shown == false, "nested inner disc stays hidden")
assert(not tab.drop or tab.drop.shown == false, "offset drop disc stays hidden")
assert(not tab.shadowUIOuter or tab.shadowUIOuter.shown == false,
  "square Outer Edge stays off the round bubble")
assert(tab.fill.orientation == "VERTICAL", "fill uses one lighting gradient")
assert(near(tab.fill.from[1], from72[1]) and near(tab.fill.to[1], to72[1]),
  "fill uses the threat gradient")
assert(tab.font.point[1] == "CENTER" and tab.font.point[2] == tab,
  "Threat Number stays centred")
assert(tab.font.w == 32 and tab.font.wordWrap == false,
  "Threat Number is one line on the bubble")
assert(tab.font.fontSize == 9 and tab.font.fontFlags == "OUTLINE",
  "Threat Number uses a slightly smaller outlined font")
assert(tab.font.justifyH == "CENTER" and tab.font.justifyV == "MIDDLE",
  "vertical and side text margins stay balanced")
local point = tab.points[1]
assert(point[1] == "CENTER" and point[2] == portrait and point[3] == "TOPRIGHT"
    and point[4] == -10 and point[5] == -10,
  "threat bubble floats on the 45-degree portrait edge")
assert(#tab.points == 1, "threat tab is not a full-width nameplate bar")

_G.GetNumGroupMembers = function() return 0 end
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.shown == true, "solo still shows the threat tab")
assert(_G.TargetFrame.shadowUIThreat.points[1][1] == "CENTER", "solo threat stays a portrait bubble")

-- Classic still ships TargetFrameNumericalThreat. Blizzard hides that stub
-- after paint, so Threat Number must live on our tab, not the native host.
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
assert(_G.TargetFrame.shadowUIThreat.shown == true, "threat tab survives native hide")
assert(_G.TargetFrame.shadowUIThreat.font.text == "72%", "threat stays on the ShadowUI tab")
assert(native.shown == false, "native threat stub stays hidden")

-- scaled percent wins; raw is the fallback so Classic nil scaled still paints.
_G.UnitDetailedThreatSituation = function()
  return false, 0, nil, 41
end
_G.TargetFrame.shadowUIThreat = nil
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.font.text == "41%", "raw threat fills when scaled is missing")
local from41b, to41b = Addon:ThreatBarGradient(41)
assert(near(_G.TargetFrame.shadowUIThreat.fill.from[1], from41b[1])
    and near(_G.TargetFrame.shadowUIThreat.fill.to[4], to41b[4]),
  "raw threat sets the tab gradient")

_G.UnitDetailedThreatSituation = function()
  return true, 3, nil, nil
end
_G.TargetFrame.shadowUIThreat = nil
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.font.text == "100%", "tanking with no percent is full threat")
local fromTank, toTank = Addon:ThreatBarGradient(100)
assert(near(_G.TargetFrame.shadowUIThreat.fill.from[1], fromTank[1])
    and near(_G.TargetFrame.shadowUIThreat.fill.to[1], toTank[1]),
  "tanking tab is a red gradient")

_G.UnitDetailedThreatSituation = function()
  return false, 2, 118
end
_G.TargetFrame.shadowUIThreat = nil
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.font.text == "118%", "over-pull threat stays accurate")
local fromOverTab, toOverTab = Addon:ThreatBarGradient(118)
assert(near(_G.TargetFrame.shadowUIThreat.fill.from[1], fromOverTab[1])
    and near(_G.TargetFrame.shadowUIThreat.fill.to[1], toOverTab[1]),
  "over-pull tab uses the full-threat gradient")

local modern = { id = "modern-portrait" }
_G.TargetFrame.portrait = nil
_G.TargetFrame.TargetFrameContainer = { Portrait = modern }
_G.TargetFrameNameBackground = { id = "nameplate" }
_G.TargetFrame.shadowUIThreat = nil
_G.UnitDetailedThreatSituation = function()
  return false, 1, 72
end
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIThreat.points[1][2] == modern,
  "threat bubble uses the circular portrait when it exists")
assert(_G.TargetFrame.shadowUIThreat.points[1][2] ~= _G.TargetFrameNameBackground,
  "threat bubble does not sit on the nameplate")

assert(Addon:TargetHasAggro("target") == false, "high threat without tanking is not aggro")
local hr, hg, hb = Addon:AggroGlowColor("target")
assert(near(hr, 1.0) and near(hg, 0.50) and near(hb, 0.06),
  "high threat without aggro is orange")
Addon:SkinTargetThreat()
local glow = _G.TargetFrame.shadowUIAggroGlow
assert(glow, "aggro glow host exists")
assert(glow.shown == true, "aggro glow shows at high threat without aggro")
assert(glow.parent == _G.TargetFrame, "aggro glow sits on the Target Frame")
assert(glow.w == 242 and glow.h == 93, "normal aggro glow matches the targeting-frame silhouette")
assert(glow.points[1][1] == "TOPLEFT" and glow.points[1][4] == -24 and glow.points[1][5] == 0,
  "normal aggro glow uses the Blizzard flash anchor")
assert(glow.points[1][2] == _G.TargetFrame.TargetFrameContainer,
  "aggro glow sits on the visual Target Frame container")
assert(#glow.textures == 1, "aggro glow is one silhouette texture, not a bounding box")
local fill = glow.fill
assert(fill.path == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash",
  "aggro glow uses the targeting-frame flash art")
assert(fill.blend == "ADD", "aggro glow is additive")
assert(near(fill.r, 1.0) and near(fill.g, 0.50) and near(fill.b, 0.06),
  "high-threat glow is orange")
assert(fill.a > 0.2 and fill.a < 0.7, "aggro glow stays semi-transparent")
assert(fill.texCoord[1] == 0 and near(fill.texCoord[2], 0.9453125)
    and fill.texCoord[3] == 0 and near(fill.texCoord[4], 0.181640625),
  "normal aggro glow uses the normal flash slice")

_G.UnitDetailedThreatSituation = function()
  return true, 3, 100
end
assert(Addon:TargetHasAggro("target") == true, "tanking is aggro")
local rr, rg, rb = Addon:AggroGlowColor("target")
assert(near(rr, 0.75) and near(rg, 0) and near(rb, 0), "aggro glow is blood red")
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIAggroGlow.shown == true,
  "aggro glow shows when the target attacks the player")
assert(near(glow.fill.r, 0.75) and near(glow.fill.g, 0) and near(glow.fill.b, 0),
  "aggro glow is blood red")

_G.UnitDetailedThreatSituation = function()
  return false, 1, 72
end
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIAggroGlow.shown == true,
  "high threat without aggro keeps the glow")
assert(near(glow.fill.r, 1.0) and near(glow.fill.g, 0.50) and near(glow.fill.b, 0.06),
  "losing aggro at high threat returns the glow to orange")

_G.UnitDetailedThreatSituation = function()
  return false, 0, 41
end
assert(Addon:AggroGlowColor("target") == nil, "low threat has no glow colour")
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIAggroGlow.shown == false,
  "aggro glow hides at low threat")

_G.UnitClassification = function() return "elite" end
_G.UnitDetailedThreatSituation = function()
  return false, 1, 72
end
_G.TargetFrame.shadowUIAggroGlow = nil
Addon:SkinTargetThreat()
local eliteGlow = _G.TargetFrame.shadowUIAggroGlow
assert(eliteGlow.h == 112, "elite aggro glow uses the elite flash slice")
assert(eliteGlow.points[1][4] == -22 and eliteGlow.points[1][5] == 9,
  "elite aggro glow follows the elite silhouette")
_G.UnitClassification = nil

local nativeFlash = { id = "flash", w = 256, h = 128 }
_G.TargetFrame.TargetFrameContainer = { Flash = nativeFlash, Portrait = modern }
_G.TargetFrame.shadowUIAggroGlow = nil
Addon:SkinTargetThreat()
assert(_G.TargetFrame.shadowUIAggroGlow.all == nativeFlash,
  "aggro glow matches the native flash so it stays framed")
_G.TargetFrame.TargetFrameContainer = { Portrait = modern }

_G.FocusFrame = { unit = "focus" }
function _G.FocusFrame:GetName() return "FocusFrame" end
function _G.FocusFrame:GetFrameLevel() return 5 end
_G.UnitDetailedThreatSituation = function(unit, mob)
  if mob == "focus" then
    return true, 3, 100
  end
  return false, 0, 20
end
Addon:SkinTargetThreat()
assert(_G.FocusFrame.shadowUIAggroGlow == nil, "aggro glow is Target Frame only")
assert(_G.FocusFrame.shadowUIThreat == nil, "Threat Bar is Target Frame only")
assert(_G.TargetFrame.shadowUIAggroGlow.shown == false,
  "focus aggro does not light the Target Frame")

print("threat_spec OK")

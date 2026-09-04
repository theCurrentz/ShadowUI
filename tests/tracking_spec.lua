-- XP sits on UIParent TOP with no offset; reputation sits directly under XP.
-- XP fill is a left-right retail purple gloss with Outer Edge; Classic overlay art stays hidden.
-- Run: lua tests/tracking_spec.lua
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
    object[method] = fn
    return
  end
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
_G.UIParent = { name = "UIParent" }
function _G.UIParent:GetWidth() return 1920 end

function Addon:ApplyStatusBarGradient(texture, orientation, from, to)
  texture.orientation = orientation
  texture.from = from
  texture.to = to
end

local function fakeTex(name)
  local tex = { name = name, hidden = false, points = {} }
  function tex:Hide() self.hidden = true end
  function tex:Show() self.hidden = false end
  function tex:SetAlpha(a) self.alpha = a end
  function tex:SetTexture(path) self.path = path end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a or 1
  end
  function tex:SetVertexColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a or 1
  end
  function tex:SetAllPoints(rel) self.all = rel end
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function tex:SetWidth(w) self.w = w end
  function tex:SetHeight(h) self.h = h end
  function tex:SetDrawLayer(layer, sub)
    self.layer = layer
    self.sub = sub
  end
  function tex:SetHorizTile(on) self.horizTile = on and true or false end
  function tex:SetVertTile(on) self.vertTile = on and true or false end
  function tex:SetTexCoord(l, r, t, b) self.crop = { l, r, t, b } end
  function tex:GetName() return self.name end
  function tex:IsShown() return not self.hidden end
  function tex:SetShown(shown) self.hidden = not shown end
  return tex
end

local function fakeFont()
  local fs = { text = "", hidden = false, points = {} }
  function fs:SetText(value) self.text = value end
  function fs:GetText() return self.text end
  function fs:Show() self.hidden = false end
  function fs:Hide() self.hidden = true end
  function fs:GetFont() return "Fonts\\FRIZQT__.TTF", 10, "" end
  function fs:SetFont(_, size, flags)
    self.size = size
    self.flags = flags
  end
  function fs:SetTextColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a or 1
  end
  function fs:SetShadowOffset() end
  function fs:SetShadowColor() end
  function fs:ClearAllPoints() self.points = {} end
  function fs:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function fs:SetJustifyH(h) self.justify = h end
  return fs
end

local function fakeBar(name, shown)
  local fill = fakeTex(name .. "Fill")
  fill.path = "Interface\\TargetingFrame\\UI-StatusBar"
  local bar = {
    name = name,
    parent = { name = "MainMenuBar" },
    shown = shown,
    points = {},
    height = 13,
    textures = {},
    fill = fill,
    r = 0, g = 0.39, b = 0.88, a = 1,
    level = 1,
    cur = 13832,
    minv = 0,
    maxv = 62800,
  }
  function bar:SetParent(parent) self.parent = parent end
  function bar:IsShown() return self.shown end
  function bar:Show() self.shown = true end
  function bar:Hide() self.shown = false end
  function bar:ClearAllPoints() self.points = {} end
  function bar:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function bar:SetWidth(width) self.width = width end
  function bar:GetWidth() return self.width or 1920 end
  function bar:GetHeight() return self.height end
  function bar:SetHeight(h) self.height = h end
  function bar:SetAlpha() end
  function bar:GetFrameLevel() return self.level end
  function bar:SetFrameLevel(level) self.level = level end
  function bar:SetFrameStrata(strata) self.strata = strata end
  function bar:GetName() return self.name end
  function bar:GetParent() return self.parent end
  function bar:EnableMouse() end
  function bar:SetAllPoints(rel) self.all = rel end
  function bar:SetMinMaxValues(minv, maxv) self.minv, self.maxv = minv, maxv end
  function bar:GetMinMaxValues() return self.minv, self.maxv end
  function bar:SetValue(v) self.cur = v end
  function bar:GetValue() return self.cur end
  function bar:GetStatusBarTexture() return fill end
  function bar:SetStatusBarTexture(path) fill.path = path end
  function bar:GetStatusBarColor() return self.r, self.g, self.b, self.a end
  function bar:SetStatusBarColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a or 1
  end
  function bar:CreateFontString()
    return fakeFont()
  end
  function bar:CreateTexture()
    local tex = fakeTex(nil)
    self.textures[#self.textures + 1] = tex
    return tex
  end
  function bar:SetBackdrop(bd) self.backdrop = bd end
  function bar:SetBackdropColor(r, g, b, a)
    self.fill = { r, g, b, a or 1 }
  end
  function bar:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a or 1 }
  end
  function bar:SetClipsChildren(clips) self.clipsChildren = clips end
  return bar
end

_G.CreateFrame = function(_, name, parent, template)
  local frame = fakeBar(name or "ShadowUIXPCover", true)
  frame.parent = parent
  frame.template = template
  return frame
end

_G.UnitXP = function() return 13832 end
_G.UnitXPMax = function() return 62800 end

local function fakeContainer(name, shown)
  local container = fakeBar(name, shown)
  container.StandaloneTextures = { fakeTex(name .. "Standalone1") }
  container.MainMenuBarTextures = { fakeTex(name .. "MainMenu1") }
  function container:UseMainMenuBarArt(useMainMenuBarArt)
    for i = 1, #self.MainMenuBarTextures do
      self.MainMenuBarTextures[i]:SetShown(useMainMenuBarArt)
    end
    for i = 1, #self.StandaloneTextures do
      self.StandaloneTextures[i]:SetShown(not useMainMenuBarArt)
    end
  end
  return container
end

local status = fakeBar("ExpStatusBar", true)
local expFrame = fakeBar("ExpStatusFrame", true)
expFrame.isExpBar = true
expFrame.barIndex = 4
expFrame.StatusBar = status
expFrame.ExhaustionLevelFillBar = fakeTex("ExhaustionLevelFillBar")
expFrame.OverlayFrame = {
  level = 8,
  Text = fakeFont(),
}
function expFrame.OverlayFrame:GetFrameLevel()
  return self.level
end

local main = fakeContainer("MainStatusTrackingBarContainer", true)
main.bars = { [4] = expFrame }
function main:GetShownBar()
  return expFrame
end

local secondary = fakeContainer("SecondaryStatusTrackingBarContainer", true)
_G.MainStatusTrackingBarContainer = main
_G.SecondaryStatusTrackingBarContainer = secondary
_G.StatusTrackingBarManager = fakeBar("StatusTrackingBarManager", true)
_G.StatusTrackingBarManager.MainStatusTrackingBarContainer = main
_G.StatusTrackingBarManager.SecondaryStatusTrackingBarContainer = secondary
_G.MainMenuExpBar = nil
_G.ReputationWatchBar = nil

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/tracking.lua"))()
Addon:SkinTrackingBars()

assert(main.parent == _G.UIParent, "XP container parents to UIParent")
assert(main.points[1][1] == "TOP" and main.points[1][2] == _G.UIParent and main.points[1][3] == "TOP",
  "XP container docks to screen top")
assert(main.points[1][4] == 0 and main.points[1][5] == 0, "XP container has no margin")
assert(main.width == 1920, "XP container spans the screen")
assert(main.height == 18, "XP container is tall enough for outlined Status Text")
assert(secondary.parent == _G.UIParent, "reputation container parents to UIParent")
assert(secondary.points[1][2] == main and secondary.points[1][3] == "BOTTOM",
  "reputation sits under XP")
assert(secondary.points[1][4] == 0 and secondary.points[1][5] == 0, "reputation container has no margin")

main:SetPoint("TOP", { name = "MainMenuBar" }, "TOP", 0, 0)
assert(main.points[#main.points][2] == _G.UIParent, "Blizzard XP anchors must be undone")

assert(main.StandaloneTextures[1].hidden, "Classic standalone XP notches stay hidden")
assert(main.MainMenuBarTextures[1].hidden, "Classic MainMenuBar XP art stays hidden")
main.StandaloneTextures[1]:Show()
assert(main.StandaloneTextures[1].hidden, "Blizzard cannot Show Classic standalone notches")
main.StandaloneTextures[1]:SetShown(true)
assert(main.StandaloneTextures[1].hidden, "Blizzard cannot SetShown Classic standalone notches")
main:UseMainMenuBarArt(false)
assert(main.StandaloneTextures[1].hidden, "UseMainMenuBarArt cannot restore Classic notches")

local host = main.shadowUIXPHost
assert(host, "XP cover host sits on the Tracking container")
assert(host.parent == _G.UIParent, "cover parents to UIParent so OverlayFrame cannot cover it")
assert(host.all == main, "cover fills the XP container")
assert(host.level > expFrame.OverlayFrame.level, "cover draws above OverlayFrame art")
assert(host.cur == 13832 and host.maxv == 62800, "cover copies live XP values")

local well = host.shadowUIWell
assert(well, "XP bar has a Darken well")
assert(well.r == 0.05 and well.g == 0.05 and well.b == 0.05, "XP well is Lorti darkest")
assert(well.all == host, "XP well fills the cover")

local outer = host.shadowUIOuter
assert(outer, "XP cover keeps a Lorti Outer Edge")
assert(outer.template == "BackdropTemplate", "XP Outer Edge uses BackdropTemplate")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true),
  "XP Outer Edge uses the Lorti shadow texture")
assert(outer.backdrop.edgeSize == 5, "XP Outer Edge size matches Lorti")
assert(outer.border[1] == 0 and outer.border[2] == 0 and outer.border[3] == 0
  and outer.border[4] == 0.9, "XP Outer Edge is black at 0.9")
assert(outer.fill[1] == 0 and outer.fill[4] == 0, "XP Outer Edge has no grey fill")
assert(outer.points[1][1] == "TOPLEFT" and outer.points[1][4] == -4,
  "XP Outer Edge extends 4px")
assert(host.clipsChildren == false, "XP cover does not clip Outer Edge")
assert(outer.level == host.level - 1, "XP Outer Edge sits behind the cover")

local meter = host.shadowUIMeter
assert(meter, "XP bar has a fill overlay")
assert(meter.all == host.fill, "XP overlay tracks the cover fill")
assert(meter.orientation == "HORIZONTAL", "XP lighting is left-right")
assert(meter.from[1] > meter.from[2] and meter.from[3] > meter.from[2],
  "XP fill starts as purple")
assert(meter.to[1] > 0.7 and meter.to[3] > 0.7 and meter.to[2] > 0.35,
  "XP fill ends as bright magenta")
assert(meter.from[1] < meter.to[1] and meter.from[3] < meter.to[3],
  "XP fill climbs from deep purple to magenta")
assert(host.fill.orientation == "HORIZONTAL", "cover fill gets the purple gradient")
assert(host.fill.horizTile == false and meter.horizTile == false,
  "XP fill does not tile, so the gradient does not repeat")
assert(status.fill.hidden, "native XP fill stays hidden so the cover does not double")
assert(meter.layer == "OVERLAY", "XP fill overlay sits above Classic bar art")
status:SetStatusBarColor(0, 0.39, 0.88, 1)
assert(meter.orientation == "HORIZONTAL" and meter.to[1] > 0.7,
  "Blizzard XP blue cannot flatten the purple fill")
assert(status.fill.hidden, "Blizzard XP colour cannot restore the native fill")

local rest = expFrame.ExhaustionLevelFillBar
assert(rest.orientation == "HORIZONTAL", "rested XP uses the same left-right lighting")
assert(rest.from[3] > rest.from[1] and rest.to[3] > rest.to[1],
  "rested XP stays cyan, not purple")

local text = host.shadowUIText
assert(text, "cover paints Status Text")
assert(text.text == "(23%) 13832 / 62800", "cover shows current XP and XP to next level")
assert(text.flags == "OUTLINE", "XP Status Text uses an outline")
assert(text.size == 12, "XP Status Text matches unit-frame size")
assert(text.r == 1 and text.g == 1 and text.b == 1, "XP Status Text stays white")
assert(text.justify == "CENTER", "XP Status Text stays centred")
assert(not text.hidden, "XP Status Text stays shown")

_G.UnitXP = function() return 20000 end
Addon:SkinTrackingBars()
assert(host.shadowUIText.text == "(32%) 20000 / 62800", "XP Status Text updates when current XP changes")

local ticks = host.shadowUITicks
assert(ticks and #ticks == 19, "XP bar keeps 5% tick marks")
assert(ticks[1].w == 1, "XP ticks stay 1px")

print("tracking_spec OK")

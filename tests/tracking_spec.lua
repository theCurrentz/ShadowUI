-- Reputation docks to UIParent TOP. The Experience bar stays with Blizzard:
-- notches, Status Text, and rested XP stay. The fill stays Blizzard.
-- The bar gets a Lorti Outer Edge.
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
_G.CreateColor = function(r, g, b, a)
  return { r = r, g = g, b = b, a = a or 1 }
end
_G.UIParent = { name = "UIParent" }
function _G.UIParent:GetWidth() return 1920 end

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
  function tex:SetGradient(orientation, from, to)
    self.orientation = orientation
    self.from = from
    self.to = to
  end
  function tex:GetName() return self.name end
  function tex:IsShown() return not self.hidden end
  function tex:SetShown(shown) self.hidden = not shown end
  function tex:GetObjectType() return "Texture" end
  function tex:IsObjectType(kind) return kind == "Texture" end
  return tex
end

local function fakeFont()
  local fs = { text = "", hidden = false, alpha = 1 }
  function fs:Show() self.hidden = false end
  function fs:Hide() self.hidden = true end
  function fs:SetAlpha(a) self.alpha = a end
  function fs:IsShown() return not self.hidden end
  function fs:GetObjectType() return "FontString" end
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
    level = 4,
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
  function bar:GetName() return self.name end
  function bar:GetParent() return self.parent end
  function bar:GetStatusBarTexture() return fill end
  function bar:SetStatusBarTexture(path) fill.path = path end
  function bar:GetStatusBarColor() return self.r, self.g, self.b, self.a end
  function bar:SetStatusBarColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a or 1
  end
  function bar:CreateTexture()
    local tex = fakeTex(nil)
    self.textures[#self.textures + 1] = tex
    return tex
  end
  return bar
end

local function fakeContainer(name, shown)
  local container = fakeBar(name, shown)
  container.StandaloneTextures = { fakeTex(name .. "Standalone1") }
  container.MainMenuBarTextures = { fakeTex(name .. "MainMenu1") }
  return container
end

_G.CreateFrame = function(kind, name, parent, template)
  if kind == "StatusBar" or name == "ShadowUIXPHost" then
    error("SkinTrackingBars must not create an XP cover: " .. tostring(name))
  end
  local frame = { points = {}, parent = parent, template = template }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor(r, g, b, a) self.bg = { r, g, b, a } end
  function frame:SetBackdropBorderColor(r, g, b, a) self.border = { r, g, b, a } end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  return frame
end

local blizzardParent = { name = "MainMenuBar" }
local status = fakeBar("ExpStatusBar", true)
local xpBorder = fakeTex("MainMenuXPBarTexture0")
local xpDiv = fakeTex("MainMenuXPBarDiv1")
_G.MainMenuXPBarTexture0 = xpBorder
_G.MainMenuXPBarDiv1 = xpDiv

local rest = fakeTex("ExhaustionLevelFillBar")
local tick = fakeBar("ExhaustionTick", true)
local tickArt = fakeTex("ExhaustionTickNormal")
local overlayTick = fakeTex(nil)
local overlayText = fakeFont()
local expFrame = fakeBar("ExpStatusFrame", true)
expFrame.StatusBar = status
expFrame.ExhaustionLevelFillBar = rest
expFrame.ExhaustionTick = tick
expFrame.OverlayFrame = {
  Text = overlayText,
}
function expFrame.OverlayFrame:GetRegions()
  return overlayTick, overlayText
end

local main = fakeContainer("MainStatusTrackingBarContainer", true)
main.parent = blizzardParent
main.points = { { "BOTTOM", blizzardParent, "TOP", 0, 0 } }
function main:GetShownBar()
  return expFrame
end

local secondary = fakeContainer("SecondaryStatusTrackingBarContainer", true)
_G.MainStatusTrackingBarContainer = main
_G.SecondaryStatusTrackingBarContainer = secondary
_G.StatusTrackingBarManager = fakeBar("StatusTrackingBarManager", true)
_G.MainMenuExpBar = nil
_G.ReputationWatchBar = nil
_G.ShadowUIXPHost = nil
_G.ExhaustionTick = tick
_G.ExhaustionLevelFillBar = rest

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/tracking.lua"))()
Addon:SkinTrackingBars()

assert(main.parent == blizzardParent, "XP container stays with Blizzard")
assert(main.points[1][2] == blizzardParent, "XP container keeps its Blizzard anchor")
assert(_G.ShadowUIXPHost == nil, "ShadowUI does not create an XP cover")
assert(status.shadowUITicks == nil, "ShadowUI does not paint replacement notches")
assert(main.shadowUIWell == nil, "ShadowUI does not cover the XP well")
assert(status.shadowUIMeter == nil, "ShadowUI does not tint the XP fill")
assert(status.r == 0 and status.g == 0.39 and status.b == 0.88,
  "XP fill stays Blizzard blue")
local outer = main.shadowUIOuter
assert(outer, "Experience bar keeps a Lorti Outer Edge")
assert(outer.template == "BackdropTemplate", "Outer Edge uses BackdropTemplate")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true),
  "Outer Edge uses the Lorti shadow texture")
assert(outer.points[1][1] == "TOPLEFT" and outer.points[1][4] == -4,
  "Outer Edge extends 4px outside the Experience bar")
assert(outer.border[1] == 0 and outer.border[2] == 0 and outer.border[3] == 0
  and math.abs(outer.border[4] - 0.9) < 0.001,
  "Outer Edge is the Lorti black drop")
assert(secondary.shadowUIOuter == nil, "reputation does not get an Outer Edge")

assert(secondary.parent == _G.UIParent, "reputation container parents to UIParent")
assert(secondary.points[1][1] == "TOP" and secondary.points[1][2] == _G.UIParent
  and secondary.points[1][3] == "TOP", "reputation docks to screen top")
assert(secondary.points[1][4] == 0 and secondary.points[1][5] == 0, "reputation has no margin")
assert(secondary.width == 1920, "reputation spans the screen")
assert(secondary.StandaloneTextures[1].hidden, "Classic standalone reputation notches stay hidden")
assert(secondary.MainMenuBarTextures[1].hidden, "Classic MainMenuBar reputation art stays hidden")
secondary:SetPoint("BOTTOM", blizzardParent, "TOP", 0, 0)
assert(secondary.points[#secondary.points][2] == _G.UIParent,
  "Blizzard reputation anchors must be undone")

assert(not main.StandaloneTextures[1].hidden, "XP standalone art stays")
assert(not main.MainMenuBarTextures[1].hidden, "XP MainMenuBar art stays")
assert(not xpBorder.hidden, "XP border textures stay")
assert(not xpDiv.hidden, "XP divider notches stay")
assert(not overlayTick.hidden, "OverlayFrame notches stay")
assert(not overlayText.hidden, "XP Status Text stays")
assert(overlayText.alpha ~= 0, "XP Status Text stays visible")
assert(not rest.hidden, "rested XP fill stays")
assert(not tick.hidden, "ExhaustionTick stays")
assert(not tickArt.hidden, "ExhaustionTick art stays")

_G.MainStatusTrackingBarContainer = nil
local classic = fakeBar("MainMenuExpBar", true)
classic.parent = blizzardParent
_G.MainMenuExpBar = classic
Addon:SkinTrackingBars()
assert(classic.parent == blizzardParent, "Classic Experience bar stays with Blizzard")
assert(classic.shadowUIMeter == nil, "Classic Experience bar fill stays Blizzard")
assert(classic.shadowUIOuter, "Classic Experience bar keeps a Lorti Outer Edge")
assert(classic.shadowUIOuter.backdrop.edgeFile:find("outer_shadow", 1, true),
  "Classic Outer Edge uses the Lorti shadow texture")

print("tracking_spec OK")

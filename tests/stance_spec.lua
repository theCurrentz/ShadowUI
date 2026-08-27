-- Blizzard Stance Bar buttons get the same 0.05 chrome as action icons,
-- plus a 4px Lorti Outer Edge. Unused shapeshift slots stay empty.
-- ShadowUI does not draw a second Stance Bar.
-- Run: lua tests/stance_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    local name, hook = object, method
    local orig = _G[name]
    _G[name] = function(...)
      orig(...)
      hook(...)
    end
    return
  end
  local orig = object[method]
  object[method] = function(...)
    orig(...)
    fn(...)
  end
end
_G.CreateFrame = function(_, _, parent, template)
  local frame = { points = {}, parent = parent, template = template, shown = true }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor(r, g, b, a)
    self.fill = { r, g, b, a }
  end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:SetParent(parent) self.parent = parent end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  return frame
end

local function fakeTex()
  local tex = { points = {}, r = 1, g = 1, b = 1, a = 1 }
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetAllPoints(frame) self.all = frame end
  function tex:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function tex:SetTexCoord(l, r, t, b) self.crop = { l, r, t, b } end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetTexture(path)
    self.texture = path
  end
  function tex:GetTexture()
    return self.texture
  end
  function tex:SetAlpha(a) self.a = a end
  function tex:SetDrawLayer() end
  function tex:SetVertexColor(r, g, b, a)
    self.r, self.g, self.b = r, g, b
    if a then
      self.a = a
    end
  end
  function tex:SetBlendMode() end
  function tex:Hide() self.hidden = true end
  function tex:Show() self.hidden = false end
  return tex
end

local barHost = { name = "StanceBarFrame", clips = true }
function barHost:SetClipsChildren(clips) self.clips = clips end
_G.StanceBarFrame = barHost
_G.ShapeshiftBarFrame = barHost

local function fakeButton(name, shown, texture)
  local button = {
    name = name,
    shown = shown ~= false,
    NormalTexture = fakeTex(),
    HighlightTexture = fakeTex(),
    PushedTexture = fakeTex(),
  }
  local icon = fakeTex()
  icon.texture = texture or "Interface\\Icons\\Ability_Warrior_OffensiveStance"
  function button:GetName() return name end
  function button:IsShown() return self.shown end
  function button:CreateTexture()
    local tex = fakeTex()
    button.chrome = tex
    return tex
  end
  function button:GetFrameLevel() return 4 end
  function button:SetFrameLevel() end
  function button:SetClipsChildren(clips) self.clipsChildren = clips end
  function button:GetParent() return barHost end
  _G[name] = button
  _G[name .. "Icon"] = icon
  return button, icon
end

_G.ShapeshiftBar_Update = function() end
_G.StanceBarLeft = fakeTex()
_G.ShapeshiftBarLeft = fakeTex()

assert(loadfile(root .. "skin/chrome.lua"))()

local battle, battleIcon = fakeButton("StanceButton1")
local unused = fakeButton("StanceButton2", false, "")
unused.shown = false
_G.StanceButton2Icon.texture = nil
local shapeshift, shapeshiftIcon = fakeButton("ShapeshiftButton1")

assert(loadfile(root .. "skin/stance.lua"))()
Addon:SkinStanceBar()

assert(battle.chrome.r == 0.05 and battle.chrome.g == 0.05 and battle.chrome.b == 0.05,
  "Stance Bar chrome is Lorti darkest")
assert(battle.chrome.all == battle, "chrome fills the Stance Button")
assert(battleIcon.all == nil, "stance icon must not cover the chrome")
assert(battleIcon.points[1][1] == "TOPLEFT" and battleIcon.points[1][2] == 2,
  "stance icon insets 2px")
assert(battleIcon.crop[1] == 0.07 and battleIcon.crop[3] == 0.07,
  "stance icon crop matches action icons")
assert(battle.NormalTexture.hidden or battle.NormalTexture.a == 0,
  "stance silver slot art stays hidden")
local outer = battle.shadowUIOuter
assert(outer, "Stance Button keeps a Lorti Outer Edge")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true),
  "Outer Edge uses the Lorti shadow texture")
assert(outer.points[1][4] == -4, "Outer Edge extends 4px")
assert(outer.parent == barHost, "Outer Edge is a sibling of the Stance Button")
assert(battle.clipsChildren == false, "the Stance Button does not clip Outer Edge")
assert(barHost.clips == false, "the Stance Bar does not clip Outer Edge")
assert(shapeshift.shadowUIOuter, "ShapeshiftButton hosts keep Outer Edge")
assert(shapeshiftIcon.points[1][2] == 2, "ShapeshiftButton icon insets 2px")
assert(not unused.chrome or unused.chrome.hidden,
  "unused stance slots do not keep Darken chrome")
assert(not unused.shadowUIOuter or unused.shadowUIOuter.shown == false,
  "unused stance slots do not keep an Outer Edge")
assert(_G.StanceBarLeft.hidden or _G.StanceBarLeft.a == 0,
  "Blizzard Stance Bar art stays hidden")
assert(_G.ShapeshiftBarLeft.hidden or _G.ShapeshiftBarLeft.a == 0,
  "Blizzard Shapeshift Bar art stays hidden")

local late, lateIcon = fakeButton("StanceButton3")
_G.ShapeshiftBar_Update()
assert(late.shadowUIOuter, "a later ShapeshiftBar_Update skins new Stance Buttons")
assert(lateIcon.points[1][2] == 2, "a later update still insets the icon")

print("stance_spec OK")

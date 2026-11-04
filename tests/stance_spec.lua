-- Blizzard Stance Bar buttons get the same chrome as Blizzard ActionButtons:
-- native icon and IconMask, blackened rim, and a 4px Lorti Outer Edge.
-- Unused shapeshift slots stay empty. ShadowUI does not draw a second Stance Bar.
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
  function tex:RemoveMaskTexture(mask) self.removedMask = mask end
  return tex
end

local barHost = { name = "StanceBarFrame", clips = true }
function barHost:SetClipsChildren()
  error("SetClipsChildren is protected")
end
_G.StanceBarFrame = barHost
_G.ShapeshiftBarFrame = barHost

local function fakeButton(name, shown, texture)
  local button = {
    name = name,
    shown = shown ~= false,
    NormalTexture = fakeTex(),
    HighlightTexture = fakeTex(),
    PushedTexture = fakeTex(),
    IconMask = fakeTex(),
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
  function button:SetClipsChildren()
    error("SetClipsChildren is protected")
  end
  function button:GetParent() return barHost end
  _G[name] = button
  _G[name .. "Icon"] = icon
  return button, icon
end

_G.ShapeshiftBar_Update = function() end
_G.StanceBarLeft = fakeTex()
_G.ShapeshiftBarLeft = fakeTex()

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "bars/button.lua"))()

local battle, battleIcon = fakeButton("StanceButton1")
local unused = fakeButton("StanceButton2", false, "")
unused.shown = false
_G.StanceButton2Icon.texture = nil
local shapeshift, shapeshiftIcon = fakeButton("ShapeshiftButton1")

assert(loadfile(root .. "skin/stance.lua"))()
Addon:SkinStanceBar()

assert(#battleIcon.points == 0 and battleIcon.all == nil,
  "a stance icon keeps its native size (no inset zoom)")
assert(battleIcon.crop == nil, "a stance icon keeps its native TexCoord (no crop zoom)")
assert(battleIcon.removedMask == nil, "a stance icon keeps its IconMask")
local rim = battle.NormalTexture
assert(rim.texture == nil and not rim.hidden, "the stance rim is kept, not stripped")
assert(rim.r == 0.05 and rim.g == 0.05 and rim.b == 0.05, "the stance rim is blackened")
assert(battle.chrome == nil, "the blackened rim replaces the Darken fill")
local outer = battle.shadowUIOuter
assert(outer, "Stance Button keeps a Lorti Outer Edge")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true),
  "Outer Edge uses the Lorti shadow texture")
assert(outer.points[1][4] == -4, "Outer Edge extends 4px")
assert(outer.parent == barHost, "Outer Edge is a sibling of the Stance Button")
assert(shapeshift.shadowUIOuter, "ShapeshiftButton hosts keep Outer Edge")
assert(#shapeshiftIcon.points == 0, "a ShapeshiftButton icon keeps its native size")
assert(not unused.shadowUIOuter or unused.shadowUIOuter.shown == false,
  "unused stance slots do not keep an Outer Edge")
assert(_G.StanceBarLeft.texture == "",
  "Blizzard Stance Bar art is stripped")
assert(_G.ShapeshiftBarLeft.texture == "",
  "Blizzard Shapeshift Bar art is stripped")

local late, lateIcon = fakeButton("StanceButton3")
_G.ShapeshiftBar_Update()
assert(late.shadowUIOuter, "a later ShapeshiftBar_Update skins new Stance Buttons")
assert(#lateIcon.points == 0, "a later update keeps the native icon")

-- Past the StanceButton1..10 scan, so only StanceBar.actionButtons reaches it.
local listed = fakeButton("StanceButton11")
_G.StanceBar = {
  actionButtons = { listed },
  clips = true,
}
function _G.StanceBar:SetClipsChildren()
  error("SetClipsChildren is protected")
end
Addon:SkinStanceBar()
assert(listed.shadowUIOuter, "1.15 StanceBar.actionButtons get Outer Edge")
assert(listed.NormalTexture.r == 0.05, "1.15 StanceBar.actionButtons get the blackened rim")

print("stance_spec OK")

-- Buff and debuff icons get the same 0.05 chrome as the player frame, plus
-- a 4px Lorti outer edge. Unused slots stay empty. Player BuffFrame and
-- DebuffFrame keep Blizzard Edit Mode place. Debuff type colour on the
-- Blizzard border stays native. Target of Target auras sit 2px to the right
-- of Target of Target in a horizontal row. Target auras sit 2px to the right
-- of the Target Frame in horizontal rows at 32px so Aura Duration numbers fit.
-- Blizzard enemy-with-no-debuffs layout starts buffs on top of the frame.
-- Classic copies TargetFrameMixin.UpdateAuras onto TargetFrame, so the
-- instance method must keep that right-side place.
-- Run: lua tests/auras_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local unpack = unpack or table.unpack
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
_G.CreateFrame = function(_, _, parent, template)
  local frame = { points = {}, parent = parent, template = template }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  return frame
end

local function fakeTex()
  local tex = { points = {}, r = 1, g = 1, b = 1 }
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetAllPoints(frame) self.all = frame end
  function tex:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function tex:SetTexCoord(l, r, t, b) self.crop = { l, r, t, b } end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetVertexColor(r, g, b) self.r, self.g, self.b = r, g, b end
  function tex:SetDrawLayer() end
  function tex:GetTexture() return self.texture end
  function tex:Show() self.shown = true end
  function tex:Hide() self.shown = false end
  tex.texture = "Interface\\Icons\\Spell_Nature_Regeneration"
  return tex
end

local function fakeButton(name, borderColor)
  local button = { name = name }
  local icon = fakeTex()
  local border = fakeTex()
  if borderColor then
    border.r, border.g, border.b = unpack(borderColor)
  end
  function button:GetName() return name end
  function button:CreateTexture()
    local tex = fakeTex()
    button.chrome = tex
    return tex
  end
  function button:GetFrameLevel() return 4 end
  function button:SetFrameLevel() end
  _G[name] = button
  _G[name .. "Icon"] = icon
  _G[name .. "Border"] = border
  return button, icon, border
end

_G.UIParent = { name = "UIParent" }
_G.ShadowUIMinimapHolder = { name = "ShadowUIMinimapHolder" }
_G.EditModeSystemMixin = {
  ApplySystemAnchor = function(self)
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 80, -40)
  end,
}
local buff, buffIcon = fakeButton("BuffButton1")
local _, _, debuffBorder = fakeButton("DebuffButton1", { 1, 0, 0 })
local unusedDebuff, unusedIcon = fakeButton("DebuffButton2")
unusedIcon.texture = nil
function unusedDebuff:IsShown() return false end

local modernIcon = fakeTex()
local modernDebuffIcon = fakeTex()
local modernDebuffBorder = fakeTex()
modernDebuffBorder.r, modernDebuffBorder.g, modernDebuffBorder.b = 1, 0, 0
local function modernButton(icon, border, auraType)
  local button = { Icon = icon, DebuffBorder = border, auraType = auraType }
  function button:CreateTexture()
    local tex = fakeTex()
    button.chrome = tex
    return tex
  end
  function button:GetFrameLevel() return 4 end
  function button:SetFrameLevel() end
  return button
end
local modernBuff = modernButton(modernIcon, fakeTex(), "Buff")
local modernDebuff = modernButton(modernDebuffIcon, modernDebuffBorder, "Debuff")
modernBuff.hasValidInfo = true
modernDebuff.hasValidInfo = true
local privateAnchor = { isAuraAnchor = true, hasValidInfo = false }
function privateAnchor:CreateTexture()
  local tex = fakeTex()
  privateAnchor.chrome = tex
  return tex
end
function privateAnchor:GetFrameLevel() return 4 end
function privateAnchor:SetFrameLevel() end
function privateAnchor:IsShown() return true end
local function fakeAuraHost(auraFrames)
  local frame = { auraFrames = auraFrames, points = {} }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPointBase(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:ClearAllPointsBase()
    self.points = {}
  end
  function frame:SetPoint(...)
    self:SetPointBase(...)
  end
  function frame:IsMovable() return true end
  function frame:IsResizable() return false end
  function frame:SetUserPlaced()
    error("BuffFrame:SetUserPlaced(): Frame is not movable or resizable")
  end
  return frame
end
local function fakePlaceButton(name, borderColor)
  local button = fakeButton(name, borderColor)
  button.points = {}
  button.w = 21
  button.h = 21
  function button:ClearAllPoints()
    self.points = {}
  end
  function button:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function button:SetSize(w, h)
    self.w, self.h = w, h
  end
  function button:SetWidth(w)
    self.w = w
  end
  function button:SetHeight(h)
    self.h = h
  end
  function button:GetWidth()
    return self.w
  end
  function button:GetHeight()
    return self.h
  end
  function button:IsShown()
    return true
  end
  return button
end

_G.TargetFrameToT = { name = "TargetFrameToT" }
function _G.TargetFrameToT:GetName()
  return "TargetFrameToT"
end
function _G.TargetFrameToT:IsShown()
  return true
end
_G.TargetFrame = { name = "TargetFrame", totFrame = _G.TargetFrameToT, unit = "target" }
function _G.TargetFrame:GetName()
  return "TargetFrame"
end
function _G.TargetFrame:IsShown()
  return true
end
local totDebuff1 = fakePlaceButton("TargetFrameToTDebuff1", { 1, 0, 0 })
local totDebuff2 = fakePlaceButton("TargetFrameToTDebuff2", { 1, 0, 0 })
local targetBuff1 = fakePlaceButton("TargetFrameBuff1")
local targetBuff2 = fakePlaceButton("TargetFrameBuff2")

local function blizzardPlaceOnTop()
  targetBuff1:ClearAllPoints()
  targetBuff1:SetPoint("TOPLEFT", _G.TargetFrame, "BOTTOMLEFT", 5, 32)
  targetBuff1:SetSize(21, 21)
  targetBuff2:ClearAllPoints()
  targetBuff2:SetPoint("TOPLEFT", targetBuff1, "TOPRIGHT", 3, 0)
  targetBuff2:SetSize(21, 21)
end
_G.TargetFrameMixin = { UpdateAuras = blizzardPlaceOnTop }
_G.TargetFrame.UpdateAuras = blizzardPlaceOnTop

_G.BuffFrame = fakeAuraHost({ modernBuff })
_G.DebuffFrame = fakeAuraHost({ modernDebuff, privateAnchor })
_G.BuffFrame:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 80, -40)
_G.DebuffFrame:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 80, -120)

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/auras.lua"))()
Addon:SkinAuras()

assert(buff.chrome.r == 0.05 and buff.chrome.g == 0.05 and buff.chrome.b == 0.05,
  "buff chrome is Lorti darkest")
assert(buffIcon.all == nil, "buff icon must not cover the chrome")
assert(buffIcon.points[1][1] == "TOPLEFT" and buffIcon.points[1][2] == 2,
  "buff icon insets 2px")
assert(_G.BuffButton1Border.r == 0.05, "buff silver border is darkened")
assert(debuffBorder.r == 1 and debuffBorder.g == 0 and debuffBorder.b == 0,
  "debuff type colour stays native")
assert(buff.shadowUIOuter, "buff keeps a Lorti outer edge")
assert(buff.shadowUIOuter.points[1][4] == -4, "buff outer edge extends 4px")

assert(modernBuff.chrome.r == 0.05, "modern buff chrome is Lorti darkest")
assert(modernBuff.shadowUIOuter, "modern buff keeps a Lorti Outer Edge")
assert(modernBuff.shadowUIOuter.template == "BackdropTemplate", "Outer Edge uses BackdropTemplate")
assert(modernBuff.shadowUIOuter.backdrop.edgeFile:find("outer_shadow", 1, true),
  "Outer Edge uses the Lorti shadow texture")
assert(modernBuff.shadowUIOuter.points[1][2] == modernIcon,
  "Outer Edge sits on the icon, not the duration slot")
assert(modernBuff.shadowUIOuter.points[1][4] == -4, "modern Outer Edge extends 4px")
assert(modernDebuff.shadowUIOuter, "modern debuff keeps a Lorti Outer Edge")
assert(modernDebuffBorder.r == 1 and modernDebuffBorder.g == 0,
  "modern debuff type colour stays native")
assert(not unusedDebuff.chrome or unusedDebuff.chrome.shown == false,
  "unused debuff slots do not keep Darken chrome")
assert(not unusedDebuff.shadowUIOuter or unusedDebuff.shadowUIOuter.shown == false,
  "unused debuff slots do not keep an Outer Edge")
assert(not privateAnchor.chrome or privateAnchor.chrome.shown == false,
  "private aura anchors do not keep Darken chrome")
assert(not privateAnchor.shadowUIOuter or privateAnchor.shadowUIOuter.shown == false,
  "private aura anchors do not keep an Outer Edge")
local function last(frame)
  return frame.points[#frame.points]
end
assert(last(_G.BuffFrame)[4] == 80 and last(_G.BuffFrame)[5] == -40,
  "SkinAuras keeps the Blizzard BuffFrame place")
assert(last(_G.DebuffFrame)[4] == 80 and last(_G.DebuffFrame)[5] == -120,
  "SkinAuras keeps the Blizzard DebuffFrame place")

_G.BuffFrame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", 24, 64)
_G.DebuffFrame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", 24, 24)
assert(last(_G.BuffFrame)[4] == 24 and last(_G.BuffFrame)[5] == 64,
  "Blizzard Edit Mode can keep a new BuffFrame place")
assert(last(_G.DebuffFrame)[4] == 24 and last(_G.DebuffFrame)[5] == 24,
  "Blizzard Edit Mode can keep a new DebuffFrame place")

Addon:SkinAuras()
assert(last(_G.BuffFrame)[4] == 24 and last(_G.BuffFrame)[5] == 64,
  "later SkinAuras must keep the Edit Mode BuffFrame place")
assert(last(_G.DebuffFrame)[4] == 24 and last(_G.DebuffFrame)[5] == 24,
  "later SkinAuras must keep the Edit Mode DebuffFrame place")

_G.EditModeSystemMixin.ApplySystemAnchor(_G.BuffFrame)
assert(last(_G.BuffFrame)[4] == 80 and last(_G.BuffFrame)[5] == -40,
  "Edit Mode ApplySystemAnchor can keep the BuffFrame place")
_G.EditModeSystemMixin.ApplySystemAnchor(_G.DebuffFrame)
assert(last(_G.DebuffFrame)[4] == 80 and last(_G.DebuffFrame)[5] == -40,
  "Edit Mode ApplySystemAnchor can keep the DebuffFrame place")

assert(totDebuff1.points[1][1] == "TOPLEFT" and totDebuff1.points[1][2] == _G.TargetFrameToT
    and totDebuff1.points[1][3] == "TOPRIGHT" and totDebuff1.points[1][4] == 2
    and totDebuff1.points[1][5] == 0,
  "target of target auras sit 2px to the right of Target of Target")
assert(totDebuff2.points[1][1] == "TOPLEFT" and totDebuff2.points[1][2] == totDebuff1
    and totDebuff2.points[1][3] == "TOPRIGHT" and totDebuff2.points[1][4] == 3
    and totDebuff2.points[1][5] == 0,
  "target of target auras stay in a horizontal row")
assert(targetBuff1.points[1][1] == "TOPLEFT" and targetBuff1.points[1][2] == _G.TargetFrame
    and targetBuff1.points[1][3] == "TOPRIGHT" and targetBuff1.points[1][4] == 2
    and targetBuff1.points[1][5] == 0,
  "target auras sit 2px to the right of the Target Frame")
assert(targetBuff2.points[1][1] == "TOPLEFT" and targetBuff2.points[1][2] == targetBuff1
    and targetBuff2.points[1][3] == "TOPRIGHT" and targetBuff2.points[1][4] == 3
    and targetBuff2.points[1][5] == 0,
  "target auras stay in a horizontal row")
assert(targetBuff1.w == 32 and targetBuff1.h == 32,
  "target auras are 32px so Aura Duration numbers fit")
assert(targetBuff2.w == 32 and targetBuff2.h == 32,
  "each target aura is 32px")
assert(totDebuff1.w == 21 and totDebuff1.h == 21,
  "target of target auras keep native size")

_G.TargetFrame:UpdateAuras()
assert(targetBuff1.points[1][1] == "TOPLEFT" and targetBuff1.points[1][2] == _G.TargetFrame
    and targetBuff1.points[1][3] == "TOPRIGHT" and targetBuff1.points[1][4] == 2
    and targetBuff1.points[1][5] == 0,
  "TargetFrame:UpdateAuras cannot keep auras on top of the Target Frame")
assert(targetBuff1.w == 32 and targetBuff1.h == 32,
  "TargetFrame:UpdateAuras cannot keep Blizzard 21px target auras")

function targetBuff1:IsShown() return false end
function targetBuff2:IsShown() return false end
local poolBuff1 = fakePlaceButton("PoolAura1")
local poolBuff2 = fakePlaceButton("PoolAura2")
poolBuff1.Icon = _G.PoolAura1Icon
poolBuff2.Icon = _G.PoolAura2Icon
poolBuff1.unit = "target"
poolBuff2.unit = "target"
poolBuff1.auraInstanceID = 1
poolBuff2.auraInstanceID = 2
poolBuff1:ClearAllPoints()
poolBuff1:SetPoint("TOPLEFT", _G.TargetFrame, "BOTTOMLEFT", 5, 32)
poolBuff1:SetSize(21, 21)
poolBuff2:ClearAllPoints()
poolBuff2:SetPoint("TOPLEFT", poolBuff1, "TOPRIGHT", 3, 0)
poolBuff2:SetSize(21, 21)
local function iterate(items)
  local i = 0
  return function()
    i = i + 1
    return items[i]
  end
end
_G.TargetFrame.auraPools = {
  GetPool = function(_, template)
    if template == "TargetBuffFrameTemplate" then
      return {
        EnumerateActive = function()
          return iterate({ poolBuff1, poolBuff2 })
        end,
      }
    end
    return {
      EnumerateActive = function()
        return iterate({})
      end,
    }
  end,
}
Addon:SkinAuras()
assert(poolBuff1.points[1][1] == "TOPLEFT" and poolBuff1.points[1][2] == _G.TargetFrame
    and poolBuff1.points[1][3] == "TOPRIGHT" and poolBuff1.points[1][4] == 2
    and poolBuff1.points[1][5] == 0,
  "1.15.9 auraPools target auras sit 2px to the right of the Target Frame")
assert(poolBuff2.points[1][2] == poolBuff1 and poolBuff2.points[1][3] == "TOPRIGHT",
  "1.15.9 auraPools target auras stay in a horizontal row")
assert(poolBuff1.w == 32 and poolBuff1.h == 32,
  "1.15.9 auraPools target auras are 32px")

print("auras_spec OK")

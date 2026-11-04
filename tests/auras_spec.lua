-- Player buff and debuff icons use a 0.07 zoom and hide their border.
-- No Darken ring and no Outer Edge. Unused slots stay empty.
-- Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place.
-- Target Frame, Target of Target, Focus, and party auras stay Blizzard.
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
  function tex:SetDrawLayer(layer) self.layer = layer end
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
local buff, buffIcon, buffBorder = fakeButton("BuffButton1")
local debuff, _, debuffBorder = fakeButton("DebuffButton1", { 1, 0, 0 })
local unusedDebuff, unusedIcon, unusedBorder = fakeButton("DebuffButton2")
unusedIcon.texture = nil
function unusedDebuff:IsShown() return false end

local modernIcon = fakeTex()
local modernDebuffIcon = fakeTex()
local modernBuffBorder = fakeTex()
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
local modernBuff = modernButton(modernIcon, modernBuffBorder, "Buff")
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
  local button, icon, border = fakeButton(name, borderColor)
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
  return button, icon, border
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
local totDebuff1, totDebuffIcon = fakePlaceButton("TargetFrameToTDebuff1", { 1, 0, 0 })
local totDebuff2 = fakePlaceButton("TargetFrameToTDebuff2", { 1, 0, 0 })
local targetBuff1, targetBuffIcon, targetBuffBorder = fakePlaceButton("TargetFrameBuff1")
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

assert(buffIcon.crop[1] == 0.07 and buffIcon.crop[2] == 1 - 0.07
    and buffIcon.crop[3] == 0.07 and buffIcon.crop[4] == 1 - 0.07,
  "buff icon zoom is 0.07")
assert(modernIcon.crop[1] == 0.07 and modernIcon.crop[3] == 0.07,
  "modern buff icon zoom is 0.07")
assert(modernDebuffIcon.crop[1] == 0.07 and modernDebuffIcon.crop[3] == 0.07,
  "debuff icon zoom is 0.07")
assert(buffIcon.points[1] == nil, "buff icon keeps its native points")
assert(modernIcon.layer == nil, "buff icons keep their native draw layer")
assert(buffBorder.shown == false, "buff icons have no border")
assert(modernBuffBorder.shown == false, "modern buff icons have no border")
assert(debuffBorder.shown == false, "debuff icons have no border")
assert(debuffBorder.r == 1 and debuffBorder.g == 0 and debuffBorder.b == 0,
  "hiding the debuff border does not recolor it")
assert(modernDebuffBorder.shown == false, "modern debuff icons have no border")
assert(not buff.chrome and not modernBuff.chrome and not debuff.chrome,
  "player auras do not get a Darken ring")
assert(not buff.shadowUIOuter and not modernBuff.shadowUIOuter and not modernDebuff.shadowUIOuter,
  "player auras do not get an Outer Edge")
assert(unusedIcon.crop == nil, "unused debuff slots do not zoom")
assert(unusedBorder.shown ~= false, "unused debuff slots keep their border state")
assert(not unusedDebuff.chrome, "unused debuff slots do not get a Darken ring")
assert(not privateAnchor.chrome, "private aura anchors do not get a Darken ring")

_G.issecretvalue = function(v)
  return v == 136085
end
local secretBuff, secretIcon, secretBorder = fakeButton("BuffButton8")
secretIcon.texture = 136085
Addon:SkinAuraButton(secretBuff)
assert(secretIcon.crop[1] == 0.07, "secret aura texture still zooms")
assert(secretBorder.shown == false, "secret aura icons have no border")
_G.issecretvalue = nil

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

assert(#totDebuff1.points == 0 and #totDebuff2.points == 0,
  "SkinAuras does not place Target of Target auras")
assert(totDebuff1.w == 21 and totDebuff1.h == 21,
  "SkinAuras does not resize Target of Target auras")
assert(totDebuffIcon.crop == nil, "Target of Target auras keep native TexCoord")
assert(#targetBuff1.points == 0 and #targetBuff2.points == 0,
  "SkinAuras does not place Target Frame auras")
assert(targetBuffIcon.crop == nil, "Target Frame auras keep native TexCoord")
assert(targetBuffBorder.shown ~= false, "Target Frame auras keep their border")
assert(Addon.PlaceTargetAuras == nil, "target aura placement is not part of ShadowUI")

_G.TargetFrame:UpdateAuras()
assert(targetBuff1.points[1][2] == _G.TargetFrame
    and targetBuff1.points[1][3] == "BOTTOMLEFT"
    and targetBuff1.points[1][4] == 5
    and targetBuff1.points[1][5] == 32,
  "TargetFrame:UpdateAuras keeps the Blizzard aura place")
assert(targetBuff1.w == 21 and targetBuff1.h == 21,
  "TargetFrame:UpdateAuras keeps the Blizzard aura size")
assert(targetBuffIcon.crop == nil, "TargetFrame:UpdateAuras does not zoom target auras")

local poolBuff1, poolIcon = fakePlaceButton("PoolAura1")
local poolBuff2 = fakePlaceButton("PoolAura2")
poolBuff1.Icon = _G.PoolAura1Icon
poolBuff2.Icon = _G.PoolAura2Icon
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
assert(poolBuff1.points[1][2] == _G.TargetFrame
    and poolBuff1.points[1][3] == "BOTTOMLEFT"
    and poolBuff1.points[1][4] == 5,
  "SkinAuras leaves 1.15.9 target auraPools in the Blizzard place")
assert(poolBuff1.w == 21 and poolBuff1.h == 21,
  "SkinAuras leaves 1.15.9 target auraPools at Blizzard size")
assert(poolIcon.crop == nil, "SkinAuras does not zoom 1.15.9 target auraPools")

print("auras_spec OK")

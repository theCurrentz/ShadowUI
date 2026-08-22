-- Buff and debuff icons get the same 0.05 chrome as the player frame, plus
-- a 4px Lorti outer edge. Unused slots stay empty. Player buffs sit 2px left
-- of the square minimap, with a 4px gap from the top of the screen.
-- Debuff type colour on the Blizzard border stays native.
-- Run: lua tests/auras_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local unpack = unpack or table.unpack
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function() end
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

_G.UIParent = {}
_G.ShadowUIMinimapHolder = { name = "ShadowUIMinimapHolder" }
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
_G.BuffFrame = { auraFrames = { modernBuff }, points = {} }
function _G.BuffFrame:ClearAllPoints() self.points = {} end
function _G.BuffFrame:SetPoint(...) self.points[#self.points + 1] = { ... } end
function _G.BuffFrame:IsMovable() return true end
function _G.BuffFrame:IsResizable() return false end
function _G.BuffFrame:SetUserPlaced()
  error("BuffFrame:SetUserPlaced(): Frame is not movable or resizable")
end
_G.DebuffFrame = { auraFrames = { modernDebuff, privateAnchor }, points = {} }
function _G.DebuffFrame:ClearAllPoints() self.points = {} end
function _G.DebuffFrame:SetPoint(...) self.points[#self.points + 1] = { ... } end
function _G.DebuffFrame:IsMovable() return false end
function _G.DebuffFrame:IsResizable() return false end

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
assert(_G.BuffFrame.points[1][1] == "TOPRIGHT"
    and _G.BuffFrame.points[1][2] == _G.ShadowUIMinimapHolder
    and _G.BuffFrame.points[1][3] == "TOPLEFT"
    and _G.BuffFrame.points[1][4] == -2
    and _G.BuffFrame.points[1][5] == -4,
  "player buffs sit 2px left of the square minimap and 4px from the top")
assert(_G.DebuffFrame.points[1][1] == "TOPRIGHT"
    and _G.DebuffFrame.points[1][2] == _G.BuffFrame
    and _G.DebuffFrame.points[1][3] == "BOTTOMRIGHT"
    and _G.DebuffFrame.points[1][4] == -13
    and _G.DebuffFrame.points[1][5] == -5,
  "player debuffs sit under the player buffs")

print("auras_spec OK")

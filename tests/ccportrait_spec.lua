-- Crowd Control on the player or target swaps the portrait to that spell
-- icon and shows remaining time. Run: lua tests/ccportrait_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.GetTime = function() return 20 end

assert(loadfile(root .. "skin/ccportrait.lua"))()

assert(Addon:CrowdControlKind(118) == "incapacitate", "Polymorph is incapacitate")
assert(Addon:CrowdControlKind(6215) == "fear", "Fear is fear")
assert(Addon:CrowdControlKind(19647) == "silence", "Spell Lock is silence")
assert(Addon:CrowdControlKind(1833) == "stun", "Cheap Shot is stun")
assert(Addon:CrowdControlKind(408) == "stun", "Kidney Shot is stun")
assert(Addon:CrowdControlKind(1776) == "incapacitate", "Gouge is incapacitate")
assert(Addon:CrowdControlKind(2094) == "disorient", "Blind is disorient")
assert(Addon:CrowdControlKind(2637) == "sleep", "Hibernate is sleep")
assert(Addon:CrowdControlKind(700) == "sleep", "Sleep is sleep")
assert(Addon:CrowdControlKind(33786) == "incapacitate", "Cyclone is incapacitate")
assert(Addon:CrowdControlKind(51514) == "incapacitate", "Hex is incapacitate")
assert(Addon:CrowdControlKind(18469) == "silence", "Counterspell lock is silence")
assert(Addon:CrowdControlKind(133) == nil, "Fireball is not Crowd Control")
assert(Addon:CrowdControlKindFromAura(nil, nil) == nil, "missing aura is not Crowd Control")

_G.GetSpellInfo = function(id)
  if id == 2637 or id == 18658 then
    return "Hibernate"
  end
  if id == 700 then
    return "Sleep"
  end
end
assert(Addon:CrowdControlKindFromAura(99999, "Hibernate") == "sleep",
  "Hibernate matches by name when the spell ID is unknown")
assert(Addon:CrowdControlKindFromAura(99999, "Sleep") == "sleep",
  "Sleep matches by name when the spell ID is unknown")

local picked = Addon:SelectCrowdControl({
  { spellId = 15487, remaining = 4, icon = "silence", duration = 5, expirationTime = 24 },
  { spellId = 118, remaining = 6, icon = "sheep", duration = 8, expirationTime = 26 },
  { spellId = 1833, remaining = 1.5, icon = "stun", duration = 2, expirationTime = 21.5 },
})
assert(picked.spellId == 1833, "stun wins over incapacitate and silence")
assert(picked.icon == "stun", "selected aura keeps its icon")

local fear = Addon:SelectCrowdControl({
  { spellId = 6215, remaining = 8, icon = "fear", duration = 10, expirationTime = 28 },
})
assert(fear.kind == "fear", "Fear is selected when it is the only Crowd Control")

local sleep = Addon:SelectCrowdControl({
  { spellId = 700, remaining = 20, icon = "sleep", duration = 30, expirationTime = 40, name = "Sleep" },
})
assert(sleep.kind == "sleep", "Sleep is selected as Crowd Control")

assert(Addon:SelectCrowdControl({}) == nil, "no Crowd Control hides the overlay")

local state = Addon:CrowdControlPortraitState(20, {
  icon = "sheep",
  duration = 8,
  expirationTime = 26,
})
assert(state.icon == "sheep", "overlay uses the Crowd Control icon")
assert(state.text == "6", "overlay shows remaining seconds")
assert(state.startTime == 18 and state.duration == 8, "overlay swipe uses aura start")
assert(Addon:CrowdControlPortraitState(20, nil) == nil, "clear aura hides the overlay")
assert(Addon:CrowdControlPortraitState(20, { icon = "fear", duration = 0, expirationTime = 0 }).text == nil,
  "missing duration still shows the icon with no timer")

local containerPort = { name = "container", w = 64 }
function containerPort:GetWidth() return self.w end
local stalePort = { name = "stale", w = 32, shown = true, alpha = 1 }
function stalePort:GetWidth() return self.w end
function stalePort:Hide() self.shown = false end
function stalePort:Show() self.shown = true end
function stalePort:SetAlpha(a) self.alpha = a end
function stalePort:GetAlpha() return self.alpha end
local leftoverChip = { name = "PlayerPortrait", w = 32, shown = true, alpha = 1 }
function leftoverChip:GetWidth() return self.w end
function leftoverChip:Hide() self.shown = false end
function leftoverChip:Show() self.shown = true end
function leftoverChip:SetAlpha(a) self.alpha = a end
function leftoverChip:GetAlpha() return self.alpha end
local frameContainer = { Portrait = containerPort, PlayerPortrait = leftoverChip }
function containerPort:GetParent() return frameContainer end
function leftoverChip:GetParent() return frameContainer end
containerPort.parent = frameContainer
leftoverChip.parent = frameContainer
local frame = {
  TargetFrameContainer = frameContainer,
  portrait = stalePort,
}
assert(Addon:CrowdControlPortraitRegion(frame) == containerPort,
  "1.15 TargetFrame uses TargetFrameContainer.Portrait, not a leftover global")

local playerLive = { name = "live64", w = 64, shown = true, alpha = 1 }
function playerLive:GetWidth() return self.w end
function playerLive:SetAlpha(a) self.alpha = a end
function playerLive:GetAlpha() return self.alpha end
local playerChip = { name = "PlayerPortrait", w = 32, shown = true, alpha = 1 }
function playerChip:GetWidth() return self.w end
function playerChip:Hide() self.shown = false end
function playerChip:Show() self.shown = true end
function playerChip:SetAlpha(a) self.alpha = a end
function playerChip:GetAlpha() return self.alpha end
-- 1.15 UnitFrame_Initialize uses PlayerFrameContainer.PlayerPortrait.
-- container.Portrait can still be a leftover chip (12:27 zzz+34).
local playerContainer = { PlayerPortrait = playerLive, Portrait = playerChip }
function playerLive:GetParent() return playerContainer end
function playerChip:GetParent() return playerContainer end
local playerFrame = {
  PlayerFrameContainer = playerContainer,
}
assert(Addon:CrowdControlPortraitRegion(playerFrame) == playerLive,
  "1.15 PlayerFrame uses PlayerFrameContainer.PlayerPortrait, not leftover Portrait")

local unsetLive = { name = "containerUnset", w = 0, alpha = 1 }
function unsetLive:GetWidth() return self.w end
function unsetLive:SetAlpha(a) self.alpha = a end
function unsetLive:GetAlpha() return self.alpha end
local wideChip = { name = "PlayerPortrait", w = 64, shown = true, alpha = 1 }
function wideChip:GetWidth() return self.w end
function wideChip:Hide() self.shown = false end
function wideChip:Show() self.shown = true end
function wideChip:SetAlpha(a) self.alpha = a end
function wideChip:GetAlpha() return self.alpha end
local unsetFrame = {
  PlayerFrameContainer = { PlayerPortrait = unsetLive },
  portrait = wideChip,
}
assert(Addon:CrowdControlPortraitRegion(unsetFrame) == unsetLive,
  "container portrait is used when it is the only container portrait")

local hole64 = { name = "Portrait", w = 64, shown = true, alpha = 1 }
function hole64:GetWidth() return self.w end
function hole64:SetAlpha(a) self.alpha = a end
function hole64:GetAlpha() return self.alpha end
local namedChip = { name = "PlayerPortrait", w = 32, shown = true, alpha = 1 }
function namedChip:GetWidth() return self.w end
function namedChip:Hide() self.shown = false end
function namedChip:Show() self.shown = true end
function namedChip:SetAlpha(a) self.alpha = a end
function namedChip:GetAlpha() return self.alpha end
local mixedContainer = { Portrait = hole64, PlayerPortrait = namedChip }
function hole64:GetParent() return mixedContainer end
function namedChip:GetParent() return mixedContainer end
local mixedFrame = { PlayerFrameContainer = mixedContainer }
assert(Addon:CrowdControlPortraitRegion(mixedFrame) == hole64,
  "the 64px hole wins even when leftover chrome is named PlayerPortrait")

local strayGlobal = { name = "globalPlayerPortrait", w = 64, shown = true, alpha = 1 }
function strayGlobal:GetWidth() return self.w end
function strayGlobal:Hide() self.shown = false end
function strayGlobal:Show() self.shown = true end
function strayGlobal:SetAlpha(a) self.alpha = a end
function strayGlobal:GetAlpha() return self.alpha end
function strayGlobal:GetParent() return playerFrame end
_G.PlayerPortrait = strayGlobal
assert(Addon:CrowdControlPortraitRegion(playerFrame) == playerLive,
  "leftover global PlayerPortrait is not the live 64px hole")

_G.PlayerPortrait = playerLive
assert(Addon:CrowdControlPortraitRegion(playerFrame) == playerLive,
  "when the global is the 64px hole, Crowd Control still uses that hole")
Addon:HideLeftoverPortraits(playerFrame, playerLive)
assert(playerLive.shown ~= false and playerLive.alpha == 1,
  "the live 64px face is not lock-hidden as a leftover chip")

_G.PlayerPortrait = playerChip
_G.TargetFramePortrait = stalePort
_G.PlayerFrame = playerFrame
_G.TargetFrame = frame
_G.GetTime = function() return 20 end
_G.SetPortraitToTexture = function() end
_G.CreateFrame = function(_, _, parent)
  local f = { parent = parent, shown = true, level = 1 }
  function f:SetAllPoints(rel) f.anchor = rel end
  function f:SetFrameLevel(n) f.level = n end
  function f:GetFrameLevel() return f.level end
  function f:EnableMouse() end
  function f:Show() f.shown = true end
  function f:Hide() f.shown = false end
  function f:CreateTexture()
    local t = { shown = false }
    function t:SetAllPoints() end
    function t:SetTexture(p) t.path = p end
    function t:Show() t.shown = true end
    function t:Hide() t.shown = false end
    function t:SetDrawLayer() end
    return t
  end
  function f:CreateFontString()
    local fs = { shown = false, text = "" }
    function fs:SetPoint() end
    function fs:SetFont() end
    function fs:SetTextColor() end
    function fs:SetDrawLayer() end
    function fs:SetText(text) fs.text = text end
    function fs:Show() fs.shown = true end
    function fs:Hide() fs.shown = false end
    return fs
  end
  return f
end
function playerContainer:GetFrameLevel() return 4 end
function frameContainer:GetFrameLevel() return 4 end
function playerContainer:CreateFrame()
  return _G.CreateFrame("Frame", nil, playerContainer)
end

Addon.CrowdControlAuraOn = function(_, unit)
  if unit == "player" or unit == "target" then
    return {
      icon = "Interface\\Icons\\Spell_Nature_Sleep",
      duration = 40,
      expirationTime = 54,
      name = "Sleep",
      spellId = 700,
    }
  end
end

Addon:SkinCrowdControlPortraits()
assert(playerChip.shown == false, "leftover PlayerPortrait chip cannot show zzz")
assert(playerLive.alpha == 1, "native 64px face stays visible")
assert(playerContainer.shadowUICCHolder.anchor == playerLive,
  "Crowd Control overlay covers the live 64px portrait")
assert(stalePort.shown == false, "leftover TargetFramePortrait chip hides")
assert(leftoverChip.shown == false, "TargetFrameContainer leftover PlayerPortrait chip hides")
assert(containerPort.alpha == 0 or (frameContainer.shadowUICCHolder and frameContainer.shadowUICCHolder.anchor == containerPort),
  "Target Frame overlay binds to TargetFrameContainer.Portrait")
playerChip:Show()
playerChip:SetAlpha(1)
assert(playerChip.shown == false and playerChip.alpha == 0,
  "Blizzard cannot show the leftover chip after HideLeftoverPortraits")

print("ccportrait_spec OK")

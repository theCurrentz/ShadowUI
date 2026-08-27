--[[
  Purpose: Paint Meter Fill on Blizzard health, power, and Name Background.
           The gradient lives on an overlay we own. StatusBar vertex colour
           flattens SetGradient on the native fill.
  Deps: ShadowUI:ApplyStatusBarGradient()
  Public: ShadowUI:LightingGradient(), ShadowUI:PaintStatusBarGradient(),
          ShadowUI:PaintNameBackgroundGradient(), ShadowUI:SkinNamePlate(),
          ShadowUI:SkinStatusBarGradients(), ShadowUI:OnNamePlateUnitAdded()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local FILL = "Interface\\Buttons\\WHITE8X8"
local DARK = 0.22
local LIGHT = 1.0
local UNIT_NAMES = {
  "PlayerFrame",
  "PetFrame",
  "TargetFrame",
  "FocusFrame",
  "TargetFrameToT",
  "FocusFrameToT",
}

local function clamp(n)
  return math.max(0, math.min(1, n or 0))
end

function Addon:LightingGradient(r, g, b, a)
  a = a or 1
  r = r or 0
  g = g or 0
  b = b or 0
  return { r * DARK, g * DARK, b * DARK, a },
    { clamp(r * LIGHT), clamp(g * LIGHT), clamp(b * LIGHT), a }
end

local function paintMeter(tex, r, g, b, a)
  if not tex then
    return
  end
  if tex.SetTexture then
    tex:SetTexture(FILL)
  end
  local from, to = Addon:LightingGradient(r, g, b, a)
  if Addon.ApplyStatusBarGradient then
    Addon:ApplyStatusBarGradient(tex, "HORIZONTAL", from, to)
  elseif tex.SetVertexColor then
    tex:SetVertexColor(to[1], to[2], to[3], to[4])
  end
end

local function overlayOn(host, fill)
  if not host then
    return fill
  end
  if host.shadowUIMeter then
    return host.shadowUIMeter
  end
  if fill and fill.shadowUIMeter then
    return fill.shadowUIMeter
  end
  if not host.CreateTexture then
    return fill
  end
  local meter = host:CreateTexture(nil, "ARTWORK", nil, 7)
  if meter.SetTexture then
    meter:SetTexture(FILL)
  end
  if meter.SetAllPoints then
    if fill then
      meter:SetAllPoints(fill)
    else
      meter:SetAllPoints(host)
    end
  end
  host.shadowUIMeter = meter
  if fill then
    fill.shadowUIMeter = meter
  end
  return meter
end

local function liveColor(bar, r, g, b, a)
  if r ~= nil then
    return r, g, b, a or 1
  end
  if bar._shadowUIMeterR ~= nil then
    return bar._shadowUIMeterR, bar._shadowUIMeterG, bar._shadowUIMeterB, bar._shadowUIMeterA or 1
  end
  if bar.GetStatusBarColor then
    return bar:GetStatusBarColor()
  end
  return 1, 1, 1, 1
end

local function paintBar(bar, r, g, b, a)
  if not bar or bar._shadowUIPainting then
    return
  end
  bar._shadowUIPainting = true
  r, g, b, a = liveColor(bar, r, g, b, a)
  bar._shadowUIMeterR, bar._shadowUIMeterG, bar._shadowUIMeterB, bar._shadowUIMeterA = r, g, b, a
  local fill = bar.GetStatusBarTexture and bar:GetStatusBarTexture()
  local meter = overlayOn(bar, fill)
  paintMeter(meter, r, g, b, a)
  bar._shadowUIPainting = nil
end

function Addon:PaintStatusBarGradient(bar, r, g, b, a)
  paintBar(bar, r, g, b, a)
end

local function watchBar(bar)
  if not bar or bar._shadowUIMeterWatch then
    return
  end
  bar._shadowUIMeterWatch = true
  if hooksecurefunc and bar.SetStatusBarColor then
    hooksecurefunc(bar, "SetStatusBarColor", function(self, r, g, b, a)
      paintBar(self, r, g, b, a)
    end)
  end
  paintBar(bar)
end

local function paintName(tex, r, g, b, a)
  if not tex or tex._shadowUIPainting then
    return
  end
  tex._shadowUIPainting = true
  if r == nil and tex.GetVertexColor then
    r, g, b, a = tex:GetVertexColor()
  end
  local parent = tex.GetParent and tex:GetParent()
  local meter = overlayOn(parent or tex, tex)
  paintMeter(meter, r, g, b, a)
  tex._shadowUIPainting = nil
end

function Addon:PaintNameBackgroundGradient(tex, r, g, b, a)
  paintName(tex, r, g, b, a)
end

local function watchName(tex)
  if not tex or tex._shadowUINameWatch then
    return
  end
  tex._shadowUINameWatch = true
  if hooksecurefunc and tex.SetVertexColor then
    hooksecurefunc(tex, "SetVertexColor", function(self, r, g, b, a)
      paintName(self, r, g, b, a)
    end)
  end
  paintName(tex)
end

local function healthBarOf(frame)
  if not frame then
    return
  end
  if frame.healthbar then
    return frame.healthbar
  end
  if frame.healthBar then
    return frame.healthBar
  end
  local main = frame.PlayerFrameContent and frame.PlayerFrameContent.PlayerFrameContentMain
    or frame.TargetFrameContent and frame.TargetFrameContent.TargetFrameContentMain
  local container = frame.HealthBarsContainer or (main and main.HealthBarsContainer)
  if container then
    return container.HealthBar or container.healthBar
  end
end

local function barsOn(frame)
  if not frame then
    return
  end
  watchBar(healthBarOf(frame))
  watchBar(frame.manabar or frame.powerbar or frame.powerBar)
  watchName(frame.NameBackground or frame.nameBackground)
  local name = frame.GetName and frame:GetName()
  if not name then
    return
  end
  watchBar(_G[name .. "HealthBar"])
  watchBar(_G[name .. "ManaBar"])
  watchBar(_G[name .. "AlternateManaBar"])
  watchName(_G[name .. "NameBackground"])
end

function Addon:SkinNamePlate(plate)
  if not plate then
    return
  end
  local uf = plate.UnitFrame or plate
  barsOn(uf)
  watchBar(uf.healthBar or uf.healthbar)
  watchBar(uf.powerBar or uf.manabar)
end

function Addon:OnNamePlateUnitAdded(_, unit)
  if not unit or not C_NamePlate or not C_NamePlate.GetNamePlateForUnit then
    return
  end
  self:SkinNamePlate(C_NamePlate.GetNamePlateForUnit(unit))
end

local function watchCompact()
  if Addon._compactMeterHook or not hooksecurefunc then
    return
  end
  Addon._compactMeterHook = true
  if CompactUnitFrame_UpdateHealthColor then
    hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
      if frame then
        watchBar(frame.healthBar or frame.healthbar)
      end
    end)
  end
  if CompactUnitFrame_UpdatePowerColor then
    hooksecurefunc("CompactUnitFrame_UpdatePowerColor", function(frame)
      if frame then
        watchBar(frame.powerBar or frame.manabar or frame.powerbar)
      end
    end)
  end
  if HealthBar_OnValueChanged then
    hooksecurefunc("HealthBar_OnValueChanged", function(bar)
      watchBar(bar)
    end)
  end
end

function Addon:SkinStatusBarGradients()
  if self.RegisterEvent and not self._statusBarEvents then
    self._statusBarEvents = true
    pcall(self.RegisterEvent, self, "NAME_PLATE_UNIT_ADDED", "OnNamePlateUnitAdded")
    pcall(self.RegisterEvent, self, "PLAYER_TARGET_CHANGED", "SkinStatusBarGradients")
    pcall(self.RegisterEvent, self, "PLAYER_FOCUS_CHANGED", "SkinStatusBarGradients")
  end
  watchCompact()
  for _, name in ipairs(UNIT_NAMES) do
    barsOn(_G[name])
  end
  watchBar(_G.PlayerFrameAlternateManaBar)
  for i = 1, 4 do
    barsOn(_G["PartyMemberFrame" .. i])
    barsOn(_G["PartyMemberFrame" .. i .. "PetFrame"])
  end
  if C_NamePlate and C_NamePlate.GetNamePlates then
    local plates = C_NamePlate.GetNamePlates() or {}
    for _, plate in ipairs(plates) do
      self:SkinNamePlate(plate)
    end
  end
end

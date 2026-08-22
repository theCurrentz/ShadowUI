--[[
  Purpose: Render the skinny glossy GCD Sweep beneath the Cast Bar.
  Deps: WoW spell cooldown APIs, ShadowUI:ApplyStatusBarGradient()
  Public: ShadowUI:CreateGCDBar(), ShadowUI:GCDSweepState(),
          ShadowUI:GCDSweepFromClient(), ShadowUI:PreviewGCDBar()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local GCD_SPELL_ID = 61304
local DEFAULT_GCD = 1.5
local MAX_GCD = 1.5
local HEIGHT = 4

function Addon:GCDSweepState(startTime, duration, enabled, now)
  if enabled == 0 or not startTime or not duration or duration <= 0 or duration > MAX_GCD then
    return nil
  end
  local remaining = startTime + duration - now
  if remaining <= 0 then
    return nil
  end
  return {
    remaining = remaining,
    duration = duration,
    endTime = startTime + duration,
  }
end

function Addon:GCDSweepFromClient(now, startTime, duration, enabled, event, isBusy, active, fromCast)
  local state = self:GCDSweepState(startTime, duration, enabled, now)
  if state then
    return state
  end
  if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
    return self:GCDSweepState(now, DEFAULT_GCD, 1, now)
  end
  if event == "UNIT_SPELLCAST_SUCCEEDED" and not isBusy and not fromCast then
    return self:GCDSweepState(now, DEFAULT_GCD, 1, now)
  end
  if active and active.endTime and active.endTime > now then
    return active
  end
  return nil
end

local function placeSpark(bar, fraction)
  local spark = bar.spark
  if not spark then
    return
  end
  spark:ClearAllPoints()
  spark:SetPoint("CENTER", bar, "LEFT", (bar:GetWidth() or 0) * fraction, 0)
  spark:Show()
end

local function applyState(bar, state)
  if not state then
    if not (Addon.editMode and bar.preview) then
      bar:Hide()
    end
    return
  end
  bar.preview = nil
  bar.endTime = state.endTime
  bar.duration = state.duration
  bar:SetMinMaxValues(0, state.duration)
  bar:SetValue(state.remaining)
  placeSpark(bar, state.remaining / state.duration)
  bar:Show()
end

local function readCooldown(spell)
  if C_Spell and C_Spell.GetSpellCooldown then
    local ok, info = pcall(C_Spell.GetSpellCooldown, spell)
    if ok and type(info) == "table" then
      local enabled = 1
      if info.isEnabled == false then
        enabled = 0
      end
      return info.startTime, info.duration, enabled
    end
  end
  if GetSpellCooldown then
    local ok, a, b, c = pcall(GetSpellCooldown, spell)
    if ok then
      return a, b, c
    end
  end
end

local function spellFromEvent(...)
  local _, a, b = ...
  if type(b) == "number" or type(b) == "string" then
    return b
  end
  if type(a) == "number" or type(a) == "string" then
    return a
  end
end

local function refreshGCD(bar, event, ...)
  if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
    bar.fromCast = true
  end
  local startTime, duration, enabled = readCooldown(GCD_SPELL_ID)
  if not duration or duration <= 0 then
    local spell = spellFromEvent(...)
    if spell then
      startTime, duration, enabled = readCooldown(spell)
    end
  end
  local isBusy = UnitCastingInfo and (UnitCastingInfo("player") or (UnitChannelInfo and UnitChannelInfo("player")))
  local active
  if bar.endTime and bar.duration then
    active = {
      remaining = bar.endTime - GetTime(),
      duration = bar.duration,
      endTime = bar.endTime,
    }
  end
  applyState(bar, Addon:GCDSweepFromClient(
    GetTime(),
    startTime,
    duration,
    enabled,
    event,
    isBusy and true or false,
    active,
    bar.fromCast
  ))
  if event == "UNIT_SPELLCAST_SUCCEEDED" and not isBusy then
    bar.fromCast = nil
  end
end

local function updateGCD(bar)
  if Addon.editMode and bar.preview then
    return
  end
  local remaining = (bar.endTime or 0) - GetTime()
  if remaining <= 0 or not bar.duration then
    bar:Hide()
    return
  end
  bar:SetValue(remaining)
  placeSpark(bar, remaining / bar.duration)
end

function Addon:CreateGCDBar(parent, above)
  local bar = CreateFrame("StatusBar", "ShadowUIGCDBar", parent)
  bar:SetHeight(HEIGHT)
  local anchor = above or parent
  bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
  bar:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
  bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
  self:ApplyStatusBarGradient(
    bar:GetStatusBarTexture(),
    "HORIZONTAL",
    { 0.55, 0.82, 0.95, 0.18 },
    { 0.92, 0.98, 1.0, 0.32 }
  )
  if bar.SetStatusBarColor then
    bar:SetStatusBarColor(0.78, 0.92, 1.0, 0.28)
  end

  local background = bar:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints()
  background:SetColorTexture(0.04, 0.08, 0.12, 0.16)
  bar.background = background

  local gloss = bar:CreateTexture(nil, "OVERLAY")
  gloss:SetColorTexture(1, 1, 1, 0.16)
  if gloss.SetBlendMode then
    gloss:SetBlendMode("ADD")
  end
  gloss:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
  gloss:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
  gloss:SetHeight(2)
  bar.gloss = gloss

  bar.spark = bar:CreateTexture(nil, "OVERLAY")
  bar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  bar.spark:SetWidth(12)
  bar.spark:SetHeight(10)
  bar.spark:SetVertexColor(1, 1, 1, 0.7)
  bar.spark:SetBlendMode("ADD")

  bar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  bar:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
  pcall(bar.RegisterEvent, bar, "SPELL_UPDATE_COOLDOWN")
  bar:SetScript("OnEvent", refreshGCD)
  bar:SetScript("OnUpdate", updateGCD)
  bar:Hide()
  return bar
end

function Addon:PreviewGCDBar(preview)
  local bar = self.gcdBar
  if not bar then
    return
  end
  bar.preview = preview and true or nil
  if not preview then
    if not bar.endTime or (bar.endTime - GetTime()) <= 0 then
      bar:Hide()
    end
    return
  end
  bar:SetMinMaxValues(0, 1.5)
  bar:SetValue(1.0)
  placeSpark(bar, 1.0 / 1.5)
  bar:Show()
end

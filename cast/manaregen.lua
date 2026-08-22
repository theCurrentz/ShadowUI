--[[
  Purpose: Classify mana regen ticks vs five-second-rule spend.
  Deps: WoW power / combat-log APIs
  Public: ShadowUI:ManaGainKind(), ShadowUI:ManaSpendAmount(),
          ShadowUI:ManaTickerOnEvent(), ShadowUI:ManaTickerPulse()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local POWER_MANA = 0
local FSR_SECONDS = 5
local TICK_SECONDS = 2

function Addon:ManaGainKind(delta, explainedGain, drinkGainSeen)
  if not delta or delta <= 0 then
    return nil
  end
  if delta - (explainedGain or 0) > 0 then
    return "tick"
  end
  if drinkGainSeen then
    return "drink"
  end
  return nil
end

function Addon:ManaSpendAmount(delta, explainedGain)
  return (explainedGain or 0) - (delta or 0)
end

local function currentMana()
  return UnitPower("player", POWER_MANA)
end

local function spellHasManaCost(spellID)
  if not spellID or not GetSpellPowerCost then
    return true
  end
  local costs = GetSpellPowerCost(spellID)
  if not costs then
    return false
  end
  for _, cost in ipairs(costs) do
    if cost.type == POWER_MANA and ((cost.cost or 0) > 0 or (cost.minCost or 0) > 0) then
      return true
    end
  end
  return false
end

local function placeSpark(bar, fraction)
  local width = bar:GetWidth() or 0
  bar.spark:SetPoint("CENTER", bar, "LEFT", width * fraction, 0)
end

local function hideCountdown(frame)
  frame.countdown:Hide()
end

local function showCountdown(frame, remaining)
  frame.countdown:SetFormattedText("%.1fs", remaining)
  frame.countdown:Show()
end

local function onCombatLog(frame)
  if not CombatLogGetCurrentEventInfo then
    return
  end
  local _, subevent, _, _, _, _, _, destGUID, _, _, _, _, spellName, _, amount, overEnergize, powerType =
    CombatLogGetCurrentEventInfo()
  if subevent ~= "SPELL_ENERGIZE" and subevent ~= "SPELL_PERIODIC_ENERGIZE" then
    return
  end
  if destGUID ~= UnitGUID("player") then
    return
  end
  if powerType == nil then
    powerType = overEnergize
    overEnergize = 0
  end
  if powerType ~= POWER_MANA then
    return
  end
  local gained = (amount or 0) - (overEnergize or 0)
  if gained > 0 then
    frame.explainedGain = frame.explainedGain + gained
  end
  if spellName == frame.drinkName then
    frame.drinkGainSeen = true
  end
end

function Addon:ManaTickerOnEvent(frame, event, unit, ...)
  if event == "COMBAT_LOG_EVENT_UNFILTERED" then
    onCombatLog(frame)
    return
  end
  if event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" then
    if spellHasManaCost(select(2, ...)) then
      frame.castPendingUntil = GetTime() + 0.4
    end
    return
  end
  frame.previousPower = currentMana()
  frame.explainedGain = 0
  frame.drinkGainSeen = false
end

function Addon:ManaTickerPulse(frame)
  if UnitIsDead("player") then
    frame.fsr:Hide()
    frame.tick:Hide()
    hideCountdown(frame)
    return
  end
  if not GetTime then
    return
  end
  local current = currentMana()
  local delta = current - frame.previousPower
  if self:ManaGainKind(delta, frame.explainedGain, frame.drinkGainSeen) then
    frame.tickAnchor = GetTime()
  end
  local spent = self:ManaSpendAmount(delta, frame.explainedGain)
  if spent > 0 and GetTime() <= frame.castPendingUntil then
    frame.gainingMana = false
    frame.mp5StartTime = GetTime() + FSR_SECONDS
    frame.castPendingUntil = 0
    frame.tick:Hide()
    frame.fsr:Show()
  end
  frame.explainedGain = 0
  frame.drinkGainSeen = false
  frame.previousPower = current

  if frame.mp5StartTime > 0 then
    local remaining = frame.mp5StartTime - GetTime()
    if remaining < 0 then
      frame.gainingMana = true
      frame.mp5StartTime = 0
      frame.fsr:Hide()
      hideCountdown(frame)
      return
    end
    frame.fsr:Show()
    frame.tick:Hide()
    frame.fsr:SetMinMaxValues(0, FSR_SECONDS)
    frame.fsr:SetValue(remaining)
    placeSpark(frame.fsr, remaining / FSR_SECONDS)
    showCountdown(frame, remaining)
    return
  end

  if not frame.gainingMana or current >= UnitPowerMax("player", POWER_MANA) then
    frame.tick:Hide()
    hideCountdown(frame)
    return
  end
  local now = GetTime()
  if not frame.tickAnchor then
    frame.tickAnchor = now
  end
  if now - frame.tickAnchor >= TICK_SECONDS then
    local steps = math.floor((now - frame.tickAnchor) / TICK_SECONDS)
    frame.tickAnchor = frame.tickAnchor + steps * TICK_SECONDS
  end
  local remaining = (frame.tickAnchor + TICK_SECONDS) - now
  frame.tick:Show()
  frame.tick:SetMinMaxValues(0, TICK_SECONDS)
  frame.tick:SetValue(TICK_SECONDS - remaining)
  placeSpark(frame.tick, 1 - remaining / TICK_SECONDS)
  showCountdown(frame, remaining)
end

--[[
  Purpose: Draw the mana ticker and remaining-seconds label under the player portrait mana bar.
  Deps: ShadowUI:ApplyStatusBarGradient(), ShadowUI:ManaTickerPulse()
  Public: ShadowUI:ApplyManaTicker()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local HEIGHT = 4
local DRINK_SPELL_ID = 1135

local function paintBar(bar, from, to)
  bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
  Addon:ApplyStatusBarGradient(bar:GetStatusBarTexture(), "HORIZONTAL", from, to)
  local bg = bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.015, 0.02, 0.025, 0.95)
  local spark = bar:CreateTexture(nil, "OVERLAY")
  spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  spark:SetWidth(10)
  spark:SetVertexColor(1, 1, 1)
  spark:SetBlendMode("ADD")
  bar.spark = spark
  bar:SetMinMaxValues(0, 1)
  bar:Hide()
end

local function makeBar(name, parent, from, to)
  local bar = CreateFrame("StatusBar", name, parent)
  bar:SetAllPoints(parent)
  paintBar(bar, from, to)
  return bar
end

local function makeCountdown(parent)
  local overlay = CreateFrame("Frame", nil, parent)
  overlay:SetAllPoints(parent)
  local countdown = overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  countdown:SetPoint("LEFT", overlay, "LEFT", 2, 0)
  countdown:SetJustifyH("LEFT")
  countdown:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  countdown:Hide()
  return countdown
end

local function anchor(frame)
  local mana = PlayerFrameManaBar
  if not mana then
    return
  end
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", mana, "BOTTOMLEFT", 0, -1)
  frame:SetPoint("TOPRIGHT", mana, "BOTTOMRIGHT", 0, -1)
  frame:SetHeight(HEIGHT)
  frame:SetWidth(mana:GetWidth() or 0)
  if frame.fsr then
    frame.fsr:SetWidth(frame:GetWidth())
  end
  if frame.tick then
    frame.tick:SetWidth(frame:GetWidth())
  end
end

local function createTicker()
  local frame = CreateFrame("Frame", "ShadowUIManaTicker", UIParent)
  frame:SetFrameStrata("MEDIUM")
  frame.fsr = makeBar("ShadowUIFSRBar", frame, { 0.28, 0.12, 0.48, 1 }, { 0.62, 0.22, 0.95, 1 })
  frame.tick = makeBar("ShadowUITickBar", frame, { 0.55, 0.55, 0.6, 1 }, { 0.95, 0.95, 1, 1 })
  frame.countdown = makeCountdown(frame)
  frame.previousPower = 0
  frame.explainedGain = 0
  frame.drinkGainSeen = false
  frame.castPendingUntil = 0
  frame.gainingMana = true
  frame.mp5StartTime = 0
  frame.tickAnchor = nil
  frame.drinkName = GetSpellInfo and GetSpellInfo(DRINK_SPELL_ID) or "Drink"
  return frame
end

function Addon:ApplyManaTicker()
  if self:GetPlayerClass() == "WARRIOR" then
    if self.manaTicker then
      self.manaTicker:Hide()
      self.manaTicker:SetScript("OnUpdate", nil)
    end
    return
  end
  if not self.manaTicker then
    self.manaTicker = createTicker()
    local frame = self.manaTicker
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    frame:RegisterEvent("PLAYER_UNGHOST")
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    frame:SetScript("OnEvent", function(selfFrame, event, unit, ...)
      Addon:ManaTickerOnEvent(selfFrame, event, unit, ...)
    end)
    frame:SetScript("OnUpdate", function(selfFrame)
      anchor(selfFrame)
      Addon:ManaTickerPulse(selfFrame)
    end)
    frame.previousPower = UnitPower("player", 0)
  end
  anchor(self.manaTicker)
  self.manaTicker:Show()
end

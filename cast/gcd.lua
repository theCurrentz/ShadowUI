--[[
  Purpose: Render the player global cooldown beneath the cast bar.
  Deps: WoW spell cooldown APIs
  Public: ShadowUI:CreateGCDBar()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local GCD_SPELL_ID = 61304

local function refreshGCD(bar)
  local startTime, duration, enabled = GetSpellCooldown(GCD_SPELL_ID)
  if enabled == 0 or not startTime or not duration or duration <= 0 then
    bar:Hide()
    return
  end

  bar.endTime = startTime + duration
  bar:SetMinMaxValues(0, duration)
  bar:SetValue(duration)
  bar:Show()
end

local function updateGCD(bar)
  local remaining = bar.endTime - GetTime()
  if remaining <= 0 then
    bar:Hide()
    return
  end
  bar:SetValue(remaining)
end

function Addon:CreateGCDBar(parent)
  local bar = CreateFrame("StatusBar", "ShadowUIGCDBar", UIParent)
  bar:SetSize(parent:GetWidth(), 3)
  bar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -2)
  bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
  bar:GetStatusBarTexture():SetGradientAlpha(
    "HORIZONTAL",
    0.25, 0.38, 0.46, 1,
    0.62, 0.86, 0.96, 1
  )

  local background = bar:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints()
  background:SetColorTexture(0.015, 0.02, 0.025, 0.95)

  bar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  bar:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
  bar:SetScript("OnEvent", refreshGCD)
  bar:SetScript("OnUpdate", updateGCD)
  bar:Hide()
  return bar
end

--[[
  Purpose: Render a fixed player cast and channel bar.
  Deps: WoW unit spellcast APIs, ShadowUI:CreateGCDBar()
  Public: ShadowUI:ApplyCastBar(), ShadowUI:ApplyStatusBarGradient()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local BACKDROP = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,
}
local WIDTH, HEIGHT = 432, 20

-- SetGradientAlpha was removed from the client; SetGradient takes ColorMixins.
function Addon:ApplyStatusBarGradient(texture, orientation, from, to)
  if not texture then
    return
  end
  if CreateColor and texture.SetGradient then
    local ok = pcall(
      texture.SetGradient,
      texture,
      orientation,
      CreateColor(from[1], from[2], from[3], from[4]),
      CreateColor(to[1], to[2], to[3], to[4])
    )
    if ok then
      return
    end
  end
  texture:SetVertexColor(to[1], to[2], to[3], to[4])
end

local function hideBlizzardCastBar()
  local frame = CastingBarFrame
  if not frame then
    return
  end
  frame:UnregisterAllEvents()
  frame:Hide()
  frame:SetScript("OnShow", frame.Hide)
end

local function refreshCast(bar, channel)
  local name, text, texture, startMS, endMS
  if channel then
    name, text, texture, startMS, endMS = UnitChannelInfo("player")
  else
    name, text, texture, startMS, endMS = UnitCastingInfo("player")
  end
  if not name or not startMS or not endMS then
    bar:Hide()
    return
  end

  bar.startTime = startMS / 1000
  bar.endTime = endMS / 1000
  bar.channel = channel
  bar:SetMinMaxValues(0, bar.endTime - bar.startTime)
  bar.name:SetText(text or name)
  bar.icon:SetTexture(texture)
  bar:Show()
end

local function updateCast(bar)
  local now = GetTime()
  local remaining = bar.endTime - now
  if remaining <= 0 then
    bar:Hide()
    return
  end

  local value = bar.channel and remaining or now - bar.startTime
  bar:SetValue(value)
  bar.time:SetFormattedText("%.1f", remaining)
end

local function createCastBar()
  local bar = CreateFrame("StatusBar", "ShadowUICastBar", UIParent, "BackdropTemplate")
  bar:SetSize(WIDTH, HEIGHT)
  bar:SetPoint("CENTER", UIParent, "CENTER", 0, -120)
  bar:SetFrameStrata("MEDIUM")
  bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
  Addon:ApplyStatusBarGradient(
    bar:GetStatusBarTexture(),
    "HORIZONTAL",
    { 0.12, 0.18, 0.22, 1 },
    { 0.35, 0.72, 0.88, 1 }
  )
  bar:SetBackdrop(BACKDROP)
  bar:SetBackdropColor(0.015, 0.02, 0.025, 0.95)
  bar:SetBackdropBorderColor(0, 0, 0, 1)

  bar.icon = bar:CreateTexture(nil, "ARTWORK")
  bar.icon:SetSize(HEIGHT, HEIGHT)
  bar.icon:SetPoint("RIGHT", bar, "LEFT", -3, 0)

  bar.name = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  bar.name:SetPoint("LEFT", bar, "LEFT", 6, 0)
  bar.name:SetPoint("RIGHT", bar, "RIGHT", -42, 0)
  bar.name:SetJustifyH("LEFT")

  bar.time = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  bar.time:SetPoint("RIGHT", bar, "RIGHT", -5, 0)

  bar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
  bar:SetScript("OnEvent", function(self, event)
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
      refreshCast(self, false)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START"
      or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
      refreshCast(self, true)
    else
      self:Hide()
    end
  end)
  bar:SetScript("OnUpdate", updateCast)
  bar:Hide()
  return bar
end

function Addon:ApplyCastBar()
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  hideBlizzardCastBar()
  if not self.castBar then
    self.castBar = createCastBar()
    self.gcdBar = self:CreateGCDBar(self.castBar)
  end
end

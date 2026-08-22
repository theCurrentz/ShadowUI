--[[
  Purpose: Paint the Threat Bar flush on the Target Frame nameplate.
  The bar is full width, zero gap. Fill follows UnitDetailedThreatSituation.
  Colour goes from desaturated grey at low threat, to orange at mid-high, to blood red at full.
  Threat Number sits on the bar. Native NumericalThreat stays hidden (Blizzard Hide).
  Hide at 0%. Solo still shows the bar.
  Deps: UnitDetailedThreatSituation
  Public: ShadowUI:ThreatCaption(), ShadowUI:ThreatBarColor(), ShadowUI:SkinTargetThreat()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local BAR_HEIGHT = 12
local MID_HIGH = 0.7
local GRAY = { 0.53, 0.53, 0.53 }
local ORANGE = { 1.0, 0.45, 0.05 }
local BLOOD = { 0.75, 0.0, 0.0 }

local function lerp(a, b, t)
  return a + (b - a) * t
end

function Addon:ThreatCaption(percent)
  if not percent or percent <= 0 then
    return nil
  end
  local n = math.floor(percent + 0.5)
  if n == 0 then
    return nil
  end
  return n .. "%"
end

function Addon:ThreatBarColor(percent)
  local p = math.max(0, math.min(100, percent or 0)) / 100
  if p <= MID_HIGH then
    local t = p / MID_HIGH
    return lerp(GRAY[1], ORANGE[1], t), lerp(GRAY[2], ORANGE[2], t), lerp(GRAY[3], ORANGE[3], t)
  end
  local t = (p - MID_HIGH) / (1 - MID_HIGH)
  return lerp(ORANGE[1], BLOOD[1], t), lerp(ORANGE[2], BLOOD[2], t), lerp(ORANGE[3], BLOOD[3], t)
end

local function threatPercent(unit)
  if not UnitDetailedThreatSituation then
    return nil
  end
  local isTanking, _, scaled, raw = UnitDetailedThreatSituation("player", unit)
  local percent = scaled or raw
  if percent == nil and isTanking then
    return 100
  end
  return percent
end

local function muteNative(frame)
  local name = frame.GetName and frame:GetName()
  local native = frame.threatNumericIndicator or (name and _G[name .. "NumericalThreat"])
  if native and native ~= frame.shadowUIThreat and native.Hide then
    native:Hide()
  end
end

local function nameplate(frame)
  if frame.nameBackground then
    return frame.nameBackground
  end
  local name = frame.GetName and frame:GetName()
  if not name then
    return frame
  end
  return _G[name .. "NameBackground"] or frame
end

local function host(frame)
  if not frame then
    return nil
  end
  muteNative(frame)
  local bar = frame.shadowUIThreat
  if bar then
    return bar
  end
  if not CreateFrame then
    return nil
  end
  bar = CreateFrame("StatusBar", nil, frame)
  if bar.SetHeight then
    bar:SetHeight(BAR_HEIGHT)
  else
    bar:SetSize(1, BAR_HEIGHT)
  end
  if bar.SetMinMaxValues then
    bar:SetMinMaxValues(0, 100)
  end
  if bar.SetStatusBarTexture then
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
  end
  if bar.SetFrameLevel and frame.GetFrameLevel then
    bar:SetFrameLevel(frame:GetFrameLevel() + 8)
  end
  local bg = bar:CreateTexture(nil, "BACKGROUND")
  if bg.SetAllPoints then
    bg:SetAllPoints(bar)
  end
  if bg.SetColorTexture then
    bg:SetColorTexture(0, 0, 0, 0.8)
  end
  bar.bg = bg
  local fs = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  if fs.SetPoint then
    fs:SetPoint("CENTER", bar, "CENTER", 0, 0)
  end
  bar.text = fs
  bar.font = fs
  if bar.SetScript then
    bar:SetScript("OnUpdate", function()
      Addon:SkinTargetThreat()
    end)
  end
  frame.shadowUIThreat = bar
  return bar
end

local function place(bar, frame)
  if not bar or not bar.SetPoint or not frame then
    return
  end
  local plate = nameplate(frame)
  if bar.ClearAllPoints then
    bar:ClearAllPoints()
  end
  bar:SetPoint("BOTTOMLEFT", plate, "TOPLEFT", 0, 0)
  bar:SetPoint("BOTTOMRIGHT", plate, "TOPRIGHT", 0, 0)
  if bar.SetHeight then
    bar:SetHeight(BAR_HEIGHT)
  end
end

local function setText(bar, text)
  local fs = bar.text or bar.font
  if fs and fs.SetText then
    fs:SetText(text)
  elseif bar.SetText then
    bar:SetText(text)
  end
end

local function paint(frame, unit)
  local bar = host(frame)
  if not bar then
    return
  end
  place(bar, frame)
  local percent = threatPercent(unit)
  local text = Addon:ThreatCaption(percent)
  if not text then
    if bar.Hide then
      bar:Hide()
    end
    return
  end
  setText(bar, text)
  if bar.SetValue then
    bar:SetValue(math.min(100, percent))
  end
  local r, g, b = Addon:ThreatBarColor(percent)
  if bar.SetStatusBarColor then
    bar:SetStatusBarColor(r, g, b)
  end
  local fill = bar.fill or bar
  if fill.SetVertexColor then
    fill:SetVertexColor(r, g, b)
  end
  if bar.Show then
    bar:Show()
  end
end

function Addon:SkinTargetThreat()
  if self.RegisterEvent and not self._threatEvents then
    self._threatEvents = true
    pcall(self.RegisterEvent, self, "PLAYER_TARGET_CHANGED", "SkinTargetThreat")
    pcall(self.RegisterEvent, self, "PLAYER_FOCUS_CHANGED", "SkinTargetThreat")
    pcall(self.RegisterEvent, self, "UNIT_THREAT_SITUATION_UPDATE", "SkinTargetThreat")
    pcall(self.RegisterEvent, self, "UNIT_THREAT_LIST_UPDATE", "SkinTargetThreat")
  end
  paint(_G.TargetFrame, "target")
  paint(_G.FocusFrame, "focus")
end

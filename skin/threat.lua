--[[
  Purpose: Paint Threat Number above the Target Frame nameplate (Modern TargetFrame gap).
  Host is the ShadowUI pip. Native NumericalThreat stays hidden (Blizzard Hide).
  Hide at 0%. Solo still shows the percent.
  Deps: UnitDetailedThreatSituation
  Public: ShadowUI:ThreatCaption(), ShadowUI:ThreatStatusColor(), ShadowUI:SkinTargetThreat()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local STATUS_COLOR = {
  [0] = { 0.69, 0.69, 0.69 },
  [1] = { 1, 1, 0.47 },
  [2] = { 1, 0.6, 0 },
  [3] = { 1, 0, 0 },
}

function Addon:ThreatCaption(percent)
  if not percent or percent == 0 then
    return nil
  end
  return math.floor(percent + 0.5) .. "%"
end

function Addon:ThreatStatusColor(status)
  if GetThreatStatusColor then
    local r, g, b = GetThreatStatusColor(status)
    if r then
      return r, g, b
    end
  end
  local color = STATUS_COLOR[status or 0] or STATUS_COLOR[0]
  return color[1], color[2], color[3]
end

local function threatPercent(unit)
  if not UnitDetailedThreatSituation then
    return nil, nil
  end
  local _, status, percent = UnitDetailedThreatSituation("player", unit)
  return percent, status
end

local function muteNative(frame)
  local name = frame.GetName and frame:GetName()
  local native = frame.threatNumericIndicator or (name and _G[name .. "NumericalThreat"])
  if native and native ~= frame.shadowUIThreat and native.Hide then
    native:Hide()
  end
end

local function host(frame)
  if not frame then
    return nil
  end
  muteNative(frame)
  local pip = frame.shadowUIThreat
  if pip then
    return pip
  end
  if not CreateFrame then
    return nil
  end
  pip = CreateFrame("Frame", nil, frame)
  pip:SetSize(49, 18)
  if pip.SetFrameLevel and frame.GetFrameLevel then
    pip:SetFrameLevel(frame:GetFrameLevel() + 8)
  end
  local bg = pip:CreateTexture(nil, "BACKGROUND")
  if bg.SetAllPoints then
    bg:SetAllPoints(pip)
  end
  if bg.SetColorTexture then
    bg:SetColorTexture(0, 0, 0, 0.8)
  end
  pip.bg = bg
  local fs = pip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  if fs.SetPoint then
    fs:SetPoint("CENTER", pip, "CENTER", 0, 0)
  end
  pip.text = fs
  pip.font = fs
  frame.shadowUIThreat = pip
  return pip
end

local function place(pip, frame)
  if not pip or not pip.SetPoint or not frame then
    return
  end
  if pip.ClearAllPoints then
    pip:ClearAllPoints()
  end
  pip:SetPoint("BOTTOM", frame, "TOP", -22, 0)
end

local function setText(pip, text)
  local fs = pip.text or pip.font
  if fs and fs.SetText then
    fs:SetText(text)
  elseif pip.SetText then
    pip:SetText(text)
  end
end

local function paint(frame, unit)
  local pip = host(frame)
  if not pip then
    return
  end
  place(pip, frame)
  local percent, status = threatPercent(unit)
  local text = Addon:ThreatCaption(percent)
  if not text then
    if pip.Hide then
      pip:Hide()
    end
    return
  end
  setText(pip, text)
  local r, g, b = Addon:ThreatStatusColor(status)
  local bg = pip.bg
  if bg and bg.SetVertexColor then
    bg:SetVertexColor(r, g, b)
  end
  if pip.Show then
    pip:Show()
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

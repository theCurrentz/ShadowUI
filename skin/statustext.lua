--[[
  Purpose: Paint health and mana numbers on the Target Frame (Modern TargetFrame gap).
  Mute native LeftText / RightText / TextString so BOTH cannot stack.
  Format follows Blizzard Status Text.
  Deps: UnitHealth / UnitPower, Status Text CVars
  Public: ShadowUI:StatusBarCaption(), ShadowUI:SkinTargetStatus()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:StatusBarCaption(current, max, display)
  if display == "NONE" or not current or not max or max <= 0 then
    return nil
  end
  local pct = math.floor(current / max * 100 + 0.5)
  if display == "PERCENT" then
    return pct .. "%"
  end
  if display == "BOTH" then
    return current .. " " .. pct .. "%"
  end
  return tostring(current)
end

local function statusDisplay()
  if GetCVarBool then
    local ok, on = pcall(GetCVarBool, "statusText")
    if ok and on == false then
      return "NONE"
    end
  end
  if GetCVar then
    local ok, value = pcall(GetCVar, "statusTextDisplay")
    if ok and type(value) == "string" and value ~= "" then
      return value
    end
  end
  return "NUMERIC"
end

local function namedBar(frame, suffix)
  if not frame then
    return nil
  end
  local key = suffix:lower()
  if frame[key] then
    return frame[key]
  end
  if frame[suffix] then
    return frame[suffix]
  end
  local name = frame.GetName and frame:GetName()
  return name and _G[name .. suffix]
end

local function unitFor(bar, fallback)
  if bar.unit then
    return bar.unit
  end
  local parent = bar.GetParent and bar:GetParent()
  if parent and parent.unit then
    return parent.unit
  end
  return fallback
end

local function captionFor(bar, kind, unit)
  local display = statusDisplay()
  local current, max
  if kind == "health" then
    current = UnitHealth and UnitHealth(unit)
    max = UnitHealthMax and UnitHealthMax(unit)
  else
    current = UnitPower and UnitPower(unit)
    max = UnitPowerMax and UnitPowerMax(unit)
  end
  return Addon:StatusBarCaption(current, max, display)
end

local NATIVE_STATUS = { "LeftText", "RightText", "TextString", "Text" }

local function muteNative(bar, keep)
  for _, key in ipairs(NATIVE_STATUS) do
    local region = bar[key]
    if region and region ~= keep then
      if region.SetText then
        region:SetText("")
      end
      if region.Hide then
        region:Hide()
      end
    end
  end
end

local function paintBar(bar, kind, unit)
  if not bar or not bar.CreateFontString then
    return
  end
  local fs = bar.shadowUIStatusText
  if not fs then
    fs = bar:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    bar.shadowUIStatusText = fs
    if fs.SetPoint then
      fs:SetPoint("CENTER", bar, "CENTER", 0, 0)
    end
  end
  muteNative(bar, fs)
  local text = captionFor(bar, kind, unit)
  if not text then
    if fs.Hide then
      fs:Hide()
    end
    return
  end
  fs:SetText(text)
  if fs.Show then
    fs:Show()
  end
end

local function paintFrame(frame, unit)
  if not frame then
    return
  end
  paintBar(namedBar(frame, "HealthBar"), "health", unit)
  paintBar(namedBar(frame, "ManaBar") or namedBar(frame, "PowerBar"), "power", unit)
end

local function watch(bar)
  if not bar or bar.shadowUIStatusHooked or not bar.HookScript then
    return
  end
  bar.shadowUIStatusHooked = true
  bar:HookScript("OnValueChanged", function()
    Addon:SkinTargetStatus()
  end)
end

function Addon:SkinTargetStatus()
  if self.RegisterEvent and not self._statusTextEvents then
    self._statusTextEvents = true
    pcall(self.RegisterEvent, self, "PLAYER_TARGET_CHANGED", "SkinTargetStatus")
    pcall(self.RegisterEvent, self, "PLAYER_FOCUS_CHANGED", "SkinTargetStatus")
    pcall(self.RegisterEvent, self, "UNIT_HEALTH", "SkinTargetStatus")
    pcall(self.RegisterEvent, self, "UNIT_POWER_UPDATE", "SkinTargetStatus")
  end
  paintFrame(_G.TargetFrame, unitFor(_G.TargetFrameHealthBar or {}, "target"))
  paintFrame(_G.FocusFrame, unitFor(_G.FocusFrameHealthBar or {}, "focus"))
  watch(_G.TargetFrameHealthBar)
  watch(_G.TargetFrameManaBar)
  watch(_G.FocusFrameHealthBar)
  watch(_G.FocusFrameManaBar)
end

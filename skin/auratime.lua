--[[
  Purpose: Show remaining time on Target Frame and Focus Frame auras.
  Classic 1.15 UnitAura already returns duration. Native Duration text stays hidden.
  Player BuffFrame keeps Blizzard text.
  Deps: C_UnitAuras or UnitAura, ShadowUI:SkinAuraButton()
  Public: ShadowUI:AuraDurationState(), ShadowUI:FormatShortDuration(),
          ShadowUI:SkinAuraDuration()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:AuraDurationState(now, duration, expirationTime)
  if not now or type(duration) ~= "number" or duration <= 0 or type(expirationTime) ~= "number" then
    return nil
  end
  local remaining = expirationTime - now
  if remaining <= 0 then
    return nil
  end
  return {
    remaining = remaining,
    duration = duration,
    startTime = expirationTime - duration,
  }
end

function Addon:FormatShortDuration(remaining)
  if not remaining or remaining <= 0 then
    return nil
  end
  if remaining >= 3600 then
    return string.format("%dh", math.floor(remaining / 3600 + 0.5))
  end
  if remaining >= 60 then
    return string.format("%dm", math.floor(remaining / 60 + 0.5))
  end
  return string.format("%d", math.ceil(remaining - 1e-6))
end

local function auraIcon(button, name)
  return button.Icon or button.icon or (name and _G[name .. "Icon"])
end

local function isUnitAuraButton(name, button)
  if button.unit == "target" or button.unit == "focus" then
    return button.unit
  end
  if not name then
    return nil
  end
  if name:find("TargetFrame", 1, true) then
    return "target"
  end
  if name:find("FocusFrame", 1, true) then
    return "focus"
  end
  return nil
end

local function auraFilter(name, button)
  if button.auraType == "Debuff" or button.auraType == "DeadlyDebuff" then
    return "HARMFUL"
  end
  if name and name:find("Debuff", 1, true) then
    return "HARMFUL"
  end
  return "HELPFUL"
end

local function auraIndex(name, button)
  if button.index then
    return button.index
  end
  if button.auraIndex then
    return button.auraIndex
  end
  if not name then
    return nil
  end
  return tonumber(name:match("(%d+)$"))
end

local function auraTimes(duration, expirationTime, fallbackDuration, fallbackExpiration)
  if type(duration) == "number" and type(expirationTime) == "number" then
    return duration, expirationTime
  end
  if type(fallbackDuration) == "number" and type(fallbackExpiration) == "number" then
    return fallbackDuration, fallbackExpiration
  end
end

local function readDuration(button, name, unit)
  if type(button.duration) == "number" and type(button.expirationTime) == "number" then
    return button.duration, button.expirationTime
  end
  if button.auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID then
    local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, button.auraInstanceID)
    if data then
      return auraTimes(data.duration, data.expirationTime)
    end
  end
  local index = auraIndex(name, button)
  if not index then
    return nil
  end
  local filter = auraFilter(name, button)
  if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
    local data = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
    if data then
      return auraTimes(data.duration, data.expirationTime)
    end
    return nil
  end
  if not UnitAura then
    return nil
  end
  -- 1.15 has no rank slot. Vanilla put duration at the next index.
  local _, _, _, _, duration, expirationTime, rankExpiration = UnitAura(unit, index, filter)
  return auraTimes(duration, expirationTime, expirationTime, rankExpiration)
end

local function hideNativeCount(region)
  if region and region.SetHideCountdownNumbers then
    region:SetHideCountdownNumbers(true)
  end
end

local function hideNativeDuration(button, name)
  local nativeTime = button.Duration or (name and _G[name .. "Duration"])
  if nativeTime and nativeTime.Hide then
    nativeTime:Hide()
  end
  hideNativeCount(button.Cooldown or button.cooldown or (name and _G[name .. "Cooldown"]))
end

function Addon:SkinAuraDuration(button)
  if not button then
    return
  end
  local name = button.GetName and button:GetName()
  local unit = isUnitAuraButton(name, button)
  if not unit then
    return
  end
  hideNativeDuration(button, name)
  local now = GetTime and GetTime() or 0
  local state = self:AuraDurationState(now, readDuration(button, name, unit))
  local icon = auraIcon(button, name)
  local cooldown = button.shadowUIAuraCooldown
  if not state then
    if cooldown and cooldown.Hide then
      cooldown:Hide()
    end
    if button.shadowUIAuraTime and button.shadowUIAuraTime.Hide then
      button.shadowUIAuraTime:Hide()
    end
    return
  end
  if not cooldown and CreateFrame then
    cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.shadowUIAuraCooldown = cooldown
    if cooldown.SetAllPoints then
      cooldown:SetAllPoints(icon or button)
    end
    if cooldown.SetReverse then
      cooldown:SetReverse(true)
    end
    if cooldown.SetDrawEdge then
      cooldown:SetDrawEdge(false)
    end
  end
  hideNativeCount(cooldown)
  if cooldown then
    if cooldown.SetCooldown then
      cooldown:SetCooldown(state.startTime, state.duration)
    elseif CooldownFrame_Set then
      CooldownFrame_Set(cooldown, state.startTime, state.duration, true)
    end
    if cooldown.Show then
      cooldown:Show()
    end
  end
  local fs = button.shadowUIAuraTime
  if not fs and button.CreateFontString then
    fs = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    button.shadowUIAuraTime = fs
    if fs.SetPoint then
      fs:SetPoint("CENTER", icon or button, "CENTER", 0, 0)
    end
  end
  if not fs then
    return
  end
  fs:SetText(self:FormatShortDuration(state.remaining))
  if fs.Show then
    fs:Show()
  end
end

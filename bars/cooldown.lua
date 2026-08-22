--[[
  Purpose: Paint remaining cooldown seconds on ShadowUI action buttons (OmniCC gap).
  The GCD swipe stays. Counts hide below 2s so GCD has no number.
  Deps: LibActionButton cooldown region
  Public: ShadowUI:FormatCooldownCount(), ShadowUI:CooldownCountState(),
          ShadowUI:SkinCooldownCount()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local MIN_DURATION = 2

function Addon:FormatCooldownCount(remaining)
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

function Addon:CooldownCountState(now, startTime, duration, minDuration)
  minDuration = minDuration or MIN_DURATION
  if not now or not startTime or not duration or duration < minDuration then
    return nil
  end
  local remaining = startTime + duration - now
  if remaining <= 0 then
    return nil
  end
  return {
    remaining = remaining,
    text = self:FormatCooldownCount(remaining),
  }
end

local function paint(button, cooldown)
  local fs = button.shadowUICooldownCount
  local startTime = cooldown.shadowUIStart
  local duration = cooldown.shadowUIDuration
  local now = GetTime and GetTime() or 0
  local state = Addon:CooldownCountState(now, startTime, duration)
  if not state then
    if fs and fs.Hide then
      fs:Hide()
    end
    return
  end
  if not fs then
    return
  end
  fs:SetText(state.text)
  if fs.Show then
    fs:Show()
  end
end

function Addon:SkinCooldownCount(button)
  local cooldown = button and button.cooldown
  if not cooldown then
    return
  end
  if cooldown.SetHideCountdownNumbers then
    cooldown:SetHideCountdownNumbers(true)
  end
  if not button.shadowUICooldownCount and button.CreateFontString then
    local fs = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    button.shadowUICooldownCount = fs
    if fs.SetPoint then
      fs:SetPoint("CENTER", cooldown, "CENTER", 0, 0)
    end
  end
  if cooldown.shadowUICountHooked then
    return
  end
  cooldown.shadowUICountHooked = true
  if cooldown.SetCooldown and hooksecurefunc then
    hooksecurefunc(cooldown, "SetCooldown", function(self, startTime, duration)
      self.shadowUIStart = startTime
      self.shadowUIDuration = duration
    end)
  end
  if cooldown.SetScript then
    cooldown:SetScript("OnUpdate", function(self)
      paint(self:GetParent() or button, self)
    end)
  end
end

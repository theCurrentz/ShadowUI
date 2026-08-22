--[[
  Purpose: Clock square on the minimap. It shows realm time. Hover shows realm
           time and local time. A click opens the Stopwatch. GameTimeFrame
           (day/night) stays hidden.
  Deps: ShadowUI:ApplyOuterChrome()
  Public: ShadowUI:SkinTime()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local CLOCK_SIZE = 36
local FONT = "Fonts\\FRIZQT__.TTF"
local FONT_SIZE = 9
local GOLD = { 1, 0.82, 0 }
local WHITE = { 1, 1, 1 }

local clock
local stopwatch

local function hideStay(frame)
  if not frame then
    return
  end
  if frame.Hide then
    frame:Hide()
  end
  if frame.Show then
    frame.Show = frame.Hide
  end
end

local function hideBlizzardTime()
  hideStay(_G.GameTimeFrame)
  hideStay(_G.GameTimeTexture)
  hideStay(_G.TimeManagerClockButton)
  hideStay(_G.TimeManagerClockTicker)
end

local function formatClock(hour, minute, wantAMPM)
  hour = tonumber(hour) or 0
  minute = tonumber(minute) or 0
  local suffix = " AM"
  local h = hour % 24
  if h >= 12 then
    suffix = " PM"
  end
  if h == 0 then
    h = 12
  elseif h > 12 then
    h = h - 12
  end
  local text = string.format("%d:%02d", h, minute)
  if wantAMPM then
    return text .. suffix
  end
  return text
end

local function realmHourMinute()
  if GetGameTime then
    return GetGameTime()
  end
  return 0, 0
end

local function localHourMinute()
  if date then
    local t = date("*t")
    if type(t) == "table" then
      return t.hour, t.min
    end
  end
  return realmHourMinute()
end

local function realmText(wantAMPM)
  if GameTime_GetGameTime then
    return GameTime_GetGameTime(wantAMPM)
  end
  if GameTime_GetTime then
    return GameTime_GetTime(wantAMPM)
  end
  local hour, minute = realmHourMinute()
  return formatClock(hour, minute, wantAMPM)
end

local function localText(wantAMPM)
  if GameTime_GetLocalTime then
    return GameTime_GetLocalTime(wantAMPM)
  end
  local hour, minute = localHourMinute()
  return formatClock(hour, minute, wantAMPM)
end

local function paintClock()
  if not clock or not clock.text or not clock.text.SetText then
    return
  end
  local text = realmText(false)
  if text == clock.lastText then
    return
  end
  clock.lastText = text
  clock.text:SetText(text)
end

local function showTimeTooltip(host)
  if not GameTooltip then
    return
  end
  if GameTooltip.SetOwner then
    GameTooltip:SetOwner(host, "ANCHOR_BOTTOMLEFT")
  end
  if GameTooltip.ClearLines then
    GameTooltip:ClearLines()
  end
  if GameTime_UpdateTooltip then
    GameTime_UpdateTooltip()
  else
    if GameTooltip.AddLine then
      GameTooltip:AddLine("Time Info", WHITE[1], WHITE[2], WHITE[3])
    end
    if GameTooltip.AddDoubleLine then
      GameTooltip:AddDoubleLine(
        "Realm time", realmText(true),
        GOLD[1], GOLD[2], GOLD[3], WHITE[1], WHITE[2], WHITE[3]
      )
      GameTooltip:AddDoubleLine(
        "Local time", localText(true),
        GOLD[1], GOLD[2], GOLD[3], WHITE[1], WHITE[2], WHITE[3]
      )
    end
  end
  if GameTooltip.Show then
    GameTooltip:Show()
  end
end

local function hideTimeTooltip()
  if GameTooltip and GameTooltip.Hide then
    GameTooltip:Hide()
  end
end

local function formatElapsed(seconds)
  seconds = math.max(0, math.floor(seconds + 0.5))
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor(seconds / 60) % 60
  local secs = seconds % 60
  if hours > 0 then
    return string.format("%d:%02d:%02d", hours, minutes, secs)
  end
  return string.format("%d:%02d", minutes, secs)
end

local function stopwatchElapsed(frame)
  local total = frame.accumulated or 0
  if frame.running and GetTime then
    total = total + (GetTime() - (frame.startedAt or 0))
  end
  return total
end

local function paintStopwatch(frame)
  if not frame or not frame.time or not frame.time.SetText then
    return
  end
  frame.time:SetText(formatElapsed(stopwatchElapsed(frame)))
end

local function playPauseStopwatch(frame)
  if not GetTime then
    return
  end
  if frame.running then
    frame.accumulated = stopwatchElapsed(frame)
    frame.running = false
  else
    frame.startedAt = GetTime()
    frame.running = true
  end
  paintStopwatch(frame)
end

local function resetStopwatch(frame)
  frame.running = false
  frame.accumulated = 0
  frame.startedAt = 0
  paintStopwatch(frame)
end

local function makeText(host, template, size)
  if not host or not host.CreateFontString then
    return nil
  end
  local fs = host:CreateFontString(nil, "OVERLAY", template)
  if fs.SetFont then
    pcall(fs.SetFont, fs, FONT, size, "OUTLINE")
  end
  if fs.SetJustifyH then
    fs:SetJustifyH("CENTER")
  end
  if fs.SetTextColor then
    fs:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
  end
  return fs
end

local function ensureStopwatch()
  if stopwatch then
    return stopwatch
  end
  local frame = CreateFrame("Button", "ShadowUIStopwatch", UIParent)
  stopwatch = frame
  frame:SetSize(132, 40)
  if clock then
    frame:SetPoint("TOPRIGHT", clock, "BOTTOMRIGHT", 0, -4)
  else
    frame:SetPoint("TOP", UIParent, "TOP", 0, -80)
  end
  if frame.SetFrameStrata then
    frame:SetFrameStrata("HIGH")
  end
  if frame.SetFrameLevel then
    frame:SetFrameLevel(20)
  end
  if frame.EnableMouse then
    frame:EnableMouse(true)
  end
  local fill = frame:CreateTexture(nil, "BACKGROUND")
  frame.shadowUIBackdrop = fill
  fill:SetAllPoints(frame)
  fill:SetColorTexture(0.05, 0.05, 0.05, 0.95)
  Addon:ApplyOuterChrome(frame)
  local title = makeText(frame, "GameFontNormalSmall", 10)
  if title then
    title:SetPoint("TOP", frame, "TOP", 0, -4)
    if title.SetTextColor then
      title:SetTextColor(GOLD[1], GOLD[2], GOLD[3], 1)
    end
    title:SetText("Stopwatch")
    frame.title = title
  end
  local time = makeText(frame, "GameFontHighlightSmall", 12)
  if time then
    time:SetPoint("BOTTOM", frame, "BOTTOM", 0, 6)
    frame.time = time
  end
  resetStopwatch(frame)
  if frame.SetMovable then
    frame:SetMovable(true)
  end
  if frame.RegisterForDrag then
    frame:RegisterForDrag("LeftButton")
  end
  if frame.RegisterForClicks then
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  end
  if frame.SetScript then
    frame:SetScript("OnDragStart", function(self)
      if self.StartMoving then
        self:StartMoving()
      end
    end)
    frame:SetScript("OnDragStop", function(self)
      if self.StopMovingOrSizing then
        self:StopMovingOrSizing()
      end
    end)
    frame:SetScript("OnClick", function(self, button)
      if button == "RightButton" then
        resetStopwatch(self)
      else
        playPauseStopwatch(self)
      end
    end)
    frame:SetScript("OnEnter", function(self)
      if not GameTooltip then
        return
      end
      if GameTooltip.SetOwner then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
      end
      if GameTooltip.ClearLines then
        GameTooltip:ClearLines()
      end
      if GameTooltip.AddLine then
        GameTooltip:AddLine("Left click: start or pause", WHITE[1], WHITE[2], WHITE[3])
        GameTooltip:AddLine("Right click: reset", WHITE[1], WHITE[2], WHITE[3])
      end
      if GameTooltip.Show then
        GameTooltip:Show()
      end
    end)
    frame:SetScript("OnLeave", hideTimeTooltip)
    frame:SetScript("OnUpdate", function(self)
      if self.running then
        paintStopwatch(self)
      end
    end)
  end
  if frame.Hide then
    frame:Hide()
  end
  return frame
end

local function toggleStopwatch()
  local frame = ensureStopwatch()
  if frame.IsShown and frame:IsShown() then
    frame:Hide()
    return
  end
  if frame.Show then
    frame:Show()
  end
  paintStopwatch(frame)
end

local function ensureClock()
  if clock then
    return clock
  end
  if not Minimap or not CreateFrame then
    return nil
  end
  clock = CreateFrame("Button", "ShadowUIMinimapClock", Minimap)
  clock:SetSize(CLOCK_SIZE, CLOCK_SIZE)
  if clock.SetFrameStrata then
    clock:SetFrameStrata("MEDIUM")
  end
  if clock.SetFrameLevel then
    clock:SetFrameLevel(8)
  end
  if clock.EnableMouse then
    clock:EnableMouse(true)
  end
  local fill = clock:CreateTexture(nil, "BACKGROUND")
  clock.shadowUIBackdrop = fill
  fill:SetAllPoints(clock)
  fill:SetColorTexture(0.05, 0.05, 0.05, 0.95)
  Addon:ApplyOuterChrome(clock)
  local text = makeText(clock, "GameFontHighlightSmall", FONT_SIZE)
  if text then
    text:SetPoint("CENTER", clock, "CENTER", 0, 0)
    clock.text = text
  end
  if clock.RegisterForClicks then
    clock:RegisterForClicks("LeftButtonUp")
  end
  if clock.SetScript then
    clock:SetScript("OnEnter", function(self)
      showTimeTooltip(self)
    end)
    clock:SetScript("OnLeave", hideTimeTooltip)
    clock:SetScript("OnClick", toggleStopwatch)
    clock:SetScript("OnUpdate", paintClock)
  end
  paintClock()
  return clock
end

function Addon:SkinTime()
  hideBlizzardTime()
  local timeFrame = ensureClock()
  if not timeFrame or not timeFrame.SetPoint or not Minimap then
    return
  end
  if timeFrame.SetParent then
    timeFrame:SetParent(Minimap)
  end
  if timeFrame.ClearAllPoints then
    timeFrame:ClearAllPoints()
  end
  timeFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -2, 2)
  if timeFrame.Show then
    timeFrame:Show()
  end
  paintClock()
  ensureStopwatch()
  hideBlizzardTime()
end

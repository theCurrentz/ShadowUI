--[[
  Purpose: Restyle Blizzard Time (TimeManagerClockButton) the SexyMap way on
           the square minimap. Hide the clock border. Size the chip to the
           ticker. Park it under the map. Hover keeps GameTime_UpdateTooltip
           (realm time and local time). A click keeps the Blizzard Stopwatch.
           GameTimeFrame (day/night) stays hidden.
  Deps: none
  Public: ShadowUI:SkinTime()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local FILL = { 0.05, 0.05, 0.05, 0.95 }
local PAD_X = 12
local PAD_Y = 10
local MEASURE = "44:44"
local LEVEL = 4000

-- SexyMap calls Frame methods from a dummy so hooked Minimap/button methods
-- do not recurse.
local proto = CreateFrame and CreateFrame("Frame")
local protoButton = CreateFrame and CreateFrame("Button")
local protoFont = protoButton and protoButton.CreateFontString
  and protoButton:CreateFontString()
local placing

local function native(host, method, ...)
  local fn = proto and proto[method]
  if not fn and protoButton then
    fn = protoButton[method]
  end
  if fn then
    return fn(host, ...)
  end
  if host and host[method] then
    return host[method](host, ...)
  end
end

local function nativeFont(host, method, ...)
  local fn = protoFont and protoFont[method]
  if fn then
    return fn(host, ...)
  end
  if host and host[method] then
    return host[method](host, ...)
  end
end

local function hideStay(frame)
  if frame and frame.Hide then
    frame:Hide()
    frame.Show = frame.Hide
  end
end

local function hideBlizzardDayNight()
  hideStay(_G.GameTimeFrame)
  hideStay(_G.GameTimeTexture)
end

local function hideClockArt(clock)
  local text = _G.TimeManagerClockTicker
  if not clock or not clock.GetRegions then
    return
  end
  local regions = { clock:GetRegions() }
  for i = 1, #regions do
    local region = regions[i]
    if region and region ~= text and region ~= clock.shadowUIBackdrop and region.Hide then
      region:Hide()
    end
  end
end

local function ensureFill(clock)
  if clock.shadowUIBackdrop then
    return clock.shadowUIBackdrop
  end
  if not clock.CreateTexture then
    return nil
  end
  local fill = clock:CreateTexture(nil, "BACKGROUND")
  clock.shadowUIBackdrop = fill
  if fill.SetAllPoints then
    fill:SetAllPoints(clock)
  end
  if fill.SetColorTexture then
    fill:SetColorTexture(FILL[1], FILL[2], FILL[3], FILL[4])
  end
  return fill
end

local function sizeToTicker(clock)
  local text = _G.TimeManagerClockTicker
  if not clock or not text then
    return
  end
  nativeFont(text, "ClearAllPoints")
  nativeFont(text, "SetAllPoints")
  local prior = text.GetText and text:GetText()
  nativeFont(text, "SetText", MEASURE)
  local width = PAD_X + ((text.GetUnboundedStringWidth and text:GetUnboundedStringWidth())
    or (text.GetStringWidth and text:GetStringWidth()) or 36)
  local height = PAD_Y + ((text.GetStringHeight and text:GetStringHeight()) or 10)
  native(clock, "SetWidth", width)
  native(clock, "SetHeight", height)
  if prior then
    nativeFont(text, "SetText", prior)
  end
end

local function parkClock(clock)
  if placing or not clock or not Minimap then
    return
  end
  placing = true
  native(clock, "SetParent", Minimap)
  native(clock, "ClearAllPoints")
  native(clock, "SetPoint", "TOP", Minimap, "BOTTOM", 0, 0)
  placing = false
end

local function watchClock(clock)
  if clock._shadowUITime then
    return
  end
  clock._shadowUITime = true
  if hooksecurefunc then
    hooksecurefunc(clock, "Hide", function()
      native(clock, "Show")
    end)
    hooksecurefunc(clock, "SetPoint", function()
      if not placing then parkClock(clock) end
    end)
    hooksecurefunc(clock, "SetParent", function()
      if not placing then parkClock(clock) end
    end)
  end
  local attach = clock.HookScript or clock.SetScript
  if attach then
    attach(clock, "OnEnter", function()
      local tip = _G.GameTooltip
      if not tip or not _G.GameTime_UpdateTooltip then
        return
      end
      if tip.SetOwner then
        tip:SetOwner(clock, "ANCHOR_LEFT")
      end
      if tip.ClearLines then
        tip:ClearLines()
      end
      _G.GameTime_UpdateTooltip()
      if tip.Show then
        tip:Show()
      end
    end)
    attach(clock, "OnLeave", function()
      local tip = _G.GameTooltip
      if tip and tip.Hide then
        tip:Hide()
      end
    end)
  end
end

function Addon:SkinTime()
  hideBlizzardDayNight()
  local clock = _G.TimeManagerClockButton
  if not clock then
    return
  end
  hideClockArt(clock)
  ensureFill(clock)
  native(clock, "SetFrameStrata", "LOW")
  native(clock, "SetFrameLevel", LEVEL)
  if clock.SetFixedFrameStrata then
    native(clock, "SetFixedFrameStrata", true)
  end
  if clock.SetFixedFrameLevel then
    native(clock, "SetFixedFrameLevel", true)
  end
  if clock.SetClampedToScreen then
    native(clock, "SetClampedToScreen", true)
  end
  if clock.SetClampRectInsets then
    native(clock, "SetClampRectInsets", 4, -4, -4, 4)
  end
  sizeToTicker(clock)
  parkClock(clock)
  watchClock(clock)
  if clock.EnableMouse then
    clock:EnableMouse(true)
  end
  native(clock, "Show")
  hideBlizzardDayNight()
end

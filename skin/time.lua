--[[
  Purpose: Keep Blizzard Time on the Forever minimap cluster header.
           Hover shows GameTime_UpdateTooltip (realm time and local time).
           A click keeps the Blizzard Stopwatch. GameTimeFrame is the calendar
           and stays on the header.
  Deps: none
  Public: ShadowUI:SkinTime()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local proto = CreateFrame and CreateFrame("Frame")
local protoButton = CreateFrame and CreateFrame("Button")
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

local function useShadowUIMinimap()
  local get = Addon.GetCharDB
  if not get then
    return true
  end
  local char = get(Addon)
  return not char or char.useShadowUIMinimap ~= false
end

local function watchClock(clock)
  if clock._shadowUITime then
    return
  end
  clock._shadowUITime = true
  local attach = clock.HookScript or clock.SetScript
  if not attach then
    return
  end
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

function Addon:SkinTime()
  if not useShadowUIMinimap() then
    return
  end
  local clock = _G.TimeManagerClockButton
  if not clock then
    return
  end
  watchClock(clock)
  if clock.EnableMouse then
    clock:EnableMouse(true)
  end
  native(clock, "Show")
end

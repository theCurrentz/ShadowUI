--[[
  Purpose: Keep Blizzard Status Text on the Target Frame.
  Hide any leftover ShadowUI health or mana caption so native text cannot stack.
  Public: ShadowUI:SkinTargetStatus()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

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

local function clearBar(bar)
  local fs = bar and bar.shadowUIStatusText
  if not fs then
    return
  end
  if fs.SetText then
    fs:SetText("")
  end
  if fs.Hide then
    fs:Hide()
  end
end

local function clearFrame(frame)
  if not frame then
    return
  end
  clearBar(namedBar(frame, "HealthBar"))
  clearBar(namedBar(frame, "ManaBar") or namedBar(frame, "PowerBar"))
end

function Addon:SkinTargetStatus()
  clearFrame(_G.TargetFrame)
  clearFrame(_G.FocusFrame)
end

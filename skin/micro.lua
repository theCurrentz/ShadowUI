--[[
  Purpose: Leave the Blizzard micro menu and bag bar in place.
           Shadow only those bar borders with an Outer Edge.
           Do not move, hide, reparent, or strip buttons or tray art.
  Deps: ShadowUI:ApplyOuterChrome()
  Public: ShadowUI:MicroBarFrames(), ShadowUI:SkinMicroAndBags()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:MicroBarFrames()
  local frames = {}
  local menu = _G.MicroMenuContainer or _G.MicroMenu
  if menu then
    frames[#frames + 1] = menu
  end
  if _G.BagsBar then
    frames[#frames + 1] = _G.BagsBar
  end
  if #frames == 0 and _G.MicroButtonAndBagsBar then
    frames[1] = _G.MicroButtonAndBagsBar
  end
  return frames
end

local function useShadow()
  local get = Addon.GetCharDB
  if not get then
    return true
  end
  local char = get(Addon)
  return not char or char.useShadowUIMenu ~= false
end

local function hideOuter(host)
  if host and host.shadowUIOuter and host.shadowUIOuter.Hide then
    host.shadowUIOuter:Hide()
  end
end

function Addon:SkinMicroAndBags()
  local frames = self:MicroBarFrames()
  if not useShadow() then
    for _, frame in ipairs(frames) do
      hideOuter(frame)
    end
  else
    for _, frame in ipairs(frames) do
      if self.ApplyOuterChrome then
        self:ApplyOuterChrome(frame, "square")
      end
    end
  end
  if self.ApplyMicroFade then
    self:ApplyMicroFade()
  end
end

if hooksecurefunc then
  hooksecurefunc("UpdateMicroButtons", function()
    Addon:SkinMicroAndBags()
  end)
end

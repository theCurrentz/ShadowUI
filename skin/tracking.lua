--[[
  Purpose: Dock Blizzard XP and reputation bars at the top of the screen.
  Deps: MainMenuExpBar, ReputationWatchBar
  Public: ShadowUI:SkinTrackingBars()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local snapping

local function watch(button)
  if button._shadowUIWatch or not hooksecurefunc then
    return
  end
  button._shadowUIWatch = true
  hooksecurefunc(button, "SetPoint", function()
    if not snapping then
      Addon:SkinTrackingBars()
    end
  end)
  hooksecurefunc(button, "SetParent", function()
    if not snapping then
      Addon:SkinTrackingBars()
    end
  end)
end

local function isShown(frame)
  return not frame.IsShown or frame:IsShown()
end

local function place(bar, relative, relativePoint)
  watch(bar)
  bar:SetParent(UIParent)
  if bar.SetAlpha then
    bar:SetAlpha(1)
  end
  bar:ClearAllPoints()
  bar:SetPoint("TOP", relative, relativePoint, 0, 0)
  local width = UIParent.GetWidth and UIParent:GetWidth()
  if width and bar.SetWidth then
    bar:SetWidth(width)
  elseif width and bar.SetSize and bar.GetHeight then
    bar:SetSize(width, bar:GetHeight() or 13)
  end
end

function Addon:SkinTrackingBars()
  if self._skinTrackingThen then
    return
  end
  self._skinTrackingThen = true
  snapping = true

  local exp = _G.MainMenuExpBar
  local rep = _G.ReputationWatchBar
  local relative = UIParent
  local relativePoint = "TOP"

  if exp and isShown(exp) then
    place(exp, UIParent, "TOP")
    relative = exp
    relativePoint = "BOTTOM"
  end
  if rep and isShown(rep) then
    place(rep, relative, relativePoint)
  end

  snapping = nil
  self._skinTrackingThen = nil
end

local function restyle()
  Addon:SkinTrackingBars()
end

if hooksecurefunc then
  if MainMenuBar_UpdateExperienceBars then
    hooksecurefunc("MainMenuBar_UpdateExperienceBars", restyle)
  end
  if MainMenuTrackingBar_Configure then
    hooksecurefunc("MainMenuTrackingBar_Configure", restyle)
  end
  if UpdateMainMenuBarArt then
    hooksecurefunc("UpdateMainMenuBarArt", restyle)
  end
end

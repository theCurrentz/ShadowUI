--[[
  Purpose: Dock the Blizzard reputation bar at the top of the screen.
           Leave the Experience bar with Blizzard and give it a Lorti Outer Edge.
           Do not tint the fill, hide notches, hide Status Text, hide rested XP,
           or fade the bar.
  Deps: SecondaryStatusTrackingBarContainer; ReputationWatchBar fallback;
        MainStatusTrackingBarContainer; MainMenuExpBar fallback;
        ShadowUI:ApplyOuterChrome()
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

local function watchMethod(frame, method)
  if not frame or not frame[method] or not hooksecurefunc then
    return
  end
  local flag = "_shadowUIWatch_" .. method
  if frame[flag] then
    return
  end
  frame[flag] = true
  hooksecurefunc(frame, method, function()
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
  elseif width and bar.SetSize then
    bar:SetSize(width, (bar.GetHeight and bar:GetHeight()) or 13)
  end
end

local function buryOverlay(tex)
  if not tex or tex._shadowUIArtBury then
    return
  end
  tex._shadowUIArtBury = true
  if tex.Hide then
    tex:Hide()
  end
  if tex.SetAlpha then
    tex:SetAlpha(0)
  end
  if hooksecurefunc and tex.Show then
    hooksecurefunc(tex, "Show", function(self)
      if self.Hide then
        self:Hide()
      end
    end)
  end
  if hooksecurefunc and tex.SetShown then
    hooksecurefunc(tex, "SetShown", function(self, shown)
      if shown and self.Hide then
        self:Hide()
      end
    end)
  end
end

local function buryContainerArt(container)
  if not container then
    return
  end
  local lists = { container.MainMenuBarTextures, container.StandaloneTextures }
  for i = 1, #lists do
    local list = lists[i]
    if list then
      for j = 1, #list do
        buryOverlay(list[j])
      end
    end
  end
end

local function edgeXP(frame)
  if frame and Addon.ApplyOuterChrome then
    Addon:ApplyOuterChrome(frame, "square")
  end
end

function Addon:SkinTrackingBars()
  if self._skinTrackingThen then
    return
  end
  self._skinTrackingThen = true
  snapping = true

  local main = _G.MainStatusTrackingBarContainer
  local secondary = _G.SecondaryStatusTrackingBarContainer
  local exp = _G.MainMenuExpBar
  local rep = _G.ReputationWatchBar

  local mgr = _G.StatusTrackingBarManager
  if mgr then
    watch(mgr)
    watchMethod(mgr, "UpdateBarVisuals")
    watchMethod(mgr, "UpdateBarsShown")
    -- SetAlpha on StatusTrackingBarManager raises ADDON_ACTION_FORBIDDEN.
  end

  if main then
    edgeXP(main)
  elseif exp then
    edgeXP(exp)
  end

  if secondary and isShown(secondary) then
    place(secondary, UIParent, "TOP")
    buryContainerArt(secondary)
  elseif rep and isShown(rep) then
    place(rep, UIParent, "TOP")
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
  if MainMenuExpBar_SetWidth then
    hooksecurefunc("MainMenuExpBar_SetWidth", restyle)
  end
end

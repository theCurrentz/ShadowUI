--[[
  Purpose: On Forever, skin Blizzard ActionButtons in place. Do not create
           LibActionButton Bars. Do not SetPoint, Hide, or EnableMouse on
           those hosts. Chrome is a blackened slot rim, dimmed empty-slot
           art, and Outer Edge. The icon, IconMask, cooldowns, glows, Flash,
           equipped Border, and spell alerts stay native.
           Empty slots follow Blizzard show state so Outer Edge does not stay.
           Do not write keys on those hosts or replace Blizzard action-button
           globals (ActionButton_UpdateCooldown). Blizzard Update reads them;
           taint there stops ACTIONBAR_SHOWGRID from showing empty slots, so a
           drop on an empty slot clicks through to the world.
  Deps: ShadowUI:SkinBarButton()
  Public: ShadowUI:SkinBlizzardActionBars()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local GROUPS = {
  { "ActionButton", 12 },
  { "MultiBarBottomLeftButton", 12 },
  { "MultiBarBottomRightButton", 12 },
  { "MultiBarRightButton", 12 },
  { "MultiBarLeftButton", 12 },
  { "MultiBar5Button", 12 },
  { "MultiBar6Button", 12 },
  { "MultiBar7Button", 12 },
  { "PetActionButton", 10 },
  { "StanceButton", 10 },
  { "ShapeshiftButton", 10 },
  { "OverrideActionBarButton", 6 },
}

local function eachButton(fn)
  for _, group in ipairs(GROUPS) do
    local prefix, count = group[1], group[2]
    for i = 1, count do
      local button = _G[prefix .. i]
      if button then
        fn(button, prefix, i)
      end
    end
  end
end

function Addon:SkinBlizzardActionBars()
  -- Do not Hide, SetAlpha, SetParent, or SetPoint on default action hosts
  -- or MainMenuBar art. pcall still pops ADDON_ACTION_FORBIDDEN.
  eachButton(function(button)
    if self.SkinBarButton then
      self:SkinBarButton(button)
    end
  end)
  if self.RegisterEvent and not self._blizzardActionBarEvents then
    self._blizzardActionBarEvents = true
    pcall(self.RegisterEvent, self, "ACTIONBAR_PAGE_CHANGED", "SkinBlizzardActionBars")
    pcall(self.RegisterEvent, self, "ACTIONBAR_SLOT_CHANGED", "SkinBlizzardActionBars")
    pcall(self.RegisterEvent, self, "UPDATE_SHAPESHIFT_FORM", "SkinBlizzardActionBars")
    pcall(self.RegisterEvent, self, "EDIT_MODE_LAYOUTS_UPDATED", "SkinBlizzardActionBars")
  end
end

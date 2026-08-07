--[[
  Purpose: Enlarge and square the Blizzard minimap.
  Deps: Blizzard minimap frames
  Public: ShadowUI:SkinMinimap()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local ART = {
  "MinimapBorder",
  "MinimapBorderTop",
  "MinimapNorthTag",
  "MiniMapTrackingBackground",
  "MiniMapMailBorder",
}

function Addon:SkinMinimap()
  if not Minimap or not MinimapCluster then
    return
  end

  MinimapCluster:ClearAllPoints()
  MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
  MinimapCluster:SetSize(250, 250)

  Minimap:ClearAllPoints()
  Minimap:SetAllPoints(MinimapCluster)
  Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")

  local backdrop = MinimapCluster.shadowUIBackdrop
  if not backdrop then
    backdrop = MinimapCluster:CreateTexture(nil, "BACKGROUND", nil, -8)
    MinimapCluster.shadowUIBackdrop = backdrop
  end
  backdrop:ClearAllPoints()
  backdrop:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -4, 4)
  backdrop:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 4, -4)
  backdrop:SetColorTexture(0, 0, 0, 0.9)

  for _, name in ipairs(ART) do
    local region = _G[name]
    if region then
      region:Hide()
    end
  end
end

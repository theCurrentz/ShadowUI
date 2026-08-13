--[[
  Purpose: Apply shared matte chrome to ShadowUI action bars.
  Deps: ShadowUI bars
  Public: ShadowUI:ApplyBarChrome(), ShadowUI:SkinBarChrome(), ShadowUI:ApplySkins()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local BACKDROP = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
}

function Addon:ApplyBarChrome(bar)
  if self:GetTheme() == "glass" then
    self:ApplyGlassPanel(bar)
    if bar.shadow then
      bar.shadow:ClearAllPoints()
      bar.shadow:SetPoint("TOPLEFT", bar, "TOPLEFT", -4, 4)
      bar.shadow:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 4, -4)
      bar.shadow:SetColorTexture(0, 0, 0, 0.28)
      bar.shadow:Show()
    end
    return
  end
  self:ClearGlassPanel(bar)
  bar:SetBackdrop(BACKDROP)
  bar:SetBackdropColor(0, 0, 0, 1)

  local shadow = bar.shadow
  if not shadow then
    shadow = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    bar.shadow = shadow
  end
  shadow:ClearAllPoints()
  shadow:SetPoint("TOPLEFT", bar, "TOPLEFT", -4, 4)
  shadow:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 4, -4)
  shadow:SetColorTexture(0, 0, 0, 0.35)
  shadow:Show()
end

function Addon:SkinBarChrome()
  for _, bar in pairs(self.bars or {}) do
    self:ApplyBarChrome(bar)
  end
end

function Addon:ApplySkins()
  -- Micro and bag buttons are protected; reparenting them in combat taints.
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  self:SkinBarChrome()
  self:SkinChat()
  self:SkinMicroAndBags()
  self:SkinMinimap()
end

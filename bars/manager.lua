--[[
  Purpose: Apply resolved bar layouts and suppress Blizzard action bars.
  Deps: ShadowUI:CreateBar(), ShadowUI:CreateSpecialBar(), ShadowUI:UpdateBarLayout()
  Public: ShadowUI:ApplyBars(), ShadowUI:HideBlizzardBars()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local SHAPESHIFT_IDS = { aura = true, form = true, stance = true }
local SHAPESHIFT_CLASSES = {
  DRUID = true, PALADIN = true, PRIEST = true,
  ROGUE = true, SHAMAN = true, WARRIOR = true,
}
local PET_CLASSES = { HUNTER = true, WARLOCK = true }
local BLIZZARD_BARS = {
  "MainMenuBar", "MainMenuBarArtFrame", "MainMenuBarOverlayFrame",
  "MainMenuBarMaxLevelBar", "MultiBarBottomLeft", "MultiBarBottomRight",
  "MultiBarLeft", "MultiBarRight", "PetActionBarFrame",
  "ShapeshiftBarFrame", "StanceBarFrame",
}
local OFFSCREEN = -1500

local function supportsSpecialBar(id, classFile)
  if id == "possess" then
    return true
  end
  if id == "pet" then
    return PET_CLASSES[classFile] == true
  end
  if SHAPESHIFT_IDS[id] then
    return SHAPESHIFT_CLASSES[classFile] == true
  end
  return false
end

-- The possess buttons stay shown so "/click PossessButtonN" still resolves;
-- hiding the frame would make those clicks silently fail.
local function parkPossessBar()
  local frame = PossessBarFrame
  if not frame then
    return
  end
  frame:SetAlpha(0)
  frame:EnableMouse(false)
  frame:ClearAllPoints()
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", OFFSCREEN, OFFSCREEN)
end

function Addon:StartSpecialBarUpdates()
  if self.specialBarEvents then
    return
  end
  local frame = CreateFrame("Frame")
  for _, event in ipairs({
    "UPDATE_SHAPESHIFT_FORMS", "UPDATE_SHAPESHIFT_FORM",
    "PET_BAR_UPDATE", "UNIT_PET", "UPDATE_POSSESS_BAR",
  }) do
    pcall(frame.RegisterEvent, frame, event)
  end
  frame:SetScript("OnEvent", function(_, event, unit)
    if event ~= "UNIT_PET" or unit == "player" then
      Addon:RefreshSpecialBars()
    end
  end)
  self.specialBarEvents = frame
end

function Addon:HideBlizzardBars()
  for _, name in ipairs(BLIZZARD_BARS) do
    local frame = _G[name]
    if frame then
      frame:UnregisterAllEvents()
      frame:Hide()
      frame:SetScript("OnShow", frame.Hide)
    end
  end
  parkPossessBar()
end

function Addon:ApplyBars(cfg)
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  if SetActionBarToggles then
    SetActionBarToggles(1, 1, 1, 1, 1)
  end
  self:HideBlizzardBars()
  self.bars = self.bars or {}

  local classFile = self:GetPlayerClass()
  for barId, barCfg in pairs(cfg.layout or {}) do
    local standard = barId:match("^bar%d+$") ~= nil
    local supported = standard or supportsSpecialBar(barId, classFile)
    local enabled = barCfg.enabled ~= false and supported
    local bar = self.bars[barId]

    if enabled then
      if not bar then
        bar = standard
          and self:CreateBar(barId, barCfg)
          or self:CreateSpecialBar(barId, barCfg)
        self.bars[barId] = bar
      end
      bar.configEnabled = true
      self:UpdateBarLayout(bar, barCfg)
      bar:Show()
    elseif bar then
      bar.configEnabled = false
      bar:Hide()
    end
  end

  self:StartSpecialBarUpdates()
  self:RefreshSpecialBars()
end

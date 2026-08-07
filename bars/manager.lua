--[[
  Purpose: Apply resolved bar layouts and suppress Blizzard action bars.
  Deps: ShadowUI:CreateBar(), ShadowUI:CreateSpecialBar(), ShadowUI:UpdateBarLayout()
  Public: ShadowUI:ApplyBars(), ShadowUI:HideBlizzardBars()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local SPECIAL_CLASSES = {
  aura = { PALADIN = true },
  form = { DRUID = true },
  pet = { HUNTER = true, WARLOCK = true },
  stance = { WARRIOR = true },
}

local function supportsSpecialBar(id, classFile)
  local classes = SPECIAL_CLASSES[id]
  return id == "possess" or classes and classes[classFile] == true
end

function Addon:StartSpecialBarUpdates()
  if self.specialBarEvents then
    return
  end
  local frame = CreateFrame("Frame")
  local events = {
    "UPDATE_SHAPESHIFT_FORMS", "UPDATE_SHAPESHIFT_FORM",
    "PET_BAR_UPDATE", "UNIT_PET", "UPDATE_POSSESS_BAR",
    "PLAYER_REGEN_ENABLED",
  }
  for _, event in ipairs(events) do
    frame:RegisterEvent(event)
  end
  frame:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_REGEN_ENABLED" then
      if Addon.pendingSpecialBarRefresh then
        Addon.pendingSpecialBarRefresh = nil
        Addon:RefreshSpecialBars()
      end
    elseif event ~= "UNIT_PET" or unit == "player" then
      Addon:RefreshSpecialBars()
    end
  end)
  self.specialBarEvents = frame
end

function Addon:HideBlizzardBars()
  for _, name in ipairs({
    "MainMenuBar",
    "MainMenuBarArtFrame",
    "MainMenuBarOverlayFrame",
    "MainMenuBarMaxLevelBar",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarLeft",
    "MultiBarRight",
    "PossessBarFrame",
    "PetActionBarFrame",
    "ShapeshiftBarFrame",
    "StanceBarFrame",
  }) do
    local frame = _G[name]
    if frame then
      frame:UnregisterAllEvents()
      frame:Hide()
      frame:SetScript("OnShow", frame.Hide)
    end
  end
end

function Addon:ApplyBars(cfg)
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

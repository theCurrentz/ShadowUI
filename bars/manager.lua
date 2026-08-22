--[[
  Purpose: Apply resolved bar layouts and suppress Blizzard and Bartender bars.
  Deps: ShadowUI:CreateBar(), ShadowUI:CreateSpecialBar(), ShadowUI:UpdateBarLayout(),
        ShadowUI:ApplyActionSlotLock()
  Public: ShadowUI:ApplyBars(), ShadowUI:HideBlizzardBars()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local SHAPESHIFT_IDS = { aura = true, form = true, stance = true }
local SHAPESHIFT_CLASSES = {
  DRUID = true, PALADIN = true, PRIEST = true,
  ROGUE = true, SHAMAN = true, WARRIOR = true,
}
local PET_CLASSES = { HUNTER = true, WARLOCK = true }
local HOST_LAYOUT = { player = true, target = true, cast = true, range = true }
local ART = {
  "MainMenuBarArtFrame",
  "MainMenuBarLeftEndCap",
  "MainMenuBarRightEndCap",
  "MainMenuBarTexture0",
  "MainMenuBarTexture1",
  "MainMenuBarTexture2",
  "MainMenuBarTexture3",
  "MainMenuBarTextureExtender",
  "MainMenuBarPageNumber",
  "MainMenuBarPerformanceBarFrame",
}
local BLIZZARD_BARS = {
  "MainMenuBarOverlayFrame",
  "MainMenuBarMaxLevelBar", "MultiBarBottomLeft", "MultiBarBottomRight",
  "MultiBarLeft", "MultiBarRight", "MultiBar5", "MultiBar6", "MultiBar7",
  "PetActionBarFrame", "ShapeshiftBarFrame", "StanceBarFrame",
  "BonusActionBarFrame", "ExtraActionBarFrame", "OverrideActionBar",
}
local BUTTON_PREFIXES = {
  "ActionButton", "BonusActionButton",
  "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
  "MultiBarLeftButton", "MultiBarRightButton",
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

local function hideFrame(frame)
  if not frame then
    return
  end
  pcall(frame.UnregisterAllEvents, frame)
  frame:Hide()
  pcall(frame.SetScript, frame, "OnShow", frame.Hide)
end

local function hideMainMenuArt()
  local get = Addon.GetCharDB
  if not get then
    return true
  end
  local char = get(Addon)
  return not char or char.useShadowUIMenu ~= false
end

local function hideActionButtons()
  for _, prefix in ipairs(BUTTON_PREFIXES) do
    for i = 1, 12 do
      hideFrame(_G[prefix .. i])
    end
  end
  for i = 1, 10 do
    hideFrame(_G["BT4Bar" .. i])
  end
  for _, name in ipairs(ART) do
    if name ~= "MainMenuBarArtFrame" or hideMainMenuArt() then
      hideFrame(_G[name])
    end
  end
end

local function hideExtraBlizzardBars()
  for _, name in ipairs(BLIZZARD_BARS) do
    hideFrame(_G[name])
  end
end

local function parkBlizzardMainMenu()
  local park = _G.ShadowUIBlizzardPark
  if not park then
    park = CreateFrame("Frame", "ShadowUIBlizzardPark", UIParent)
    park:Hide()
  end
  park:Hide()
  pcall(park.SetPoint, park, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", OFFSCREEN, OFFSCREEN)
  local bar = _G.MainMenuBar
  if not bar then
    return
  end
  pcall(bar.SetParent, bar, park)
  pcall(bar.EnableMouse, bar, false)
  pcall(bar.ClearAllPoints, bar)
  pcall(bar.SetPoint, bar, "BOTTOMLEFT", park, "BOTTOMLEFT", 0, 0)
  if bar.SetAlpha then
    bar:SetAlpha(0)
  end
  if bar.slideOut then
    pcall(bar.slideOut.Stop, bar.slideOut)
  end
end

local function suppressBlizzardActionBar()
  hideActionButtons()
  hideExtraBlizzardBars()
  parkBlizzardMainMenu()
end

local function hookBlizzardActionBar()
  if Addon._blizzardBarHooks or not hooksecurefunc then
    return
  end
  Addon._blizzardBarHooks = true
  if ActionBarController_UpdateAll then
    hooksecurefunc("ActionBarController_UpdateAll", suppressBlizzardActionBar)
  end
  if MultiActionBar_Update then
    hooksecurefunc("MultiActionBar_Update", hideActionButtons)
  end
  if ShapeshiftBar_Update then
    hooksecurefunc("ShapeshiftBar_Update", hideExtraBlizzardBars)
  end
  if StanceBar_Update then
    hooksecurefunc("StanceBar_Update", hideExtraBlizzardBars)
  end
  local bar = _G.MainMenuBar
  if bar then
    hooksecurefunc(bar, "Show", suppressBlizzardActionBar)
    hooksecurefunc(bar, "SetParent", function(_, parent)
      local park = _G.ShadowUIBlizzardPark
      if park and parent ~= park then
        suppressBlizzardActionBar()
      end
    end)
  end
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
  -- Extra Blizzard bars must stay off; (1,1,1,1,1) would re-show them.
  if SetActionBarToggles then
    SetActionBarToggles(0, 0, 0, 0, 0)
  end
  hideExtraBlizzardBars()
  if self.SkinMicroAndBags then
    self:SkinMicroAndBags()
  end
  if self.SkinTrackingBars then
    self:SkinTrackingBars()
  end
  suppressBlizzardActionBar()
  hookBlizzardActionBar()
  parkPossessBar()
end

function Addon:ApplyBars(cfg)
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  self.bars = self.bars or {}

  local classFile = self:GetPlayerClass()
  for barId, barCfg in pairs(cfg.layout or {}) do
    if not HOST_LAYOUT[barId] then
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
        if self.UpdateBarDragOverlay then
          self:UpdateBarDragOverlay(bar, false)
        end
      end
    end
  end

  -- Hide Blizzard bars only after ShadowUI bars exist. A create error must not
  -- leave the player with neither set.
  self:ApplyActionSlotLock()
  self:HideBlizzardBars()
  self:StartSpecialBarUpdates()
  self:RefreshSpecialBars()
end

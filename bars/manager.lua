--[[
  Purpose: Apply resolved bar layouts. Forever skins Blizzard ActionButtons
           in place. It does not Hide or SetAlpha default action hosts.
  Deps: ShadowUI:CreateBar(), ShadowUI:CreateSpecialBar(), ShadowUI:UpdateBarLayout(),
        ShadowUI:ApplyActionSlotLock(), ShadowUI:ParkFrame(),
        ShadowUI:ShowBarsForActionPlacement()
  Public: ShadowUI:ApplyBars(), ShadowUI:HideBlizzardBars(),
          ShadowUI:ParkBlizzardStanceBar(), ShadowUI:ShowBarsForActionPlacement()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local PET_CLASSES = { HUNTER = true, WARLOCK = true }
local SPECIAL_IDS = { "pet", "possess" }
local DROPPED_SPECIAL = { stance = true, aura = true, form = true }
local HOST_LAYOUT = {
  stance = true,
  global = true, barGroups = true,
}
local STANCE_PARK = { point = "CENTER", x = 0, y = -84 }
local STANCE_FRAMES = { "StanceBar", "StanceBarFrame", "ShapeshiftBarFrame" }

local function isSpecialBar(id)
  return id == "pet" or id == "possess"
end

local function supportsSpecialBar(id, classFile)
  if id == "possess" then
    return true
  end
  if id == "pet" then
    return PET_CLASSES[classFile] == true
  end
  return false
end

local function specialBarPreviewDefaults(id)
  local defaults = Addon.Defaults
  if not defaults then
    return nil
  end
  local base = defaults.base and defaults.base.layout
  return base and base[id]
end

local function layoutForApply(cfg, preview)
  local layout = {}
  for id, barCfg in pairs(cfg.layout or {}) do
    layout[id] = barCfg
  end
  if not preview then
    return layout
  end
  for _, id in ipairs(SPECIAL_IDS) do
    if layout[id] == nil then
      layout[id] = specialBarPreviewDefaults(id)
    end
  end
  return layout
end

local function suppressBlizzardActionBar()
  -- Hide, SetAlpha, SetParent, and SetPoint on default action hosts raise
  -- ADDON_ACTION_FORBIDDEN. pcall still pops the dialog. Live buttons stay.
  if Addon.ParkBlizzardStanceBar then
    Addon:ParkBlizzardStanceBar()
  end
end

local function stanceLayout()
  local layout
  if Addon.ResolveEffective then
    local resolved = Addon:ResolveEffective()
    layout = resolved and resolved.layout and resolved.layout.stance
  end
  layout = layout or {}
  local point = layout.point or STANCE_PARK.point
  local x = layout.x
  if x == nil then
    x = STANCE_PARK.x
  end
  local y = layout.y
  if y == nil then
    y = STANCE_PARK.y
  end
  return point, x, y, layout.relativeTo, layout.relativePoint or point
end

local function hookStanceParent(frame)
  if not frame or not hooksecurefunc or frame._shadowUIStanceParent then
    return
  end
  frame._shadowUIStanceParent = true
  hooksecurefunc(frame, "SetParent", function(self, parent)
    if self._shadowUIReparenting or parent == UIParent then
      return
    end
    Addon:ParkBlizzardStanceBar()
  end)
end

local function parkStanceFrame(frame, point, x, y, relativeTo, relativePoint)
end

function Addon:ParkBlizzardStanceBar()
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
    hooksecurefunc("MultiActionBar_Update", suppressBlizzardActionBar)
  end
  if ShapeshiftBar_Update then
    hooksecurefunc("ShapeshiftBar_Update", function()
      Addon:ParkBlizzardStanceBar()
    end)
  end
  if StanceBar_Update then
    hooksecurefunc("StanceBar_Update", function()
      Addon:ParkBlizzardStanceBar()
    end)
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

function Addon:StartSpecialBarUpdates()
  if self.specialBarEvents then
    return
  end
  local frame = CreateFrame("Frame")
  for _, event in ipairs({
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
  if self.SkinMicroAndBags then
    self:SkinMicroAndBags()
  end
  if self.SkinTrackingBars then
    self:SkinTrackingBars()
  end
  suppressBlizzardActionBar()
  hookBlizzardActionBar()
end

function Addon:ShowBarsForActionPlacement(show)
  if InCombatLockdown() then
    return
  end
  for _, bar in pairs(self.bars or {}) do
    if not bar.specialId then
      if show or bar.configEnabled then
        bar:Show()
      else
        bar:Hide()
      end
    end
  end
end

function Addon:ApplyBars(cfg)
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  if self.SkinBlizzardActionBars then
    self:SkinBlizzardActionBars()
  end
end

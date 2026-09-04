--[[
  Purpose: AceDB schema for account Layers/Loadout Snapshots and Character state.
  Deps: AceDB-3.0, ShadowUI addon table
  Public: ShadowUI:SetupDB(), ShadowUI:GetDB(), ShadowUI:GetCharDB()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local ACCOUNT_DEFAULTS = {
  profile = {
    base = {
      layout = {},
      keybinds = {},
    },
    classes = {},
    loadouts = {},
  },
}

local CHAR_DEFAULTS = {
  profile = {
    activeVariant = nil,
    editLayer = "variant",
    variantManual = false,
    hardLockActionSlots = false,
    useShadowUIMenu = true,
    microFadeIdle = 1,
    microIconShape = "square",
    xpFadeIdle = 1,
    minimapIcons = {},
    layout = {},
    keybinds = {},
  },
}

local LEGACY_BAR_RELATIVES = {
  MainActionBar = true,
  MainMenuBar = true,
  MainMenuBarArtFrame = true,
  MultiBarBottomLeft = true,
  MultiBarBottomRight = true,
  MultiBarLeft = true,
  MultiBarRight = true,
  MultiBar5 = true,
  MultiBar6 = true,
  MultiBar7 = true,
  MultiBar8 = true,
  MultiBar9 = true,
  MultiBar10 = true,
}
local ANCHOR_FIELDS = { "point", "relativeTo", "relativePoint", "x", "y" }

local function clearLegacyBarAnchors(layout)
  if type(layout) ~= "table" then
    return
  end
  for barId, cfg in pairs(layout) do
    if type(barId) == "string" and barId:match("^bar%d+$")
      and type(cfg) == "table" and LEGACY_BAR_RELATIVES[cfg.relativeTo] then
      for _, field in ipairs(ANCHOR_FIELDS) do
        cfg[field] = nil
      end
    end
  end
end

local function clearLayerAnchors(layer)
  if type(layer) ~= "table" then
    return
  end
  clearLegacyBarAnchors(layer.layout)
  for _, variant in pairs(layer.variants or {}) do
    clearLegacyBarAnchors(variant and variant.layout)
  end
end

local function clearAccountAnchors(account)
  if type(account) ~= "table" then
    return
  end
  clearLayerAnchors(account.base)
  for _, class in pairs(account.classes or {}) do
    clearLayerAnchors(class)
  end
end

function Addon:SetupDB()
  self.db = LibStub("AceDB-3.0"):New("ShadowUIDB", ACCOUNT_DEFAULTS, true)
  self.chardb = LibStub("AceDB-3.0"):New("ShadowUICharDB", CHAR_DEFAULTS, true)
  -- Blizzard-host Layout was reversed by ADR 0006. Keep non-anchor settings,
  -- but let the next valid Layer place each ShadowUI Bar.
  clearAccountAnchors(self.db.profile)
  clearLayerAnchors(self.chardb.profile)
end

function Addon:GetDB()
  return self.db.profile
end

function Addon:GetCharDB()
  return self.chardb.profile
end

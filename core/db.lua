--[[
  Purpose: AceDB schema and default registration for account + character stores.
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
  },
}

local CHAR_DEFAULTS = {
  profile = {
    activeVariant = nil,
    editLayer = "variant",
    variantManual = false,
    theme = "matte",
  },
}

function Addon:SetupDB()
  self.db = LibStub("AceDB-3.0"):New("ShadowUIDB", ACCOUNT_DEFAULTS, true)
  self.chardb = LibStub("AceDB-3.0"):New("ShadowUICharDB", CHAR_DEFAULTS, true)
end

function Addon:GetDB()
  return self.db.profile
end

function Addon:GetCharDB()
  return self.chardb.profile
end

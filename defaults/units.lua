--[[
  Purpose: Classic targeting-frame Baseline for Player Frame and Target Frame.
           Player is portrait-left. Target is that Widget tree mirrored, plus
           Name Background, auras, and the spell bar. Screen parks match the
           current chrome lock. Widget deltas sparse-merge on the same keys.
  Deps: ShadowUI:BaselineUnitFrameLayout() from units/layout.lua when present
  Public: populates Defaults.base.layout.player and .target
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults = Addon.Defaults or { base = {}, classes = {} }
Addon.Defaults.base = Addon.Defaults.base or {}
Addon.Defaults.base.layout = Addon.Defaults.base.layout or {}

local function seed()
  if Addon.BaselineUnitFrameLayout then
    Addon.Defaults.base.layout.player = Addon:BaselineUnitFrameLayout("player")
    Addon.Defaults.base.layout.target = Addon:BaselineUnitFrameLayout("target")
    return
  end
end

seed()

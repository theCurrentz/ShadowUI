--[[
  Purpose: Apply profile keybinds with combat-lockdown deferral.
  Deps: ShadowUI addon table; PLAYER_REGEN_ENABLED wired in init.lua
  Public: ApplyKeybinds(cfg), FlushPendingKeybinds()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:ApplyKeybinds(cfg)
  self._pendingKeybinds = cfg.keybinds or {}
  if InCombatLockdown() then
    return
  end
  self:FlushPendingKeybinds()
end

function Addon:FlushPendingKeybinds()
  local binds = self._pendingKeybinds
  if not binds or InCombatLockdown() then return end
  for name, key in pairs(binds) do
    if key and key ~= "" then
      SetBinding(key, name)
    end
  end
  SaveBindings(GetCurrentBindingSet())
  self._pendingKeybinds = nil
end

--[[
  Purpose: AceAddon bootstrap, combat-safe apply lifecycle, and regen flush.
  Deps: AceAddon-3.0, AceEvent-3.0, AceConsole-3.0; modules loaded later by TOC
  Public: ShadowUI addon table, ShadowUI:GetPlayerClass(), ShadowUI:ApplyAll(),
          ShadowUI:OnRegenEnabled()
]]

local Addon = LibStub("AceAddon-3.0"):NewAddon("ShadowUI", "AceEvent-3.0", "AceConsole-3.0")

-- Event names differ across Classic Era, SoD, and modernized clients; registration
-- of an unknown event raises an error, so each one is registered defensively.
local EVENTS = {
  { "PLAYER_ENTERING_WORLD", "OnPlayerReady" },
  { "PLAYER_REGEN_ENABLED", "OnRegenEnabled" },
  { "PLAYER_TALENT_UPDATE", "OnTalentUpdate" },
  { "CHARACTER_POINTS_CHANGED", "OnTalentUpdate" },
}

function Addon:OnInitialize()
  self:SetupDB()
  self:RegisterChatCommand("shadowui", "SlashCommand")
end

function Addon:OnEnable()
  for _, entry in ipairs(EVENTS) do
    pcall(self.RegisterEvent, self, entry[1], entry[2])
  end
end

function Addon:GetPlayerClass()
  local _, classFile = UnitClass("player")
  return classFile
end

function Addon:OnPlayerReady()
  if self._appliedOnce then
    return
  end
  self._appliedOnce = true
  self:ApplyAll()
end

function Addon:ApplyAll()
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  self.pendingApplyAll = nil
  local cfg = self:ResolveEffective()
  self:ApplyBars(cfg)
  self:ApplyKeybinds(cfg)
  self:ApplySkins()
  self:ApplyCastBar()
end

function Addon:OnRegenEnabled()
  if self.pendingApplyAll then
    self:ApplyAll()
    return
  end
  self:FlushPendingKeybinds()
  self:FlushPendingSpecialBars()
end

function Addon:SlashCommand(input)
  input = (input or ""):match("^%s*(.-)%s*$") or ""
  if input == "" then
    self:OpenOptions()
    return
  end
  local cmd, rest = input:match("^(%S+)%s*(.*)$")
  cmd = cmd and cmd:lower() or ""
  if cmd == "edit" then
    self:ToggleEditMode()
  elseif cmd == "layer" then
    self:SetEditLayer(rest)
  elseif cmd == "variant" then
    self:HandleVariantCommand(rest)
  elseif cmd == "theme" then
    if rest == "" then
      self:Print("Theme: " .. self:GetTheme())
    else
      self:SetTheme(rest)
    end
  else
    self:Print("Usage: /shadowui [edit|layer|variant|theme]")
  end
end

function Addon:ResolveEffective() end
function Addon:ApplyBars(cfg) end
function Addon:ApplyKeybinds(cfg) end
function Addon:ApplySkins() end
function Addon:ApplyCastBar() end
function Addon:FlushPendingKeybinds() end
function Addon:FlushPendingSpecialBars() end
function Addon:OnTalentUpdate() end
function Addon:OpenOptions() end
function Addon:ToggleEditMode() end
function Addon:SetEditLayer(layer) end
function Addon:HandleVariantCommand(rest) end

--[[
  Purpose: AceAddon bootstrap and first-run apply lifecycle.
  Deps: AceAddon-3.0, AceEvent-3.0, AceConsole-3.0; modules loaded later by TOC
  Public: ShadowUI addon table, ShadowUI:GetPlayerClass(), ShadowUI:ApplyAll()
]]

local Addon = LibStub("AceAddon-3.0"):NewAddon("ShadowUI", "AceEvent-3.0", "AceConsole-3.0")

function Addon:OnInitialize()
  self:SetupDB()
  self:RegisterChatCommand("shadowui", "SlashCommand")
end

function Addon:OnEnable()
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerReady")
  self:RegisterEvent("PLAYER_REGEN_ENABLED", "FlushPendingKeybinds")
  self:RegisterEvent("PLAYER_TALENT_UPDATE", "OnTalentUpdate")
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
  local cfg = self:ResolveEffective()
  self:ApplyBars(cfg)
  self:ApplyKeybinds(cfg)
  self:ApplySkins()
  self:ApplyCastBar()
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
  else
    self:Print("Usage: /shadowui [edit|layer|variant]")
  end
end

function Addon:ResolveEffective() end
function Addon:ApplyBars(cfg) end
function Addon:ApplyKeybinds(cfg) end
function Addon:ApplySkins() end
function Addon:ApplyCastBar() end
function Addon:FlushPendingKeybinds() end
function Addon:OnTalentUpdate() end
function Addon:OpenOptions() end
function Addon:ToggleEditMode() end
function Addon:SetEditLayer(layer) end
function Addon:HandleVariantCommand(rest) end

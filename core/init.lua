--[[
  Purpose: AceAddon bootstrap, combat-safe apply lifecycle, and regen flush.
  Deps: AceAddon-3.0, AceEvent-3.0, AceConsole-3.0; modules loaded later by TOC
  Public: ShadowUI addon table, ShadowUI:GetPlayerClass(), ShadowUI:ApplyAll(),
          ShadowUI:ApplyAutoLoot(), ShadowUI:OnRegenEnabled(), ShadowUI:OnLearnedSpell()
]]

local Addon = LibStub("AceAddon-3.0"):NewAddon("ShadowUI", "AceEvent-3.0", "AceConsole-3.0")

-- Event names differ across Classic Era, SoD, and modernized clients; registration
-- of an unknown event raises an error, so each one is registered defensively.
local EVENTS = {
  { "PLAYER_ENTERING_WORLD", "OnPlayerReady" },
  { "PLAYER_REGEN_ENABLED", "OnRegenEnabled" },
  { "PLAYER_REGEN_DISABLED", "OnRegenDisabled" },
  { "PLAYER_TALENT_UPDATE", "OnTalentUpdate" },
  { "CHARACTER_POINTS_CHANGED", "OnTalentUpdate" },
  { "LEARNED_SPELL_IN_TAB", "OnLearnedSpell" },
  { "LEARNED_SPELL_IN_SKILL_LINE", "OnLearnedSpell" },
}

function Addon:OnInitialize()
  self:SetupDB()
  self:RegisterChatCommand("shadowui", "SlashCommand")
  self:RegisterChatCommand("sui", "SlashCommand")
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
  local function step(label, method)
    local ok, err = pcall(method, self, cfg)
    if not ok then
      self:Print(label .. " failed: " .. tostring(err))
    end
  end
  step("bars", self.ApplyBars)
  step("keybinds", self.ApplyKeybinds)
  step("auto loot", self.ApplyAutoLoot)
  step("skins", self.ApplySkins)
  step("cast bar", self.ApplyCastBar)
  step("mana ticker", self.ApplyManaTicker)
  step("swing timer", self.ApplySwingTimer)
  step("range display", self.ApplyRangeDisplay)
  step("shields", self.ApplyShields)
end

function Addon:OnRegenEnabled()
  if self.pendingApplyAll then
    self:ApplyAll()
  else
    self:FlushPendingKeybinds()
    self:FlushPendingSpecialBars()
  end
  self:FlushPendingLearn()
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
  elseif cmd == "binds" or cmd == "bind" or cmd == "keybind" then
    self:ToggleKeybindMode()
  elseif cmd == "layer" then
    self:SetEditLayer(rest)
  elseif cmd == "variant" then
    self:HandleVariantCommand(rest)
  else
    self:Print("Usage: /shadowui [edit|binds|layer|variant]")
  end
end

function Addon:ResolveEffective() end
function Addon:ApplyBars(cfg) end
function Addon:ApplyAutoLoot()
  if SetCVar then
    pcall(SetCVar, "autoLootDefault", "1")
  end
end
function Addon:ApplyActionSlotLock() end
function Addon:LockBarButton(button) end
function Addon:SetActionSlotHardLock(locked) end
function Addon:ApplyKeybinds(cfg) end
function Addon:ApplyBarChrome(bar) end
function Addon:ApplyOuterChrome(host) end
function Addon:ApplySkins() end
function Addon:ApplyCastBar() end
function Addon:ApplyManaTicker() end
function Addon:ApplySwingTimer() end
function Addon:ApplyRangeDisplay() end
function Addon:ApplyShields() end
function Addon:SkinTrackingBars() end
function Addon:FlushPendingKeybinds() end
function Addon:FlushPendingSpecialBars() end
function Addon:OnLearnedSpell() end
function Addon:FlushPendingLearn() end
function Addon:OnTalentUpdate() end
function Addon:OpenOptions() end
function Addon:ToggleEditMode() end
function Addon:ToggleKeybindMode() end
function Addon:SetEditSession(session) end
function Addon:HookButtonForKeybinds(button) end
function Addon:OnRegenDisabled() end
function Addon:SetEditLayer(layer) end
function Addon:HandleVariantCommand(rest) end

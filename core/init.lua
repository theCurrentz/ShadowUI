--[[
  Purpose: AceAddon bootstrap, combat-safe apply lifecycle, and regen flush.
  Deps: AceAddon-3.0, AceEvent-3.0, AceConsole-3.0; modules loaded later by TOC
  Public: ShadowUI addon table, ShadowUI:GetVersion(), ShadowUI:GetPlayerClass(),
          ShadowUI:ApplyAll(), ShadowUI:ApplyAutoLoot(), ShadowUI:ApplyCooldownManager(),
          ShadowUI:OnRegenEnabled(), ShadowUI:OnPressCastEvent()
]]

local Addon = LibStub("AceAddon-3.0"):NewAddon("ShadowUI", "AceEvent-3.0", "AceConsole-3.0")

-- Event names differ across Classic Era and modernized clients; registration
-- of an unknown event raises an error, so each one is registered defensively.
local EVENTS = {
  { "PLAYER_ENTERING_WORLD", "OnPlayerReady" },
  { "PLAYER_REGEN_ENABLED", "OnRegenEnabled" },
  { "PLAYER_REGEN_DISABLED", "OnRegenDisabled" },
  { "PLAYER_TALENT_UPDATE", "OnTalentUpdate" },
  { "CHARACTER_POINTS_CHANGED", "OnTalentUpdate" },
  { "ACTIONBAR_SHOWGRID", "OnActionBarShowGrid" },
  { "ACTIONBAR_HIDEGRID", "OnActionBarHideGrid" },
  { "CURSOR_CHANGED", "OnCursorChanged" },
  { "UNIT_SPELLCAST_START", "OnPressCastEvent" },
  { "UNIT_SPELLCAST_STOP", "OnPressCastEvent" },
  { "UNIT_SPELLCAST_FAILED", "OnPressCastEvent" },
  { "UNIT_SPELLCAST_INTERRUPTED", "OnPressCastEvent" },
  { "UNIT_SPELLCAST_SUCCEEDED", "OnPressCastEvent" },
  { "UNIT_SPELLCAST_CHANNEL_START", "OnPressCastEvent" },
  { "UNIT_SPELLCAST_CHANNEL_STOP", "OnPressCastEvent" },
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

function Addon:GetVersion()
  if type(GetBuildInfo) == "function" then
    local ok, interface = pcall(function()
      return select(4, GetBuildInfo())
    end)
    if ok and type(interface) == "number" then
      if interface >= 20000 and interface < 30000 then
        return "TBC"
      end
      if interface >= 10000 and interface < 20000 then
        return "ERA"
      end
    end
  end
  local project = _G.WOW_PROJECT_ID
  local tbc = _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
  if project and tbc and project == tbc then
    return "TBC"
  end
  return "ERA"
end

function Addon:OnPlayerReady()
  if not self._appliedOnce then
    self._appliedOnce = true
    self:ApplyAll()
  end
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
  step("cooldown manager", self.ApplyCooldownManager)
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
  elseif cmd == "binds" or cmd == "bind" or cmd == "keybind" then
    self:ToggleKeybindMode()
  elseif cmd == "prune" or cmd == "shift" then
    self:ShiftAndPruneBars(rest)
  elseif cmd == "layer" then
    self:SetEditLayer(rest)
  elseif cmd == "variant" then
    self:HandleVariantCommand(rest)
  elseif cmd == "loadout" then
    self:HandleLoadoutCommand(rest)
  elseif cmd == "xpstack" then
    self:DumpXPStack()
  else
    self:Print("Usage: /shadowui [edit|binds|prune <group>|layer|variant|loadout|xpstack]")
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
function Addon:ShouldShowEmptyActionSlots() return false end
function Addon:PaintEmptySlotVisibility() end
function Addon:RefreshActionPlacement() end
function Addon:OnActionBarShowGrid() end
function Addon:OnActionBarHideGrid() end
function Addon:OnCursorChanged() end
function Addon:ShowBarsForActionPlacement() end
function Addon:LockBarButton(button) end
function Addon:SetActionSlotHardLock(locked) end
function Addon:ApplyKeybinds(cfg) end
function Addon:ShiftAndPruneBars(groupName) end
function Addon:InsertBarSlot() end
function Addon:HookButtonForSlotShift() end
function Addon:ClearSlotShiftFrom() end
function Addon:ApplyBarChrome(bar) end
function Addon:ApplyOuterChrome(host) end
function Addon:PaintOuterChrome(outer) end
function Addon:ApplySkins() end
function Addon:ApplyCastBar() end
function Addon:ApplyManaTicker() end
function Addon:ApplySwingTimer() end
function Addon:ApplyRangeDisplay() end
function Addon:ApplyShields() end
function Addon:ApplyCooldownManager() end
function Addon:SkinTrackingBars() end
function Addon:DumpXPStack() end
function Addon:FlushPendingKeybinds() end
function Addon:FlushPendingSpecialBars() end
function Addon:OnTalentUpdate() end
function Addon:OpenOptions() end
function Addon:ToggleEditMode() end
function Addon:ToggleKeybindMode() end
function Addon:SetEditSession(session) end
function Addon:HookButtonForKeybinds(button) end
function Addon:OnRegenDisabled() end
function Addon:SetEditLayer(layer) end
function Addon:HandleVariantCommand(rest) end
function Addon:HandleLoadoutCommand(rest) end

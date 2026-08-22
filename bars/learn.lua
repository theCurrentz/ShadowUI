--[[
  Purpose: Place a newly learned spell on a shipped Action Slot. New ranks replace
           the same slot. Sparse class maps only; not Layout.
  Deps: ShadowUI addon table, InCombatLockdown, PickupSpell, PlaceAction
  Public: ShadowUI:LearnSlotForSpell(), ShadowUI:PlaceLearnedSpell(),
          ShadowUI:OnLearnedSpell(), ShadowUI:FlushPendingLearn()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local function spellName(spellId)
  if type(spellId) ~= "number" then
    return nil
  end
  if C_Spell and C_Spell.GetSpellName then
    return C_Spell.GetSpellName(spellId)
  end
  if not GetSpellInfo then
    return nil
  end
  local name = GetSpellInfo(spellId)
  if type(name) == "table" then
    return name.name
  end
  return name
end

local function pickupSpell(spellId)
  if C_Spell and C_Spell.PickupSpell then
    pcall(C_Spell.PickupSpell, spellId)
    return
  end
  if PickupSpell then
    pcall(PickupSpell, spellId)
  end
end

local function cursorBusy()
  return GetCursorInfo and GetCursorInfo() ~= nil
end

function Addon:LearnSlotForSpell(spellId)
  local classFile = self:GetPlayerClass()
  local defaults = classFile and self.Defaults and self.Defaults.classes[classFile]
  local map = defaults and defaults.learnSlots
  if type(map) ~= "table" or type(spellId) ~= "number" then
    return nil
  end
  local direct = map[spellId]
  if direct then
    return direct
  end
  local name = spellName(spellId)
  if not name then
    return nil
  end
  for id, slot in pairs(map) do
    if spellName(id) == name then
      return slot
    end
  end
  return nil
end

function Addon:PlaceLearnedSpell(spellId, slot)
  if type(spellId) ~= "number" or type(slot) ~= "number" then
    return
  end
  if InCombatLockdown() then
    self._pendingLearn = self._pendingLearn or {}
    self._pendingLearn[slot] = spellId
    return
  end
  if cursorBusy() then
    return
  end
  if GetActionInfo then
    local actionType, actionId = GetActionInfo(slot)
    if actionType == "spell" and actionId == spellId then
      return
    end
  end
  pickupSpell(spellId)
  if not cursorBusy() then
    return
  end
  if PlaceAction then
    PlaceAction(slot)
  end
  if cursorBusy() and ClearCursor then
    ClearCursor()
  end
end

function Addon:OnLearnedSpell(event, spellId)
  if type(event) == "number" then
    spellId = event
  end
  local slot = self:LearnSlotForSpell(spellId)
  if not slot then
    return
  end
  self:PlaceLearnedSpell(spellId, slot)
end

function Addon:FlushPendingLearn()
  local pending = self._pendingLearn
  if not pending then
    return
  end
  self._pendingLearn = nil
  if InCombatLockdown() then
    self._pendingLearn = pending
    return
  end
  for slot, spellId in pairs(pending) do
    self:PlaceLearnedSpell(spellId, slot)
  end
end

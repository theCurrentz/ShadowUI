--[[
  Purpose: Place the shipped Action Deck onto Blizzard Action Slots.
  Deps: ShadowUI addon table, ShadowUI.Defaults.catalog, InCombatLockdown
  Public: ResolveDeck, ResolveDeckSlots, FindMacroIndex, EnsureDeckMacro, PlaceDeck,
          RefreshActionDeckButtons
  Notes: ResolveDeck merges Class then Variant. Variant false clears a Class slot.
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local ACCOUNT_MACROS = _G.MAX_ACCOUNT_MACROS or 120

local function sortedSlots(src)
  local slots = {}
  for slot in pairs(src or {}) do
    if type(slot) == "number" then
      slots[#slots + 1] = slot
    end
  end
  table.sort(slots)
  return slots
end

function Addon:ResolveDeck(classFile, variantName)
  classFile = classFile or self:GetPlayerClass()
  variantName = variantName or self:GetActiveVariantName(classFile)
  local shipped = self:ShippedClass(classFile)
  local deck = {}
  local function take(src)
    if type(src) ~= "table" or type(src.actions) ~= "table" then
      return
    end
    for slot, entry in pairs(src.actions) do
      if entry == false then
        deck[slot] = nil
      else
        deck[slot] = entry
      end
    end
  end
  take(shipped)
  if variantName and shipped.variants then
    take(shipped.variants[variantName])
  end
  return deck
end

function Addon:ResolveDeckSlots(classFile)
  classFile = classFile or self:GetPlayerClass()
  local shipped = self:ShippedClass(classFile)
  local slots = {}
  for _, range in ipairs(shipped.deckSlots or {}) do
    if type(range) == "number" then
      slots[range] = true
    elseif type(range) == "table"
      and type(range[1]) == "number"
      and type(range[2]) == "number"
    then
      for slot = range[1], range[2] do
        slots[slot] = true
      end
    end
  end
  return slots
end

function Addon:FindMacroIndex(name, match, notMatch)
  if type(name) ~= "string" or name == "" or type(GetMacroInfo) ~= "function" then
    return nil
  end
  local acc, char = 0, 0
  if type(GetNumMacros) == "function" then
    acc, char = GetNumMacros()
  end
  local function scan(from, count)
    for i = from, from + count - 1 do
      local macroName, _, body = GetMacroInfo(i)
      if macroName == name then
        body = body or ""
        if match and not body:find(match, 1, true) then
          -- skip
        elseif notMatch and body:find(notMatch, 1, true) then
          -- skip
        else
          return i
        end
      end
    end
    return nil
  end
  return scan(1, acc or 0) or scan(ACCOUNT_MACROS + 1, char or 0)
end

function Addon:EnsureDeckMacro(entry)
  if type(entry) ~= "table" or type(entry.name) ~= "string" then
    return nil
  end
  local found = self:FindMacroIndex(entry.name, entry.match, entry.notMatch)
  if found then
    return found
  end
  if entry.createName then
    found = self:FindMacroIndex(entry.createName, entry.match, entry.notMatch)
    if found then
      return found
    end
  end
  local rec = ((self.Defaults or {}).catalog or {})[entry.id]
  if type(rec) ~= "table" or type(CreateMacro) ~= "function" then
    return nil
  end
  local createName = entry.createName or rec.name
  pcall(CreateMacro, createName, rec.icon, rec.body, false)
  return self:FindMacroIndex(createName, entry.match, entry.notMatch)
    or self:FindMacroIndex(entry.name, entry.match, entry.notMatch)
end

function Addon:PlaceDeck(classFile, variantName)
  if InCombatLockdown and InCombatLockdown() then
    self:Print("Leave combat to place the Action Deck.")
    return false
  end
  local deck = self:ResolveDeck(classFile, variantName)
  local actionSlots = sortedSlots(deck)
  if #actionSlots == 0 then
    self:Print("No Action Deck for this class.")
    return false
  end
  local managed = self:ResolveDeckSlots(classFile)
  if type(PickupMacro) ~= "function" or type(PlaceAction) ~= "function"
    or (next(managed) and (type(PickupAction) ~= "function" or type(ClearCursor) ~= "function"))
  then
    self:Print("Action Deck placement is unavailable.")
    return false
  end

  -- Create and find every macro before changing an Action Slot. A full macro
  -- tab must not leave the player with a half-cleared deck.
  local indices, missing = {}, {}
  for _, slot in ipairs(actionSlots) do
    local entry = deck[slot]
    local index = self:EnsureDeckMacro(entry)
    if index then
      indices[slot] = index
    else
      missing[#missing + 1] = (entry and (entry.id or entry.name)) or tostring(slot)
    end
  end
  if next(indices) == nil then
    table.sort(missing)
    self:Print("Action Deck unchanged. Missing macros: " .. table.concat(missing, ", "))
    return false
  end

  if type(ClearCursor) == "function" then
    ClearCursor()
  end
  local lockBars
  if type(GetCVar) == "function" then
    lockBars = GetCVar("lockActionBars")
  end
  if lockBars == "1" and type(SetCVar) == "function" then
    pcall(SetCVar, "lockActionBars", "0")
  end
  for _, slot in ipairs(sortedSlots(managed)) do
    PickupAction(slot)
    ClearCursor()
  end
  local placed = 0
  for _, slot in ipairs(actionSlots) do
    local index = indices[slot]
    if index then
      PickupMacro(index)
      PlaceAction(slot)
      ClearCursor()
      placed = placed + 1
    end
  end
  if lockBars == "1" and type(SetCVar) == "function" then
    pcall(SetCVar, "lockActionBars", lockBars)
  end
  self:RefreshActionDeckButtons()
  local msg = "Placed " .. placed .. " Action Slots."
  if #missing > 0 then
    table.sort(missing)
    msg = msg .. " Skipped: " .. table.concat(missing, ", ")
  end
  self:Print(msg)
  return true
end

function Addon:RefreshActionDeckButtons()
  for _, bar in pairs(self.bars or {}) do
    for _, button in ipairs(bar.buttons or {}) do
      if type(button.UpdateAction) == "function" then
        pcall(button.UpdateAction, button, true)
      end
    end
  end
end

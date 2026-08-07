--[[
  Purpose: Create and refresh class, pet, and possess action bars.
  Deps: ShadowUI:CreateBar(), Classic Era shapeshift and pet APIs
  Public: ShadowUI:CreateSpecialBar(), ShadowUI:RefreshSpecialBars()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local PAGES = { stance = 11, form = 12, aura = 13, pet = 14, possess = 15 }

local function isTrue(value)
  return value == true or value == 1
end

local function setMacro(button, text)
  button:SetState(0, "empty")
  button:SetAttribute("type", "macro")
  button:SetAttribute("macrotext", text)
end

local function setTexture(button, texture)
  button.icon:SetTexture(texture)
  button.icon:SetShown(texture ~= nil)
end

local function getShapeshiftInfo(index)
  local icon, second, third, fourth, fifth = GetShapeshiftFormInfo(index)
  if type(second) == "string" then
    return icon, second, third, fifth
  end
  local spellId = fourth
  return icon, spellId and GetSpellInfo(spellId), second, spellId
end

local function refreshShapeshift(bar)
  local available = false
  for i, button in ipairs(bar.buttons) do
    local texture, name, active, spellId = getShapeshiftInfo(i)
    if spellId and button.boundSpellId ~= spellId and not InCombatLockdown() then
      button:SetState(0, "spell", spellId)
      button.boundSpellId = spellId
    elseif name and not button.boundSpellId and not InCombatLockdown() then
      setMacro(button, "/cast " .. name)
    end
    setTexture(button, texture)
    button:SetChecked(isTrue(active))
    button:SetShown(name ~= nil)
    available = available or name ~= nil
  end
  bar:SetShown(available)
end

local function refreshPet(bar)
  local available = UnitExists("pet")
  for i, button in ipairs(bar.buttons) do
    local name, texture, _, active = GetPetActionInfo(i)
    setTexture(button, texture)
    button:SetChecked(isTrue(active))
    button:SetShown(name ~= nil)
  end
  bar:SetShown(available)
end

local function refreshPossess(bar)
  local available = false
  for i, button in ipairs(bar.buttons) do
    local texture, _, enabled = GetPossessInfo(i)
    setTexture(button, texture)
    button:SetShown(isTrue(enabled))
    available = available or isTrue(enabled)
  end
  bar:SetShown(available)
end

function Addon:CreateSpecialBar(barId, cfg)
  local page = assert(PAGES[barId], "unknown special bar id")
  local bar = self:CreateBar("bar" .. page, cfg)
  bar.specialId = barId

  for i, button in ipairs(bar.buttons) do
    if barId == "pet" then
      button:SetState(0, "empty")
      button:SetAttribute("type", "pet")
      button:SetAttribute("action", i)
    elseif barId == "possess" then
      setMacro(button, "/click PossessButton" .. i)
    else
      local _, name, _, spellId = getShapeshiftInfo(i)
      if spellId then
        button:SetState(0, "spell", spellId)
        button.boundSpellId = spellId
      else
        setMacro(button, name and "/cast " .. name or "")
      end
    end
  end

  return bar
end

function Addon:RefreshSpecialBars()
  if InCombatLockdown() then
    self.pendingSpecialBarRefresh = true
    return
  end
  for id, bar in pairs(self.bars or {}) do
    if bar.specialId and bar.configEnabled then
      if id == "pet" then
        refreshPet(bar)
      elseif id == "possess" then
        refreshPossess(bar)
      else
        refreshShapeshift(bar)
      end
    end
  end
end

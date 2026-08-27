--[[
  Purpose: Create and refresh pet and possess action bars.
           Layout Edit Mode keeps empty Special Bars shown for every class.
  Deps: ShadowUI:CreateBar(), ShadowUI:RefreshPetBar()
  Public: ShadowUI:CreateSpecialBar(), ShadowUI:RefreshSpecialBars(),
          ShadowUI:FlushPendingSpecialBars()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local PAGES = { pet = 14, possess = 15 }

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

local function previewSpecialBar()
  return Addon.editMode == true
end

local function refreshPossess(bar)
  local available = false
  local preview = previewSpecialBar()
  for i, button in ipairs(bar.buttons) do
    local texture, _, enabled = GetPossessInfo(i)
    setTexture(button, texture)
    button:SetShown(isTrue(enabled) or preview)
    available = available or isTrue(enabled)
  end
  bar:SetShown(available or preview)
end

function Addon:CreateSpecialBar(barId, cfg)
  local page = assert(PAGES[barId], "unknown special bar id")
  local bar = self:CreateBar("bar" .. page, cfg)
  bar.barId = barId
  bar.specialId = barId

  for i, button in ipairs(bar.buttons) do
    if barId == "pet" then
      self:BindPetButton(button, i)
    else
      setMacro(button, "/click PossessButton" .. i)
    end
  end

  return bar
end

function Addon:RefreshSpecialBars()
  if InCombatLockdown() then
    self.pendingSpecialBarRefresh = true
    return
  end
  self.pendingSpecialBarRefresh = nil
  for id, bar in pairs(self.bars or {}) do
    if bar.specialId and bar.configEnabled then
      if id == "pet" then
        self:RefreshPetBar(bar)
      elseif id == "possess" then
        refreshPossess(bar)
      end
    end
  end
end

function Addon:FlushPendingSpecialBars()
  if self.pendingSpecialBarRefresh then
    self:RefreshSpecialBars()
  end
end

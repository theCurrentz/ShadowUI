-- The Blizzard micro menu stays put. ShadowUI shadows the bar border
-- and leaves tray art, Flash, Selection, and every micro button in place.
-- Run: lua tests/micro_menu_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local orig = _G[object]
    if type(orig) ~= "function" then
      return
    end
    _G[object] = function(...)
      orig(...)
      fn(...)
    end
    return
  end
  local orig = object[method]
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.UIParent = { name = "UIParent" }
_G.CreateFrame = function(_, name, parent, template)
  local frame = {
    name = name,
    parent = parent or _G.UIParent,
    template = template,
    shown = true,
    points = {},
  }
  if name then
    _G[name] = frame
  end
  function frame:SetParent(nextParent) self.parent = nextParent end
  function frame:GetParent() return self.parent end
  function frame:SetFrameStrata() end
  function frame:GetFrameLevel() return self.level or 1 end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetSize() end
  function frame:GetWidth() return 32 end
  function frame:GetHeight() return 32 end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function frame:GetLeft() return 4 end
  function frame:GetRight() return 36 end
  function frame:GetBottom() return 4 end
  function frame:GetTop() return 36 end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor() end
  function frame:SetBackdropBorderColor() end
  function frame:EnableMouse() end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown end
  return frame
end

local function fakeButton(name, parent)
  local button = {
    name = name,
    parent = parent,
    shown = true,
    points = { { "LEFT", parent, "LEFT", 0, 0 } },
    layoutIndex = 3,
    width = 28,
    height = 58,
  }
  function button:GetName() return name end
  function button:SetParent(frame) self.parent = frame end
  function button:GetParent() return self.parent end
  function button:GetWidth() return self.width end
  function button:GetHeight() return self.height end
  function button:ClearAllPoints() self.points = {} end
  function button:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function button:Show() self.shown = true end
  function button:Hide() self.shown = false end
  function button:GetFrameLevel() return 4 end
  local flash = { hidden = false, alpha = 1, points = {} }
  function flash:Show() self.hidden = false end
  function flash:Hide() self.hidden = true end
  function flash:SetAlpha(a) self.alpha = a end
  button.Flash = flash
  _G[name] = button
  return button
end

local container = _G.CreateFrame("Frame", "MicroMenuContainer", _G.UIParent)
container:SetPoint("BOTTOMRIGHT", _G.UIParent, "BOTTOMRIGHT", 0, 0)
local menu = _G.CreateFrame("Frame", "MicroMenu", container)
local tray = { hidden = false, alpha = 1 }
function tray:Hide() self.hidden = true end
function tray:SetAlpha(a) self.alpha = a end
function container:GetRegions()
  return tray
end
local selection = _G.CreateFrame("Frame", nil, container)
selection:SetPoint("TOPLEFT", container, "TOPLEFT", -4, 4)
container.Selection = selection

local names = {
  "CharacterMicroButton",
  "SpellbookMicroButton",
  "ProfessionMicroButton",
  "LegacyMicroButton",
  "AchievementMicroButton",
  "StoreMicroButton",
  "HelpMicroButton",
  "EJMicroButton",
  "CollectionsMicroButton",
}
for _, name in ipairs(names) do
  fakeButton(name, menu)
end

local char = { useShadowUIMenu = true }
function Addon:GetCharDB()
  return char
end
_G.UpdateMicroButtons = function() end

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/micro.lua"))()
Addon:SkinMicroAndBags()

assert(menu.parent == container, "MicroMenu stays on MicroMenuContainer")
assert(container.points[1][2] == _G.UIParent, "MicroMenuContainer keeps its Blizzard anchor")
assert(_G.StoreMicroButton.parent == menu, "Store stays on MicroMenu")
assert(_G.HelpMicroButton.parent == menu, "Help stays on MicroMenu")
assert(_G.AchievementMicroButton.parent == menu, "Achievement stays on MicroMenu")
assert(_G.EJMicroButton.parent == menu, "EJ stays on MicroMenu")
assert(_G.StoreMicroButton.layoutIndex == 3, "buttons keep layoutIndex")
assert(_G.CharacterMicroButton:GetWidth() == 28 and _G.CharacterMicroButton:GetHeight() == 58,
  "micro buttons keep native size")
assert(_G.ProfessionMicroButton.parent == menu, "Professions stays on MicroMenu")
assert(_G.LegacyMicroButton.parent == menu, "Legacy stays on MicroMenu")
assert(not _G.CharacterMicroButton.Flash.hidden and _G.CharacterMicroButton.Flash.alpha == 1,
  "Flash highlight stays Blizzard")
assert(not tray.hidden and tray.alpha == 1, "micro bar tray art stays")
assert(container.shadowUIOuter and container.shadowUIOuter.shown ~= false,
  "micro bar border gets an Outer Edge")
assert(menu.shadowUIOuter == nil, "Outer Edge sits on the bar, not each button row")
assert(_G.CharacterMicroButton.shadowUIOuter == nil, "micro buttons do not get an Outer Edge")
assert(container.Selection:GetLeft() == 4, "Edit Mode Selection stays measurable")

_G.UpdateMicroButtons()
assert(_G.HelpMicroButton.parent == menu, "UpdateMicroButtons leaves Help on MicroMenu")
assert(container.shadowUIOuter.shown ~= false, "UpdateMicroButtons keeps the border shadow")

char.useShadowUIMenu = false
Addon:SkinMicroAndBags()
assert(container.shadowUIOuter.shown == false, "toggle off hides the border shadow")
assert(menu.parent == container, "toggle off leaves MicroMenu on its container")

print("micro_menu_spec OK")

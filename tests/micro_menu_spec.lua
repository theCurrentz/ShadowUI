-- On clients with MicroMenu, Blizzard Edit Mode calls MicroMenuContainer:Layout.
-- GetEdgeButton compares GetCenter of children that still have layoutIndex.
-- SkinMicroAndBags must not leave those children with nil centres.
-- Run: lua tests/micro_menu_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local name = object
    local orig = _G[name]
    if type(orig) ~= "function" then
      return
    end
    _G[name] = function(...)
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
  function frame:SetParent(nextParent) self.parent = nextParent end
  function frame:GetParent() return self.parent end
  function frame:SetFrameStrata() end
  function frame:GetFrameLevel() return self.level or 1 end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function frame:GetCenter()
    if not self.shown or #self.points == 0 then
      return nil
    end
    return 10, 10
  end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:SetAlpha() end
  function frame:SetClipsChildren() end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown end
  return frame
end

local function fakeButton(name, parent, shown, layoutIndex)
  local button = {
    name = name,
    parent = parent,
    shown = shown,
    points = {},
    layoutIndex = layoutIndex,
  }
  function button:SetParent(frame) self.parent = frame end
  function button:GetParent() return self.parent end
  function button:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function button:GetWidth() return self.width or 28 end
  function button:GetHeight() return self.height or 58 end
  function button:SetScale() end
  function button:GetHitRectInsets()
    return 0, 0, 18, 0
  end
  function button:SetHitRectInsets() end
  function button:SetClipsChildren() end
  function button:GetFrameLevel() return self.level or 4 end
  function button:SetFrameLevel(level) self.level = level end
  local function fakeArt()
    local art = {}
    function art:SetVertexColor() end
    function art:SetTexCoord() end
    function art:ClearAllPoints() end
    function art:SetAllPoints() end
    function art:SetPoint() end
    function art:SetAlpha() end
    return art
  end
  function button:GetNormalTexture()
    return fakeArt()
  end
  function button:GetPushedTexture()
    return fakeArt()
  end
  function button:GetDisabledTexture()
    return fakeArt()
  end
  function button:GetHighlightTexture()
    return fakeArt()
  end
  function button:Show() self.shown = true end
  function button:Hide() self.shown = false end
  function button:IsShown() return self.shown end
  function button:ClearAllPoints() self.points = {} end
  function button:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function button:SetScript() end
  function button:GetCenter()
    if not self.shown or #self.points == 0 then
      return nil
    end
    return 10, 10
  end
  return button
end

local art = { name = "MainMenuBarArtFrame", shown = true }
function art:Show() self.shown = true end
function art:Hide() self.shown = false end
function art:SetParent() end
function art:ClearAllPoints() end
function art:SetPoint() end
function art:SetScript() end
_G.MainMenuBarArtFrame = art

local container = _G.CreateFrame("Frame", "MicroMenuContainer", _G.UIParent)
container.isHorizontal = true
_G.MicroMenuContainer = container

local menu = _G.CreateFrame("Frame", "MicroMenu", container)
menu.isHorizontal = true
menu.numButtons = 3
_G.MicroMenu = menu

_G.MainMenuBarBackpackButton = fakeButton("MainMenuBarBackpackButton", art, true)
_G.CharacterMicroButton = fakeButton("CharacterMicroButton", menu, true, 1)
_G.SpellbookMicroButton = fakeButton("SpellbookMicroButton", menu, true, 2)
_G.SocialsMicroButton = fakeButton("SocialsMicroButton", menu, true, 3)
_G.AchievementMicroButton = fakeButton("AchievementMicroButton", menu, true, 4)
_G.StoreMicroButton = fakeButton("StoreMicroButton", menu, true, 5)
_G.GuildMicroButton = fakeButton("GuildMicroButton", menu, true, 6)
_G.EJMicroButton = fakeButton("EJMicroButton", menu, true, 7)
_G.CollectionsMicroButton = fakeButton("CollectionsMicroButton", menu, true, 8)
_G.CharacterBag0Slot = fakeButton("CharacterBag0Slot", art, true)
_G.KeyRingButton = fakeButton("KeyRingButton", art, true)

local allMicro = {
  _G.CharacterMicroButton,
  _G.SpellbookMicroButton,
  _G.SocialsMicroButton,
  _G.AchievementMicroButton,
  _G.StoreMicroButton,
  _G.GuildMicroButton,
  _G.EJMicroButton,
  _G.CollectionsMicroButton,
}
function menu:GetChildren()
  local kids = {}
  for _, button in ipairs(allMicro) do
    local host = button._shadowUIHost
    if host and host.parent == self then
      kids[#kids + 1] = host
    elseif button.parent == self then
      kids[#kids + 1] = button
    end
  end
  return table.unpack(kids)
end

-- Blizzard MicroMenuMixin:GetEdgeButton (nil GetCenter compares two nils).
local function getEdgeButton(self, rightMost)
  local firstButton
  local lastButton
  for _, child in ipairs({ self:GetChildren() }) do
    if child.layoutIndex then
      if not firstButton or child.layoutIndex < firstButton.layoutIndex then
        firstButton = child
      end
      if not lastButton or child.layoutIndex > lastButton.layoutIndex then
        lastButton = child
      end
    end
  end
  if not firstButton then
    return nil
  end
  local firstButtonX = firstButton:GetCenter()
  local lastButtonX = lastButton:GetCenter()
  if rightMost then
    return firstButtonX > lastButtonX and firstButton or lastButton
  end
  return firstButtonX < lastButtonX and firstButton or lastButton
end

function menu:Layout()
  getEdgeButton(self, true)
  -- Blizzard HorizontalLayoutFrame sizes to layout children. Hosts set
  -- ignoreInLayout, so a real Layout would collapse the menu to 0 and clip
  -- every micro button.
  local n = 0
  for _, child in ipairs({ self:GetChildren() }) do
    if child.layoutIndex and not child.ignoreInLayout then
      n = n + 1
    end
  end
  if n == 0 and self.SetSize then
    self:SetSize(0, 0)
  end
end

function container:Layout()
  if menu:GetParent() ~= self then
    return
  end
  menu:Layout()
end

_G.UpdateMicroButtonsParent = function(parent)
  menu:SetParent(parent)
end

assert(loadfile(root .. "skin/chrome.lua"))()
local char = { useShadowUIMenu = true }
function Addon:GetCharDB()
  return char
end
assert(loadfile(root .. "skin/micro.lua"))()
Addon:SkinMicroAndBags()

assert(menu.parent.name == "ShadowUIMicroCluster", "MicroMenu parents to the Micro Cluster")
assert(_G.CharacterMicroButton._shadowUIHost.parent == menu, "hosts stay children of MicroMenu")
assert(_G.CharacterMicroButton.parent == _G.CharacterMicroButton._shadowUIHost,
  "micro buttons parent to their host")
assert(_G.CharacterMicroButton._shadowUIHost.width == 28
  and _G.CharacterMicroButton._shadowUIHost.height == 58,
  "host matches native 28x58 size")
assert(_G.CharacterMicroButton.width == 28 and _G.CharacterMicroButton.height == 58,
  "micro buttons keep native 28x58 size")
assert(_G.AchievementMicroButton.shown == false, "AchievementMicroButton stays out of the Micro Cluster")
assert(_G.AchievementMicroButton.parent ~= menu or _G.AchievementMicroButton.layoutIndex == nil,
  "hidden extras must not stay on MicroMenu with layoutIndex")
assert(_G.EJMicroButton.shown == false,
  "EJMicroButton stays out of the Micro Cluster when ToggleEncounterJournal is missing")
assert(_G.EJMicroButton.parent ~= menu or _G.EJMicroButton.layoutIndex == nil,
  "hidden EJMicroButton must not stay on MicroMenu with layoutIndex")
assert(_G.CollectionsMicroButton.shown == false,
  "CollectionsMicroButton stays out of the Micro Cluster when ToggleCollectionsJournal is missing")

container:Layout()
menu:Layout()
getEdgeButton(menu, true)

local cluster = menu.parent
assert(cluster.width and cluster.width > 0, "Micro Cluster keeps a positive width")
assert(menu.shown ~= false, "MicroMenu stays shown")
assert((menu.width or 0) > 0 and (menu.height or 0) > 0,
  "MicroMenu keeps a positive size so it does not clip the row")
assert(_G.CharacterMicroButton.shown, "micro buttons stay shown")

local bag = _G.MainMenuBarBackpackButton
assert(bag.parent.name == "ShadowUIMicroCluster", "backpack parents to the Micro Cluster")
local menuDock = menu.points[#menu.points]
assert(menuDock[2] == bag and menuDock[3] == "BOTTOMLEFT",
  "MicroMenu sits on the backpack left so hosts stay inside the menu")

_G.ToggleEncounterJournal = function() end
Addon:SkinMicroAndBags()
assert(_G.EJMicroButton.shown,
  "EJMicroButton stays in the Micro Cluster when ToggleEncounterJournal exists")

char.useShadowUIMenu = false
Addon:SkinMicroAndBags()
assert(menu.parent == container, "blizzard menu parents MicroMenu to MicroMenuContainer")
assert(_G.CharacterMicroButton.parent == menu, "blizzard menu keeps buttons on MicroMenu")

print("micro_menu_spec OK")

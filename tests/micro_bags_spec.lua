-- The Blizzard micro menu and bag bar stay in place. ShadowUI shadows
-- only those bar borders. Buttons, tray art, and extra slots stay Blizzard.
-- Run: lua tests/micro_bags_spec.lua
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
  function frame:SetParent(nextParent) self.parent = nextParent end
  function frame:GetParent() return self.parent end
  function frame:SetFrameStrata() end
  function frame:GetFrameLevel() return self.level or 1 end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function frame:GetWidth() return self.width or 28 end
  function frame:GetHeight() return self.height or 37 end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor() end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
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
    points = { { "RIGHT", parent, "RIGHT", 0, 0 } },
    layoutIndex = 1,
    width = 37,
    height = 37,
  }
  function button:GetName() return self.name end
  function button:SetParent(frame) self.parent = frame end
  function button:GetParent() return self.parent end
  function button:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function button:GetWidth() return self.width end
  function button:GetHeight() return self.height end
  function button:ClearAllPoints() self.points = {} end
  function button:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function button:Show() self.shown = true end
  function button:Hide() self.shown = false end
  function button:GetFrameLevel() return 4 end
  _G[name] = button
  return button
end

local function fakeTex(name)
  return { name = name, points = {}, hidden = false, alpha = 1 }
end

local bags = _G.CreateFrame("Frame", "BagsBar", _G.UIParent)
bags:SetPoint("BOTTOMRIGHT", _G.UIParent, "BOTTOMRIGHT", -4, 4)
_G.BagsBar = bags
local center = fakeTex("BagsBarCenter")
local border = fakeTex("BagsBarBorder")
function bags:GetRegions()
  return center, border
end
bags.Center = center
bags.Border = border

local bag = fakeButton("MainMenuBarBackpackButton", bags)
bag.width = 37
bag.height = 37
fakeButton("CharacterBag0Slot", bags)
fakeButton("CharacterBag1Slot", bags)
fakeButton("KeyRingButton", bags)

local menu = _G.CreateFrame("Frame", "MicroMenu", _G.UIParent)
_G.MicroMenu = menu
local container = _G.CreateFrame("Frame", "MicroMenuContainer", _G.UIParent)
container:SetPoint("BOTTOMRIGHT", bags, "BOTTOMLEFT", 0, 0)
_G.MicroMenuContainer = container
menu:SetParent(container)
local menuCenter = fakeTex("MicroMenuCenter")
function container:GetRegions()
  return menuCenter
end

local character = fakeButton("CharacterMicroButton", menu)
character.width = 28
character.height = 58

local char = { useShadowUIMenu = true }
function Addon:GetCharDB()
  return char
end

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/micro.lua"))()
Addon:SkinMicroAndBags()

assert(bag.parent == bags, "backpack stays on BagsBar")
assert(bag.points[1][1] == "RIGHT", "backpack keeps its Blizzard point")
assert(bag.width == 37 and bag.height == 37, "backpack keeps native size")
assert(_G.CharacterBag0Slot.parent == bags, "extra bag slots stay on BagsBar")
assert(_G.KeyRingButton.parent == bags, "keyring stays on BagsBar")
assert(bags.shown, "BagsBar stays shown")
assert(bags.points[1][1] == "BOTTOMRIGHT", "BagsBar keeps its Blizzard point")
assert(not center.hidden and center.alpha == 1, "bag bar center art stays")
assert(not border.hidden and border.alpha == 1, "bag bar border art stays")
assert(center.vertex == nil, "bag bar center is not darkened")

local outer = bags.shadowUIOuter
assert(outer and outer.shown ~= false, "bag bar border gets an Outer Edge")
assert(outer.template == "BackdropTemplate", "bag bar Outer Edge uses BackdropTemplate")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true),
  "bag bar Outer Edge uses the Lorti shadow texture")
assert(outer.points[1][4] == -4, "bag bar Outer Edge extends 4px")
assert(bag.shadowUIOuter == nil, "backpack does not get its own Outer Edge")
assert(_G.CharacterBag0Slot.shadowUIOuter == nil, "bag slots do not get an Outer Edge")

assert(character.parent == menu, "micro buttons stay on MicroMenu")
assert(menu.parent == container, "MicroMenu stays on MicroMenuContainer")
assert(character.shadowUIOuter == nil, "micro buttons do not get an Outer Edge")
assert(container.shadowUIOuter and container.shadowUIOuter.shown ~= false,
  "micro bar border gets an Outer Edge")
assert(not menuCenter.hidden, "micro bar center art stays")
assert(_G.ShadowUIMicroCluster == nil, "ShadowUI does not build a Micro Cluster")
assert(_G.ShadowUIMicroExtraPark == nil, "ShadowUI does not park extra buttons")

char.useShadowUIMenu = false
Addon:SkinMicroAndBags()
assert(bags.shadowUIOuter.shown == false, "border shadow hides when the toggle is off")
assert(container.shadowUIOuter.shown == false, "micro border shadow hides when the toggle is off")
assert(bag.parent == bags, "toggle off leaves the backpack on BagsBar")

local dbSrc = assert(io.open(root .. "core/db.lua", "r")):read("*a")
assert(dbSrc:find("useShadowUIMenu%s*=%s*true"), "character default shadows the menu and bag borders")
local configSrc = assert(io.open(root .. "options/config.lua", "r")):read("*a")
assert(configSrc:find("Shadow menu and bag borders"), "/shadowui names the border shadow toggle")

print("micro_bags_spec OK")

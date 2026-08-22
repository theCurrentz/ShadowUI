-- ActionBarController shows MainMenuBar whenever it is hidden. Do not Hide it.
-- Parent it to a hidden park frame after micro/bag buttons are reparented.
-- Run: lua tests/park_main_menu_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.SetActionBarToggles = function() end
_G.UIParent = { name = "UIParent" }
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    return
  end
  local orig = object[method]
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.CreateFrame = function(_, name)
  local frame = { name = name, shown = true, parent = _G.UIParent, points = {} }
  function frame:Hide() self.shown = false end
  function frame:Show() self.shown = true end
  function frame:IsShown() return self.shown end
  function frame:SetParent(parent) self.parent = parent end
  function frame:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:ClearAllPoints() self.points = {} end
  return frame
end

local function fakeBar(name)
  local bar = {
    name = name,
    shown = true,
    parent = _G.UIParent,
    hidden = false,
    scripts = {},
    points = {},
  }
  function bar:Hide() self.shown = false self.hidden = true end
  function bar:Show()
    self.shown = true
    if self.scripts.OnShow then
      self.scripts.OnShow(self)
    end
  end
  function bar:IsShown() return self.shown end
  function bar:SetScript(event, fn) self.scripts[event] = fn end
  function bar:UnregisterAllEvents() end
  function bar:SetAlpha() end
  function bar:EnableMouse() end
  function bar:ClearAllPoints() self.points = {} end
  function bar:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function bar:SetParent(parent) self.parent = parent end
  return bar
end

_G.MainMenuBar = fakeBar("MainMenuBar")
_G.MainMenuBarArtFrame = fakeBar("MainMenuBarArtFrame")
_G.MainMenuBarOverlayFrame = fakeBar("MainMenuBarOverlayFrame")
_G.ActionButton1 = fakeBar("ActionButton1")
_G.PossessBarFrame = fakeBar("PossessBarFrame")
_G.ShapeshiftBarFrame = fakeBar("ShapeshiftBarFrame")
_G.StanceBarFrame = fakeBar("StanceBarFrame")

assert(loadfile(root .. "bars/manager.lua"))()
Addon:HideBlizzardBars()

assert(_G.MainMenuBar.shown, "MainMenuBar must stay shown so ActionBarController does not Show() it")
assert(_G.MainMenuBar.parent and _G.MainMenuBar.parent.name == "ShadowUIBlizzardPark",
  "MainMenuBar must parent to the hidden park frame")
assert(_G.MainMenuBar.parent.shown == false, "park frame stays hidden")
assert(_G.MainMenuBarArtFrame.hidden, "default art frame hides")
assert(_G.ActionButton1.hidden, "default action buttons hide")
assert(_G.MainMenuBarOverlayFrame.hidden, "overlay art still hides")
assert(_G.ShapeshiftBarFrame.hidden, "default shapeshift bar hides")
assert(_G.StanceBarFrame.hidden, "default stance bar hides")

_G.ShapeshiftBarFrame:Show()
assert(_G.ShapeshiftBarFrame.shown == false, "shapeshift Show must not bring the default bar back")
_G.MainMenuBar:Show()
assert(_G.ShapeshiftBarFrame.shown == false, "MainMenuBar Show must re-hide the shapeshift bar")
assert(_G.MainMenuBarArtFrame.hidden, "MainMenuBar Show must re-hide default art")

print("park_main_menu_spec OK")

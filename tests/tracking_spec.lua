-- XP sits on UIParent TOP with no offset; reputation sits directly under XP.
-- Run: lua tests/tracking_spec.lua
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
function _G.UIParent:GetWidth() return 1920 end

local function fakeBar(name, shown)
  local bar = {
    name = name,
    parent = { name = "MainMenuBar" },
    shown = shown,
    points = {},
    height = 13,
  }
  function bar:SetParent(parent) self.parent = parent end
  function bar:IsShown() return self.shown end
  function bar:Show() self.shown = true end
  function bar:Hide() self.shown = false end
  function bar:ClearAllPoints() self.points = {} end
  function bar:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function bar:SetWidth(width) self.width = width end
  function bar:GetHeight() return self.height end
  function bar:SetAlpha() end
  return bar
end

_G.MainMenuExpBar = fakeBar("MainMenuExpBar", true)
_G.ReputationWatchBar = fakeBar("ReputationWatchBar", true)

assert(loadfile(root .. "skin/tracking.lua"))()
Addon:SkinTrackingBars()

local exp = _G.MainMenuExpBar
local rep = _G.ReputationWatchBar
assert(exp.parent == _G.UIParent, "XP bar parents to UIParent")
assert(exp.points[1][1] == "TOP" and exp.points[1][2] == _G.UIParent and exp.points[1][3] == "TOP",
  "XP bar docks to screen top")
assert(exp.points[1][4] == 0 and exp.points[1][5] == 0, "XP bar has no margin")
assert(exp.width == 1920, "XP bar spans the screen")
assert(rep.parent == _G.UIParent, "reputation bar parents to UIParent")
assert(rep.points[1][2] == exp and rep.points[1][3] == "BOTTOM", "reputation sits under XP")
assert(rep.points[1][4] == 0 and rep.points[1][5] == 0, "reputation bar has no margin")

exp:SetPoint("TOP", { name = "MainMenuBar" }, "TOP", 0, 0)
assert(exp.points[#exp.points][2] == _G.UIParent, "Blizzard XP anchors must be undone")

print("tracking_spec OK")

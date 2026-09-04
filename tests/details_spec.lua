-- Details damage and threat charts park from the Currentz chrome lock.
-- Those windows use the Chat zen fade. Run: lua tests/details_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  local orig = object[method]
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.InCombatLockdown = function() return false end
_G.UIParent = { name = "UIParent" }

local driver
_G.CreateFrame = function(_, name)
  if name then
    local frame = { name = name, scripts = {} }
    function frame:SetScript(event, fn) self.scripts[event] = fn end
    function frame:GetScript(event) return self.scripts[event] end
    function frame:RegisterEvent() end
    return frame
  end
  if driver then
    return driver
  end
  driver = { scripts = {} }
  function driver:SetScript(event, fn) self.scripts[event] = fn end
  function driver:GetScript(event) return self.scripts[event] end
  function driver:RegisterEvent() end
  return driver
end

local function fakeFrame(name)
  local frame = { name = name, points = {}, alpha = 1, scripts = {}, mouse = false }
  function frame:GetName() return self.name end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:SetWidth(width) self.width = width end
  function frame:SetHeight(height) self.height = height end
  function frame:SetSize(width, height)
    self.width, self.height = width, height
  end
  function frame:SetUserPlaced() end
  function frame:SetAlpha(a) self.alpha = a end
  function frame:GetAlpha() return self.alpha end
  function frame:EnableMouse(on) self.mouse = on and true or false end
  function frame:HookScript(event, fn)
    self.scripts[event] = self.scripts[event] or {}
    self.scripts[event][#self.scripts[event] + 1] = fn
  end
  return frame
end

assert(loadfile(root .. "core/easing.lua"))()
assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/fade.lua"))()
assert(loadfile(root .. "skin/details.lua"))()
Addon:SkinDetails()

_G.Details = {
  instances = {
    {
      meu_id = 1,
      atributo = 1,
      modo = 2,
      baseframe = fakeFrame("DetailsBaseFrame1"),
      rowframe = fakeFrame("DetailsRowFrame1"),
      windowSwitchButton = fakeFrame("Details_SwitchButtonFrame1"),
    },
    { meu_id = 2, atributo = 1, modo = 2, baseframe = fakeFrame("DetailsBaseFrame2") },
    {
      meu_id = 3,
      modo = 4,
      last_raid_plugin = "DETAILS_PLUGIN_TINY_THREAT",
      isLocked = false,
      baseframe = fakeFrame("DetailsBaseFrame3"),
      rowframe = fakeFrame("DetailsRowFrame3"),
    },
  },
  OnEnterMainWindow = function() end,
  OnLeaveMainWindow = function() end,
}
function _G.Details:GetInstance(id)
  return self.instances[id]
end

Addon:SkinDetails()

local damage = _G.Details.instances[1].baseframe
local rows = _G.Details.instances[1].rowframe
local extra = _G.Details.instances[2].baseframe
local threat = _G.Details.instances[3].baseframe
local threatRows = _G.Details.instances[3].rowframe
assert(damage.points[1][1] == "RIGHT" and damage.points[1][5] == -194, "damage chart is flush right")
assert(damage.width == 153 and damage.height == 164, "damage chart size matches Currentz")
assert(#extra.points == 0, "closed extra damage chart is left alone")
assert(threat.points[1][1] == "BOTTOMRIGHT" and threat.points[1][5] == 150, "threat chart sits above the micro row")
assert(threat.width == 153 and threat.height == 106, "threat chart size matches Currentz")
assert(_G.Details.instances[3].isLocked == true, "threat chart stays locked")
assert(math.abs(damage.alpha - 0.35) < 0.001, "damage chart starts at zen idle alpha")
assert(math.abs(rows.alpha - 0.35) < 0.001, "meter bars start at zen idle alpha")
assert(math.abs(threat.alpha - 0.35) < 0.001, "threat chart starts at zen idle alpha")
assert(math.abs(threatRows.alpha - 0.35) < 0.001, "threat bars start at zen idle alpha")
assert(damage.mouse == true, "damage chart can receive mouse for zen fade")
rows:SetAlpha(1)
assert(math.abs(rows.alpha - 0.35) < 0.001, "meter refresh cannot force row alpha to 1")

for _, fn in ipairs(damage.scripts.OnEnter) do
  fn(damage)
end
Addon:TickFade(0.6)
assert(math.abs(damage.alpha - 0.85) < 0.001, "mouse enter darkens the Details window")
assert(math.abs(rows.alpha - 0.85) < 0.001, "mouse enter darkens meter bars")
assert(math.abs(threat.alpha - 0.35) < 0.001, "threat chart fade is independent")

Addon:SetFadeMouseOver(damage, false)
Addon:TickFade(20)
Addon:TickFade(2.5)
assert(math.abs(damage.alpha - 0.35) < 0.001, "reset damage to idle before Details mouse API")
_G.Details.OnEnterMainWindow(_G.Details.instances[1])
Addon:TickFade(0.6)
assert(math.abs(damage.alpha - 0.85) < 0.001, "Details OnEnterMainWindow darkens the window")
assert(math.abs(rows.alpha - 0.85) < 0.001, "Details OnEnterMainWindow darkens meter bars")
_G.Details.OnLeaveMainWindow(_G.Details.instances[1])

for _, fn in ipairs(damage.scripts.OnLeave) do
  fn(damage)
end
Addon:TickFade(19)
assert(math.abs(damage.alpha - 0.85) < 0.001, "Details linger keeps active alpha")
Addon:TickFade(1)
Addon:TickFade(2.5)
assert(math.abs(damage.alpha - 0.35) < 0.001, "after delay, Details leave reaches idle")

print("details_spec OK")

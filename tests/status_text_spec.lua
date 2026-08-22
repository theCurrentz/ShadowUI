-- Target Frame health and mana captions follow Blizzard Status Text.
-- Native LeftText / RightText / TextString stay hidden so BOTH cannot stack.
-- Run: lua tests/status_text_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function() end
local cvars = { statusTextDisplay = "NUMERIC", statusText = "1" }
_G.GetCVar = function(name)
  return cvars[name]
end
_G.GetCVarBool = function(name)
  return cvars[name] == "1" or cvars[name] == true
end
_G.UnitHealth = function(unit)
  return unit == "target" and 450 or 0
end
_G.UnitHealthMax = function(unit)
  return unit == "target" and 1000 or 1
end
_G.UnitPower = function(unit)
  return unit == "target" and 80 or 0
end
_G.UnitPowerMax = function(unit)
  return unit == "target" and 200 or 1
end

assert(loadfile(root .. "skin/statustext.lua"))()

assert(Addon:StatusBarCaption(450, 1000, "NUMERIC") == "450", "numeric status is current health")
assert(Addon:StatusBarCaption(450, 1000, "PERCENT") == "45%", "percent status is rounded")
assert(Addon:StatusBarCaption(450, 1000, "BOTH") == "450 45%", "both status is current and percent")
assert(Addon:StatusBarCaption(450, 1000, "NONE") == nil, "none hides status text")
assert(Addon:StatusBarCaption(0, 0, "NUMERIC") == nil, "empty bar hides status text")

local function fakeFont(text)
  local fs = { text = text, shown = text ~= nil }
  function fs:SetPoint() end
  function fs:SetText(value) fs.text = value end
  function fs:Show() fs.shown = true end
  function fs:Hide() fs.shown = false end
  return fs
end

local function fakeBar(name)
  local bar = { name = name, unit = "target" }
  function bar:GetName() return name end
  function bar:GetParent() return _G.TargetFrame end
  function bar:HookScript() end
  function bar:CreateFontString()
    local fs = fakeFont()
    bar.font = fs
    return fs
  end
  _G[name] = bar
  return bar
end

_G.TargetFrame = { name = "TargetFrame" }
function _G.TargetFrame:GetName() return "TargetFrame" end
local health = fakeBar("TargetFrameHealthBar")
fakeBar("TargetFrameManaBar")

Addon:SkinTargetStatus()
assert(health.font.text == "450", "target health uses Status Text numeric")

-- Classic Target Frame BOTH uses LeftText percent + RightText current. ShadowUI
-- also paints a centre caption. 1007/1822 is ceil 56% and round 55%, so both
-- layers on one bar read as "56% 1007 55% 1007".
cvars.statusTextDisplay = "BOTH"
_G.UnitHealth = function(unit)
  return unit == "target" and 1007 or 0
end
_G.UnitHealthMax = function(unit)
  return unit == "target" and 1822 or 1
end
health.LeftText = fakeFont("56%")
health.RightText = fakeFont("1007")
health.TextString = fakeFont("56% 1007")
Addon:SkinTargetStatus()
assert(health.font.text == "1007 55%", "target health BOTH is current then percent")
assert(health.LeftText.shown == false, "native left percent does not stack")
assert(health.RightText.shown == false, "native right current does not stack")
assert(health.TextString.shown == false, "native centre string does not stack")
assert(health.font.shown == true, "ShadowUI Status Text stays on")

print("status_text_spec OK")

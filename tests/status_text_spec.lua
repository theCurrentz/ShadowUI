-- Target Frame keeps Blizzard Status Text. ShadowUI does not paint a caption.
-- Run: lua tests/status_text_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end

local function fakeFont(text)
  local fs = { text = text, shown = text ~= nil }
  function fs:SetText(value) fs.text = value end
  function fs:Show() fs.shown = true end
  function fs:Hide() fs.shown = false end
  return fs
end

local function fakeBar(name)
  local bar = { name = name }
  function bar:GetName() return name end
  function bar:CreateFontString()
    error("ShadowUI must not create Status Text")
  end
  _G[name] = bar
  return bar
end

_G.TargetFrame = { name = "TargetFrame" }
function _G.TargetFrame:GetName() return "TargetFrame" end
local health = fakeBar("TargetFrameHealthBar")
fakeBar("TargetFrameManaBar")

assert(loadfile(root .. "skin/statustext.lua"))()

health.LeftText = fakeFont("56%")
health.RightText = fakeFont("1007")
health.TextString = fakeFont("56% 1007")
Addon:SkinTargetStatus()
assert(health.shadowUIStatusText == nil, "ShadowUI does not create health Status Text")
assert(health.LeftText.shown == true, "native left Status Text stays")
assert(health.RightText.shown == true, "native right Status Text stays")
assert(health.TextString.shown == true, "native centre Status Text stays")

health.shadowUIStatusText = fakeFont("1171 53%")
Addon:SkinTargetStatus()
assert(health.shadowUIStatusText.shown == false, "leftover ShadowUI health caption hides")
assert(health.shadowUIStatusText.text == "", "leftover ShadowUI health caption clears")
assert(health.LeftText.shown == true, "native Status Text stays after leftover hide")

print("status_text_spec OK")

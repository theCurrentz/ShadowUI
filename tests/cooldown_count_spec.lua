-- ShadowUI action buttons show remaining cooldown seconds (OmniCC-style count).
-- Counts hide for the GCD and other cooldowns shorter than 2s. The swipe stays.
-- Run: lua tests/cooldown_count_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return {
    GetAddon = function() return Addon end,
    RegisterCallback = function() end,
  }
end
_G.GetTime = function() return 12 end
_G.hooksecurefunc = function(object, method, fn)
  local orig = object[method]
  object[method] = function(self, ...)
    if orig then
      orig(self, ...)
    end
    fn(self, ...)
  end
end

assert(loadfile(root .. "bars/cooldown.lua"))()

assert(Addon:FormatCooldownCount(5) == "5", "short cooldown is seconds")
assert(Addon:FormatCooldownCount(90) == "2m", "minute cooldown rounds")
assert(Addon:FormatCooldownCount(3600) == "1h", "hour cooldown is hours")

local gcd = Addon:CooldownCountState(10, 10, 1.5)
assert(gcd == nil, "GCD does not get a cooldown count")
local long = Addon:CooldownCountState(12, 10, 30)
assert(long.text == "28", "long cooldown shows remaining seconds")
assert(Addon:CooldownCountState(40, 10, 30) == nil, "finished cooldown hides the count")

local count
local button
local cooldown = {
  points = {},
}
function cooldown:SetHideCountdownNumbers(hidden)
  cooldown.nativeHidden = hidden
end
function cooldown:SetCooldown(startTime, duration)
  cooldown.startTime = startTime
  cooldown.duration = duration
end
function cooldown:SetScript(name, fn)
  cooldown.scripts = cooldown.scripts or {}
  cooldown.scripts[name] = fn
end
function cooldown:GetParent()
  return button
end
button = { cooldown = cooldown }
function button:CreateFontString()
  count = {
    shown = false,
    text = "",
    r = 1, g = 1, b = 1,
    flags = "",
    shadowX = 0, shadowY = 0,
  }
  function count:SetPoint() end
  function count:SetText(text) count.text = text end
  function count:Show() count.shown = true end
  function count:Hide() count.shown = false end
  function count:SetTextColor(r, g, b, a)
    count.r, count.g, count.b, count.a = r, g, b, a
  end
  function count:GetFont() return "Fonts\\FRIZQT__.TTF", 12, "" end
  function count:SetFont(path, size, flags)
    count.path, count.size, count.flags = path, size, flags
  end
  function count:SetShadowOffset(x, y)
    count.shadowX, count.shadowY = x, y
  end
  function count:SetShadowColor(r, g, b, a)
    count.shadow = { r, g, b, a }
  end
  return count
end
function button:GetFrameLevel() return 4 end

Addon:SkinCooldownCount(button)
assert(cooldown.nativeHidden == true, "native cooldown numbers stay off")
assert(count.r == 1 and math.abs(count.g - 0.82) < 0.01, "cooldown count is yellow")
assert(count.flags == "OUTLINE", "cooldown count uses an outline")
assert(count.shadowX == 1 and count.shadowY == -1, "cooldown count uses a drop shadow")
cooldown:SetCooldown(10, 30)
cooldown.scripts.OnUpdate(cooldown)
assert(count.text == "28", "action button paints remaining cooldown seconds")

cooldown:SetCooldown(10, 1.5)
cooldown.scripts.OnUpdate(cooldown)
assert(count.shown == false, "GCD swipe has no count")

print("cooldown_count_spec OK")

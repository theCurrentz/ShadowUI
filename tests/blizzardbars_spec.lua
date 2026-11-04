-- Forever skins Blizzard ActionButtons. It does not SetPoint, Hide, or
-- SetAlpha them. pcall of a protected call still pops ADDON_ACTION_FORBIDDEN.
-- Run: lua tests/blizzardbars_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
Addon.events = {}
function Addon:RegisterEvent(event)
  self.events[event] = true
end
function Addon:SkinBarButton(button)
  button.skinned = true
end
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end

local forbidden = 0
local function protect(frame, method)
  frame[method] = function()
    forbidden = forbidden + 1
    error(method .. " is protected")
  end
end

local function fakeButton(name)
  local button = { name = name, points = {}, alpha = 1 }
  function button:GetName() return self.name end
  function button:ClearAllPoints()
    self.cleared = (self.cleared or 0) + 1
    self.points = {}
  end
  function button:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function button:SetHitRectInsets()
    self.hitRect = true
  end
  function button:SetAlpha(a) self.alpha = a end
  function button:EnableMouse() end
  function button:Hide() end
  function button:SetParent() end
  return button
end

_G.ActionButton1 = fakeButton("ActionButton1")
_G.ActionButton2 = fakeButton("ActionButton2")
_G.ActionButton1Icon = { name = "icon" }
_G.MainMenuBarLeftEndCap = fakeButton("MainMenuBarLeftEndCap")
_G.MainMenuBarArtFrame = fakeButton("MainMenuBarArtFrame")
_G.StatusTrackingBarManager = fakeButton("StatusTrackingBarManager")
for _, frame in ipairs({
  _G.ActionButton1,
  _G.ActionButton2,
  _G.MainMenuBarLeftEndCap,
  _G.MainMenuBarArtFrame,
  _G.StatusTrackingBarManager,
}) do
  protect(frame, "SetAlpha")
  protect(frame, "Hide")
  protect(frame, "SetParent")
  protect(frame, "SetPoint")
  protect(frame, "EnableMouse")
  protect(frame, "SetHitRectInsets")
end

local blizzardCooldown = function() end
_G.ActionButton_UpdateCooldown = blizzardCooldown

-- Blizzard Update reads these keys. An addon write taints the drag grid, so
-- empty Action Slots stay hidden and a drop clicks through.
local writes = {}
for _, button in ipairs({ _G.ActionButton1, _G.ActionButton2 }) do
  setmetatable(button, {
    __newindex = function(t, k, v)
      writes[#writes + 1] = tostring(k)
      rawset(t, k, v)
    end,
  })
end

assert(loadfile(root .. "skin/blizzardbars.lua"))()
Addon:SkinBlizzardActionBars()

assert(_G.ActionButton1.skinned, "slot 1 gets Lorti chrome")
assert(_G.ActionButton2.skinned, "slot 2 gets Lorti chrome")
assert(not _G.ActionButton2.cleared, "do not ClearAllPoints default ActionButtons")
assert(#_G.ActionButton2.points == 0, "do not SetPoint default ActionButtons")
assert(not _G.ActionButton1.hitRect, "do not SetHitRectInsets default ActionButtons")
assert(forbidden == 0, "pcall of SetAlpha/Hide on bar art still pops the Blizzard dialog")
assert(_G.MainMenuBarLeftEndCap.alpha == 1, "gryphon art stays; Darken tints it")
assert(Addon.events.ACTIONBAR_SLOT_CHANGED,
  "slot changes re-skin so hidden Action Slots drop Outer Edge")
assert(_G.ActionButton_UpdateCooldown == blizzardCooldown,
  "do not replace ActionButton_UpdateCooldown; Blizzard Update calls it")
local blizzardWrites = {}
for _, key in ipairs(writes) do
  if key ~= "skinned" then
    blizzardWrites[#blizzardWrites + 1] = key
  end
end
assert(#blizzardWrites == 0,
  "do not write keys on Blizzard ActionButtons: " .. table.concat(blizzardWrites, ", "))

print("blizzardbars_spec OK")

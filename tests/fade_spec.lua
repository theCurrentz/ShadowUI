-- FadeDriver eases a host between idle and active alpha. Enter is 0.6s,
-- leave is 0.4s, and an optional delay can linger before leave. The OnUpdate
-- driver is off when every host is at rest. Per-Bar fadeIdle, Micro Cluster
-- microFadeIdle, and Experience bar xpFadeIdle register as hosts. Empty
-- Action Slots stay at alpha 0.
-- Run: lua tests/fade_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function(name)
  if name == "LibActionButton-1.0" then
    return { RegisterCallback = function() end }
  end
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end

local driver
_G.CreateFrame = function()
  driver = { scripts = {} }
  function driver:SetScript(event, fn) self.scripts[event] = fn end
  function driver:GetScript(event) return self.scripts[event] end
  function driver:RegisterEvent() end
  return driver
end

local function fakeFrame(name)
  local frame = { name = name, alpha = 1, shown = true, mouseOver = false }
  function frame:SetAlpha(a) self.alpha = a end
  function frame:GetAlpha() return self.alpha end
  function frame:IsShown() return self.shown end
  function frame:IsMouseOver() return self.mouseOver end
  function frame:EnableMouse() end
  function frame:SetScript() end
  function frame:HookScript() end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  return frame
end

assert(loadfile(root .. "core/easing.lua"))()
assert(loadfile(root .. "skin/fade.lua"))()

local host = fakeFrame("bar1")
Addon:RegisterFadeHost({
  frame = host,
  idleAlpha = 0.4,
  activeAlpha = 1,
})
assert(math.abs(host.alpha - 0.4) < 0.001, "a new host snaps to idle alpha")
assert(not Addon:FadeDriverRunning(), "driver is off at rest")

Addon:SetFadeMouseOver(host, true)
assert(Addon:FadeDriverRunning(), "mouseover starts the driver")
Addon:TickFade(0.6)
assert(math.abs(host.alpha - 1) < 0.001, "enter reaches active alpha in 0.6s")
assert(not Addon:FadeDriverRunning(), "driver stops at active rest")

Addon:SetFadeMouseOver(host, false)
Addon:TickFade(0.4)
assert(math.abs(host.alpha - 0.4) < 0.001, "leave reaches idle alpha in 0.4s")
assert(not Addon:FadeDriverRunning(), "driver stops at idle rest")

local delayed = fakeFrame("chat")
Addon:RegisterFadeHost({
  frame = delayed,
  idleAlpha = 0.35,
  activeAlpha = 0.85,
  delay = 20,
  leaveDur = 2.5,
  useForced = false,
})
Addon:SetFadeMouseOver(delayed, true)
Addon:TickFade(0.6)
assert(math.abs(delayed.alpha - 0.85) < 0.001, "delayed host reaches active alpha")
Addon:SetFadeMouseOver(delayed, false)
Addon:TickFade(19)
assert(math.abs(delayed.alpha - 0.85) < 0.001, "linger delay keeps active alpha")
Addon:TickFade(1)
Addon:TickFade(2.5)
assert(math.abs(delayed.alpha - 0.35) < 0.001, "after delay, leave reaches idle in 2.5s")
_G.InCombatLockdown = function() return true end
Addon:WakeFadeDriver()
Addon:TickFade(0.6)
assert(math.abs(delayed.alpha - 0.35) < 0.001, "Chat fade does not use combat")
_G.InCombatLockdown = function() return false end

local combat = fakeFrame("bar2")
Addon:RegisterFadeHost({
  frame = combat,
  idleAlpha = 0.2,
  activeAlpha = 1,
})
_G.InCombatLockdown = function() return true end
Addon:WakeFadeDriver()
Addon:TickFade(0.6)
assert(math.abs(combat.alpha - 1) < 0.001, "combat forces active alpha")
_G.InCombatLockdown = function() return false end
Addon:TickFade(0.4)
assert(math.abs(combat.alpha - 0.2) < 0.001, "leaving combat starts the leave")

assert(loadfile(root .. "bars/button.lua"))()

local bar1 = fakeFrame("ShadowUIBar1")
local bar2 = fakeFrame("ShadowUIBar2")
local empty = fakeFrame("slot")
empty.setAlphaCalls = 0
function empty:SetAlpha(a)
  self.alpha = a
  self.setAlphaCalls = self.setAlphaCalls + 1
end
function empty:HasAction() return false end
function empty:HookScript() end
bar1.buttons = { empty }
bar2.buttons = {}
Addon.bars = { bar1 = bar1, bar2 = bar2 }
Addon:ApplyBarFades({
  layout = {
    bar1 = { fadeIdle = 0.25 },
    bar2 = { fadeIdle = 1 },
  },
})
assert(math.abs(bar1.alpha - 0.25) < 0.001, "Bar 1 uses its Layout fadeIdle")
assert(math.abs(bar2.alpha - 1) < 0.001, "Bar 2 with fadeIdle 1 stays opaque")
Addon:PaintEmptySlotVisibility(empty)
assert(empty.alpha == 0, "an empty Action Slot stays at alpha 0")
local emptyCalls = empty.setAlphaCalls
Addon:SetFadeMouseOver(bar1, true)
Addon:TickFade(0.6)
assert(math.abs(bar1.alpha - 1) < 0.001, "mouseover raises Bar 1 to 1")
assert(math.abs(bar2.alpha - 1) < 0.001, "Bar 2 stays opaque while Bar 1 fades in")
assert(empty.alpha == 0, "fade does not show an empty Action Slot")
assert(empty.setAlphaCalls == emptyCalls, "fade does not SetAlpha on LAB buttons")

Addon.editMode = true
Addon:WakeFadeDriver()
Addon:TickFade(0.6)
assert(math.abs(bar1.alpha - 1) < 0.001, "Layout Edit Mode raises Bar fade")
Addon.editMode = false
Addon.keybindMode = true
Addon:WakeFadeDriver()
Addon:TickFade(0)
assert(math.abs(bar1.alpha - 1) < 0.001, "Keybind Edit Mode keeps Bar fade active")
Addon.keybindMode = false

_G.ShadowUIMicroCluster = fakeFrame("ShadowUIMicroCluster")
function Addon:GetCharDB()
  return { useShadowUIMenu = true, microFadeIdle = 0.5 }
end
Addon:ApplyMicroFade()
assert(math.abs(_G.ShadowUIMicroCluster.alpha - 0.5) < 0.001, "Micro Cluster uses Character fade idle")
Addon:SetFadeMouseOver(_G.ShadowUIMicroCluster, true)
Addon:TickFade(0.6)
assert(math.abs(_G.ShadowUIMicroCluster.alpha - 1) < 0.001, "Micro Cluster mouseover raises to 1")

_G.ShadowUIXPHost = fakeFrame("ShadowUIXPHost")
_G.MainStatusTrackingBarContainer = fakeFrame("MainStatusTrackingBarContainer")
function Addon:GetCharDB()
  return { xpFadeIdle = 0.15 }
end
Addon:ApplyXPFade()
assert(math.abs(_G.ShadowUIXPHost.alpha - 0.15) < 0.001, "Experience bar uses Character fade idle")
Addon:SetFadeMouseOver(_G.ShadowUIXPHost, true)
Addon:TickFade(0.6)
assert(math.abs(_G.ShadowUIXPHost.alpha - 1) < 0.001, "Experience bar mouseover raises to 1")
Addon:SetFadeMouseOver(_G.ShadowUIXPHost, false)
Addon:TickFade(0.4)
assert(math.abs(_G.ShadowUIXPHost.alpha - 0.15) < 0.001, "Experience bar leave reaches idle alpha")
_G.InCombatLockdown = function() return true end
Addon:WakeFadeDriver()
Addon:TickFade(0.6)
assert(math.abs(_G.ShadowUIXPHost.alpha - 1) < 0.001, "combat raises Experience bar fade")
_G.InCombatLockdown = function() return false end

print("fade_spec OK")

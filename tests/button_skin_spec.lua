-- Action-button chrome is a 0.05 fill with a 2px icon inset, a 0.07 crop,
-- hover/press colour overlay, a GCD clock swipe, a 4px Lorti outer edge, and a
-- press overlay that snaps off on up and stays through a player cast.
-- The icon must not fill the whole button or the chrome is covered.
-- An Action Slot with no spell, macro, or item stays hidden, including its Keybind,
-- except during Keybind Edit Mode or a pickup.
-- Keybind labels are gold thick-outlined uppercase text. Item counts are pale lime.
-- Run: lua tests/button_skin_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return {
    GetAddon = function() return Addon end,
    RegisterCallback = function() end,
  }
end
_G.CreateFrame = function(_, _, parent, template)
  local frame = { points = {}, parent = parent, template = template, shown = true }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetAllPoints(owner) self.all = owner end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:EnableMouse(on) self.mouse = on and true or false end
  function frame:SetScript(name, fn)
    self.scripts = self.scripts or {}
    self.scripts[name] = fn
  end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor(r, g, b, a)
    self.fill = { r, g, b, a }
  end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:SetParent(parent) self.parent = parent end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:ApplyBackdrop()
    self.border = { 1, 1, 1, 1 }
  end
  return frame
end

local function fakeTex()
  local tex = { points = {}, r = 1, g = 1, b = 1, shown = true }
  function tex:SetTexture() end
  function tex:SetAlpha(a) self.a = a end
  function tex:Hide() self.hidden = true self.shown = false end
  function tex:Show() self.hidden = false self.shown = true end
  function tex:IsShown() return self.shown ~= false and not self.hidden end
  function tex:SetScript(name, fn)
    if name == "OnUpdate" then
      error('Texture:SetScript(): Doesn\'t have a "OnUpdate" script')
    end
    self.scripts = self.scripts or {}
    self.scripts[name] = fn
  end
  function tex:SetVertexColor(r, g, b, a)
    self.r, self.g, self.b = r, g, b
    if a then
      self.a = a
    end
  end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetAllPoints(frame) self.all = frame end
  function tex:SetPoint(point, a, b, c, d)
    self.points[#self.points + 1] = { point, a, b, c, d }
  end
  function tex:SetTexCoord(l, r, t, b)
    self.crop = { l, r, t, b }
  end
  function tex:SetDrawLayer() end
  function tex:SetBlendMode() end
  return tex
end

local hotkey = { shown = true, text = "1" }
function hotkey:SetText(text) self.text = text end
function hotkey:Show() self.shown = true end
function hotkey:Hide() self.shown = false end
function hotkey:SetFont(path, size, flags)
  self.font = { path, size, flags }
end
function hotkey:SetTextColor(r, g, b, a)
  self.color = { r, g, b, a }
end
function hotkey:SetVertexColor(r, g, b, a)
  self.vertex = { r, g, b, a }
end
function hotkey:SetShadowOffset(x, y)
  self.shadowOffset = { x, y }
end
function hotkey:SetShadowColor(r, g, b, a)
  self.shadowColor = { r, g, b, a }
end
local countLabel = { shown = true, text = "20" }
function countLabel:SetFont(path, size, flags)
  self.font = { path, size, flags }
end
function countLabel:SetTextColor(r, g, b, a)
  self.color = { r, g, b, a }
end
function countLabel:SetVertexColor(r, g, b, a)
  self.vertex = { r, g, b, a }
end
function countLabel:SetShadowOffset(x, y)
  self.shadowOffset = { x, y }
end
function countLabel:SetShadowColor(r, g, b, a)
  self.shadowColor = { r, g, b, a }
end
function countLabel:ClearAllPoints()
  self.points = {}
end
function countLabel:SetPoint(...)
  self.points = self.points or {}
  self.points[#self.points + 1] = { ... }
end
local macroName = { shown = true, text = "Macro" }
function macroName:SetText(text) self.text = text end
function macroName:Hide() self.shown = false end

local button = {
  icon = fakeTex(),
  NormalTexture = fakeTex(),
  HighlightTexture = fakeTex(),
  PushedTexture = fakeTex(),
  cooldown = fakeTex(),
  HotKey = hotkey,
  Count = countLabel,
  Name = macroName,
  alpha = 1,
}
function button:SetAlpha(a)
  self.alpha = a
end
button.hooks = {}
function button:HookScript(name, fn)
  self.hooks[name] = self.hooks[name] or {}
  self.hooks[name][#self.hooks[name] + 1] = fn
end
button.cooldown.clearCount = 0
function button.cooldown:ClearAllPoints()
  self.clearCount = self.clearCount + 1
  self.points = {}
end
function button.cooldown:SetDrawSwipe(on)
  self.swipe = on
end
function button.cooldown:SetSwipeColor(r, g, b, a)
  self.swipeColor = { r, g, b, a }
end
function button.cooldown:SetDrawEdge(on)
  self.edge = on
end
function button.cooldown:SetDrawBling(on)
  self.bling = on
end
function button.cooldown:SetFrameLevel(level)
  self.level = level
end
function button:CreateTexture()
  local tex = fakeTex()
  if not button.chrome then
    button.chrome = tex
  end
  return tex
end
function button:GetName()
  return "ShadowUIActionButton1"
end
button.hitRectCalls = 0
function button:SetHitRectInsets()
  self.hitRectCalls = self.hitRectCalls + 1
end
local combat = false
_G.InCombatLockdown = function()
  return combat
end
function button:GetFrameLevel() return 4 end
function button:SetFrameLevel() end
function button:SetClipsChildren(clips) self.clipsChildren = clips end
local barHost = { name = "ShadowUIBar1" }
function button:GetParent() return barHost end

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "bars/button.lua"))()
Addon:SkinBarButton(button)

assert(button.chrome, "button must create a chrome fill")
assert(button.chrome.r == 0.05 and button.chrome.g == 0.05 and button.chrome.b == 0.05,
  "spell-icon chrome is Lorti darkest")
assert(button.chrome.all == button, "chrome fills the button so the inset shows it")
assert(button.icon.all == nil, "icon must not cover the chrome")
assert(button.icon.points[1][1] == "TOPLEFT" and button.icon.points[1][2] == 2,
  "icon insets 2px from the top-left")
assert(button.icon.points[2][1] == "BOTTOMRIGHT" and button.icon.points[2][2] == -2,
  "icon insets 2px from the bottom-right")
assert(button.icon.crop[1] == 0.07 and button.icon.crop[3] == 0.07,
  "icon crop is 0.07 so the picture is not over-zoomed")
assert(button.NormalTexture.hidden, "default silver slot art stays hidden")
assert(not button.HighlightTexture.hidden, "hover overlay stays available")
assert(button.HighlightTexture.r == 0 and button.HighlightTexture.a == 0.22,
  "hover overlay is a slight darkening")
assert(button.PushedTexture.hidden, "native pushed plate stays hidden")
assert(macroName.shown == false, "macro names stay hidden")
assert(macroName.text == "", "macro name text is cleared")
assert(hotkey.font and hotkey.font[2] == 16 and hotkey.font[3] == "THICKOUTLINE",
  "Keybind label is enlarged thick-outlined text")
assert(hotkey.color and hotkey.color[1] == 1 and hotkey.color[2] == 0.82 and hotkey.color[3] == 0,
  "Keybind label is gold so it reads on Darken icons")
assert(countLabel.font and countLabel.font[2] == 15 and countLabel.font[3] == "OUTLINE",
  "item count is smaller outlined text")
assert(countLabel.color and countLabel.color[1] == 0.7 and countLabel.color[2] == 0.88
  and countLabel.color[3] == 0.55 and countLabel.color[4] == 0.75, "item count is pale lime")
assert(countLabel.points and countLabel.points[1] and countLabel.points[1][1] == "BOTTOMRIGHT"
  and countLabel.points[1][3] == -5,
  "item count sits below the bottom edge of the Action Slot")
assert(Addon:PressGlowAlpha(0) == 0, "press overlay snaps off with no fade")
assert(Addon:PressGlowAlpha(0, 0.04) > 0, "PressGlowAlpha still maps a duration when given one")
assert(not Addon:BindingKeyIsDown("SHIFT-Q"), "idle keybind is not held")
assert(button.cooldown.points[1][1] == "TOPLEFT" and button.cooldown.points[1][2] == 2,
  "GCD swipe insets with the icon")
assert(button.cooldown.swipe == true, "GCD swipe is on")
assert(button.cooldown.edge == true, "GCD clock edge is on")
assert(button.cooldown.bling == true, "GCD refresh bling is on")
local outer = button.shadowUIOuter
assert(outer, "button keeps a Lorti outer edge")
assert(outer.template == "BackdropTemplate", "outer edge uses BackdropTemplate")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true), "outer edge uses the Lorti shadow texture")
assert(outer.backdrop.edgeSize == 5, "outer edge size matches Lorti")
assert(outer.border[1] == 0 and outer.border[2] == 0 and outer.border[3] == 0
  and outer.border[4] == 0.9, "outer edge is black at 0.9")
assert(outer.fill[1] == 0 and outer.fill[4] == 0, "outer edge has no grey fill")
assert(outer.parent == barHost, "outer edge is a sibling of the action button")
assert(button.clipsChildren == false, "the action button does not clip Outer Edge")
assert(outer.points[1][1] == "TOPLEFT" and outer.points[1][4] == -4,
  "outer edge extends 4px past the button")
assert(outer.level == 3, "outer edge sits behind the button")

assert(button.hitRectCalls == 1, "full-button hit rect is applied out of combat")
combat = true
Addon:SkinBarButton(button)
assert(button.hitRectCalls == 1, "do not call SetHitRectInsets in combat")
assert(button.cooldown.clearCount == 1, "do not re-anchor cooldown or the GCD swipe restarts")
outer.border = { 1, 1, 1, 1 }
Addon:SkinBarButton(button)
assert(outer.border[1] == 0 and outer.border[4] == 0.9,
  "Outer Edge stays black after a later Action Slot update")
outer:ApplyBackdrop()
Addon:SkinBarButton(button)
assert(outer.border[1] == 0 and outer.border[4] == 0.9,
  "Outer Edge stays black after BackdropTemplate resets the border to white")

function button:HasAction()
  return false
end
button.shadowUIHotkey = "1"
button.shown = true
function button:Hide()
  self.shown = false
end
Addon:SkinBarButton(button)
assert(button.shown ~= false, "an empty Action Slot stays a drop target")
assert(button.alpha == 0, "an empty Action Slot is invisible")
assert(button.HotKey.shown == false, "an empty Action Slot hides its Keybind")
assert(button.chrome.hidden, "an empty Action Slot does not keep Darken chrome")
assert(button.shadowUIOuter.shown == false, "an empty Action Slot does not keep an Outer Edge")

Addon.keybindMode = true
Addon:SkinBarButton(button)
assert(button.alpha == 1, "Keybind Edit Mode shows empty Action Slots")
assert(not button.chrome.hidden, "Keybind Edit Mode paints empty Action Slot chrome")
assert(button.HotKey.shown == true, "Keybind Edit Mode shows the Keybind on an empty Action Slot")
Addon.keybindMode = false

_G.GetCursorInfo = function()
  return "spell"
end
Addon:SkinBarButton(button)
assert(button.alpha == 1, "a pickup shows empty Action Slots")
assert(not button.chrome.hidden, "a pickup paints empty Action Slot chrome")
assert(button.shadowUIOuter.shown, "a pickup paints empty Action Slot Outer Edge")
assert(button.HotKey.shown == true, "a pickup shows the Keybind on an empty Action Slot")
_G.GetCursorInfo = function() end
Addon:SkinBarButton(button)
assert(button.alpha == 0, "clearing the cursor hides empty Action Slots again")
assert(button.HotKey.shown == false, "clearing the cursor hides empty Action Slot Keybinds")

Addon.actionBarGridCount = 1
Addon:SkinBarButton(button)
assert(button.alpha == 1, "ACTIONBAR_SHOWGRID shows empty Action Slots")
assert(button.HotKey.shown == true, "ACTIONBAR_SHOWGRID shows the Keybind on an empty Action Slot")
Addon.bars = { bar1 = { buttons = { button } } }
Addon:OnActionBarHideGrid()
assert(button.alpha == 0, "ACTIONBAR_HIDEGRID hides empty Action Slots again")

function button:HasAction()
  return true
end
Addon:SkinBarButton(button)
assert(button.alpha == 1, "a bound Action Slot is visible")
assert(not button.chrome.hidden, "a bound Action Slot keeps Darken chrome")
assert(button.shadowUIOuter.shown, "a bound Action Slot keeps an Outer Edge")

local bar = { fill = fakeTex(), shadow = fakeTex() }
bar.fill.hidden = false
Addon:ApplyBarChrome(bar)
assert(bar.fill.hidden, "the Bar does not paint a black fill under empty Action Slots")

_G.GetTime = function() return 10 end
local now = 10
_G.GetTime = function() return now end
local glowOk, glowErr = pcall(function()
  Addon:ShowPressGlow(button)
end)
assert(glowOk, "press glow must not SetScript OnUpdate on a Texture: " .. tostring(glowErr))
local glow = button.shadowUIPressGlow
assert(glow, "press glow creates an overlay")
assert(glow.shown ~= false and not glow.hidden, "press glow shows while held")
assert(math.abs((glow.a or 0) - 0.40) < 0.01, "press overlay alpha is 0.40")
assert(glow.points[1] and glow.points[1][1] == "TOPLEFT" and glow.points[1][2] == 4,
  "press overlay insets 4px so it is not a full-slot plate")
assert(button.icon.points[1] and button.icon.points[1][2] == 2,
  "press does not push the icon in")
assert(not (glow.scripts and glow.scripts.OnUpdate), "Texture has no OnUpdate script")
button.shadowUIPressHeld = true
Addon:ShowPressGlow(button)
Addon:HidePressGlow(button)
assert(not button.shadowUIPressHeld, "release clears the held flag")
assert(glow.hidden, "release snaps the overlay off")
assert(button.icon.points[1][2] == 2, "idle icon inset stays 2px")
local watch = button.shadowUIPressWatch
assert(watch, "press watch exists")
assert(watch.mouse == false, "press watch does not steal clicks")
assert(not (watch.scripts and watch.scripts.OnUpdate), "snap hide stops OnUpdate")
Addon:ShowPressGlow(button)
Addon:ClearPressGlow(button)
assert(glow.hidden, "ClearPressGlow hides the overlay while idle")
assert(glow.a == 0, "idle overlay alpha is 0")

assert(button.hooks.OnMouseDown and button.hooks.OnMouseDown[1],
  "click down hooks the press overlay")
now = 15
button.hooks.OnMouseDown[1]()
assert(button.shadowUIPressHeld, "click down holds the press overlay")
assert(glow.shown ~= false and not glow.hidden, "click down shows the press overlay")
assert(button.icon.points[1][2] == 2, "click down does not change icon inset")
button.hooks.OnMouseUp[1]()
assert(not button.shadowUIPressHeld, "click up releases the held flag")
assert(glow.hidden, "click up snaps the overlay off")
assert(not Addon:PressGlowIsActive(button, 15.05), "click up does not keep the overlay")

_G.IsMouseButtonDown = function()
  return false
end
now = 16
button.hooks.OnMouseDown[1]()
assert(not glow.hidden, "click down shows the overlay before mouse poll")
watch.scripts.OnUpdate(watch)
assert(glow.hidden, "a missing mouse up snaps the overlay off")
_G.IsMouseButtonDown = nil

_G.IsKeyDown = function(key)
  return key == "Q"
end
button.shadowUIBindingKey = "Q"
now = 20
Addon:ClearPressGlow(button)
button.hooks.OnClick[1]()
assert(glow.shown ~= false and not glow.hidden, "key down shows the press overlay")
watch.scripts.OnUpdate(watch)
assert(not glow.hidden, "a held Keybind keeps the press overlay")
_G.IsKeyDown = function()
  return false
end
watch.scripts.OnUpdate(watch)
assert(glow.hidden, "key up snaps the overlay off")

button._state_action = 1
_G.GetActionInfo = function()
  return "spell", 133
end
assert(Addon:ActionSlotSpellID(button) == 133, "Action Slot spell id comes from GetActionInfo")
now = 30
button.hooks.OnMouseDown[1]()
Addon:OnPressCastEvent("UNIT_SPELLCAST_START", "player", "guid", 133)
button.hooks.OnMouseUp[1]()
assert(button.shadowUIPressCast, "START latches the pressed Action Slot")
assert(glow.shown ~= false and not glow.hidden, "a cast keeps the overlay after mouse up")
assert(button.icon.points[1][2] == 2, "a latched cast does not push the icon in")
now = 32
Addon:OnPressCastEvent("UNIT_SPELLCAST_STOP", "player", "guid", 133)
assert(not button.shadowUIPressCast, "STOP clears the cast latch")
assert(glow.hidden, "STOP snaps the overlay off when the key is up")

now = 40
button.hooks.OnMouseDown[1]()
Addon:OnPressCastEvent("UNIT_SPELLCAST_CHANNEL_START", "player", "guid", 133)
button.hooks.OnMouseUp[1]()
_G.UnitChannelInfo = function()
  return "Blizzard"
end
Addon:OnPressCastEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "guid", 133)
assert(button.shadowUIPressCast, "channel SUCCEEDED does not clear the latch")
assert(not glow.hidden, "a channel keeps the overlay")
_G.UnitChannelInfo = nil
Addon:OnPressCastEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player", "guid", 133)
assert(glow.hidden, "CHANNEL_STOP snaps the overlay off")

now = 50
button.hooks.OnMouseDown[1]()
Addon:OnPressCastEvent("UNIT_SPELLCAST_START", "player", "guid", 116)
assert(not button.shadowUIPressCast, "a different spell does not latch this Action Slot")
button.hooks.OnMouseUp[1]()
assert(glow.hidden, "a mismatched START still snaps off on mouse up")
Addon:ClearPressGlow(button)

now = 60
button.hooks.OnMouseDown[1]()
Addon:OnPressCastEvent("UNIT_SPELLCAST_START", "player", "guid", 133)
button.hooks.OnMouseUp[1]()
Addon:OnPressCastEvent("UNIT_SPELLCAST_FAILED", "player", "guid", 133)
assert(glow.hidden, "FAILED snaps the overlay off")

now = 70
button.hooks.OnClick[1]()
Addon:OnPressCastEvent("UNIT_SPELLCAST_START", "player", "guid", 133)
_G.IsKeyDown = function() return false end
watch.scripts.OnUpdate(watch)
assert(button.shadowUIPressCast, "START latches a Keybind press")
assert(not glow.hidden, "a Keybind cast keeps the overlay after key up")
Addon:OnPressCastEvent("UNIT_SPELLCAST_STOP", "player", "guid", 133)
assert(glow.hidden, "STOP snaps a Keybind cast overlay off")

local initSrc = assert(io.open(root .. "core/init.lua", "r")):read("*a")
assert(initSrc:find('UNIT_SPELLCAST_START", "OnPressCastEvent"', 1, true),
  "init registers START for the press overlay")
assert(initSrc:find('UNIT_SPELLCAST_CHANNEL_STOP", "OnPressCastEvent"', 1, true),
  "init registers channel stop for the press overlay")

print("button_skin_spec OK")

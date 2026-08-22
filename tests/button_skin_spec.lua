-- Action-button chrome is a 0.05 fill with a 2px icon inset, a 0.07 crop,
-- hover/press darken, a GCD clock swipe, and a 4px Lorti outer edge.
-- The icon must not fill the whole button or the chrome is covered.
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
  local frame = { points = {}, parent = parent, template = template }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:Show() self.shown = true end
  return frame
end

local function fakeTex()
  local tex = { points = {}, r = 1, g = 1, b = 1 }
  function tex:SetTexture() end
  function tex:SetAlpha(a) self.a = a end
  function tex:Hide() self.hidden = true end
  function tex:Show() self.hidden = false end
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

local button = {
  icon = fakeTex(),
  NormalTexture = fakeTex(),
  HighlightTexture = fakeTex(),
  PushedTexture = fakeTex(),
  cooldown = fakeTex(),
}
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
  button.chrome = tex
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
assert(not button.PushedTexture.hidden, "pressed overlay stays available")
assert(button.PushedTexture.r == 0 and button.PushedTexture.a == 0.45,
  "pressed overlay is a deeper darkening")
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
assert(outer.border[1] == 0 and outer.border[4] == 0.9, "outer edge is black at 0.9")
assert(outer.points[1][1] == "TOPLEFT" and outer.points[1][4] == -4,
  "outer edge extends 4px past the button")
assert(outer.level == 3, "outer edge sits behind the button")

assert(button.hitRectCalls == 1, "full-button hit rect is applied out of combat")
combat = true
Addon:SkinBarButton(button)
assert(button.hitRectCalls == 1, "do not call SetHitRectInsets in combat")
assert(button.cooldown.clearCount == 1, "do not re-anchor cooldown or the GCD swipe restarts")

print("button_skin_spec OK")

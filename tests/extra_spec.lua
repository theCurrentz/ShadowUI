-- Blizzard Extra Action Button keeps its place. ShadowUI applies icon chrome
-- and a circle Outer Edge. ExtraActionBarFrame stays shown.
-- Run: lua tests/extra_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    local name, hook = object, method
    local orig = _G[name]
    _G[name] = function(...)
      orig(...)
      hook(...)
    end
    return
  end
  local orig = object[method]
  object[method] = function(...)
    orig(...)
    fn(...)
  end
end
_G.CreateFrame = function(_, _, parent, template)
  local frame = { points = {}, parent = parent, template = template, shown = true, textures = {} }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetFrameLevel(level) self.level = level end
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
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:SetAllPoints(host) self.all = host end
    function tex:SetTexture(path) self.file = path end
    function tex:Hide() self.hidden = true end
    function tex:Show() self.hidden = false end
    self.textures[#self.textures + 1] = tex
    return tex
  end
  return frame
end

local function fakeTex()
  local tex = { points = {}, r = 1, g = 1, b = 1, a = 1 }
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetAllPoints(frame) self.all = frame end
  function tex:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function tex:SetTexCoord(l, r, t, b) self.crop = { l, r, t, b } end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetTexture(path)
    self.texture = path
  end
  function tex:GetTexture()
    return self.texture
  end
  function tex:SetAlpha(a) self.a = a end
  function tex:SetDrawLayer() end
  function tex:Hide() self.hidden = true end
  function tex:Show() self.hidden = false end
  return tex
end

local barHost = { name = "ExtraActionBarFrame", clips = true, shown = true }
function barHost:SetClipsChildren(clips) self.clips = clips end
function barHost:IsShown() return self.shown end
_G.ExtraActionBarFrame = barHost

local button = {
  name = "ExtraActionButton1",
  shown = true,
  NormalTexture = fakeTex(),
  style = fakeTex(),
}
local icon = fakeTex()
icon.texture = "Interface\\Icons\\INV_Misc_QuestionMark"
function button:GetName() return "ExtraActionButton1" end
function button:IsShown() return self.shown end
function button:CreateTexture()
  local tex = fakeTex()
  if not button.chrome then
    button.chrome = tex
  end
  return tex
end
function button:GetFrameLevel() return 4 end
function button:SetFrameLevel() end
function button:SetClipsChildren(clips) self.clipsChildren = clips end
function button:GetParent() return barHost end
_G.ExtraActionButton1 = button
_G.ExtraActionButton1Icon = icon
_G.ExtraActionButtonStyle = fakeTex()
_G.ExtraActionBar_Update = function() end

assert(loadfile(root .. "skin/shape.lua"))()
assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/extra.lua"))()
Addon:SkinExtraActionBar()

assert(button.chrome.r == 0.05 and button.chrome.g == 0.05 and button.chrome.b == 0.05,
  "Extra Action chrome is Lorti darkest")
assert(icon.points[1][1] == "TOPLEFT" and icon.points[1][2] == 2,
  "Extra Action icon insets 2px")
assert(icon.crop[1] == 0.07 and icon.crop[3] == 0.07,
  "Extra Action icon crop matches action icons")
assert(button.NormalTexture.hidden or button.NormalTexture.a == 0,
  "Extra Action silver slot art stays hidden")
assert(button.style.hidden or button.style.a == 0,
  "Extra Action style art stays hidden")
assert(_G.ExtraActionButtonStyle.hidden or _G.ExtraActionButtonStyle.a == 0,
  "ExtraActionButtonStyle stays hidden")
assert(button.shadowUIOuterShape == "circle", "Extra Action keeps a circle Outer Edge")
assert(barHost.clips == false, "Extra Action Bar does not clip Outer Edge")
assert(button.clipsChildren == false, "Extra Action Button does not clip Outer Edge")

button.shown = false
icon.texture = nil
Addon:SkinExtraActionBar()
assert(not button.chrome or button.chrome.hidden,
  "a hidden Extra Action Button does not keep Darken chrome")

print("extra_spec OK")

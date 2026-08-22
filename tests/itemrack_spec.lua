-- ItemRack worn-item and menu buttons get the same 0.05 chrome as action
-- icons, plus a 4px Lorti Outer Edge. The minimap ItemRack icon stays on the
-- square map and does not get a second edge.
-- Run: lua tests/itemrack_spec.lua
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
  local frame = { points = {}, parent = parent, template = template }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
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
  function tex:SetAlpha(a) self.a = a end
  function tex:SetDrawLayer() end
  function tex:Hide() self.hidden = true end
  function tex:Show() self.hidden = false end
  return tex
end

local function fakeButton(name)
  local button = { name = name, NormalTexture = fakeTex() }
  local icon = fakeTex()
  function button:GetName() return name end
  function button:CreateTexture()
    local tex = fakeTex()
    button.chrome = tex
    return tex
  end
  function button:GetFrameLevel() return 4 end
  function button:SetFrameLevel() end
  _G[name] = button
  _G[name .. "Icon"] = icon
  return button, icon
end

assert(loadfile(root .. "skin/chrome.lua"))()
Addon:SkinItemRack()

local worn, wornIcon = fakeButton("ItemRackButton13")
local menu, menuIcon = fakeButton("ItemRackMenu1")
local minimap = fakeButton("LibDBIcon10_ItemRack")
_G.ItemRack = {
  CreateMenuButton = function() end,
}

assert(loadfile(root .. "skin/itemrack.lua"))()
Addon:SkinItemRack()

assert(worn.chrome.r == 0.05 and worn.chrome.g == 0.05 and worn.chrome.b == 0.05,
  "ItemRack chrome is Lorti darkest")
assert(worn.chrome.all == worn, "chrome fills the ItemRack button")
assert(wornIcon.all == nil, "ItemRack icon must not cover the chrome")
assert(wornIcon.points[1][1] == "TOPLEFT" and wornIcon.points[1][2] == 2,
  "ItemRack icon insets 2px")
assert(wornIcon.crop[1] == 0.07 and wornIcon.crop[3] == 0.07,
  "ItemRack icon crop matches action icons")
assert(worn.NormalTexture.hidden or worn.NormalTexture.a == 0,
  "ItemRack silver slot art stays hidden")
local outer = worn.shadowUIOuter
assert(outer, "ItemRack button keeps a Lorti Outer Edge")
assert(outer.backdrop.edgeFile:find("outer_shadow", 1, true),
  "Outer Edge uses the Lorti shadow texture")
assert(outer.points[1][4] == -4, "Outer Edge extends 4px")
assert(menu.shadowUIOuter, "ItemRack menu buttons keep a Lorti Outer Edge")
assert(menuIcon.points[1][2] == 2, "ItemRack menu icon insets 2px")
assert(not minimap.shadowUIOuter,
  "minimap ItemRack icon does not get a second Outer Edge")

local late = fakeButton("ItemRackMenu2")
_G.ItemRack.CreateMenuButton(2, "12345")
assert(late.shadowUIOuter, "late ItemRack menu buttons get Outer Edge")

print("itemrack_spec OK")

-- Bagnon inventory and bank get ShadowUI Darken, Outer Edge, search, sort,
-- and the Rainbow Organizer. Bag breaks stay off. Missing Bagnon is a no-op.
-- Run: lua tests/bagnon_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    local name, hook = object, method
    local orig = _G[name]
    if type(orig) ~= "function" then
      return
    end
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
_G.CreateFrame = function(_, name, parent, template)
  local frame = { name = name, points = {}, parent = parent, template = template, shown = true }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetAllPoints(host) self.all = host end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level or 4 end
  function frame:EnableMouse(on) self.mouse = on end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor(r, g, b, a)
    self.fill = { r, g, b, a }
  end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:SetVertexColor(r, g, b, a)
    self.vertex = { r, g, b, a }
  end
  function frame:SetColorTexture(r, g, b, a)
    self.color = { r, g, b, a }
  end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:GetParent() return self.parent end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:SetTexture(path) tex.path = path end
    function tex:SetBlendMode(mode) tex.blend = mode end
    function tex:SetPoint(...) tex.points[#tex.points + 1] = { ... } end
    function tex:SetAllPoints(host) tex.all = host end
    function tex:SetSize(w, h) tex.w, tex.h = w, h end
    function tex:SetVertexColor(r, g, b, a)
      tex.r, tex.g, tex.b, tex.a = r, g, b, a
    end
    function tex:Show() tex.shown = true end
    function tex:Hide() tex.shown = false end
    return tex
  end
  if name then
    _G[name] = frame
  end
  return frame
end
_G.UIParent = { name = "UIParent" }

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/rainbow.lua"))()
assert(loadfile(root .. "skin/bagnon.lua"))()

Addon:SkinBagnon()
assert(Addon._bagnonHook == nil, "missing Bagnon is a no-op")

local skins = {}
local itemGroupLayouts = 0
local itemBorders = 0
local profile = {
  skin = "Bagnon",
  bagBreak = 1,
  search = false,
  sort = false,
  color = { 1, 1, 1, 1 },
  borderColor = { 1, 1, 1, 1 },
  columns = 10,
  itemScale = 1,
  spacing = 2,
}
local inventory = {
  id = "inventory",
  profile = profile,
  [0] = true,
}
function inventory:GetProfile()
  return self.profile
end
function inventory:UpdateVisuals()
  self.visuals = (self.visuals or 0) + 1
end
function inventory:GetFrameLevel()
  return 4
end
local bank = {
  id = "bank",
  profile = {
    skin = "Bagnon",
    bagBreak = 1,
    search = true,
    sort = true,
    color = { 1, 1, 0, 1 },
    borderColor = { 1, 1, 0, 1 },
  },
  [0] = true,
}
function bank:GetProfile()
  return self.profile
end
function bank:UpdateVisuals()
  self.visuals = (self.visuals or 0) + 1
end
function bank:GetFrameLevel()
  return 4
end

_G.Bagnon = {
  Skins = {
    Registry = {},
    Register = function(self, skin)
      self.Registry[skin.id] = skin
      skins[#skins + 1] = skin
    end,
  },
  ItemGroup = {
    Layout = function(self)
      itemGroupLayouts = itemGroupLayouts + 1
      self.laidOut = true
    end,
    LayoutTraits = function()
      return 10, 1, 39, false
    end,
  },
  Item = {
    UpdateBorder = function()
      itemBorders = itemBorders + 1
    end,
  },
  Frames = {
    registry = { inventory, bank },
  },
}
function _G.Bagnon.Frames:Iterate()
  return ipairs(self.registry)
end
function _G.Bagnon.Frames:Show(id)
  return id == "bank" and bank or inventory
end

local group = {
  buttons = {
    {
      info = { itemID = 6948, quality = 1, classID = 15, subclassID = 4, name = "Hearthstone" },
      points = {},
    },
    {
      info = { itemID = 2770, quality = 1, classID = 7, subclassID = 7, name = "Copper Ore" },
      points = {},
    },
  },
  frame = inventory,
}
function group:GetProfile()
  return inventory.profile
end
function group:SetSize(width, height)
  self.width, self.height = width, height
end
local function bindButton(button)
  function button:SetPoint(...)
    self.points = { ... }
  end
  function button:SetScale(scale)
    self.scale = scale
  end
  function button:GetFrameLevel()
    return 4
  end
end
bindButton(group.buttons[1])
bindButton(group.buttons[2])

Addon:SkinBagnon()

local skin = _G.Bagnon.Skins.Registry.ShadowUI
assert(skin, "registers a ShadowUI Bagnon skin")
assert(skin.template == "BagnonOnePixelTemplate", "skin uses the one-pixel template")
assert(profile.skin == "ShadowUI", "inventory uses the ShadowUI skin")
assert(profile.bagBreak == 0, "bag breaks stay off so categories can group")
assert(profile.search == true, "search stays on")
assert(profile.sort == true, "sort stays on")
assert(profile.color[1] == 0.05 and profile.color[4] >= 0.9, "inventory fill is Darken black")
assert(bank.profile.skin == "ShadowUI", "bank uses the ShadowUI skin")
assert(bank.profile.bagBreak == 0, "bank has no bag breaks")
assert(inventory.shadowUIOuter, "inventory keeps an Outer Edge")
assert(bank.shadowUIOuter, "bank keeps an Outer Edge")
assert(inventory.shadowUIOuter.backdrop.edgeFile:find("outer_shadow", 1, true),
  "Bagnon Outer Edge uses the Lorti shadow")

_G.Bagnon.ItemGroup.Layout(group)
assert(group.buttons[1].info.itemID == 6948, "Hearthstone stays first after layout")
assert(group.buttons[2].points[5] < group.buttons[1].points[5] - 39,
  "Rainbow Organizer separates categories after Bagnon layout")
assert(group.buttons[1].shadowUIRainbow, "layout paints the category glow")

_G.Bagnon.Item.UpdateBorder(group.buttons[1])
assert(group.buttons[1].shadowUIRainbow.shown ~= false,
  "quality border updates keep the category glow")

local bg = {
  Center = _G.CreateFrame(nil, nil, inventory),
  TopEdge = _G.CreateFrame(),
  parent = inventory,
}
function bg:GetParent()
  return self.parent
end
skin.centerColor(bg, 0.05, 0.05, 0.05, 0.92)
assert(bg.Center.color[1] == 0.05, "skin center is Darken black")
skin.load(bg)
assert(inventory.shadowUIOuter, "skin load keeps Outer Edge on the panel")

print("bagnon_spec OK")

-- Meter Fill is a horizontal lighting overlay. The native StatusBar fill stays
-- solid; vertex colour on that fill must not wipe the overlay gradient.
-- Run: lua tests/statusbars_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local name = object
    local orig = _G[name]
    if type(orig) ~= "function" then
      return
    end
    _G[name] = function(...)
      orig(...)
      fn(...)
    end
    return
  end
  local orig = object[method]
  if type(orig) ~= "function" then
    return
  end
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
function Addon:ApplyStatusBarGradient(texture, orientation, from, to)
  if not texture then
    return
  end
  texture.orientation = orientation
  texture.from = from
  texture.to = to
end

local function near(a, b)
  return math.abs(a - b) < 0.02
end

local function fakeTex(path)
  local tex = { path = path }
  function tex:SetTexture(p)
    tex.path = p
  end
  function tex:SetAllPoints(rel)
    tex.anchor = rel
  end
  function tex:GetVertexColor()
    return tex.r, tex.g, tex.b, tex.a
  end
  function tex:SetVertexColor(r, g, b, a)
    tex.r, tex.g, tex.b, tex.a = r, g, b, a or 1
    tex.orientation, tex.from, tex.to = nil, nil, nil
  end
  return tex
end

local function fakeBar(name, r, g, b)
  local tex = fakeTex("Interface\\TargetingFrame\\UI-StatusBar")
  local bar = { name = name, r = r, g = g, b = b, a = 1, tex = tex, textures = {} }
  function bar:GetName()
    return name
  end
  function bar:GetStatusBarTexture()
    return tex
  end
  function bar:GetStatusBarColor()
    return bar.r, bar.g, bar.b, bar.a
  end
  function bar:SetStatusBarColor(nr, ng, nb, na)
    bar.r, bar.g, bar.b, bar.a = nr, ng, nb, na or 1
    tex:SetVertexColor(nr, ng, nb, na or 1)
  end
  function bar:SetStatusBarTexture(path)
    bar.texture = path
    tex.path = path
  end
  function bar:CreateTexture()
    local created = fakeTex(nil)
    bar.textures[#bar.textures + 1] = created
    return created
  end
  return bar
end

assert(loadfile(root .. "skin/statusbars.lua"))()

local fromG, toG = Addon:LightingGradient(0, 1, 0, 1)
assert(near(fromG[2], 0.22) and near(toG[2], 1), "green lighting is 22% to the live colour")
assert(fromG[2] < toG[2], "lighting climbs from dark to light")
local fromR, toR = Addon:LightingGradient(1, 0, 0, 1)
assert(near(fromR[1], 0.22) and near(toR[1], 1), "red lighting is 22% to the live colour")
local fromM, toM = Addon:LightingGradient(0, 0, 1, 1)
assert(near(fromM[3], 0.22) and near(toM[3], 1), "blue lighting is 22% to the live colour")

local health = fakeBar("PlayerFrameHealthBar", 0, 1, 0)
_G.PlayerFrame = { healthbar = health }
function _G.PlayerFrame:GetName()
  return "PlayerFrame"
end
_G.PlayerFrameHealthBar = health

local mana = fakeBar("PlayerFrameManaBar", 0, 0, 1)
_G.PlayerFrame.manabar = mana
_G.PlayerFrameManaBar = mana

local rage = fakeBar("TargetFrameManaBar", 1, 0, 0)
local targetHealth = fakeBar("TargetFrameHealthBar", 0, 1, 0)
local nameBg = fakeTex("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
nameBg.r, nameBg.g, nameBg.b, nameBg.a = 1, 0, 0, 1
_G.TargetFrame = {
  healthbar = targetHealth,
  manabar = rage,
  NameBackground = nameBg,
  textures = {},
}
function _G.TargetFrame:GetName()
  return "TargetFrame"
end
function _G.TargetFrame:CreateTexture()
  local created = fakeTex(nil)
  _G.TargetFrame.textures[#_G.TargetFrame.textures + 1] = created
  return created
end
function nameBg:GetParent()
  return _G.TargetFrame
end
_G.TargetFrameHealthBar = targetHealth
_G.TargetFrameManaBar = rage
_G.TargetFrameNameBackground = nameBg

local plateHealth = fakeBar("NamePlate1Health", 0.85, 0.2, 0.2)
local plate = { UnitFrame = { healthBar = plateHealth } }
_G.C_NamePlate = {
  GetNamePlateForUnit = function(unit)
    if unit == "nameplate1" then
      return plate
    end
  end,
  GetNamePlates = function()
    return { plate }
  end,
}

Addon:SkinStatusBarGradients()

assert(health.texture == nil, "native fill texture is not replaced")
assert(health.tex.path == "Interface\\TargetingFrame\\UI-StatusBar", "native fill art stays")
assert(health.shadowUIMeter, "health has a Meter Fill overlay")
assert(health.shadowUIMeter.anchor == health.tex, "overlay tracks the native fill")
assert(health.shadowUIMeter.orientation == "HORIZONTAL", "Meter Fill is horizontal like the Cast Bar")
assert(near(health.shadowUIMeter.from[2], 0.22) and near(health.shadowUIMeter.to[2], 1),
  "health overlay climbs from dark green to live green")
assert(mana.shadowUIMeter.from[3] < mana.shadowUIMeter.to[3], "mana overlay climbs from dark blue")
assert(rage.shadowUIMeter.from[1] < rage.shadowUIMeter.to[1], "rage overlay climbs from dark red")

local nameMeter = nameBg.shadowUIMeter
assert(nameMeter, "Name Background has a Meter Fill overlay")
assert(nameMeter.orientation == "HORIZONTAL", "Name Background overlay is horizontal")
assert(nameMeter.from[1] < nameMeter.to[1], "hostile Name Background climbs from dark red")

assert(plateHealth.shadowUIMeter.orientation == "HORIZONTAL", "nameplate health uses Meter Fill")
assert(plateHealth.shadowUIMeter.from[1] < plateHealth.shadowUIMeter.to[1],
  "nameplate health climbs from dark red")

health:SetStatusBarColor(1, 1, 0, 1)
assert(health.tex.from == nil, "native fill stays flattened by StatusBar colour")
assert(health.shadowUIMeter.from[1] > 0.1 and health.shadowUIMeter.from[2] > 0.1,
  "overlay keeps lighting after StatusBar colour")
assert(health.shadowUIMeter.from[1] < health.shadowUIMeter.to[1],
  "yellow energy overlay climbs from dark to light")

nameBg:SetVertexColor(0, 0, 1, 1)
assert(nameBg.shadowUIMeter.from[3] < nameBg.shadowUIMeter.to[3],
  "friendly Name Background overlay climbs from dark blue")

Addon:OnNamePlateUnitAdded("NAME_PLATE_UNIT_ADDED", "nameplate1")
assert(plateHealth.shadowUIMeter.orientation == "HORIZONTAL", "a new nameplate still gets Meter Fill")

print("statusbars_spec OK")

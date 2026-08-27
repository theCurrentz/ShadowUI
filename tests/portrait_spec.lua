-- Circular Target Frame portraits get a subtle class-coloured ring.
-- Run: lua tests/portrait_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = { DARKEN_BLACK = { 0.05, 0.05, 0.05 } }
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function() end
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

local function makePortrait(id, size)
  local tex = { id = id, w = size, h = size, r = 0.5, g = 0.5, b = 0.5, a = 0.4 }
  function tex:GetWidth() return tex.w end
  function tex:GetHeight() return tex.h end
  function tex:SetVertexColor(r, g, b, a)
    tex.r, tex.g, tex.b, tex.a = r, g, b, a
  end
  function tex:SetDesaturated(on)
    tex.desaturated = on and true or false
  end
  function tex:SetAlpha(a)
    tex.alpha = a
  end
  return tex
end

local function makeUnitFrame(name, portrait)
  local frame = { textures = {}, portrait = portrait }
  function frame:GetName() return name end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:SetTexture(path) tex.path = path end
    function tex:SetVertexColor(r, g, b, a)
      tex.r, tex.g, tex.b, tex.a = r, g, b, a
    end
    function tex:SetSize(w, h) tex.w, tex.h = w, h end
    function tex:SetPoint(...)
      tex.points[#tex.points + 1] = { ... }
      tex.point = { ... }
    end
    function tex:ClearAllPoints() tex.points = {} tex.point = nil end
    function tex:SetDrawLayer(layer, sub)
      tex.layer = layer
      tex.sub = sub
    end
    function tex:Show() tex.shown = true end
    function tex:Hide() tex.shown = false end
    tex.shown = true
    frame.textures[#frame.textures + 1] = tex
    return tex
  end
  return frame
end

assert(loadfile(root .. "skin/portrait.lua"))()

local wr, wg, wb = Addon:PortraitClassColor("WARRIOR")
assert(near(wr, 0.78) and near(wg, 0.61) and near(wb, 0.43), "warrior ring is brown")
local mr, mg, mb = Addon:PortraitClassColor("MAGE")
assert(near(mr, 0.41) and near(mg, 0.80) and near(mb, 0.94), "mage ring is blue")
local rr, rg, rb = Addon:PortraitClassColor("ROGUE")
assert(near(rr, 1.00) and near(rg, 0.96) and near(rb, 0.41), "rogue ring is yellow")
assert(Addon:PortraitClassColor(nil) == nil, "missing class has no ring colour")
assert(Addon:PortraitClassColor("NPC") == nil, "unknown class has no ring colour")

local fromW, toW = Addon:PortraitRingGradient(wr, wg, wb)
assert(fromW[1] < toW[1], "ring gradient climbs from dark to light")
assert(fromW[4] < toW[4], "ring gradient stays more transparent on the dark end")
assert(toW[4] < 0.7, "ring stays unobtrusive")
assert(fromW[4] > 0.1, "dark end stays visible")

_G.RAID_CLASS_COLORS = { MAGE = { r = 0.10, g = 0.20, b = 0.30 } }
local liveR, liveG, liveB = Addon:PortraitClassColor("MAGE")
assert(near(liveR, 0.10) and near(liveG, 0.20) and near(liveB, 0.30),
  "live RAID_CLASS_COLORS win when present")
_G.RAID_CLASS_COLORS = nil

local portrait = makePortrait("portrait", 64)
_G.TargetFrame = makeUnitFrame("TargetFrame", portrait)
_G.FocusFrame = makeUnitFrame("FocusFrame", makePortrait("focus-port", 64))
_G.PlayerFrame = makeUnitFrame("PlayerFrame", makePortrait("player-port", 64))
_G.UnitClass = function(unit)
  if unit == "target" then
    return "Warrior", "WARRIOR"
  end
  if unit == "focus" then
    return "Mage", "MAGE"
  end
end
_G.UnitIsPlayer = function(unit)
  return unit == "target" or unit == "focus"
end

Addon:SkinPortraitRings()
local ring = _G.TargetFrame.shadowUIPortraitRing
assert(ring, "target paints a portrait ring")
assert(ring.shown == true, "player target shows the ring")
assert(ring.path == "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
  "ring uses the portrait circle")
assert(ring.layer == "BACKGROUND" and ring.sub == -1,
  "ring sits behind the portrait so only the rim shows")
assert(ring.w == 66 and ring.h == 66, "ring stays flush with the portrait chrome")
assert(ring.point[1] == "CENTER" and ring.point[2] == portrait,
  "ring centres on the circular portrait")
assert(ring.orientation == "VERTICAL", "ring uses a vertical lighting gradient")
local from72, to72 = Addon:PortraitRingGradient(wr, wg, wb)
assert(near(ring.from[1], from72[1]) and near(ring.to[1], to72[1]),
  "warrior ring uses the brown gradient")
assert(_G.PlayerFrame.shadowUIPortraitRing == nil, "Player Frame keeps a native portrait")

local focusRing = _G.FocusFrame.shadowUIPortraitRing
assert(focusRing.shown == true, "focus paints a portrait ring")
local fromM, toM = Addon:PortraitRingGradient(mr, mg, mb)
assert(near(focusRing.from[1], fromM[1]) and near(focusRing.to[1], toM[1]),
  "mage focus ring uses the blue gradient")

_G.UnitClass = function() end
_G.UnitIsPlayer = function() return false end
Addon:SkinPortraitRings()
assert(_G.TargetFrame.shadowUIPortraitRing.shown == false, "NPC target hides the ring")
assert(_G.FocusFrame.shadowUIPortraitRing.shown == false, "NPC focus hides the ring")
assert(portrait.r == 1 and portrait.g == 1 and portrait.b == 1 and portrait.a == 1,
  "NPC portrait keeps full original colour")
assert(portrait.desaturated == false, "NPC portrait is not grayed")
assert(portrait.alpha == 1, "NPC portrait is not washed out")

_G.UnitClass = function()
  return "Warrior", "WARRIOR"
end
_G.UnitIsPlayer = function() return false end
Addon:SkinPortraitRings()
assert(_G.TargetFrame.shadowUIPortraitRing.shown == false,
  "non-player target has no class ring even when UnitClass returns a class")

local modern = makePortrait("modern", 64)
_G.TargetFrame.portrait = nil
_G.TargetFrame.TargetFrameContainer = { Portrait = modern }
_G.TargetFrame.shadowUIPortraitRing = nil
_G.UnitClass = function(unit)
  if unit == "target" then
    return "Rogue", "ROGUE"
  end
end
_G.UnitIsPlayer = function(unit)
  return unit == "target"
end
Addon:SkinPortraitRings()
local rogueRing = _G.TargetFrame.shadowUIPortraitRing
assert(rogueRing.point[2] == modern, "ring uses the container portrait when it exists")
local fromR, toR = Addon:PortraitRingGradient(rr, rg, rb)
assert(near(rogueRing.from[1], fromR[1]) and near(rogueRing.to[1], toR[1]),
  "rogue ring uses the yellow gradient")

print("portrait_spec OK")

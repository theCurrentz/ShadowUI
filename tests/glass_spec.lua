local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "cast/castbar.lua"))()
assert(loadfile(root .. "skin/glass.lua"))()

local function fakeTexture()
  local tex = { points = {}, shown = true }
  function tex:SetColorTexture(r, g, b, a) self.color = { r, g, b, a } end
  function tex:SetBlendMode(mode) self.blend = mode end
  function tex:SetGradient(...) self.gradient = { ... } end
  function tex:SetVertexColor(...) self.vertex = { ... } end
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetAllPoints() self.all = true end
  function tex:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function tex:SetHeight(h) self.height = h end
  function tex:SetWidth(w) self.width = w end
  function tex:Show() self.shown = true end
  function tex:Hide() self.shown = false end
  return tex
end

local function fakeFrame()
  local frame = { created = {} }
  function frame:CreateTexture(_, layer, _, sub)
    local tex = fakeTexture()
    tex.layer, tex.sub = layer, sub
    self.created[#self.created + 1] = tex
    return tex
  end
  function frame:SetBackdropColor(...) self.backdrop = { ... } end
  return frame
end

_G.CreateColor = function(r, g, b, a) return { r = r, g = g, b = b, a = a } end

local char = { theme = nil }
function Addon:GetCharDB() return char end
function Addon:Print() end
function Addon:ApplySkins() self.skinned = true end

assert(Addon:GetTheme() == "matte", "missing theme is matte")
char.theme = "glass"
assert(Addon:GetTheme() == "glass", "glass theme is stored per character")
assert(Addon:SetTheme("neon") == false, "unknown theme rejected")
assert(Addon:SetTheme("matte") == true and char.theme == "matte", "matte stores")
assert(Addon.skinned == true, "theme change reapplies skins")

char.theme = "glass"
local frame = fakeFrame()
Addon:ApplyGlassPanel(frame)
assert(frame.backdrop[4] == 0, "opaque backdrop is cleared")
assert(frame.glassFill and frame.glassFill.all, "fill covers the frame")
assert(frame.glassFill.color[4] < 1, "fill is translucent")
assert(frame.glassSheen.blend == "ADD", "sheen uses additive blend")
assert(frame.glassSheen.height == 7, "sheen is a thin top band")
assert(frame.glassSheen.gradient, "sheen uses the gradient path")
assert(frame.glassRimT.height == 1 and frame.glassRimL.width == 1, "rims are 1px")
assert(frame.glassRimT.color[4] > frame.glassRimB.color[4], "top rim is brighter")

Addon:ClearGlassPanel(frame)
assert(frame.glassFill.shown == false, "clear hides fill")
assert(frame.glassSheen.shown == false, "clear hides sheen")

Addon:ApplyGlassPanel(nil)
Addon:ClearGlassPanel(nil)
local empty = {}
Addon:ApplyGlassPanel(empty)
assert(empty.glassFill == nil, "frames without CreateTexture are skipped")

print("glass_spec OK")
